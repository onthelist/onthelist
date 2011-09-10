#
# Cookbook Name:: redis
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package "redis-server"

bash "insert-node-path" do
  user "root"
  cwd "/home/www-server"
  code <<-EOH
    echo "NODE_PATH=$NODE_PATH:/usr/local/lib/node_modules" >> /etc/environment
      . /etc/environment
      EOH
end