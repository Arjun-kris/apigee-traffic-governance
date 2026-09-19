#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cat <<'EOF'
Bootstrap sequence:
  1. Validate project.
  2. Create environment KVM if missing.
  3. Upload monitor-mode KVM configuration.
  4. Import shared-flow revision.
  5. Deploy shared-flow revision.

The Flow Hook is NOT attached automatically because attaching it affects every
proxy in the environment. Run scripts/attach-flow-hook.sh separately after
testing the deployed shared flow and reviewing the runbook.
EOF

"${SCRIPT_DIR}/validate.sh"
"${SCRIPT_DIR}/create-kvm.sh"
"${SCRIPT_DIR}/put-kvm-config.sh"
"${SCRIPT_DIR}/import-sharedflow.sh"
"${SCRIPT_DIR}/deploy-sharedflow.sh"

echo
echo "Bootstrap complete. Review docs/RUNBOOK.md before attaching the Flow Hook."
