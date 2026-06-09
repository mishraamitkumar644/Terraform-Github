package terraform

import future.keywords.if
import future.keywords.in

# ── Helper: collect all resource_group resources from plan ───────────────────
resource_groups[resource] if {
  resource := input.resource_changes[_]
  resource.type == "azurerm_resource_group"
  resource.change.actions[_] in ["create", "update"]
}

# ── DENY: Required tags missing ──────────────────────────────────────────────
deny[msg] if {
  rg := resource_groups[_]
  required_tags := ["environment", "project", "owner"]
  tag := required_tags[_]
  not rg.change.after.tags[tag]
  msg := sprintf(
    "Resource Group '%s' is missing required tag: '%s'",
    [rg.address, tag]
  )
}

# ── DENY: Location must be approved ──────────────────────────────────────────
deny[msg] if {
  rg := resource_groups[_]
  approved_locations := ["eastus", "eastus2", "westus2", "westeurope", "northeurope"]
  location := rg.change.after.location
  not location in approved_locations
  msg := sprintf(
    "Resource Group '%s' uses unapproved location '%s'. Approved: %v",
    [rg.address, location, approved_locations]
  )
}
