package terraform

# ──────────────────────────────────────────────────────────────────────────────
# data.terraform.deny  — violations that BLOCK the pipeline (hard failures)
# data.terraform.warn  — violations that WARNING only (non-blocking)
# ──────────────────────────────────────────────────────────────────────────────

# Example: Block deletion of Key Vaults via pipeline
deny contains msg if {
  r := input.resource_changes[_]
  r.change.actions[_] == "delete"
  r.type == "azurerm_key_vault"
  msg := sprintf("Deletion of Key Vault '%v' is not allowed via CI/CD pipeline", [r.address])
}

# Example: Block storage accounts without HTTPS enforcement
deny contains msg if {
  r := input.resource_changes[_]
  r.type == "azurerm_storage_account"
  r.change.after.enable_https_traffic_only == false
  msg := sprintf("Storage account '%v' must have HTTPS-only traffic enabled", [r.address])
}

# Example: Warn when public network access is enabled on a resource
warn contains msg if {
  r := input.resource_changes[_]
  r.change.after.public_network_access_enabled == true
  msg := sprintf("Resource '%v' has public network access enabled — verify this is intentional", [r.address])
}
