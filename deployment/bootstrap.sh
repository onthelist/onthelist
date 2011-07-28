#!/bin/sh
# SpeedyTable bootstrap
# Installs all requirements for a SpeedyTable server

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
apt-get -yy install wget screen zip unzip vim git

#  Clone repo.
cd /home/www-server
git clone git@github.com:onthelist/onthelist.git

# Fix file permissions now that everything is in place.
chown -R www-server:www /home/www-server/

# Install Chef dependencies. Use Ruby 1.8 or Compass and Jade may cause problems.
apt-get -yy install ruby1.8 ruby1.8-dev libopenssl-ruby rdoc ri irb build-essential wget ssl-cert

# Install RubyGems from source or Ubuntu will disable updates and cause random issues.
cd /tmp
wget http://production.cf.rubygems.org/rubygems/rubygems-1.3.7.tgz
tar zxf rubygems-1.3.7.tgz 
cd rubygems-1.3.7 
ruby setup.rb --no-format-executable

# Install Chef: This takes a few minutes.
gem install chef

# Chef-solo needs a configuration file for path variables so we'll make a symlink to our repo.
ln -s /home/www-server/onthelist/deployment/chef/solo.rb /etc/chef/solo.rb

# We can let Chef-solo take over now. node.json lists all recipes Chef should install.
chef-solo -j /home/www-server/onthelist/deployment/chef/node.json
