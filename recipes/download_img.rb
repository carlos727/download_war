# Cookbook Name:: download_war
# Recipe:: download_img
# Reload advertising images
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Ensure C:\Eva folder exits
directory 'C:\Eva' do
  not_if { File.directory?('C:\Eva') }
end

# Ensure C:\Eva\Imagenes folder exits
directory 'C:\Eva\Imagenes' do
  not_if { File.directory?('C:\Eva\Imagenes') }
end

# Delete C:\Eva\Imagenes\Publicidad folder
directory 'C:\Eva\Imagenes\Publicidad' do
  recursive true
  action :delete
  only_if { File.directory?('C:\Eva\Imagenes\Publicidad') }
end

# Unzip remote file
windows_zipfile 'C:\Eva\Imagenes' do
  source node[:advertising][:url]
  action :unzip
end
