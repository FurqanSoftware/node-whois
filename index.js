var http = require('http')
  , jsdom = require('jsdom')
  , net = require('net')

var SERVERS = require('./servers.json')

exports.lookup = lookup

function lookup(addr, options, done) {
  if(typeof done == 'undefined') {
    done = options
    options = undefined
  }

  var addrKind
  if(net.isIP(addr)) {
    addrKind = 'IP'
  } else {
    addrKind = 'DOMAIN'
  }

  var parts = addr.split('.')
    , tld = parts[parts.length - 1]

  var server = SERVERS[tld] || {}

  if(typeof server == 'object' && server.method) {
    var method = server.method
      , host = server.host
      , path = server.path
      , payload = server.payload || ''
      , selector = server.selector
      , parser = server.parser

    path = path.replace('$ADDR', addr)
    payload = payload.replace('$ADDR', addr)

    var headers = {
      'Origin': 'http://' + host + '/',
      'Referer': 'http://' + host + '/',
      'User-Agent': 'Mozilla/5.0 (IE 11.0; Windows NT 6.3; Trident/7.0; .NET4.0E; .NET4.0C; rv:11.0) like Gecko'
    }
    if(method == 'post') {
      headers['Content-Type'] = 'application/x-www-form-urlencoded'
      headers['Content-Length'] = payload.length
    }

    var req = http.request({
      method: method,
      host: host,
      path: path,
      headers: headers
    }, function(res) {
      var body = ''
      res.on('data', function(chunk) {
        body += chunk
      })
      res.on('end', function() {
        var document = jsdom.jsdom(body)
          , window = document.createWindow()

        var data = ''
        switch(parser) {
          case 'table':
            var table = window.document.querySelector(server.selector)
              , trs = table.querySelectorAll('tr')
            for(var i = 0; i < trs.length; ++i) {
              var tr = trs[i]
                , tds = tr.querySelectorAll('td')
              for(var j = 0; j < tds.length; ++j) {
                var td = tds[j]
                data += td.textContent + ' '
              }
              data += '\n'
            }
            break;
        }
        window.close()

        done(null, data)
      })
    })

    req.on('error', function(err) {
      done(err)
    })

    req.write(payload);
    req.end();
    return
  }

  options = options || {}

  options.server = options.server || {}
  var host = options.server.host
    , port = options.server.port || 43

  var follow = 2
  if(typeof options.follow != 'undefined') {
    follow = options.follow
  }

  var timeout = options.timeout || 10000

  var command = ''
  if(!options.server.host && addrKind != 'IP') {
    command += 'domain '
  }
  command += addr + '\r\n'

  if(addrKind == 'IP') {
    host = host || 'whois.arin.net'
  } else {
    if(typeof server == 'string') {
      server = {
        host: server
      }
    }
    if(server.command) {
      command = server.command.replace('$ADDR', addr) + '\r\n'
    }
    host = host || server.host
  }

  if(!host) {
    var err = new Error('lookup: unknown tld')
    err.code = 'ENOTFOUND'
    done(err)
    return
  }

  var client = net.connect(port, host, function() {
    client.write(command, 'ascii')
  })
  client.setTimeout(timeout)
  client.setEncoding('ascii')

  var data = ''
    , timedout = false
  client.on('data', function(chunk) {
    data += chunk
  })
  client.on('timeout', function() {
    timedout = true
    client.destroy()
    var err = new Error('lookup: timeout')
    err.code = 'TIMEOUT'
    done(err)
  })
  client.on('error', function(err) {
    done(err)
  })
  client.on('close', function(hadErr) {
    if(hadErr || timedout) {
      return
    }

    if(follow > 0) {
      var match = data.match(/(ReferralServer|Registrar Whois|Whois Server):\s*(whois:\/\/)?(.+)/)
      if(match) {
        var parts = match[3].split(':')
        if(host != parts[0]) {
          lookup(addr, {
            server: {
              host: parts[0],
              port: parts[1]
            },
            timeout: timeout,
            follow: follow - 1
          }, done)
          return
        }
      }
    }

    done(null, data)
  })
}