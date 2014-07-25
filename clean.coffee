_ = require 'underscore'
fs = require 'fs'
os = require 'os'

# clean cache by deleting files
# in the temp folder with the "node-whois-" prefix

files = fs.readdirSync os.tmpdir()
_.each files, (file) ->
	if file.match(/^node-whois-/)
		fs.unlinkSync os.tmpdir() + file
