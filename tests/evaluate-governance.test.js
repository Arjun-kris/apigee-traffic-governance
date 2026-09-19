"use strict";

const fs = require("fs");
const vm = require("vm");
const path = require("path");
const assert = require("assert");

const source = fs.readFileSync(
  path.join(__dirname, "..", "sharedflowbundle", "resources", "jsc", "evaluate-governance.js"),
  "utf8"
);

function run({ proxy = "orders-api", config = null, rawOverride }) {
  const vars = {
    "apiproxy.name": proxy,
    "private.governance.config":
      rawOverride !== undefined
        ? rawOverride
        : config === null
          ? null
          : JSON.stringify(config)
  };

  const context = {
    getVariable(name) {
      return Object.prototype.hasOwnProperty.call(vars, name) ? vars[name] : null;
    },
    setVariable(name, value) {
      vars[name] = value;
    }
  };

  vm.runInNewContext(source, { context });
  return vars;
}

function expect(name, fn) {
  try {
    fn();
    console.log(`PASS ${name}`);
  } catch (err) {
    console.error(`FAIL ${name}`);
    throw err;
  }
}

expect("monitor never enforces", () => {
  const v = run({
    config: {
      mode: "monitor",
      throttleProxies: { "orders-api": "50ps" },
      bypassProxies: []
    }
  });
  assert.equal(v["governance.enforce"], "false");
  assert.equal(v["governance.decision"], "MONITOR");
});

expect("enforce targets explicit proxy", () => {
  const v = run({
    config: {
      mode: "enforce",
      throttleProxies: { "orders-api": "50ps" },
      bypassProxies: []
    }
  });
  assert.equal(v["governance.enforce"], "true");
  assert.equal(v["governance.rate"], "50ps");
  assert.equal(v["governance.decision"], "THROTTLE");
});

expect("unlisted proxy is monitor-only", () => {
  const v = run({
    proxy: "search-api",
    config: {
      mode: "enforce",
      throttleProxies: { "orders-api": "50ps" },
      bypassProxies: []
    }
  });
  assert.equal(v["governance.enforce"], "false");
  assert.equal(v["governance.decision"], "MONITOR");
});

expect("bypass wins over throttle mapping", () => {
  const v = run({
    config: {
      mode: "enforce",
      throttleProxies: { "orders-api": "50ps" },
      bypassProxies: ["orders-api"]
    }
  });
  assert.equal(v["governance.enforce"], "false");
  assert.equal(v["governance.decision"], "BYPASS");
});

expect("off disables enforcement", () => {
  const v = run({
    config: {
      mode: "off",
      throttleProxies: { "orders-api": "50ps" },
      bypassProxies: []
    }
  });
  assert.equal(v["governance.enforce"], "false");
  assert.equal(v["governance.decision"], "OFF");
});

expect("invalid JSON fails open to monitor", () => {
  const v = run({ rawOverride: "not-json" });
  assert.equal(v["governance.enforce"], "false");
  assert.equal(v["governance.decision"], "MONITOR");
  assert.equal(v["governance.config.valid"], "false");
});

expect("invalid rate fails open for that proxy", () => {
  const v = run({
    config: {
      mode: "enforce",
      throttleProxies: { "orders-api": "banana" },
      bypassProxies: []
    }
  });
  assert.equal(v["governance.enforce"], "false");
  assert.equal(v["governance.rate.valid"], "false");
});

console.log("All governance decision-engine tests passed.");
