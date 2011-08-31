#!/bin/sh
chef-solo -j /home/www-server/onthelist/deployment/chef/node.json -c /home/www-server/onthelist/deployment/chef/solo.rb

