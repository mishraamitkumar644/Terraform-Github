# OPA Policy Directory

## Structure
| File | Covers | Rules |
|------|--------|-------|
| `azure_storage.rego` | `azurerm_storage_account` | D1-D6 (deny), W1-W3 (warn) |
| `azure_resource_group.rego` | `azurerm_resource_group` | D7-D8 (deny) |

## How It Works
All policies share `package terraform`.

- **`deny[]`** — pipeline hard-fails. Fix before merge.
- **`warn[]`** — logged in GitHub Step Summary, non-blocking.

OPA evaluates against `tfplan.json` (output of `terraform show -json tfplan`).

## Testing OPA Locally
```bash
# Install OPA
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64
chmod +x opa && sudo mv opa /usr/local/bin/

# Generate plan JSON
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json

# Evaluate deny rules
opa eval --data policies --input tfplan.json --format raw 'data.terraform.deny'

# Evaluate warn rules
opa eval --data policies --input tfplan.json --format raw 'data.terraform.warn'
```
