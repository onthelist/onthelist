#!/bin/sh
cd /home/www-server/onthelist/site/conf

# Jade
cd ../src; mkdir -p ../public/html; ../../tools/jade.js --out ../public html

# Compass
cd ..; mkdir -p public/styles; compass compile

# CoffeeScript
mkdir -p public/scripts; coffee -c -o ./public/scripts ./src/scripts

