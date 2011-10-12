#
# Cookbook Name:: nginx
# Recipe:: default
# Author:: AJ Christensen <aj@junglist.gen.nz>
#
# Copyright 2008-2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package "nginx"

package "python-setuptools" do
  action :install
end

# easy_install_package is broken
execute "install_boto" do
  command "/usr/bin/easy_install \"boto>=2.0\""
end

execute "get_instances" do
  command "/usr/bin/python /home/www-server/onthelist/deployment/boto/get_launched_instances.py"
  creates "/home/www-server/init/dns_names"
end

ruby_block "load_dns_names" do
  block do
    servers = []

    File.open('/home/www-server/init/dns_names', 'r') do |infile|
      while (line = infile.gets)
        line = line.strip
        if line
          servers << line
        end
      end
    end

    node.set['servers'] = servers
  end
end

directory node[:nginx][:log_dir] do
  mode 0755
  owner node[:nginx][:user]
  action :create
end

%w{nxensite nxdissite}.each do |nxscript|
  template "/usr/sbin/#{nxscript}" do
    source "#{nxscript}.erb"
    mode 0755
    owner "root"
    group "root"
  end
end

template "nginx.conf" do
  path "#{node[:nginx][:dir]}/nginx.conf"
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

template "#{node[:nginx][:dir]}/sites-available/default" do
  source "default-site.erb"
  owner "root"
  group "root"
  mode 0644
end

template "#{node[:nginx][:dir]}/upstream.conf" do
  source "upstream.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

service "nginx" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end
