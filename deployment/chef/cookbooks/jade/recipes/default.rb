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

node_npm "jade" do
  action :install
end

script "insert-node-path" do
  interpreter "bash"
  user "root"
  cwd "/home/www-server/onthelist"
  code <<-EOH
  echo "NODE_PATH=/usr/local/lib/node_modules/jade/lib" >> /etc/environment
  . /etc/environment
  EOH
  not_if "cat /etc/environment | grep 'NODE_PATH=/usr/local/lib/node_modules/jade/lib'"
end
