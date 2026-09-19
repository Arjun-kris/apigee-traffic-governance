#!/usr/bin/env python3
import json
import re
import sys
from pathlib import Path

RATE_RE = re.compile(r"^[1-9][0-9]*(ps|pm)$")
VALID_MODES = {"off", "monitor", "enforce"}

def fail(message):
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)

def main():
    if len(sys.argv) != 2:
        fail("usage: validate_config.py <config.json>")

    path = Path(sys.argv[1])
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:
        fail(f"{path}: invalid JSON: {exc}")

    if not isinstance(data, dict):
        fail("root config must be an object")

    mode = data.get("mode", "monitor")
    if mode not in VALID_MODES:
        fail(f"mode must be one of {sorted(VALID_MODES)}")

    throttle = data.get("throttleProxies", {})
    if not isinstance(throttle, dict):
        fail("throttleProxies must be an object")

    for proxy, rate in throttle.items():
        if not isinstance(proxy, str) or not proxy.strip():
            fail("throttleProxies keys must be non-empty proxy names")
        if not isinstance(rate, str) or not RATE_RE.match(rate):
            fail(f"invalid rate for {proxy!r}: {rate!r}; expected e.g. 100ps or 500pm")

    bypass = data.get("bypassProxies", [])
    if not isinstance(bypass, list) or any(not isinstance(v, str) or not v for v in bypass):
        fail("bypassProxies must be an array of non-empty strings")

    overlap = sorted(set(throttle).intersection(bypass))
    if overlap:
        print(
            "WARN: proxy appears in both throttleProxies and bypassProxies; "
            f"bypass wins: {', '.join(overlap)}"
        )

    print(f"Config OK: {path}")

if __name__ == "__main__":
    main()
