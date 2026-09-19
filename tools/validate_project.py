#!/usr/bin/env python3
import json
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BUNDLE = ROOT / "sharedflowbundle"

def fail(message):
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)

def main():
    xml_files = sorted(BUNDLE.rglob("*.xml"))
    if not xml_files:
        fail("no XML files found")

    for path in xml_files:
        try:
            ET.parse(path)
        except Exception as exc:
            fail(f"invalid XML: {path.relative_to(ROOT)}: {exc}")

    descriptor = BUNDLE / "global-gateway-governance.xml"
    if not descriptor.exists():
        fail("shared flow bundle descriptor is missing")

    tree = ET.parse(descriptor)
    root = tree.getroot()
    if root.tag != "SharedFlowBundle":
        fail("bundle descriptor root must be SharedFlowBundle")

    policy_names = {
        p.stem for p in (BUNDLE / "policies").glob("*.xml")
    }
    declared_policies = {
        el.text.strip() for el in root.findall("./Policies/Policy") if el.text
    }
    if policy_names != declared_policies:
        fail(
            "policy manifest mismatch. "
            f"files={sorted(policy_names)}, manifest={sorted(declared_policies)}"
        )

    flow_path = BUNDLE / "sharedflows" / "default.xml"
    flow = ET.parse(flow_path).getroot()
    step_names = {
        el.text.strip() for el in flow.findall("./Step/Name") if el.text
    }
    missing = step_names - policy_names
    if missing:
        fail(f"shared flow references missing policies: {sorted(missing)}")

    js = BUNDLE / "resources" / "jsc" / "evaluate-governance.js"
    if not js.exists():
        fail("JavaScript resource is missing")

    for cfg in sorted((ROOT / "config").glob("governance-config*.json")):
        data = json.loads(cfg.read_text(encoding="utf-8"))
        if data.get("mode") not in {"off", "monitor", "enforce"}:
            fail(f"{cfg.name}: invalid mode")

    print(f"Project XML OK ({len(xml_files)} files)")
    print("Bundle manifest OK")
    print("Shared-flow policy references OK")
    print("Project validation OK")

if __name__ == "__main__":
    main()
