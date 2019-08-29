all: index.js

clean:
	rm -rf index.js

index.js: index.coffee
	node_modules/.bin/coffee -c $^
	printf "#!/usr/bin/env node\n\n" > index.js.tmp && \
		cat index.js >> index.js.tmp && \
		mv index.js.tmp index.js

test: index.js test.coffee
	node_modules/.bin/mocha -u bdd -R spec -t 10000 -s 5000 --compilers coffee:coffee-script/register test.coffee
