_ = require 'underscore'
assert = require 'assert'
whois = require './index'

describe '#lookup()', ->
	it 'should work with google.com', (done) ->
		whois.lookup 'google.com', (err, data) ->
			assert.ifError err
			assert.notEqual data.toLowerCase().indexOf('domain name: google.com'), -1
			done()

	it 'should work with 50.116.8.109', (done) ->
		whois.lookup '50.116.8.109', (err, data) ->
			assert.ifError err
			assert.notEqual data.toLowerCase().indexOf('netname:        linode-us'), -1
			done()

	it 'should work with 2001:0db8:11a3:09d7:1f34:8a2e:07a0:765d', (done) ->
		whois.lookup '2001:0db8:11a3:09d7:1f34:8a2e:07a0:765d', (err, data) ->
			assert.ifError err
			assert.notEqual data.toLowerCase().indexOf('inet6num:       2001:db8::/32'), -1
			done()

	it 'should honor specified WHOIS server', (done) ->
		whois.lookup 'gandi.net', server: 'whois.gandi.net', (err, data) ->
			assert.ifError err
			data = data.toLowerCase()
			assert.notEqual data.indexOf('whois server: whois.gandi.net'), -1
			assert.notEqual data.indexOf('domain name: gandi.net'), -1
			done()

	it 'should honor specified WHOIS server with port override', (done) ->
		whois.lookup 'tucows.com', server: 'whois.tucows.com:43', (err, data) ->
			assert.ifError err
			data = data.toLowerCase()
			assert.notEqual data.indexOf('whois server: whois.tucows.com'), -1
			assert.notEqual data.indexOf('domain name: tucows.com'), -1
			done()

	it 'should follow specified number of redirects for domain', (done) ->
		whois.lookup 'google.com', follow: 1, (err, data) ->
			assert.ifError err
			assert.notEqual data.toLowerCase().indexOf('domain name: google.com'), -1
			done()

	it 'should follow specified number of redirects for IP address', (done) ->
		whois.lookup '176.58.115.202', follow: 1, (err, data) ->
			assert.ifError err
			assert.notEqual data.toLowerCase().indexOf('inetnum:        176.58.112.0 - 176.58.119.255'), -1
			done()

	it 'should work with verbose option', (done) ->
		whois.lookup 'google.com', {verbose: true}, (err, data) ->
			assert.ifError err
			assert.equal (data[0].server == 'whois.verisign-grs.com') or (data[0].server == 'whois.markmonitor.com'), 1
			assert.notEqual data[0].data.toLowerCase().indexOf('domain name: google.com'), -1
			done()

	it 'should work with nic.sh', (done) ->
		whois.lookup 'nic.sh', (err, data) ->
			assert.ifError err
			assert.notEqual data.toLowerCase().indexOf('registry domain id: dede5cd207a640ae8285d181431a00c4-donuts'), -1
			done()

	it 'should work with nic.io', (done) ->
		whois.lookup 'nic.io', (err, data) ->
			assert.ifError err
			assert.notEqual data.toLowerCase().indexOf('registry domain id: 09b2461d0b6449ffbc9edb53bc7326c1-donuts'), -1
			done()

	it 'should work with nic.ac', (done) ->
		whois.lookup 'nic.ac', (err, data) ->
			assert.ifError err
			assert.notEqual data.toLowerCase().indexOf('registry domain id: bcb94de2bd4e43459a9ef5e67e2e02d3-donuts'), -1
			done()

	it 'should work with nic.tm', (done) ->
		whois.lookup 'nic.tm', (err, data) ->
			assert.ifError err
			assert.notEqual data.toLowerCase().indexOf('status : permanent/reserved'), -1
			done()

	it 'should work with nic.global', (done) ->
		whois.lookup 'nic.global', (err, data) ->
			assert.ifError err
			assert.notEqual data.toLowerCase().indexOf('registry domain id: 696c235291444e9ab8c0f1336238c349-donuts'), -1
			done()

	it 'should work with srs.net.nz', (done) ->
		whois.lookup 'srs.net.nz', (err, data) ->
			assert.ifError err
			assert.notEqual data.toLowerCase().indexOf('domain name: srs.net.nz'), -1
			done()

	it 'should work with redundant follow', (done) ->
		whois.lookup 'google.com', follow: 5, (err, data) ->
			assert.ifError err
			assert.notEqual data.toLowerCase().indexOf('domain name: google.com'), -1
			done()

	it 'should work with küche.de', (done) ->
		whois.lookup 'küche.de', (err, data) ->
			assert.ifError err
			assert.notEqual data.toLowerCase().indexOf('domain: küche.de'), -1
			assert.notEqual data.toLowerCase().indexOf('status: connect'), -1
			done()

	it 'should work with google.co.jp in english', (done) ->
		whois.lookup 'google.co.jp', (err, data) ->
			assert.ifError err
			assert.notEqual data.toLowerCase().indexOf('a. [domain name]                google.co.jp'), -1
			done()

	it 'should work with registry.pro', (done) ->
		whois.lookup 'registry.pro', follow: 0, (err, data) ->
			assert.ifError err
			assert.notEqual data.toLowerCase().indexOf('domain id: a78bed915c9748fdbdf91224299d2058-donuts'), -1
			done()

	it 'should fail with google.com due to timeout', (done) ->
		whois.lookup 'google.com', {timeout: 1}, (err, data) ->
			assert err
			assert.equal 'lookup: timeout', err.message
			done()

	it 'should succeed with google.com with timeout', (done) ->
		whois.lookup 'google.com', {timeout: 10000}, (err, data) ->
			assert.ifError err
			assert.notEqual data.toLowerCase().indexOf('domain name: google.com'), -1
			done()

	it 'should work with åre.no', (done) ->
		whois.lookup 'åre.no', (err, data) ->
			assert.ifError err
			assert.notEqual data.toLowerCase().indexOf('åre.no'), -1
			done()

	it 'should work with nic.digital', (done) ->
		whois.lookup 'nic.digital', (err, data) ->
			assert.ifError err
			assert.notEqual data.toLowerCase().indexOf('nic.digital'), -1
			done()

	it 'should work with whois.nic.ai', (done) ->
		whois.lookup 'whois.nic.ai', (err, data) ->
			assert.ifError err
			assert.notEqual data.toLowerCase().indexOf('whois.nic.ai'), -1
			done()

	it 'should work with currentzoology.org', (done) ->
		whois.lookup 'currentzoology.org', (err, data) ->
			assert.ifError err
			assert.notEqual data.toLowerCase().indexOf('currentzoology.org'), -1
			done()

	it 'should work with 148.241.109.161', (done) ->
		whois.lookup '148.241.109.161', {encoding: 'binary'}, (err, data) ->
			assert.ifError err
			assert.notEqual data.indexOf('MX-ITYE8-LACNIC'), -1
			done()

	it 'should work with dot.ai', (done) ->
		whois.lookup 'dot.ai', (err, data) ->
			assert.ifError err
			assert.notEqual data.toLowerCase().indexOf('dot.ai'), -1
			done()

	it 'should avoid socket BAD_PORT Error and fail with a catchable ECONNRESET with whois.yesnic.com (eigene.io)', (done) ->
		whois.lookup 'eigene.io', { follow: 2, timeout: 10000 }, (err, data) ->
			if data
				assert.notEqual data, null
			else if err
				assert.notEqual err.toString().indexOf('ECONNRESET'), -1
			done()

	it 'should work with gen.xyz', (done) ->
		whois.lookup 'gen.xyz', (err, data) ->
			assert.ifError err
			console.log data
			assert.equal data.toLowerCase().indexOf('not found'), -1
			done()
