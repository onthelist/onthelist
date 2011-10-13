#
# Cookbook Name:: ss-notifier
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
script "sync-install" do
  interpreter "bash"
  user "root"
  cwd "/home/www-server/onthelist/sync"
  code <<-EOH
  npm install
  EOH
end

template "/etc/init/ss-sync.conf" do
  source "ss-sync.conf.erb"
end

service "ss-sync" do
  provider Chef::Provider::Service::Upstart
  action [ :start, :enable ]
end
