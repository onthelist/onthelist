#
# Author:: Joe Williams (<j@boundary.com>)
# Cookbook Name:: jenkins
# Recipe:: default
#
# Copyright 2011, Boundary
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

execute "apt-get update for jenkins" do
  command "apt-get update"
  action :nothing
end

execute "add jenkins apt key" do
  command "apt-key add /tmp/jenkins-ci.org.key"
  action :nothing
  notifies :run, resources("execute[apt-get update for jenkins]"), :immediately
end

remote_file "/tmp/jenkins-ci.org.key" do
  source "http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key"
  not_if "apt-key list | grep '1024D/D50582E6'"
  notifies :run, resources("execute[add jenkins apt key]"), :immediately
end

script "insert-jenkins-repo" do
  interpreter "bash"
  user "root"
  cwd "/home/www-server/onthelist"
  code <<-EOH
  echo "deb http://pkg.jenkins-ci.org/debian binary/" >> /etc/apt/sources.list
  apt-get -yy update
  EOH
  not_if "cat /etc/apt/sources.list | grep 'deb http://pkg.jenkins-ci.org/debian binary/'"
end

package "jenkins"

link "/home/jenkins" do
  to "/var/lib/jenkins"
end

service "jenkins" do
  supports :status => true, :restart => true
  action [ :start, :enable ]
end

script "download-jenkins-cli" do
  interpreter "bash"
  user "root"
  cwd "/var/run/jenkins/war/WEB-INF"
  code <<-EOH
  wget localhost:8080/jnlpJars/jenkins-cli.jar
  EOH
end

jenkins "github" do
  action :install_plugin
  cli_jar "/var/run/jenkins/war/WEB-INF/jenkins-cli.jar"
  url "http://localhost:8080"
  path "/var/lib/jenkins"
end

jenkins "github-oauth" do
  action :install_plugin
  cli_jar "/var/run/jenkins/war/WEB-INF/jenkins-cli.jar"
  url "http://localhost:8080"
  path "/var/lib/jenkins"
end

jenkins "reload config" do
  action :reload_configuration
  cli_jar "/var/run/jenkins/war/WEB-INF/jenkins-cli.jar"
  url "http://localhost:8080"
  path "/var/lib/jenkins"
end

service "jenkins" do
  supports :status => true, :restart => true
  action :restart
end
