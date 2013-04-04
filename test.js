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

  it('should work with 50.116.8.109', function(done) {
    whois.lookup('50.116.8.109', function(err, data) {
      assert(!err)
      assert.notEqual(data.indexOf('OrgName:        Linode'), -1)
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
      assert.notEqual(data.indexOf('Dns Admin'), -1)
      assert.notEqual(data.indexOf('Google Inc.'), -1)
      done()
    })
  })

  it('should follow redirects for domain names', function(done) {
    whois.lookup('google.com', {
      follow: 1
    }, function(err, data) {
      assert(!err)
      assert.notEqual(data.indexOf('Dns Admin'), -1)
      assert.notEqual(data.indexOf('Google Inc.'), -1)
      done()
    })
  })

  it('should follow redirects for IPs', function(done) {
    whois.lookup('176.58.115.202', {
      follow: 1
    }, function(err, data) {
      assert(!err)
      assert.notEqual(data.indexOf('netname:        LINODE-UK'), -1)
      done()
    })
  })

  it('should work with efi.sh', function(done) {
    whois.lookup('efi.sh', function(err, data) {
      assert(!err)
      assert.notEqual(data.indexOf('Domain "EFI.SH" - Not available'), -1)
      done()
    })
  })
})