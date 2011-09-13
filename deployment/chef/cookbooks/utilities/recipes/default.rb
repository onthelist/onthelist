#
# Cookbook Name:: utilities
# Recipe:: default
#
# Copyright 2011, SpeedySeat
#
# All rights reserved - Do Not Redistribute
#

script "notifier-deps-install" do
  interpreter "bash"
  user "root"
  cwd "/home/www-server/onthelist/utils"
  code <<-EOH
    npm install -d -g
    EOH
end
