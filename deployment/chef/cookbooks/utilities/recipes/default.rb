#
# Cookbook Name:: utilities
# Recipe:: default
#
# Copyright 2011, SpeedySeat
#
# All rights reserved - Do Not Redistribute
#

script "winston-deps-install" do
  interpreter "bash"
  user "root"
  cwd "/home/www-server/onthelist/utils/lib/winston"
  code <<-EOH
    npm install
  EOH
end
