#!/bin/bash
# SpeedyTable bootstrap
# Installs all requirements for a SpeedyTable server

# The script will fail without GitHub having the onthelist/keys SSH key in root's .ssh directory.
while true; do
    read -p "Does this server have the Github SSH key copied to root's SSH directory?  (y/n) " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "y or n";;
    esac
done

# Get rid of annoying welcome text
rm /etc/update-motd.d/51_update-motd

# Add www group and daemon users.
groupadd www
useradd -m www-server --home /home/www-server --shell /dev/null --group www

# Enable the multiverse. Used for Chef java cookbook.
# The OpenJDK alternative has issues with jenkins.
sed -i -e "s/# deb/deb/g" /etc/apt/sources.list

# Add Jenkins package key and entry to sources.list
wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
echo "deb http://pkg.jenkins-ci.org/debian binary/" >> /etc/apt/sources.list

apt-get -yy update
apt-get -yy upgrade

# Install some useful stuff.
apt-get -yy install wget screen zip unzip vim htop git build-essential

#  Clone repo.
cd /home/www-server
git clone git@github.com:onthelist/onthelist.git
# Temporary fix, remove when merged with master.
cd /home/www-server/onthelist
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

# We can let Chef-solo take over now. node.json lists all recipes Chef should install.
chef-solo -j /home/www-server/onthelist/deployment/chef/node.json -c /home/www-server/onthelist/deployment/chef/solo.rb

# Now that Chef is done, install any unchefable software
# Try "npm --force --registry http://registry.npmjs.org/ install *" if you're having trouble.
npm --force --registry http://registry.npmjs.org/ install -g coffee-script
npm --force --registry http://registry.npmjs.org/ install -g jade

gem update --system
gem install compass --no-ri --no-rdoc

# Set Node path for jade compiler. This will not take effect until logout. We can take effect for the current sesssion with bash's source command.
echo "NODE_PATH=/usr/local/lib/node_modules/jade/lib" >> /etc/environment
. /etc/environment

# Jenkins time
apt-get -yy update
apt-get -yy install jenkins
#cp 
