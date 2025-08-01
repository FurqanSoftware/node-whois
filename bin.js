#!/usr/bin/env node

import yargs from "yargs";
import { lookup } from "./index.js";

yargs
  .usage("$0 [options] address")
  .default("s", null)
  .alias("s", "server")
  .describe("s", "whois server")
  .default("f", 0)
  .alias("f", "follow")
  .describe("f", "number of times to follow redirects")
  .default("t", 60000)
  .alias("t", "timeout")
  .describe("t", "socket timeout")
  .default("p", null)
  .alias("p", "proxy")
  .describe("p", "SOCKS proxy")
  .boolean("v")
  .default("v", false)
  .alias("v", "verbose")
  .describe("v", "show verbose results")
  .default("b", null)
  .alias("b", "bind")
  .describe("b", "bind to a local IP address")
  .boolean("h")
  .default("h", false)
  .alias("h", "help")
  .describe("h", "display this help message");

if (yargs.argv.h) {
  yargs.showHelp();
  process.exit(0);
}

if (yargs.argv._[0] == null) {
  yargs.showHelp();
  process.exit(1);
}

lookup(
  yargs.argv._[0],
  {
    server: yargs.argv.server,
    follow: yargs.argv.follow,
    timeout: yargs.argv.timeout,
    proxy: yargs.argv.proxy,
    verbose: yargs.argv.verbose,
    bind: yargs.argv.bind,
  },
  (err, data) => {
    var i, len, part, results;
    if (err != null) {
      console.log(err);
      process.exit(1);
    }
    if (Array.isArray(data)) {
      results = [];
      for (i = 0, len = data.length; i < len; i++) {
        part = data[i];
        if ("object" === typeof part.server) {
          console.log(part.server.host);
        } else {
          console.log(part.server);
        }
        console.log(part.data);
        results.push(console.log);
      }
      return results;
    } else {
      return console.log(data);
    }
  },
);
