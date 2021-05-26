all: index.js bin.js

clean:
	rm -rf index.js bin.js

index.js: index.coffee
	./node_modules/.bin/coffee -c $^

bin.js: bin.coffee
	./node_modules/.bin/coffee -c $^
	printf "#!/usr/bin/env node\n\n" > bin.js.tmp && \
		cat bin.js >> bin.js.tmp && \
		mv bin.js.tmp bin.js

test: index.js test.coffee
	./node_modules/.bin/mocha -u bdd -R spec -t 10000 -s 5000 --require coffeescript/register test.coffee
