var knox = require('knox');
var aws_key = require('./aws_key');

var client = null;
module.exports.upload_file = function(name, data, headers){
  if (!client){
    client = knox.createClient({
      key: aws_key.access,
      secret: aws_key.secret,
      bucket: 'speedyseat-files'
    });
  }

  headers = headers || {};
  headers['Content-Length'] = data.length;
  headers['Expires'] = 'Wed, 14 Sep 2022 03:29:41 GMT'
  headers['Cache-Control'] = 'Public, s-maxage=99999999'
  headers['Vary'] = 'Accept-Encoding'

  var req = client.put(name, headers);
  req.on('response', function(res){
    if (res.statusCode == 200){
      console.log('Saved Successfully');
    } else {
      console.log('Error Saving');
      console.log(res);
    }
  });
    
  req.end(data);
};

