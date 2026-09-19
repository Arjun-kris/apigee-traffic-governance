#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

MODE="${1:-}"
CONFIG_FILE="${2:-${CONFIG_FILE:-${ROOT_DIR}/config/governance-config.example.json}}"

case "${MODE}" in
  off|monitor|enforce) ;;
  *)
    echo "Usage: $0 {off|monitor|enforce} [config-file]" >&2
    exit 2
    ;;
esac

python3 - "${CONFIG_FILE}" "${MODE}" <<'PY'
import json, sys
path, mode = sys.argv[1], sys.argv[2]
with open(path, "r", encoding="utf-8") as fh:
    data = json.load(fh)
data["mode"] = mode
with open(path, "w", encoding="utf-8") as fh:
    json.dump(data, fh, indent=2)
    fh.write("\n")
print(f"Updated {path}: mode={mode}")
PY

CONFIG_FILE="${CONFIG_FILE}" "${SCRIPT_DIR}/put-kvm-config.sh"
