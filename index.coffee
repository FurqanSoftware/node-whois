_ = require 'underscore'
net = require 'net'
punycode = require 'punycode'
util = require 'util'


@SERVERS = require './servers.json'

@lookup = (addr, options, done) =>
	if typeof done is 'undefined' and typeof options is 'function'
		done = options
		options = {}

	_.defaults options,
		follow: 2

	done = _.once done

	server = options.server

	if not server
		switch true
			when _.contains addr, '@'
				done new Error 'lookup: email addresses not supported'
				return

			when net.isIP(addr) isnt 0
				server = @SERVERS['_']['ip']

			else
				tld = punycode.toASCII addr
				while true
					server = @SERVERS[tld]
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
		idn = addr
		if server.punycode isnt false and options.punycode isnt false
			idn = punycode.toASCII addr
		socket.write server.query.replace '$addr', idn
	socket.setEncoding 'utf-8'
	if options.timeout?
		socket.setTimeout options.timeout

	data = ''
	socket.on 'data', (chunk) =>
		data += chunk

	socket.on 'timeout', =>
		socket.destroy()
		done new Error 'lookup: timeout'

	socket.on 'error', (err) =>
		done err

	socket.on 'close', (err) =>
		if options.follow > 0
			match = data.match /(ReferralServer|Registrar Whois|Whois Server|WHOIS Server):\s*(r?whois:\/\/)?(.*?)/
			if match? and match[3] != server.host
				options = _.extend {}, options,
					follow: options.follow - 1
					server: match[3]
				@lookup addr, options, (err, parts) =>
					if err?
						return done err

					if options.verbose
						done null, [
							server: server
							data: data
						].concat(parts)
					else
						done null, parts
				return

		if options.verbose
			done null, [
				server: server
				data: data
			]
		else
			done null, data


if module is require.main
	optimist = require('optimist')
	.usage('$0 [options] address')
	.default('s', null)
	.alias('s', 'server')
	.describe('s', 'whois server')
	.default('f', 0)
	.alias('f', 'follow')
	.describe('f', 'number of times to follow redirects')
	.boolean('v')
	.default('v', no)
	.alias('v', 'verbose')
	.describe('v', 'show verbose results')
	.boolean('h')
	.default('h', no)
	.alias('h', 'help')
	.describe('h', 'display this help message')

	if optimist.argv.h
		console.log optimist.help()
		process.exit 0

	if not optimist.argv._[0]?
		console.log optimist.help()
		process.exit 1

	@lookup optimist.argv._[0], server: optimist.argv.server, follow: optimist.argv.follow, verbose: optimist.argv.verbose, (err, data) =>
		if err?
			console.log err
			process.exit 1

		if util.isArray data
			for part in data
				console.log part.server.host
				console.log part.data
				console.log

		else
			console.log data
