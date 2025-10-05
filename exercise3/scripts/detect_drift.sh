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

DETECTION_ID=$(aws cloudformation detect-stack-drift \
  --stack-name "$STACK_NAME" \
  --query StackDriftDetectionId \
  --output text)

echo "Started drift detection for stack $STACK_NAME (id: $DETECTION_ID)"

while true; do
  STATUS=$(aws cloudformation describe-stack-drift-detection-status \
    --stack-drift-detection-id "$DETECTION_ID" \
    --query DetectionStatus \
    --output text)

  if [[ "$STATUS" == "DETECTION_IN_PROGRESS" ]]; then
    echo "Drift detection still running..."
    sleep 5
    continue
  fi

  FINAL_STATUS=$(aws cloudformation describe-stack-drift-detection-status \
    --stack-drift-detection-id "$DETECTION_ID" \
    --query StackDriftStatus \
    --output text)
  echo "Detection finished ($STATUS). Overall drift status: $FINAL_STATUS"

  if [[ "$STATUS" == "DETECTION_FAILED" ]]; then
    REASON=$(aws cloudformation describe-stack-drift-detection-status \
      --stack-drift-detection-id "$DETECTION_ID" \
      --query DetectionStatusReason \
      --output text)
    echo "Failure reason: $REASON" >&2
    exit 2
  fi
  break
done

echo
aws cloudformation describe-stack-resource-drifts \
  --stack-name "$STACK_NAME" \
  --stack-resource-drift-status-filters MODIFIED DELETED NOT_CHECKED \
  --output yaml
