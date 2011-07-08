#!/usr/bin/env node

// Initially copied from bin/jade (8b8d4087)

/**
 * Module dependencies.
 */

var fs = require('fs')
  , path = require('path')
  , resolve = path.resolve
  , basename = path.basename
  , dirname = path.dirname
  , jade;

try {
  jade = require('../lib/jade');
} catch (err) {
  jade = require('jade');
}

var Compiler = jade.Compiler;

/**
 * Arguments.
 */

var args = process.argv.slice(2);

/**
 * Options javascript.
 */

var options = {};

/**
 * Destination dir.
 */

var dest;

/**
 * Watcher hash.
 */

var watchers;


/**
 * Usage information.
 */

var usage = ''
  + '\n'
  + '  Usage: jade [options]\n'
  + '              [path ...]\n'
  + '              < in.jade > out.jade'
  + '  \n'
  + '  Options:\n'
  + '    -o, --options <str>  JavaScript options object passed\n'
  + '    -h, --help           Output help information\n'
  + '    -w, --watch          Watch file(s) or folder(s) for changes and re-compile\n'
  + '    -v, --version        Output jade version\n'
  + '    --out <dir>          Output the compiled html to <dir>\n';
  + '\n';

// Parse arguments

var arg
  , files = [];
while (args.length) {
  arg = args.shift();
  switch (arg) {
    case '-h':
    case '--help':
      console.log(usage);
      process.exit(1);
    case '-v':
    case '--version':
      console.log(jade.version);
      process.exit(1);
    case '-o':
    case '--options':
      var str = args.shift();
      if (str) {
        options = eval('(' + str + ')');
      } else {
        console.error('-o, --options requires a string.');
        process.exit(1);
      }
      break;
    case '-w':
    case '--watch':
      watchers = {};
      break;
    case '--out':
      dest = args.shift();
      break;
    default:
      files.push(arg);
  }
}

// Watching and no files passed - watch cwd
if (watchers && !files.length) {
  fs.readdirSync(process.cwd()).forEach(processFile);
// Process passed files
} else if (files.length) {
  files.forEach(processFile);
// Stdio
} else {
  var buf = '';
  process.stdin.setEncoding('utf8');
  process.stdin.on('data', function(chunk){
    buf += chunk;
  }).on('end', function(){
    console.log(jade.render(buf, options));
  }).resume();
}

/**
 * Filters
 */

var dependencies = [];

var add_dep = function(file){
  if (dependencies.indexOf(file) == -1)
    dependencies.push(file);
};

var strip_quotes = function(s){
  return s.substring(1, s.length - 1);
};

jade.filters.include_files = function(block, compiler, opts){
  var Visitor = function(node, opts) {
    this.node = node;
    this.path = strip_quotes(opts.path);
    this.first = opts.first ? strip_quotes(opts.first) : null;
  }

  Visitor.prototype.__proto__ = Compiler.prototype;

  Visitor.prototype.compile = function(){
    var self = this;

    this.buf = ['var interp;'];

    var files = fs.readdirSync(self.path);
    
    this.buf.push('var files=[];');
    for (var i=0; i < files.length; i++){
      var filename = files[i];

      if (filename.match(/\.jade$/)){
        // Jade is annoyingly synchronous, yet it uses an async call to
        // read the file, so it's impossible to render one template and use its
        // output in another using the readFile func.
         
        var p = path.join(self.path, filename);

        add_dep(p);

        var str = fs.readFileSync(p);
        var html = jade.render(str, options);
    
        var obj = {
          'filename': filename,
          'contents': html
        };

        if (!self.first || self.first != filename)
          self.buf.push('files.push(' + JSON.stringify(obj) + ');');
        else
          self.buf.push('files.splice(0, 0, ' + JSON.stringify(obj) + ');');
      }
    }

    this.visit(this.node);
    return this.buf.join('\n');
  };

  return new Visitor(block, opts).compile();
};

jade.filters.include_file = function(block, compiler, opts){
  var Visitor = function(node, opts) {
    this.node = node;
    this.path = strip_quotes(opts.path);
  }

  Visitor.prototype.__proto__ = Compiler.prototype;

  Visitor.prototype.compile = function(){
    var self = this;

    this.buf = ['var interp;'];

    add_dep(self.path);

    var str = fs.readFileSync(self.path);
    var html = jade.render(str, options);
    
    self.buf.push('var contents = ' + JSON.stringify(html) + ';');

    this.visit(this.node);
    return this.buf.join('\n');
  };

  return new Visitor(block, opts).compile();
};



/**
 * Process the given path, compiling the jade files found.
 * Always walk the subdirectories.;
 */

function processFile(path) {
  fs.lstat(path, function(err, stat) {
    if (err) throw err;
    // Found jade file
    if (stat.isFile() && path.match(/\.jade$/)) {
      renderJade(path);
    // Found directory
    } else if (stat.isDirectory()) {
      fs.readdir(path, function(err, files) {
        if (err) throw err;
        files.map(function(filename) {
          return path + '/' + filename;
        }).forEach(processFile);
      });
    }
  });
}

/**
 * Render jade
 */

function renderJade(jadefile) {
  // Updated by filters
  dependencies = [];

  jade.renderFile(jadefile, options, function(err, html) {
    if (err){
      console.error('Error with file ' + jadefile);
      console.error(err);
    } else {
      writeFile(jadefile, html, dependencies);
    }
  });
}

/**
 * mkdir -p implementation.
 */

function mkdirs(path, fn) {
  var segs = dirname(path).split('/')
    , dir = '';

  (function next() {
    var seg = segs.shift();
    if (seg) {
      dir += seg + '/';
      fs.mkdir(dir, 0755, function(err){
        if (!err) return next();
        if ('EEXIST' == err.code) return next();
      });
    } else {
      fn();
    }
  })();
}

/**
 * Write the html output to a file.
 */

function writeFile(src, html, deps) {
  var path = src.replace('.jade', '.html');
  if (dest) path = dest + '/' + path;
  mkdirs(path, function(err){
    if (err) throw err;
    fs.writeFile(path, html, function(err) {
      if (err) throw err;
      console.log('  \033[90mcompiled\033[0m %s', path);
      watch(src, renderJade);

      console.log(deps);
      if (deps){
        for (var i=0; i < deps.length; i++){
          watch(deps[i], renderJade, src);
        }
      }
    });
  });
}

/**
 * Watch the given `file` and invoke `fn` when modified.
 */

function watch(file, fn, out_file) {
  out_file = out_file || file;
  // not watching
  if (!watchers) return;

  // already watched
  if (watchers[file]) return;

  // watch the file itself
  watchers[file] = true;
  console.log('  \033[90mwatching\033[0m %s', file);
  fs.watchFile(file, { interval: 50 }, function(curr, prev){
    if (curr.mtime > prev.mtime) fn(out_file);
  });
}
