# Cookbook Name:: download_war
# Recipe:: download_proc
# Download Process
# Copyright (c) 2016 The Authors, All Rights Reserved.

#
# Variables
#
version = false
war_url = if $node_name.start_with? 'B'
            node["war"]["url_bbi"]
          elsif $node_name.start_with? 'P'
            node["war"]["url_panama"]
          else
            node["war"]["url"]
          end

#
# Main Process
#
log 'Folder C:\chef\New_War created.' do
  action :nothing
end

ruby_block 'Send Email war' do
  block do
    message = "Successful download, Eva.war v#{war_url[/\d+(.)\d+(.)\d+/]} was downloaded from #{war_url} !"
    Chef::Log.info(message)
    Tools.simple_email node["mail"]["to"], :message => message, :subject => "Chef Download on Node #{$node_name}"
  end
  action :nothing
end

directory 'C:\chef\New_War' do
  notifies :write, 'log[Folder C:\chef\New_War created.]', :immediately
  not_if { File.directory?('C:\chef\New_War') }
end

ruby_block 'Verify version of Eva.war' do
  block do
    version = Eva.is_current_version?(war_url)
    if version
      Chef::Log.info('The new war has the same version than the current.')
      Chef::Log.info('Download canceled.')
    end
  end
end

remote_file 'C:\chef\New_War\Eva.war' do
  source war_url
  notifies :run, 'ruby_block[Send Email war]', :immediately
  only_if { File.directory?('C:\chef\New_War') && !version && !$node_name.eql?("B124") }
end
