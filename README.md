# Node WHOIS

A simple WHOIS client for NodeJS.

## Installation

    $ npm install node-whois

## Usage

    var whois = require('node-whois')

    whois.lookup(addr, [options], done)

* `addr` is the address to be looked up

* `options`

  * `server` is a hash with `host` and `port` of the WHOIS server

  * `follow` is the number of times redirection will be honored

  * `timeout` is the number of milliseconds after which the connection will timeout

## Examples

### Basic

    whois.lookup('google.com', function(err, data) {
      console.log(err, data)
    })

### Advanced

    whois.lookup('google.com', {
      server: {
        host: 'whois.markmonitor.com'
      },
      timeout: 5000
    }, function(err, data) {
      console.log(err, data)
    })

## License

FreeBSD