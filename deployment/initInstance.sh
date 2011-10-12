#!/bin/bash
export NODE_PATH=/usr/local/lib/node_modules    

mkdir /home/www-server/logs
mkdir /home/www-server/init

echo "${launch_id}" > /home/www-server/init/launch_id

cd /home/www-server/
/usr/lib/git-core/git-clone -b $branch git@github.com:onthelist/onthelist.git 2>&1 >> /var/log/speedy-deployment-git.log
cd onthelist
/usr/lib/git-core/git-submodule init
/usr/lib/git-core/git-submodule update

/usr/bin/chef-solo -j /home/www-server/onthelist/deployment/chef/node.json -c /home/www-server/onthelist/deployment/chef/solo.rb 2>&1 >> /var/log/speedy-deployment-chef.log

touch /home/www-server/init/cloned
chown -R www-server:www /home/www-server/
chmod -R ug+rw /home/www-server

