# ============================================================
# policies/azure_resource_group.rego
# OPA policy for Azure Resource Group Terraform resources
# ============================================================

package terraform

import future.keywords.in
import future.keywords.if

# ── Helper ─────────────────────────────────────────────────
resource_groups[resource] if {
  resource := input.resource_changes[_]
  resource.type == "azurerm_resource_group"
  resource.change.actions[_] in ["create", "update"]
}

# ── DENY: Tags required on RG ──────────────────────────────
required_rg_tags := {"Environment", "Project", "ManagedBy"}

deny[msg] if {
  rg := resource_groups[_]
  missing := required_rg_tags - {k | rg.change.after.tags[k]}
  count(missing) > 0
  msg := sprintf("DENY [D7] Resource Group '%s': missing required tags: %v", [rg.address, missing])
}

# ── DENY: Location must be an approved region ──────────────
approved_locations := {"eastus", "westus2", "northeurope", "westeurope"}

deny[msg] if {
  rg := resource_groups[_]
  not approved_locations[lower(rg.change.after.location)]
  msg := sprintf("DENY [D8] Resource Group '%s': location '%s' is not in approved list: %v", [rg.address, rg.change.after.location, approved_locations])
}
