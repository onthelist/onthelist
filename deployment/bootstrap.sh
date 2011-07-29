#!/bin/sh
# SpeedyTable bootstrap
# Installs all requirements for a SpeedyTable server

# The script will fail without GitHub having the user's SSH key. You'll need root's SSH key if running as such.
while true; do
    read -p "Did you copy this machine's SSH key to GitHub? (y/n) " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "y or n";;
    esac
done

# Add www group and daemon users.
groupadd www
useradd -m www-server --home /home/www-server --shell /dev/null --group www
#...add users as necessary

# Update system.
apt-get -yy update
apt-get -yy upgrade

# Install some useful stuff.
apt-get -yy install wget screen zip unzip vim git build-essential

#  Clone repo.
cd /home/www-server
git clone git@github.com:onthelist/onthelist.git
# Temporary fix, remove when merged with master.
git checkout deployment

# Fix file permissions now that everything is in place.
chown -R www-server:www /home/www-server/

# Install Chef dependencies. Use Ruby 1.8 or Compass and Jade may cause problems.
apt-get -yy install ruby1.8 ruby1.8-dev libopenssl-ruby irb ssl-cert

# Install RubyGems from source or Ubuntu will disable updates and cause random issues.
cd /tmp
wget http://production.cf.rubygems.org/rubygems/rubygems-1.3.7.tgz
tar zxf rubygems-1.3.7.tgz 
cd rubygems-1.3.7 
ruby setup.rb --no-format-executable

# Install Chef: This takes a few minutes.
gem install chef --no-ri --no-rdoc

# Chef-solo needs a configuration file for path variables so we'll make a symlink to our repo.
# !!! Danger Will Robinson! This link will be invalid if you don't checkout deployment.
mkdir /etc/chef
ln -s /home/www-server/onthelist/deployment/chef/solo.rb /etc/chef/solo.rb

# We can let Chef-solo take over now. node.json lists all recipes Chef should install.
chef-solo -j /home/www-server/onthelist/deployment/chef/node.json
