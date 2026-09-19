#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=_common.sh
source "${SCRIPT_DIR}/_common.sh"

require_var ORG
require_cmd zip

"${SCRIPT_DIR}/validate.sh"
"${SCRIPT_DIR}/package-sharedflow.sh"

ZIP_FILE="${ROOT_DIR}/dist/global-gateway-governance.zip"
URL="${APIGEE_BASE_URL}/organizations/${ORG}/sharedflows?action=import&name=${SHAREDFLOW}"

RESPONSE="$(curl --fail-with-body --silent --show-error \
  -X POST \
  -H "Authorization: Bearer $(token)" \
  -F "file=@${ZIP_FILE}" \
  "${URL}")"

echo "${RESPONSE}"
REVISION="$(python3 -c 'import json,sys; print(json.load(sys.stdin).get("revision",""))' <<< "${RESPONSE}")"

if [[ -z "${REVISION}" ]]; then
  echo "ERROR: import succeeded but no revision was found in the response." >&2
  exit 1
fi

echo
echo "Imported shared flow '${SHAREDFLOW}', revision ${REVISION}."
echo "${REVISION}" > "${ROOT_DIR}/dist/revision.txt"
