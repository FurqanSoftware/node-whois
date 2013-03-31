var assert = require('assert')
  , whois = require('./index')

describe('lookup', function() {
  it('should work with google.com', function(done) {
    whois.lookup('google.com', function(err, data) {
      assert(!err)
      assert.notEqual(data.indexOf('Registrar: MARKMONITOR INC.'), -1)
      done()
    })
  })

  it('should honor user specified server', function(done) {
    whois.lookup('google.com', {
      server: {
        host: 'whois.markmonitor.com'
      }
    }, function(err, data) {
      assert(!err)
      assert.notEqual(data.indexOf('dns-admin@google.com +1.6502530000 Fax: +1.6506188571'), -1)
      done()
    })
  })

  it('should follow redirects', function(done) {
    whois.lookup('google.com', {
      follow: 1
    }, function(err, data) {
      assert(!err)
      assert.notEqual(data.indexOf('dns-admin@google.com +1.6502530000 Fax: +1.6506188571'), -1)
      done()
    })
  })
})