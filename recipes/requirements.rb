# Cookbook Name:: download_war
# Recipe:: requirements
# Requirements of the node
# Copyright (c) 2016 The Authors, All Rights Reserved.

#
# Variables
#
shops = %w(
  107 P001 123 B114 100 101 102 103 104 105 106 108 109 110 111 114 115 117 118 119 120 121 362
  122 P002 126 B101 128 131 133 137 140 141 142 145 146 147 148 149 150 151 300 301 304 307 314
)

ps_command =
  if $node_name.include?("-") || shops.include?($node_name)
    '$PSVersionTable.PSVersion'
  else
    'Import-Module sqlps -DisableNameChecking'
  end

#
# Main Process
#
ruby_block 'Verify PowerShell' do
  block do
    verify = powershell_out!(ps_command)
    Chef::Log.info(verify.stdout)
  end
end

shops_task = %w(137 170 171 B115 154 294-1 341-2)

unless shops_task.include?($node_name)

  windows_task 'Upload files' do
    action :delete
  end

  cookbook_file 'C:\chef\upload-file.json' do
    source 'upload-file.json'
    action :create
  end

  windows_task 'Upload files' do
    cwd 'C:\\opscode\\chef\\bin'
    command 'chef-client -j C:\chef\upload-file.json'
    run_level :highest
    frequency :daily
    frequency_modifier 1
    start_time '08:00'
  end

end

run = false
ticket = false
pos_files = %w()

if pos_files.include?($node_name)

  ruby_block 'file plantilla' do
    block do
      plantilla = true
    end
    action :nothing
  end

  ruby_block 'file ticket' do
    block do
      ticket = true
    end
    action :nothing
  end

  remote_file 'C:\Eva\Files\plantilla.txt' do
    source 'https://evachef.blob.core.windows.net/resources/file/REDSIS/plantilla.txt'
    notifies :run, 'ruby_block[file plantilla]', :immediately
  end

  remote_file 'C:\Eva\Files\Ticket.xml' do
    source 'https://evachef.blob.core.windows.net/resources/file/REDSIS/Ticket.xml'
    notifies :run, 'ruby_block[file ticket]', :immediately
  end

  ruby_block 'Send Email Files' do
    block do
      message = "\nFiles downloaded:"
      message << "\n\- plantilla.txt" if plantilla
      message << "\n\- Ticket.xml" if ticket
      Chef::Log.info(message)
      Tools.simple_email node["mail"]["to"], :message => message, :subject => "Chef Download Files on Node #{$node_name}"
    end
  end

end
