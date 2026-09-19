# Troubleshooting

## Shared Flow import fails

Run:

```bash
./scripts/validate.sh
./scripts/package-sharedflow.sh
unzip -l dist/global-gateway-governance.zip
```

The ZIP must contain a top-level `sharedflowbundle/` directory.

## Shared Flow is imported but does not execute

Check that:

1. the imported revision is deployed to the same environment,
2. the Shared Flow is attached to `PreProxyFlowHook`,
3. the request reaches a proxy deployed in that environment.

```bash
./scripts/list-sharedflow-deployments.sh
./scripts/get-flow-hooks.sh
```

## Governance variables show MONITOR in enforce mode

Confirm:

- `mode` is exactly `enforce`,
- the current `apiproxy.name` exists in `throttleProxies`,
- its rate matches `^[1-9][0-9]*(ps|pm)$`,
- it is not listed in `bypassProxies`,
- enough time has passed for the KVM cache to refresh.

## Unexpected 429 responses

First set mode to `monitor` or `off`. Then inspect:

- proxy name,
- configured rate,
- traffic burst pattern,
- whether another existing proxy-level SpikeArrest or Quota also applies.

Remember that this repository adds a platform-level control; existing proxy
traffic policies remain active.

## KVM changes are not immediate

`KVM-Get-Governance-Config.xml` uses a 60-second cache expiry. This reduces
runtime KVM reads. Tune it only after understanding the latency/control-plane
tradeoff.

## Flow Hook attach is rejected

Attaching a Flow Hook requires appropriate Apigee IAM permissions and is an
organization-administrator class operation. Also check whether the hook already
has another Shared Flow attached.

## Analytics query is unavailable

Analytics functionality depends on your Apigee entitlement/environment. For
Pay-as-you-go, API Analytics can require an add-on. Use the console's built-in
Analytics pages if the Queries API is not available to your role or plan.
