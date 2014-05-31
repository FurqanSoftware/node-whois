_ = require 'underscore'
assert = require 'assert'
whois = require './index'


describe '#lookup()', ->
	it 'should work with google.com', (done) ->
		whois.lookup 'google.com', (err, data) ->
			assert.ifError err
			assert.notEqual data.indexOf('Domain Name: GOOGLE.COM'), -1
			done()

	it 'should work with 50.116.8.109', (done) ->
		whois.lookup '50.116.8.109', (err, data) ->
			assert.ifError err
			assert.notEqual data.indexOf('NetName:        LINODE-US'), -1
			done()

	it 'should honor specified WHOIS server', (done) ->
		whois.lookup 'google.com', server: 'whois.markmonitor.com', (err, data) ->
			assert.ifError err
			assert.notEqual data.indexOf('Domain Name: google.com'), -1
			done()

	it 'should honor specified WHOIS server with port override', (done) ->
		whois.lookup 'google.com', server: 'whois.markmonitor.com:43', (err, data) ->
			assert.ifError err
			assert.notEqual data.indexOf('Domain Name: google.com'), -1
			done()

	it 'should follow specified number of redirects for domain', (done) ->
		whois.lookup 'google.com', follow: 1, (err, data) ->
			assert.ifError err
			assert.notEqual data.indexOf('Domain Name: google.com'), -1
			done()

	it 'should follow specified number of redirects for IP address', (done) ->
		whois.lookup '176.58.115.202', follow: 1, (err, data) ->
			assert.ifError err
			assert.notEqual data.indexOf('netname:        LINODE-UK'), -1
			done()

	it 'should work with nic.sh', (done) ->
		whois.lookup 'nic.sh', (err, data) ->
			assert.ifError err
			assert.notEqual data.indexOf('Domain reserved'), -1
			done()

	it 'should work with nic.io', (done) ->
		whois.lookup 'nic.io', (err, data) ->
			assert.ifError err
			assert.notEqual data.indexOf('Domain reserved'), -1
			done()

	it 'should work with nic.ac', (done) ->
		whois.lookup 'nic.ac', (err, data) ->
			assert.ifError err
			assert.notEqual data.indexOf('Domain reserved'), -1
			done()

	it 'should work with nic.tm', (done) ->
		whois.lookup 'nic.tm', (err, data) ->
			assert.ifError err
			assert.notEqual data.indexOf('Domain reserved'), -1
			done()

	it 'should work with srs.net.nz', (done) ->
		whois.lookup 'srs.net.nz', (err, data) ->
			assert.ifError err
			assert.notEqual data.indexOf('domain_name: srs.net.nz'), -1
			done()

	it 'should work with redundant follow', (done) ->
		whois.lookup 'google.com', follow: 5, (err, data) ->
			assert.ifError err
			assert.notEqual data.indexOf('Domain Name: google.com'), -1
			done()
