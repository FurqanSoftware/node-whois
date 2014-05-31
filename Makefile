PATH := ./node_modules/.bin:${PATH}

all: index.js

clean:
	rm -rf index.js

index.js: index.coffee
	coffee -c $^
