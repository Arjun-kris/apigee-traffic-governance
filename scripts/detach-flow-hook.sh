#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_common.sh
source "${SCRIPT_DIR}/_common.sh"

require_var ORG
require_var ENV

URL="${APIGEE_BASE_URL}/organizations/${ORG}/environments/${ENV}/flowhooks/PreProxyFlowHook"

if [[ "${YES:-false}" != "true" ]]; then
  read -r -p "Type DETACH to remove the PreProxy Flow Hook: " CONFIRM
  [[ "${CONFIRM}" == "DETACH" ]] || { echo "Cancelled."; exit 1; }
fi

api DELETE "${URL}"
echo
echo "Detached PreProxyFlowHook in ${ORG}/${ENV}."
