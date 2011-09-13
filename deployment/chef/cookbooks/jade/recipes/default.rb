#
# Cookbook Name:: jade
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
# Node package manager has occasional issues with their HTTPS certificate, try "npm --force --registry http://registry.npmjs.org/ install *" if you're having trouble.

node_npm "jade@0.14.2" do
  action :install
end
