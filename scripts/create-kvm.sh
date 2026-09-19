#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_common.sh
source "${SCRIPT_DIR}/_common.sh"

require_var ORG
require_var ENV

URL="${APIGEE_BASE_URL}/organizations/${ORG}/environments/${ENV}/keyvaluemaps"

if api GET "${URL}/${KVM_NAME}" >/dev/null 2>&1; then
  echo "KVM '${KVM_NAME}' already exists in ${ORG}/${ENV}; nothing to do."
  exit 0
fi

api POST "${URL}" \
  -H "Content-Type: application/json" \
  --data "{\"name\":\"${KVM_NAME}\",\"encrypted\":true,\"maskedValues\":true}"

echo
echo "Created KVM '${KVM_NAME}' in ${ORG}/${ENV}."
