#!/bin/bash
# SpeedyTable bootstrap: installs all requirements for a SpeedyTable server
# Must run as root.
# Used for clean server creation
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

# Add www group and daemon users. Add to as needed.
groupadd www
useradd -m www-server --home /home/www-server --shell /dev/null -g www

# Enable the multiverse. Used for Chef java cookbook.
# The OpenJDK alternative has issues with jenkins.
sed -i -e "s/# deb/deb/g" /etc/apt/sources.list

# Install some useful stuff.
apt-get -yy update
apt-get -yy upgrade
apt-get -yy install wget screen zip unzip vim htop git build-essential

# Install Chef dependencies. Use Ruby 1.8 or Compass and Jade may cause problems.
apt-get -yy install ruby1.8 ruby1.8-dev libopenssl-ruby irb ssl-cert

#  Clone repo.
cd /home/www-server
git clone git@github.com:onthelist/onthelist.git
cd /home/www-server/onthelist
# Temporary fix, remove when merged with master.
git checkout development

# Install RubyGems from source or Ubuntu will disable updates and cause random issues.
cd /tmp
wget http://production.cf.rubygems.org/rubygems/rubygems-1.8.7.tgz
tar zxf rubygems-1.8.7.tgz
cd rubygems-1.8.7 
ruby setup.rb --no-format-executable

gem update --system

# Install Chef: This takes a few minutes.
gem install chef --no-ri --no-rdoc

# Fix file permissions now that everything is in place.
chown -R www-server:www /home/www-server/
chmod -R ug+rw /home/www-server

echo "Server bootstrap process complete. Run /home/www-server/onthelist/deployment/startChefSolo.sh when ready."
