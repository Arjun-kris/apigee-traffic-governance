#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=_common.sh
source "${SCRIPT_DIR}/_common.sh"

require_var ORG
require_var ENV

REVISION="${REVISION:-}"
if [[ -z "${REVISION}" && -f "${ROOT_DIR}/dist/revision.txt" ]]; then
  REVISION="$(tr -d '[:space:]' < "${ROOT_DIR}/dist/revision.txt")"
fi

if [[ -z "${REVISION}" ]]; then
  echo "ERROR: set REVISION or run scripts/import-sharedflow.sh first." >&2
  exit 2
fi

URL="${APIGEE_BASE_URL}/organizations/${ORG}/environments/${ENV}/sharedflows/${SHAREDFLOW}/revisions/${REVISION}/deployments?override=true"
api POST "${URL}"
echo
echo "Deployed ${SHAREDFLOW} revision ${REVISION} to ${ORG}/${ENV}."
