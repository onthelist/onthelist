#!/bin/bash
# SpeedySeat bootstrap
# Installs server components for a SpeedySeat server
#!!! This bootstrap file expects a SpeedySeat base server AMI.
#!!! Not using the proper AMI will result in failure. Use newServerBootstrap.sh for a clean image. 

# Add www group and daemon users. Add to as needed.
groupadd www
useradd -m www-server --home /home/www-server --shell /dev/null -g www

apt-get -yy update
apt-get -yy upgrade

#  Clone repo.
cd /home/www-server
git clone git@github.com:onthelist/onthelist.git
cd /home/www-server/onthelist
# Temporary fix, remove when merged with master.
git checkout development

# Install Chef dependencies. Use Ruby 1.8 or Compass and Jade may cause problems.
apt-get -yy install ruby1.8 ruby1.8-dev libopenssl-ruby irb ssl-cert

# Install RubyGems from source or Ubuntu will disable updates and cause random issues.
cd /tmp
wget http://production.cf.rubygems.org/rubygems/rubygems-1.8.7.tgz
cd rubygems-1.8.7
tar zxf rubygems-1.8.7.tgz 
ruby setup.rb --no-format-executable

gem update --system

# Install Chef: This takes a few minutes.
gem install chef --no-ri --no-rdoc

# We can let Chef-solo take over now. node.json lists all recipes Chef should install.
cd /home/www-server/onthelist/
./tools/startChefSolo.sh

# Fix file permissions now that everything is in place.
chown -R www-server:www /home/www-server/
