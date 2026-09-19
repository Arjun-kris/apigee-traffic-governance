#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=_common.sh
source "${SCRIPT_DIR}/_common.sh"

require_var ORG
require_var ENV

QUERY_FILE="${QUERY_FILE:-${ROOT_DIR}/config/analytics-query.json}"
if [[ ! -f "${QUERY_FILE}" ]]; then
  echo "ERROR: analytics query file not found: ${QUERY_FILE}" >&2
  exit 2
fi

api POST "${APIGEE_BASE_URL}/organizations/${ORG}/environments/${ENV}/queries" \
  -H "Content-Type: application/json" \
  --data-binary @"${QUERY_FILE}"
echo
