# Cookbook Name:: download_war
# Recipe:: download_pdt
# Download Files to update PDT's applications
# Copyright (c) 2016 The Authors, All Rights Reserved.

#
# Variables
#
readme, db = false, false

#
# Main Process
#
ruby_block 'Send Email PDT' do
  block do
    message = "\nFiles downloaded:"
    message << "\n\- AppPDTInventario.CAB"
    message << "\n\- PDTInventarios.db" if db
    message << "\n\- Leeme.txt" if readme
    Chef::Log.info(message)
  end
  action :nothing
end

ruby_block 'db downloaded' do
  block do
    db = true
  end
  action :nothing
end

ruby_block 'readme downloaded' do
  block do
    readme = true
  end
  action :nothing
end

log 'File AppPDTInventario.CAB downloaded.' do
  action :nothing
  notifies :run, 'ruby_block[Send Email PDT]', :immediately
end

log 'File PDTInventarios.db downloaded.' do
  action :nothing
  notifies :run, 'ruby_block[db downloaded]', :immediately
end

log 'File Leeme.txt downloaded.' do
  action :nothing
  notifies :run, 'ruby_block[readme downloaded]', :immediately
end

directory 'C:\PDT' do
  not_if { File.directory?('C:\PDT') }
end

directory 'C:\PDT\InstallerPDT' do
  not_if { File.directory?('C:\PDT\InstallerPDT') }
end

remote_file 'C:\PDT\InstallerPDT\Leeme.txt' do
  source node[:pdt][:readme]
  notifies :write, 'log[File Leeme.txt downloaded.]', :immediately
end

remote_file 'C:\PDT\InstallerPDT\PDTInventarios.db' do
  source node[:pdt][:db]
  notifies :write, 'log[File PDTInventarios.db downloaded.]', :immediately
end

remote_file 'C:\PDT\InstallerPDT\AppPDTInventario.CAB' do
  source node[:pdt][:app]
  notifies :write, 'log[File AppPDTInventario.CAB downloaded.]', :immediately
end
