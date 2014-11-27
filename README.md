# Node-whois

[![Build Status](https://drone.io/github.com/hjr265/node-whois/status.png)](https://drone.io/github.com/hjr265/node-whois/latest)

Node-whois is a WHOIS client for Node.js.

## Installation

    $ npm install node-whois

## Usage

```js
var whois = require('node-whois')
whois.lookup('google.com', function(err, data) {
	console.log(data)
})
```

You may pass an object in between the address and the callback function to tweak the behavior of the lookup function:

```js
{
	"server":  "",   // this can be a string ("host:port") or an object with host and port as its keys; leaving it empty makes lookup rely on servers.json
	"follow":  2,    // number of times to follow redirects
	"timeout": 0,    // socket timeout, excluding this doesn't override any default timeout value
	"verbose": false // setting this to true returns an array of responses from all servers
}
```

## Contributing

Contributions are welcome.

## License

Node-whois is available under the [BSD (2-Clause) License](http://opensource.org/licenses/BSD-2-Clause).
