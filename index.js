var net = require('net')

var SERVERS = require('./servers.json')

exports.lookup = lookup

function lookup(addr, options, done) {
  if(typeof done == 'undefined') {
    done = options
    options = undefined
  }

  options = options || {}

  var parts = addr.split('.')
    , tld = parts[parts.length - 1]

  options.server = options.server || {}
  var host = options.server.host || SERVERS[tld]
    , port = options.server.port || 43

  if(!host) {
    var err = new Error('lookup: unknown tld')
    err.code = 'ENOTFOUND'
    done(err)
    return
  }

  var timeout = options.timeout || 10000

  var command = ''
  if(!options.server.host) {
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

    var follow = options.follow || 0
    if(follow > 0) {
      var match = data.match(/(Registrar Whois|Whois Server):\s*(.+)/)
      if(match) {
        lookup(addr, {
          server: {
            host: match[2]
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