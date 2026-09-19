#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=_common.sh
source "${SCRIPT_DIR}/_common.sh"

require_var ORG
require_var ENV

CONFIG_FILE="${CONFIG_FILE:-${ROOT_DIR}/config/governance-config.example.json}"
if [[ ! -f "${CONFIG_FILE}" ]]; then
  echo "ERROR: config file not found: ${CONFIG_FILE}" >&2
  exit 2
fi

python3 "${ROOT_DIR}/tools/validate_config.py" "${CONFIG_FILE}"

TMP_FILE="$(mktemp)"
trap 'rm -f "${TMP_FILE}"' EXIT

python3 - "${CONFIG_FILE}" > "${TMP_FILE}" <<'PY'
import json, sys
path = sys.argv[1]
with open(path, "r", encoding="utf-8") as fh:
    config_text = fh.read()
print(json.dumps({"name": "config", "value": config_text}))
PY

BASE="${APIGEE_BASE_URL}/organizations/${ORG}/environments/${ENV}/keyvaluemaps/${KVM_NAME}/entries"
if api GET "${BASE}/config" >/dev/null 2>&1; then
  api PUT "${BASE}/config" \
    -H "Content-Type: application/json" \
    --data-binary @"${TMP_FILE}"
  echo
  echo "Updated KVM entry '${KVM_NAME}/config'."
else
  api POST "${BASE}" \
    -H "Content-Type: application/json" \
    --data-binary @"${TMP_FILE}"
  echo
  echo "Created KVM entry '${KVM_NAME}/config'."
fi
