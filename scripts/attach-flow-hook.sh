#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_common.sh
source "${SCRIPT_DIR}/_common.sh"

require_var ORG
require_var ENV

URL="${APIGEE_BASE_URL}/organizations/${ORG}/environments/${ENV}/flowhooks/PreProxyFlowHook"

cat <<EOF
About to attach '${SHAREDFLOW}' to PreProxyFlowHook in ${ORG}/${ENV}.
This affects EVERY API proxy deployed to that environment.
EOF

if [[ "${YES:-false}" != "true" ]]; then
  read -r -p "Type ATTACH to continue: " CONFIRM
  [[ "${CONFIRM}" == "ATTACH" ]] || { echo "Cancelled."; exit 1; }
fi

api PUT "${URL}" \
  -H "Content-Type: application/json" \
  --data "{\"sharedFlow\":\"${SHAREDFLOW}\",\"continueOnError\":true,\"description\":\"Global traffic governance at PreProxy\"}"

echo
echo "Attached ${SHAREDFLOW} to PreProxyFlowHook."
