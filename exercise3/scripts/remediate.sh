#!/usr/bin/env bash
set -euo pipefail

DEFAULT_STACK_NAME=exercise3

usage() {
  cat <<USAGE
Usage: $0 [stack-name]
  stack-name Optional CloudFormation stack name (default: $DEFAULT_STACK_NAME)
USAGE
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  usage
  exit 0
fi

STACK_NAME=${1:-$DEFAULT_STACK_NAME}
ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

echo "Checking current stack status for $STACK_NAME..."
STACK_STATUS=$(aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --query "Stacks[0].StackStatus" \
  --output text 2>/dev/null || true)

if [[ -z "$STACK_STATUS" ]]; then
  echo "ERROR: Stack '$STACK_NAME' was not found." >&2
  exit 1
fi

case "$STACK_STATUS" in
  CREATE_COMPLETE|UPDATE_COMPLETE|UPDATE_ROLLBACK_COMPLETE|UPDATE_COMPLETE_CLEANUP_IN_PROGRESS)
    ;;
  *)
    echo "ERROR: Stack '$STACK_NAME' is in status '$STACK_STATUS'. Remediation requires a completed stack." >&2
    echo "Delete or fix the stack before rerunning this script." >&2
    exit 1
    ;;
esac

echo "Reapplying CloudFormation template to remediate drift..."
aws cloudformation deploy \
  --stack-name "$STACK_NAME" \
  --template-file "$ROOT_DIR/template.yaml" \
  --capabilities CAPABILITY_NAMED_IAM \
  --no-fail-on-empty-changeset

echo "Remediation applied. Consider running detect_drift.sh to confirm the stack is back in sync."
