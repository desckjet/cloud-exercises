#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0
  Configure optional environment variables before running:
    STACK_NAME         CloudFormation stack name (default: exercise3)
USAGE
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -gt 0 ]]; then
  usage
  exit 1
fi

STACK_NAME=${STACK_NAME:-exercise3}

# Obtain the absolute path to the script's parent directory
ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

aws cloudformation deploy \
  --stack-name "$STACK_NAME" \
  --template-file "$ROOT_DIR/template.yaml" \
  --capabilities CAPABILITY_NAMED_IAM
