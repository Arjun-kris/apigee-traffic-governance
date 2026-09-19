# Architecture

## Goal

Apply environment-level traffic governance to an existing Apigee estate without
editing every API proxy and without changing backend services.

```text
Clients
  |
  v
Apigee Environment
  |
  v
PreProxy Flow Hook
  |
  v
Global Gateway Governance Shared Flow
  |-- Read environment KVM
  |-- Resolve current apiproxy.name
  |-- Check bypass list
  |-- Resolve explicit per-proxy rate
  |-- Apply targeted SpikeArrest
  v
Existing API Proxy
  |
  v
Existing Backend
```

## Why Flow Hook + Shared Flow

A Flow Hook is the environment-level attachment point. The Shared Flow contains
the reusable governance policies. This means the proxies themselves do not need
FlowCallout policies added one by one.

Only one Shared Flow can be attached to a given Flow Hook in an environment, so
this repository assumes ownership of `PreProxyFlowHook`. If your organization
already uses that hook, merge governance into the existing hook Shared Flow or
have that Shared Flow call a governance Shared Flow.

## Control plane

The environment KVM `GLOBAL_GATEWAY_GOVERNANCE` contains one entry named
`config`. The value is JSON.

The KVM stores configuration only. It is **not** used as a runtime counter.

## Runtime modes

- `off`: no governance enforcement.
- `monitor`: evaluate the request but do not execute SpikeArrest.
- `enforce`: execute SpikeArrest only for proxies explicitly listed in
  `throttleProxies`.

A proxy in `bypassProxies` always bypasses this additional governance layer.

## Per-proxy rate isolation

The SpikeArrest policy uses:

```xml
<Identifier ref="governance.proxy"/>
```

`governance.proxy` is populated from `apiproxy.name`. This groups SpikeArrest
counting by API proxy rather than placing all traffic in one rate bucket.

## Failure strategy

The KVM read uses `continueOnError="true"`. The JavaScript decision engine
defaults to monitor-only if the KVM value is missing, malformed, uses an
unsupported mode, or contains an invalid rate.

This design intentionally fails open for the governance layer because a
PreProxy Flow Hook has environment-wide blast radius. Existing proxy security,
authentication, quotas, and validation continue to execute as before.

The SpikeArrest policy itself uses `continueOnError="false"` so an actual rate
violation produces the expected rate-limit failure.

## Billing boundary

This project governs and measures API traffic. It does not calculate an exact
cloud invoice. Use Apigee Analytics for request/TPS/error/latency data and
Google Cloud Billing/FinOps data for financial correlation.
