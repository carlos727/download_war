# Cookbook Name:: download_war
# Recipe:: default
# Cookbook to download Eva.war
# Copyright (c) 2016 The Authors, All Rights Reserved.

#
# Variables
#
$node_name = Chef.run_context.node.name.to_s

#
# Main Process
#
unless $node_name.include? '-'

  include_recipe 'download_war::download_proc'
  include_recipe 'download_war::download_pdt' unless $node_name.start_with? 'B'

end

if $node_name.include?('-') && !$node_name.start_with?('B')

  #include_recipe 'download_war::download_img'
  #include_recipe 'download_war::mercadoni'
  include_recipe 'edit_file'

end

include_recipe 'download_war::requirements'
