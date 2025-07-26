declare module "whois" {
  interface WhoisOptions {
    server?: string | { host: string; port: number };
    follow?: number;
    timeout?: number;
    verbose?: boolean;
    bind?: string;
    proxy?: {
      ipaddress: string;
      port: number;
      type?: number;
    };
    punycode?: boolean;
    encoding?: string;
  }

  interface WhoisResult {
    server: string;
    data: string;
  }

  type WhoisCallback = (
    err: Error | null,
    data: string | WhoisResult[],
  ) => void;

  function lookup(addr: string, callback: WhoisCallback): void;
  function lookup(
    addr: string,
    options: WhoisOptions,
    callback: WhoisCallback,
  ): void;
}
