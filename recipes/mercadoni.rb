# Cookbook Name:: download_war
# Recipe:: mercadoni
# Update Keyboard to identify client mercadoni
# Copyright (c) 2016 The Authors, All Rights Reserved.

#
# Variables
#
file = node["mercadoni"]["file"]
delimiter = node["mercadoni"]["delimiter"]
update = [false, false]

#
# Main Process
#
ruby_block 'Send Email Mercadoni' do
  block do
    message = update.first && update.last ? 'Enable mercadoni key.' : 'Disable mercadoni key.'
    Chef::Log.info(message)
    Tools.simple_email node["mail"]["to"], :message => message, :subject => "Chef Update Mercadoni Key on Node #{$node_name}"
  end
  action :nothing
end

template 'Enable mercadoni key' do
  path 'C:\Eva\Files\TecladoPOS_w.xml'
  source 'ETecladoPOS_w.erb'
  action :nothing
  only_if { update.first && update.last }
  notifies :run, 'ruby_block[Send Email Mercadoni]', :immediately
end

template 'Disable mercadoni key' do
  path 'C:\Eva\Files\TecladoPOS_w.xml'
  source 'DTecladoPOS_w.erb'
  action :nothing
  only_if { update.first && !update.last }
  notifies :run, 'ruby_block[Send Email mercadoni]', :immediately
end

ruby_block 'Keyboard need to be updated ?' do
  block do
    update = Eva.update_keyboard? file, delimiter, $node_name
  end
  action :nothing
  notifies :create, 'template[Enable mercadoni key]', :immediately
  notifies :create, 'template[Disable mercadoni key]', :immediately
end

remote_file 'C:\chef\mercadoni.txt' do
  source node[:mercadoni][:url]
  notifies :run, 'ruby_block[Keyboard need to be updated ?]', :immediately
end
