_ = require 'underscore'
net = require 'net'
SocksClient = require('socks').SocksClient
punycode = require 'punycode'
util = require 'util'


@SERVERS = require './servers.json'

cleanParsingErrors = (string) =>
	return string.replace(/^[:\s]+/, '').replace(/^https?[:\/]+/, '') || string

@lookup = (addr, options, done) =>
	if typeof done is 'undefined' and typeof options is 'function'
		done = options
		options = {}

	_.defaults options,
		follow: 2
		timeout: 60000 # 60 seconds in ms

	done = _.once done

	server = options.server
	proxy = options.proxy
	timeout = options.timeout

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

	if typeof proxy is 'string'
		parts = proxy.split ':'
		proxy =
			ipaddress: parts[0]
			port: parseInt parts[1]

	_.defaults server,
		port: 43
		query: "$addr\r\n"

	if proxy
		_.defaults proxy,
			type: 5


	_lookup = (socket, done) =>
		idn = addr
		if server.punycode isnt false and options.punycode isnt false
			idn = punycode.toASCII addr
		if options.encoding
			socket.setEncoding options.encoding
		socket.write server.query.replace '$addr', idn

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
				match = data.replace(/\r/gm, '').match /(ReferralServer|Registrar Whois|Whois Server|WHOIS Server|Registrar WHOIS Server):[^\S\n]*((?:r?whois|https?):\/\/)?(.*)/
				if match? and match[3] != server.host
					options = _.extend {}, options,
						follow: options.follow - 1
						server: match[3].trim()

					options.server = cleanParsingErrors(options.server)

					@lookup addr, options, (err, parts) =>
						if err?
							return done err

						if options.verbose
							done null, [
								server: if ('object' == typeof server) then server.host.trim() else server.trim()
								data: data
							].concat(parts)
						else
							done null, parts
					return

			if options.verbose
				done null, [
					server: if ('object' == typeof server) then server.host.trim() else server.trim()
					data: data
				]
			else
				done null, data

	if !Number.isInteger(server.port)
		server.port = 43

	if proxy
		SocksClient.createConnection
			proxy: proxy
			destination:
				host: server.host
				port: server.port
			command: 'connect'
			timeout: timeout
		, (err, info) =>
			if err?
				return done err
			{socket} = info
			if timeout
				socket.setTimeout timeout

			_lookup socket, done

			socket.resume()

	else
		sockOpts =
			host: server.host
			port: server.port

		if options.bind
			sockOpts.localAddress = options.bind

		socket = net.connect sockOpts
		if timeout
			socket.setTimeout timeout
		_lookup socket, done
