# Azure Policy + OPA/Rego Governance

[![Policy CI](https://github.com/ugochuk/azure-policy-opa-governance/actions/workflows/policy-ci.yml/badge.svg)](https://github.com/ugochuk/azure-policy-opa-governance/actions/workflows/policy-ci.yml)

Policy-as-Code portfolio project demonstrating how Azure Policy and Open Policy Agent (OPA/Rego) can be used together to enforce cloud governance before and after infrastructure deployment.

## What this project demonstrates

- OPA/Rego policy development and unit testing
- Terraform plan JSON evaluation before deployment
- Azure Policy definition validation
- Preventive and runtime cloud governance
- Security requirements for tags, storage, Key Vault, and network exposure
- Deterministic compliant/noncompliant plan fixtures for CI testing
- Separation of platform policy from workload code

## Governance model

```mermaid
flowchart LR
    DEV[Terraform Change] --> PLAN[Terraform Plan JSON]
    PLAN --> OPA[OPA / Rego]
    OPA -->|Pass| MERGE[Merge / Deploy]
    OPA -->|Deny| FAIL[CI Failure]
    MERGE --> AZURE[Azure Resources]
    AZURE --> AP[Azure Policy]
    AP --> COMPLY[Compliance State]
```

OPA provides a pre-deployment policy gate against Terraform plan JSON. Azure Policy provides Azure-native enforcement and compliance at the platform boundary.

## Repository structure

```text
.
├── .github/workflows/policy-ci.yml
├── azure-policy/
│   └── require-environment-tag.json
├── examples/
│   ├── compliant/
│   ├── noncompliant/
│   ├── compliant-plan.json
│   └── noncompliant-plan.json
├── policies/
│   ├── keyvault_security.rego
│   ├── network_security.rego
│   ├── require_environment_tag.rego
│   └── storage_security.rego
├── tests/
│   └── storage_security_test.rego
├── scripts/evaluate-plan.sh
└── docs/governance-model.md
```

## Implemented controls

The Rego package evaluates planned resource changes and can deny:

- Resources missing the `Environment` tag
- Storage Accounts that do not enforce TLS 1.2
- Storage Accounts allowing anonymous public blob access
- Storage Accounts exposing public network access
- Key Vaults with public network access enabled
- Key Vaults not using Azure RBAC authorization
- Key Vaults without purge protection
- NSG rules exposing SSH or RDP from any source

The included custom Azure Policy definition requires the `Environment` tag with a deny effect.

## CI strategy

CI intentionally uses deterministic Terraform-plan-shaped JSON fixtures for OPA evaluation so policy tests do not require Azure credentials. Terraform syntax for the compliant example is separately initialized and validated. In a real delivery pipeline, the same Rego package would evaluate the JSON produced by an authenticated `terraform plan` stage.

## Local testing

```bash
opa test policies tests -v

opa eval \
  --data policies \
  --input examples/noncompliant-plan.json \
  'data.azure.governance.deny'
```

For a real Terraform plan:

```bash
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json
opa eval --data policies --input tfplan.json 'data.azure.governance.deny'
```

## Why combine OPA and Azure Policy?

OPA catches violations before deployment and provides fast developer feedback. Azure Policy protects Azure even when resources are created through a different deployment path. Together they provide defense in depth: shift-left prevention plus platform-level enforcement.

## Portfolio note

This is an original portfolio implementation and contains no proprietary employer policy code, tenant IDs, subscription IDs, customer data, or internal standards.
