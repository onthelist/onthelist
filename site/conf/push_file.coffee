knox = require('knox')
compress =require('compress-buffer').compress
fs = require('fs')

aws_key = require('../../tools/aws_key')
upload_file = require('../../tools/s3_push').upload_file

in_file = process.argv[2]
out_file = process.argv[3]

data = fs.readFileSync(in_file)
in_len = data.length

data = compress(data)
com_len = data.length

console.log "#{in_len} / #{com_len}"
console.log out_file

upload_file out_file, data,
  "Content-Type": "text/html"
  "Content-Encoding": "gzip"
