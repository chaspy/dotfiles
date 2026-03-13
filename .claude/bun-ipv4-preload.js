// IPv4 強制パッチ for Claude Code + VPN (AnyConnect/Netskope)
//
// Bun の Happy Eyeball 実装が VPN 環境で IPv6 接続を試行してタイムアウトする問題の回避策。
// BUN_OPTIONS="--preload=$HOME/.claude/bun-ipv4-preload.js" として使用する。
//
// 参考:
// - https://github.com/oven-sh/bun/issues/25619
// - https://github.com/oven-sh/bun/pull/26012

import https from "node:https";
import dns from "node:dns";
import net from "node:net";
import dnsPromises from "node:dns/promises";

const originalHttpsRequest = https.request;
const logEnabled = !!process.env.DEBUG_IPV4_PATCH;

function log(...args) {
  if (logEnabled) {
    console.log("[IPv4 Patch]", ...args);
  }
}

function normalizeLookupOptions(opts) {
  if (typeof opts === "number") {
    return { family: opts };
  }
  if (!opts || typeof opts !== "object") {
    return {};
  }
  return opts;
}

// Use the OS resolver so VPN-provided DNS behavior is preserved.
function lookupIPv4(hostname, opts, callback) {
  const options = normalizeLookupOptions(opts);
  dns.lookup(
    hostname,
    {
      ...options,
      family: 4,
      all: Boolean(options.all),
    },
    (err, address, family) => {
      if (err) {
        return callback(err);
      }
      if (options.all) {
        return callback(null, address);
      }
      return callback(null, address, family);
    },
  );
}

async function resolveIPv4(hostname) {
  const result = await dnsPromises.lookup(hostname, { family: 4 });
  return result.address;
}

// https.request を IPv4 強制に上書き
// @ts-ignore
https.request = function (...args) {
  log("Custom https.request called with:", args);

  let optionsIndex = -1;
  if (typeof args[0] === "object" && !(args[0] instanceof URL)) {
    optionsIndex = 0;
    log("Detected options in args[0]");
  } else if (typeof args[1] === "object") {
    optionsIndex = 1;
  }

  if (optionsIndex !== -1) {
    args[optionsIndex].lookup = lookupIPv4;
    const host = args[optionsIndex].hostname || args[optionsIndex].host;
    if (host) {
      args[optionsIndex].headers = {
        ...args[optionsIndex].headers,
        Host: host,
      };
    }
  } else if (typeof args[0] === "string" || args[0] instanceof URL) {
    args.splice(1, 0, { family: 4, lookup: lookupIPv4 });
  }

  log("Modified args for IPv4:", args);
  return originalHttpsRequest(...args);
};

// fetch を IPv4 強制に上書き
const originalFetch = globalThis.fetch;
globalThis.fetch = async (input, init) => {
  log("Custom fetch called with:", input);

  if (typeof input === "string" && !input.startsWith("http")) {
    return originalFetch(input, init);
  }

  const requestUrl =
    typeof input === "string"
      ? new URL(input)
      : input instanceof URL
        ? input
        : new URL(input.url);

  try {
    const ipv4 = await resolveIPv4(requestUrl.hostname);
    const fetchUrl = new URL(requestUrl);
    fetchUrl.hostname = ipv4;
    const headers = new Headers(init?.headers);
    headers.set("Host", requestUrl.host);
    return originalFetch(fetchUrl, { ...init, headers });
  } catch (e) {
    log("IPv4 resolve failed, falling back:", e);
  }

  return originalFetch(input, init);
};

// net.connect / net.createConnection を IPv4 強制に上書き
const originalConnect = net.connect;
const originalCreateConnection = net.createConnection;

function injectFamily4(args) {
  if (args.length === 0) return args;
  const arg0 = args[0];

  if (arg0 !== null && typeof arg0 === "object") {
    arg0.family = 4;
    return args;
  }

  const port = Number(arg0);
  if (!Number.isNaN(port)) {
    const options = { port: port, family: 4 };
    let callback;
    if (typeof args[1] === "string") {
      options.host = args[1];
      callback = args[2];
    } else if (typeof args[1] === "function") {
      callback = args[1];
    }
    const newArgs = [options];
    if (callback) newArgs.push(callback);
    return newArgs;
  }

  return args;
}

net.connect = function (...args) {
  return originalConnect.apply(this, injectFamily4(args));
};

net.createConnection = function (...args) {
  log("Custom net.createConnection called with:", args);
  return originalCreateConnection.apply(this, injectFamily4(args));
};
