#
# Cookbook Name:: compass
# Recipe:: default
#
# Copyright 2011, SpeedySeat
#
# All rights reserved - Do Not Redistribute
#

package "compass" do
  Chef::Provider::Package::Rubygems
  options "--no-ri --no-rdoc"
end
