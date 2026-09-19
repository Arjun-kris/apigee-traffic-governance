/*
 * Global Gateway Governance decision engine.
 *
 * Fail-safe behavior:
 *   - Missing/invalid KVM JSON -> monitor only.
 *   - Unsupported mode         -> monitor only.
 *   - Invalid proxy rate       -> monitor only for that proxy.
 *   - Only proxies explicitly present in throttleProxies are enforced.
 *
 * Supported modes:
 *   off      : governance logic is effectively disabled.
 *   monitor  : calculate decisions, do not throttle.
 *   enforce  : throttle only explicitly configured proxies.
 */

(function () {
  "use strict";

  var RATE_RE = /^[1-9][0-9]*(ps|pm)$/;
  var VALID_MODES = { off: true, monitor: true, enforce: true };

  function asString(value, fallback) {
    if (value === null || value === undefined || value === "") {
      return fallback;
    }
    return String(value);
  }

  function safeArray(value) {
    return Object.prototype.toString.call(value) === "[object Array]" ? value : [];
  }

  function safeObject(value) {
    return value && typeof value === "object" &&
      Object.prototype.toString.call(value) !== "[object Array]" ? value : {};
  }

  var raw = context.getVariable("private.governance.config");
  var cfg = {};
  var configValid = true;
  var configError = "";

  try {
    if (raw) {
      cfg = JSON.parse(String(raw));
    } else {
      configValid = false;
      configError = "KVM_CONFIG_MISSING";
    }
  } catch (e) {
    cfg = {};
    configValid = false;
    configError = "KVM_CONFIG_INVALID_JSON";
  }

  cfg = safeObject(cfg);

  var mode = asString(cfg.mode, "monitor").toLowerCase();
  if (!VALID_MODES[mode]) {
    mode = "monitor";
    configValid = false;
    configError = "UNSUPPORTED_MODE";
  }

  var proxy = asString(context.getVariable("apiproxy.name"), "");
  var bypassList = safeArray(cfg.bypassProxies);
  var throttleMap = safeObject(cfg.throttleProxies);

  var bypass = bypassList.indexOf(proxy) !== -1;
  var configuredRate = throttleMap[proxy];
  var targeted = configuredRate !== null && configuredRate !== undefined;
  var rate = targeted ? String(configuredRate) : "";
  var rateValid = !targeted || RATE_RE.test(rate);

  if (targeted && !rateValid) {
    configValid = false;
    configError = "INVALID_RATE_FOR_PROXY";
  }

  var enforce =
    mode === "enforce" &&
    !bypass &&
    targeted &&
    rateValid &&
    proxy !== "";

  var decision;
  if (mode === "off") {
    decision = "OFF";
  } else if (bypass) {
    decision = "BYPASS";
  } else if (enforce) {
    decision = "THROTTLE";
  } else {
    decision = "MONITOR";
  }

  context.setVariable("governance.mode", mode);
  context.setVariable("governance.proxy", proxy);
  context.setVariable("governance.bypass", bypass ? "true" : "false");
  context.setVariable("governance.targeted", targeted ? "true" : "false");
  context.setVariable("governance.rate", rate);
  context.setVariable("governance.rate.valid", rateValid ? "true" : "false");
  context.setVariable("governance.enforce", enforce ? "true" : "false");
  context.setVariable("governance.decision", decision);
  context.setVariable("governance.config.valid", configValid ? "true" : "false");
  context.setVariable("governance.config.error", configError);
}());
