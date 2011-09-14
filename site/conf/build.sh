bash -c 'cd ../src; mkdir -p ../public/html; ../../tools/jade.js -p --out ../public html'

coffee push_file.coffee ../public/html/index.html `git rev-parse HEAD`.html
