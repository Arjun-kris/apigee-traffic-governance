#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_common.sh
source "${SCRIPT_DIR}/_common.sh"

require_var ORG
require_var ENV

api GET "${APIGEE_BASE_URL}/organizations/${ORG}/environments/${ENV}/sharedflows/${SHAREDFLOW}/deployments"
echo
