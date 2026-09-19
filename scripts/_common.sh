#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -f "${ROOT_DIR}/.env" ]]; then
  # shellcheck disable=SC1091
  set -a
  source "${ROOT_DIR}/.env"
  set +a
fi

APIGEE_BASE_URL="${APIGEE_BASE_URL:-https://apigee.googleapis.com/v1}"
SHAREDFLOW="${SHAREDFLOW:-global-gateway-governance}"
KVM_NAME="${KVM_NAME:-GLOBAL_GATEWAY_GOVERNANCE}"

require_var() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    echo "ERROR: required environment variable '$name' is not set." >&2
    exit 2
  fi
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "ERROR: required command '$1' was not found." >&2
    exit 2
  }
}

token() {
  require_cmd gcloud
  gcloud auth print-access-token
}

api() {
  local method="$1"
  local url="$2"
  shift 2
  curl --fail-with-body --silent --show-error \
    -X "${method}" \
    -H "Authorization: Bearer $(token)" \
    "$@" \
    "${url}"
}
