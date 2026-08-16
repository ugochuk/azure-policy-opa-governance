#!/usr/bin/env bash
set -euo pipefail

PLAN_FILE="${1:-tfplan}"
PLAN_JSON="${2:-tfplan.json}"

if ! command -v terraform >/dev/null 2>&1; then
  echo "terraform is required"
  exit 1
fi

if ! command -v opa >/dev/null 2>&1; then
  echo "opa is required"
  exit 1
fi

terraform show -json "${PLAN_FILE}" > "${PLAN_JSON}"

echo "Evaluating Terraform plan against OPA/Rego policies..."

violations=$(opa eval \
  --format=json \
  --data policies \
  --input "${PLAN_JSON}" \
  'data.azure.governance.deny' | jq -r '.result[0].expressions[0].value[]?')

if [[ -n "${violations}" ]]; then
  echo "Policy violations detected:"
  echo "${violations}"
  exit 1
fi

echo "Policy evaluation passed."
