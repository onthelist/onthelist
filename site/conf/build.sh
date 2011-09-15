bash -c 'mkdir -p ../public/scripts; coffee -c -o ../public/scripts ../src/scripts'
bash -c 'cd ..; mkdir -p public/styles; compass compile'
bash -c 'cd ../src; mkdir -p ../public/html; ../../tools/jade.js -p --out ../public html'

coffee push_file.coffee ../public/html/index.html `GIT_DIR=~/onthelist/.git git rev-parse HEAD`.html
