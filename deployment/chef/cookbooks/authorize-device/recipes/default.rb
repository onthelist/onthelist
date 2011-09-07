#
# Cookbook Name:: authorize-device
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
script "authorize-deps-install" do
  interpreter "bash"
  user "root"
  cwd "/home/www-server/onthelist/auth/device"
  code <<-EOH
  npm install -d
  EOH
end

template "/etc/init/authorize-device.conf" do
  source "authorize-device.conf.erb"
end

service "authorize-device" do
  provider Chef::Provider::Service::Upstart
  action [ :start, :enable ]
end
