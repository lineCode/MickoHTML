'use strict';

var cp   = require('child_process');
var fs   = require('fs');
var http = require('http');
var url  = require('url');
var tmp  = require('tmp');
var path = require('path');

main();

function main() {
  const port = 80;

  tmp.setGracefulCleanup();

  console.log('Creating server');
  let server = http.createServer((request, response) => {
    console.log('Request:');
    console.log(`\tHTTP:   ${request.httpVersion}`)
    console.log(`\tMethod: ${request.method}`);
    console.log(`\tURL:    ${request.url}`);
    console.log(`\tFrom:   ${request.connection.remoteAddress}`)

    if (request.method === 'GET') {
      handleGET(request, response);
    } else if (request.method === 'POST') {
      handlePOST(request, response);
    } else {
      console.log('Sending NOT IMPLEMENTED');
      response500(response);
    }

    console.log('');
  });

  console.log(`Listening on port ${port}`);
  server.listen(port);
}


function handleGET(request, response) {
  const name = url.parse(request.url).pathname;
  const adjustedName = (name === '/')? '/index.html' : name;

  const siteDir = path.join('.', 'site');
  const pathname = path.join(siteDir, adjustedName);

  if (!checkFileExists(pathname)) {
    console.log('Sending FILE NOT FOUND');
    response404(response);
    return;
  }

  const extension = path.extname(pathname);
  if (extension === '.html') {
    console.log(`Sending html: ${pathname}`);
    response.writeHead(200, {
      'Content-Type': 'text/html; charset=UTF-8'
    });
  } else if (extension === '.css') {
    console.log(`Sending css: ${pathname}`);
    response.writeHead(200, {
      'Content-Type': 'text/css; charset=UTF-8'
    });
  } else if (extension === '.js') {
    console.log(`Sending js: ${pathname}`);
    response.writeHead(200, {
      'Content-Type': 'text/javascript; charset=UTF-8'
    });
  } else if (adjustedName === '/favicon.ico') {
    console.log('Sending favicon');
    response.writeHead(200, {
      'Content-Type': 'image/x-icon'
    });
  } else {
    console.log('Sending FILE NOT FOUND');
    response404(response);
    return;
  }

  fs.createReadStream(pathname).pipe(response);
}


function handlePOST(request, response) {
  response.writeHead(200, {
    'Content-Type': 'application/json; charset=UTF-8'
  });

  let data = '';
  request.on('data', chunk => data += chunk);

  request.on('end', () => {
    runMicko(data, output => {
      if (output.error === false)
        console.log('Sending successful JSON');
      else
        console.log('Sending unsuccessful JSON');

      response.write(JSON.stringify(output));
      response.end();
    });
  });
}


function runMicko(data, callback) {
  console.log('Received JSON');
  const dir      = tmp.dirSync({ unsafeCleanup: true });
  const received = path.join(__dirname, 'received.mc');
  const minic    = path.join(__dirname, 'color_mc.html');
  const assembly = path.join(__dirname, 'output.html');
  const rules    = path.join(__dirname, 'rules.html');
  const exe      = path.join(__dirname, process.argv[2]);

  fs.writeFile(received, JSON.parse(data).code, _ => {
    cp.exec(`${exe} < ${received}`, { cwd: __dirname }, (error, out, err) => {
      if (error !== null) {
        callback({
          error: true,
          errormsg: `${err}<br>${out}`
        });
      } else {
        fs.readFile(minic, 'UTF-8', (_, data_minic) => {
        fs.readFile(assembly, 'UTF-8', (_, data_assembly) => {
        fs.readFile(rules, 'UTF-8', (_, data_rules) => {
          callback({
            error: false,
            errormsg: '',
            minic: data_minic,
            assembly: data_assembly,
            rules: data_rules
          });
        })})});
      }
      fs.unlink(received, _ => { });
    });
  });
}


function response404(response) {
  response.writeHead(404, {
    'Content-Type': 'text/html; charset=UTF-8'
  });
  fs.createReadStream('404.html').pipe(response);
}

function response500(response) {
  response.writeHead(500, {
    'Content-Type': 'text/html; charset=UTF-8'
  });
  fs.createReadStream('500.html').pipe(response);
}

function checkFileExists(path) {
  try {
    fs.statSync(path);
    return true;
  } catch (e) {
    console.log(`Does not exist: ${path}`);
    return false;
  }
}
