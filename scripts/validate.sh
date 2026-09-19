#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python3 "${ROOT_DIR}/tools/validate_project.py"

for f in "${ROOT_DIR}"/scripts/*.sh; do
  bash -n "$f"
done

if command -v node >/dev/null 2>&1; then
  node "${ROOT_DIR}/tests/evaluate-governance.test.js"
else
  echo "WARN: node not found; JavaScript unit tests skipped."
fi

echo "Validation complete."
