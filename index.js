var net = require('net')

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

  options = options || {}

  options.server = options.server || {}
  var host = options.server.host
    , port = options.server.port || 43

  var follow = options.follow || 0

  var timeout = options.timeout || 10000

  if(addrKind == 'IP') {
    host = host || 'whois.arin.net'
  } else {
    var parts = addr.split('.')
      , tld = parts[parts.length - 1]
    host = host || SERVERS[tld]
  }

  if(!host) {
    var err = new Error('lookup: unknown tld')
    err.code = 'ENOTFOUND'
    done(err)
    return
  }

  var command = ''
  if(!options.server.host && addrKind != 'IP') {
    command += 'domain '
  }
  command += addr + '\r\n'

  var client = net.connect(port, host, function() {
    client.write(command, 'ascii')
  })
  client.setTimeout(timeout)
  client.setEncoding('ascii')

  var data = ''
  client.on('data', function(chunk) {
    data += chunk
  })
  client.on('timeout', function() {
    var err = new Error('lookup: timeout')
    err.code = 'TIMEOUT'
    done(err)
    client.destroy()
  })
  client.on('error', function(err) {
    done(err)
  })
  client.on('close', function(hadErr) {
    if(hadErr) {
      return
    }

    if(follow > 0) {
      var match = data.match(/(ReferralServer|Registrar Whois|Whois Server):\s*(whois:\/\/)?(.+)/)
      if(match) {
        var parts = match[3].split(':')
        lookup(addr, {
          server: {
            host: parts[0],
            port: parts[1]
          },
          timeout: timeout,
          follow: follow - 1
        }, done)
      }
      return
    }

    done(null, data)
  })
}