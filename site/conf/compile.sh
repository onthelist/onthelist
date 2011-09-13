#!/bin/sh
cd /home/www-server/onthelist/site

# Jade
mkdir -p ./public/html; cd ./src; ../../tools/jade.js --out ../public html

# Compass
cd ..; mkdir -p public/styles; compass compile

# CoffeeScript
mkdir -p public/scripts; coffee -c -o ./public/scripts ./src/scripts

