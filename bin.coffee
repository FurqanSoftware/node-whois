yargs = require 'yargs'
whois = require './index'

yargs.usage('$0 [options] address')
.default('s', null)
.alias('s', 'server')
.describe('s', 'whois server')
.default('f', 0)
.alias('f', 'follow')
.describe('f', 'number of times to follow redirects')
.default('p', null)
.alias('p', 'proxy')
.describe('p', 'SOCKS proxy')
.boolean('v')
.default('v', no)
.alias('v', 'verbose')
.describe('v', 'show verbose results')
.default('b', null)
.alias('b', 'bind')
.describe('b', 'bind to a local IP address')
.boolean('h')
.default('h', no)
.alias('h', 'help')
.describe('h', 'display this help message')

if yargs.argv.h
    yargs.showHelp()
    process.exit 0

if not yargs.argv._[0]?
    yargs.showHelp()
    process.exit 1

@lookup yargs.argv._[0], server: yargs.argv.server, follow: yargs.argv.follow, proxy: yargs.argv.proxy, verbose: yargs.argv.verbose, bind: yargs.argv.bind, (err, data) =>
    if err?
        console.log err
        process.exit 1

    if util.isArray data
        for part in data
            if 'object' == typeof part.server
                console.log part.server.host
            else
                console.log part.server
            console.log part.data
            console.log

    else
        console.log data
