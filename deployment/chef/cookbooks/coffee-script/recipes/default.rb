#
# Cookbook Name:: coffee-script
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
# Node package manager has occasional issues with their HTTPS certificate, try "npm --force --registry http://registry.npmjs.org/ install *" if you're having trouble.
script "jade-install" do
  interpreter "bash"
  user "root"
  cwd "/home/www-server/onthelist"
  code <<-EOH
  npm install -g coffee-script
  EOH
end
