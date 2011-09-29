#!/bin/bash
export NODE_PATH=/usr/local/lib/node_modules    

cd /home/www-server/
/usr/lib/git-core/git-clone -b master git@github.com:onthelist/onthelist.git 2>&1 >> /var/log/speedy-deployment-git.log

/usr/bin/chef-solo -j /home/www-server/onthelist/deployment/chef/node.json -c /home/www-server/onthelist/deployment/chef/solo.rb 2>&1 >> /var/log/speedy-deployment-chef.log

mkdir /home/www-server/init
touch /home/www-server/init/cloned
chown -R www-server:www /home/www-server/
chmod -R ug+rw /home/www-server

