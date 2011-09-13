#
# Cookbook Name:: redis
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package "redis-server"

node_npm "redis" do
  action :install
end