PATH := ./node_modules/.bin:${PATH}

all: index.js

clean:
	rm -rf index.js
	coffee clean.coffee

index.js: index.coffee
	coffee -c $^

test: index.js test.coffee
	mocha -u bdd -R spec -t 10000 -s 5000 --compilers coffee:coffee-script test.coffee
