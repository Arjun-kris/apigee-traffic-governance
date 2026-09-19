#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_common.sh
source "${SCRIPT_DIR}/_common.sh"

require_var TEST_URL

COUNT="${COUNT:-10}"
DELAY="${DELAY:-0.2}"

echo "Sending ${COUNT} requests to ${TEST_URL}"
for ((i=1; i<=COUNT; i++)); do
  code="$(curl -sS -o /dev/null -w '%{http_code}' "${TEST_URL}")"
  printf '%03d  HTTP %s\n' "${i}" "${code}"
  sleep "${DELAY}"
done
