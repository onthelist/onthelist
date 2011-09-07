#
# Cookbook Name:: jade
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
# Node package manager has occasional issues with their HTTPS certificate, try "npm --force --registry http://registry.npmjs.org/ install *" if you're having trouble.

include_recipe "node"

node_npm "jade@0.14.2" do
  action :install
end

bash "insert-node-path" do
  user "root"
  cwd "/home/www-server"
  code <<-EOH
  echo "NODE_PATH=$NODE_PATH:/usr/local/lib/node_modules/jade/lib" >> /etc/environment
  . /etc/environment
  EOH
  not_if "grep '/usr/local/lib/node_modules/jade/lib' /etc/environment"
end

