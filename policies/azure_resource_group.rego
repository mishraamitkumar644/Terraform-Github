package terraform

import future.keywords.if
import future.keywords.contains

# ── DENY: Required tags missing ──────────────────────────────────────────────
deny contains msg if {
  rc := input.resource_changes[_]
  rc.type == "azurerm_resource_group"
  rc.change.actions[_] == "create"
  required_tags := ["environment", "project", "owner"]
  tag := required_tags[_]
  not rc.change.after.tags[tag]
  msg := sprintf("RG '%s' missing required tag: '%s'", [rc.address, tag])
}

# ── DENY: Location must be approved ──────────────────────────────────────────
deny contains msg if {
  rc := input.resource_changes[_]
  rc.type == "azurerm_resource_group"
  rc.change.actions[_] == "create"
  approved := {"eastus", "eastus2", "westus2", "westeurope", "northeurope"}
  not approved[rc.change.after.location]
  msg := sprintf("RG '%s' uses unapproved location '%s'", [rc.address, rc.change.after.location])
}
