PATH := ./node_modules/.bin:${PATH}

all: index.js

clean:
	rm -rf index.js

index.js: index.coffee
	coffee -c $^
	printf "#!/usr/bin/env node\n\n" > index.js.tmp && \
		cat index.js >> index.js.tmp && \
		mv index.js.tmp index.js

test: index.js test.coffee
	mocha -u bdd -R spec -t 10000 -s 5000 --require coffee-script/register --compilers coffee:coffee-script test.coffee
