var net = require('net')

var SERVERS = require('./servers.json')

exports.lookup = function(addr, options, done) {
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

  if(!tld) {
    done(new Error('unknown tld'))
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
    client.destroy()
    done(new Error('lookup: timeout'))
    done = function() {}
  })
  client.on('error', function(err) {
    done(err)
  })
  client.on('close', function(hadErr) {
    if(hadErr) {
      return
    }
    done(null, data)
  })
}