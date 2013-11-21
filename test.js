var assert = require('assert')
  , whois = require('./index')

describe('lookup', function() {
  it('should work with google.com', function(done) {
    whois.lookup('google.com', function(err, data) {
      assert(!err)
      assert.notEqual(data.indexOf('Dns Admin'), -1)
      assert.notEqual(data.indexOf('Google Inc.'), -1)
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

  it('should work with nic.sh', function(done) {
    whois.lookup('nic.sh', function(err, data) {
      assert(!err)
      assert.notEqual(data.indexOf('Domain Name : nic.sh'), -1)
      done()
    })
  })

  it('should work with nic.io', function(done) {
    whois.lookup('nic.io', function(err, data) {
      assert(!err)
      assert.notEqual(data.indexOf('Domain Name : nic.io'), -1)
      done()
    })
  })

  it('should work with nic.ac', function(done) {
    whois.lookup('nic.ac', function(err, data) {
      assert(!err)
      assert.notEqual(data.indexOf('Domain Name : nic.ac'), -1)
      done()
    })
  })

  it('should work with nic.tm', function(done) {
    whois.lookup('nic.tm', function(err, data) {
      assert(!err)
      assert.notEqual(data.indexOf('Domain Name : nic.tm'), -1)
      done()
    })
  })

  it('should work with srs.net.nz', function(done) {
    whois.lookup('srs.net.nz', function(err, data) {
      assert(!err)
      assert.notEqual(data.indexOf('domain_name: srs.net.nz'), -1)
      done()
    })
  })

  it('should work with redundant follow', function(done) {
    whois.lookup('google.com', {
      follow: 5
    }, function(err, data) {
      assert(!err)
      assert.notEqual(data.indexOf('Dns Admin'), -1)
      assert.notEqual(data.indexOf('Google Inc.'), -1)
      done()
    })
  })
})