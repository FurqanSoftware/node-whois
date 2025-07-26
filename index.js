import net from "net";
import url from "url";

import _ from "underscore";
import { SocksClient } from "socks";

import SERVERS from "./servers.json" with { type: "json" };
export { SERVERS };

export const lookup = (addr, options, done) => {
  if (typeof done === "undefined" && typeof options === "function") {
    done = options;
    options = {};
    if (addr === "__proto__") {
      done(new Error("lookup: __proto__ is not allowed to lookup"));
      return;
    }
  }
  _.defaults(options, {
    follow: 2,
    timeout: 60000, // 60s
  });
  done = _.once(done);

  let { server, proxy } = options;
  server = parseServer(server);
  proxy = parseProxy(proxy);
  if (!server) {
    switch (true) {
      case _.contains(addr, "@"):
        done(new Error("lookup: email addresses not supported"));
        return;
      case net.isIP(addr) !== 0:
        server = { ...parseServer(SERVERS["_"]["ip"]), punycode: false };
        options.punycode = false;
        break;
      default:
        let tld = url.domainToASCII(addr);
        while (tld && !server) {
          if (!SERVERS[tld]) {
            tld = tld.replace(/^.+?(\.|$)/, "");
            continue;
          }
          server = { ...parseServer(SERVERS[tld]) };
        }
        break;
    }
  }
  if (!server) {
    done(new Error("lookup: no whois server is known for this kind of object"));
    return;
  }

  server = withServerDefaults(server);
  if (proxy) proxy = withProxyDefaults(proxy);

  const _lookup = (socket, done) => {
    let idn = addr;
    if (server.punycode !== false && options.punycode !== false)
      idn = url.domainToASCII(addr);
    if (options.encoding) socket.setEncoding(options.encoding);
    socket.write(server.query.replace("$addr", idn));
    let data = "";
    socket.on("data", (chunk) => {
      data += chunk;
    });
    socket.on("timeout", () => {
      socket.destroy();
      done(new Error("lookup: timeout"));
    });
    socket.on("error", (err) => {
      done(err);
    });
    return socket.on("close", (err) => {
      if (options.follow > 0) {
        const referralServer = extractReferralServer(data, server);
        if (referralServer) {
          lookup(
            addr,
            {
              ...options,
              follow: options.follow - 1,
              server: referralServer,
            },
            (err, parts) => {
              if (options.verbose) {
                parts = [
                  {
                    server: server.host.trim(),
                    data,
                  },
                ].concat(parts || []);
              }
              return done(err, parts);
            },
          );
          return;
        }
      }
      return done(
        null,
        options.verbose
          ? [
              {
                server: server.host.trim(),
                data,
              },
            ]
          : data,
      );
    });
  };

  makeSocket(server, proxy, options, (err, socket) => {
    if (err !== null) {
      done(err);
      return;
    }
    _lookup(socket, done);
  });
};

const parseServer = (server) => {
  if (typeof server !== "string") return server;
  const [host, port] = server.split(":");
  server = {
    host,
  };
  if (port) server.port = parseInt(port);
  return server;
};

const withServerDefaults = (server) => {
  if (!Number.isInteger(server.port)) delete server.port;
  return {
    port: 43,
    query: "$addr\r\n",
    ...server,
  };
};

const parseProxy = (proxy) => {
  if (typeof proxy !== "string") return proxy;
  const [host, port] = proxy.split(":");
  return {
    host: host,
    port: parseInt(port),
  };
};

const withProxyDefaults = (proxy) => {
  return {
    type: 5,
    ...proxy,
  };
};

const extractReferralServer = (data, currentServer) => {
  const match = data
    .replace(/\r/gm, "")
    .match(
      /(ReferralServer|Registrar Whois|Whois Server|WHOIS Server|Registrar WHOIS Server|refer):[^\S\n]*((?:r?whois|https?):\/\/)?([0-9A-Za-z\.\-_]*(:\d+)?)/,
    );
  if (!match) return null;
  const value = (match[3] || "")
    .replace(/^[:\s]+/, "")
    .replace(/^https?[:\/]+/, "");
  if (value === currentServer?.host) return null;
  return parseServer(value);
};

const makeSocket = (server, proxy, options, done) => {
  if (proxy) {
    return SocksClient.createConnection(
      {
        proxy,
        destination: {
          host: server.host,
          port: server.port,
        },
        command: "connect",
        timeout: options.timeout,
      },
      (err, { socket }) => {
        if (err !== null) {
          done(err);
          return;
        }
        if (options.timeout) socket.setTimeout(options.timeout);
        done(null, socket);
        socket.resume();
      },
    );
    return;
  }

  const sockOpts = {
    host: server.host,
    port: server.port,
  };
  if (options.bind) sockOpts.localAddress = options.bind;
  const socket = net.connect(sockOpts);
  if (options.timeout) socket.setTimeout(options.timeout);
  done(null, socket);
};

export const exportedForTesting = {
  extractReferralServer,
};
