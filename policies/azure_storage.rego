package terraform

import future.keywords.if
import future.keywords.contains

# ── DENY: HTTPS must be enforced ─────────────────────────────────────────────
deny contains msg if {
  rc := input.resource_changes[_]
  rc.type == "azurerm_storage_account"
  rc.change.actions[_] == "create"
  not rc.change.after.https_traffic_only_enabled
  msg := sprintf("Storage Account '%s' must have HTTPS-only enabled", [rc.address])
}

# ── DENY: TLS version must be TLS1_2 ─────────────────────────────────────────
deny contains msg if {
  rc := input.resource_changes[_]
  rc.type == "azurerm_storage_account"
  rc.change.actions[_] == "create"
  rc.change.after.min_tls_version != "TLS1_2"
  msg := sprintf("Storage Account '%s' must use TLS1_2, found: '%s'", [rc.address, rc.change.after.min_tls_version])
}

# ── DENY: Public blob access must be disabled ─────────────────────────────────
deny contains msg if {
  rc := input.resource_changes[_]
  rc.type == "azurerm_storage_account"
  rc.change.actions[_] == "create"
  rc.change.after.allow_nested_items_to_be_public == true
  msg := sprintf("Storage Account '%s' must not allow public blob access", [rc.address])
}

# ── DENY: Required tags missing ──────────────────────────────────────────────
deny contains msg if {
  rc := input.resource_changes[_]
  rc.type == "azurerm_storage_account"
  rc.change.actions[_] == "create"
  required_tags := ["environment", "project", "owner"]
  tag := required_tags[_]
  not rc.change.after.tags[tag]
  msg := sprintf("Storage Account '%s' missing required tag: '%s'", [rc.address, tag])
}

# ── WARN: Shared access key should be disabled ────────────────────────────────
warn contains msg if {
  rc := input.resource_changes[_]
  rc.type == "azurerm_storage_account"
  rc.change.actions[_] == "create"
  rc.change.after.shared_access_key_enabled == true
  msg := sprintf("Storage Account '%s': shared access key enabled, prefer Azure AD auth", [rc.address])
}

# ── WARN: LRS replication ─────────────────────────────────────────────────────
warn contains msg if {
  rc := input.resource_changes[_]
  rc.type == "azurerm_storage_account"
  rc.change.actions[_] == "create"
  rc.change.after.account_replication_type == "LRS"
  msg := sprintf("Storage Account '%s' uses LRS. Consider GRS/ZRS for production", [rc.address])
}
