# Node WHOIS

A simple WHOIS client for NodeJS.

## Installation

    $ npm install node-whois

## Usage

    var whois = require('node-whois')

    whois.lookup(addr, [options], done)

## Examples

### Basic

    whois.lookup('google.com', function(err, data) {
      console.log(err, data)
    })

### Advanced

    whois.lookup('google.com', {
      server: {
        host: 'whois.markmonitor.com',
        port: 43
      },
      timeout: 5000
    }, function(err, data) {
      console.log(err, data)
    })

## TODO

* Write tests

## License

FreeBSD