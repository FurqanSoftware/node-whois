_ = require 'underscore'
net = require 'net'
punycode = require 'punycode'


SERVERS = require './servers.json'

@lookup = (addr, options, done) =>
	if typeof done is 'undefined' and typeof options is 'function'
		done = options
		options = {}

	done = _.once done

	server = options.server

	if not server
		switch true
			when _.contains addr, ':'
				done new Error 'lookup: IPv6 not supported'
				return

			when _.contains addr, '@'
				done new Error 'lookup: email addresses not supported'
				return

			when (addr.match /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/)?
				server = SERVERS['_']['ipv4']

			else
				tld = punycode.toASCII addr
				while true
					server = SERVERS[tld]
					if not tld or server
						break
					tld = tld.replace /^.+?(\.|$)/, ''

	if not server
		done new Error 'lookup: no whois server is known for this kind of object'
		return

	if typeof server is 'string'
		parts = server.split ':'
		server = 
			host: parts[0]
			port: parts[1]

	_.defaults server,
		port: 43
		query: "$addr\r\n"

	socket = net.connect server.port, server.host, =>
		socket.write server.query.replace '$addr', punycode.toASCII addr

	data = ''
	socket.on 'data', (chunk) =>
		data += chunk

	socket.on 'timeout', =>
		done new Error 'lookup: timeout'

	socket.on 'error', (err) =>
		done err

	socket.on 'close', (err) =>
		if options.follow > 0
			match = data.match /(ReferralServer|Registrar Whois|Whois Server):\s*(whois:\/\/)?(.+)/
			if match?
				@lookup addr, server: match[3], done
				return

		done null, data