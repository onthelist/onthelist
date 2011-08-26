#
# Cookbook Name:: compass
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
script "jade-install" do
  interpreter "bash"
  user "root"
  cwd "/home/www-server/onthelist"
  code <<-EOH
  gem install compass --no-ri --no-rdoc
  EOH
end
