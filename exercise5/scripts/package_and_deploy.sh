#!/usr/bin/env bash
set -euo pipefail

# Helper script to create (if needed) an S3 bucket for CloudFormation artifacts,
# package nested templates, and deploy the stack.
#
# Usage:
#   ./scripts/package_and_deploy.sh \
#     --region us-east-1 \
#     --bucket exercise5-cfn-artifacts \
#     --stack exercise5 \
#     --parameters parameters/stack-params.json

print_usage() {
  cat <<USAGE
Usage: $0 --region REGION --bucket BUCKET_NAME --stack STACK_NAME [--parameters PARAM_FILE] [--capabilities CAP_1,CAP_2]

Required:
  --region        AWS region for the stack.
  --bucket        S3 bucket for CloudFormation artifacts.
  --stack         CloudFormation stack name.

Optional:
  --parameters    JSON file with ParameterKey/ParameterValue objects (default: parameters/stack-params.json).
  --capabilities  Comma-separated list passed to --capabilities (default: CAPABILITY_NAMED_IAM).
  --force-bucket  Skip bucket existence check and attempt creation even if it already exists.

USAGE
}

REGION=""
BUCKET=""
STACK=""
PARAM_FILE="parameters/stack-params.json"
CAPABILITIES="CAPABILITY_NAMED_IAM"
FORCE_BUCKET=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --region)
      REGION="$2"
      shift 2
      ;;
    --bucket)
      BUCKET="$2"
      shift 2
      ;;
    --stack)
      STACK="$2"
      shift 2
      ;;
    --parameters)
      PARAM_FILE="$2"
      shift 2
      ;;
    --capabilities)
      CAPABILITIES="$2"
      shift 2
      ;;
    --force-bucket)
      FORCE_BUCKET=true
      shift
      ;;
    --help|-h)
      print_usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      print_usage
      exit 1
      ;;
  esac
done

if [[ -z "$REGION" || -z "$BUCKET" || -z "$STACK" ]]; then
  echo "Missing required arguments." >&2
  print_usage
  exit 1
fi

if [[ ! -f "$PARAM_FILE" ]]; then
  echo "Parameter file not found: $PARAM_FILE" >&2
  exit 1
fi

bucket_exists() {
  aws s3api head-bucket --bucket "$BUCKET" >/dev/null 2>&1
}

ensure_bucket() {
  if bucket_exists && ! $FORCE_BUCKET; then
    echo "Bucket ${BUCKET} already exists. Skipping creation."
    return
  fi

  echo "Creating bucket ${BUCKET} in region ${REGION}..."
  if [[ "$REGION" == "us-east-1" ]]; then
    aws s3api create-bucket \
      --bucket "$BUCKET" \
      >/dev/null
  else
    aws s3api create-bucket \
      --bucket "$BUCKET" \
      --create-bucket-configuration LocationConstraint="$REGION" \
      >/dev/null
  fi
  aws s3api put-bucket-versioning \
    --bucket "$BUCKET" \
    --versioning-configuration Status=Enabled \
    >/dev/null
}

PACKAGE_DIR="$(dirname "$0")/../build"
mkdir -p "$PACKAGE_DIR"

ensure_bucket

echo "Packaging CloudFormation templates..."
aws cloudformation package \
  --region "$REGION" \
  --template-file "$(dirname "$0")/../templates/main.yaml" \
  --s3-bucket "$BUCKET" \
  --output-template-file "$PACKAGE_DIR/main.packaged.yaml"

PARAM_OVERRIDES=$(jq -r '.[] | "\(.ParameterKey)=\(.ParameterValue)"' "$PARAM_FILE")

echo "Deploying stack ${STACK}..."
aws cloudformation deploy \
  --region "$REGION" \
  --stack-name "$STACK" \
  --template-file "$PACKAGE_DIR/main.packaged.yaml" \
  --parameter-overrides $PARAM_OVERRIDES \
  --capabilities "$CAPABILITIES"

echo "Stack deployment triggered. Check CloudFormation console for status."
