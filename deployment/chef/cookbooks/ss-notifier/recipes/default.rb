#
# Cookbook Name:: ss-notifier
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
script "notifier-deps-install" do
  interpreter "bash"
  user "root"
  cwd "/home/www-server/onthelist/notify"
  code <<-EOH
  npm install -d
  EOH
end

template "/etc/init/ss-notifier.conf" do
  source "ss-notifier.conf.erb"
end

service "ss-notifier" do
  provider Chef::Provider::Service::Upstart
  action :start
end