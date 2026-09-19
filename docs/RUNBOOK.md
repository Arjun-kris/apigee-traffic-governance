# Production Runbook

## Safe deployment sequence

1. Deploy to a non-production environment.
2. Keep KVM `mode` set to `monitor`.
3. Import and deploy the Shared Flow.
4. Confirm the environment's current Flow Hooks.
5. Confirm no other team already owns `PreProxyFlowHook`.
6. Attach the Shared Flow to the hook.
7. Exercise representative APIs.
8. Inspect Apigee Trace/Debug and Analytics.
9. Run monitor-only for an observation period.
10. Add one non-critical noisy proxy to `throttleProxies`.
11. Change mode to `enforce`.
12. Verify 429 behavior and downstream impact.
13. Expand gradually.

## Emergency actions

### Option A: disable enforcement

```bash
./scripts/set-mode.sh off config/governance-config.production.template.json
```

KVM reads are cached, so allow for the configured cache expiry.

### Option B: return to monitor-only

```bash
./scripts/set-mode.sh monitor config/governance-config.production.template.json
```

### Option C: detach the Flow Hook

```bash
./scripts/detach-flow-hook.sh
```

Detaching removes this Shared Flow from the environment-level request path.

## Adding a throttled proxy

Edit the environment's config file:

```json
{
  "mode": "monitor",
  "throttleProxies": {
    "orders-api": "200ps"
  },
  "bypassProxies": []
}
```

Validate and upload:

```bash
python3 tools/validate_config.py config/my-env.json
CONFIG_FILE=config/my-env.json ./scripts/put-kvm-config.sh
```

Keep monitor mode first, observe traffic, then switch to enforce.

## Bypassing a critical proxy

Add the exact `apiproxy.name` to `bypassProxies` and upload the config.

If a proxy exists in both `throttleProxies` and `bypassProxies`, bypass wins.

## Rate changes

Valid examples:

```text
50ps
200ps
3000pm
```

Rates must be positive integers followed by `ps` or `pm`.

## Change management checklist

Before production changes, record:

- organization and environment
- Shared Flow revision
- previous KVM configuration
- new KVM configuration
- affected proxy names
- intended rate
- owner/approver
- change window
- rollback decision point
- Analytics baseline

## Observability

Track at least:

- message count by API proxy
- average/peak request rate
- response status codes, especially 429
- API and target latency
- 4xx/5xx rates
- top traffic-generating proxies
- before/after traffic volume

For large time ranges use asynchronous Analytics report jobs rather than an
interactive query.

## Existing proxy behavior

This project does not replace existing proxy-specific security, quota,
validation, or SpikeArrest policies. The environment-level layer should be
treated as an additional platform-governance control.
