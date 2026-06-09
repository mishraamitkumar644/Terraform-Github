package terraform

import future.keywords.if
import future.keywords.in

# ── Helper: collect all storage_account resources from plan ──────────────────
storage_accounts[resource] if {
  resource := input.resource_changes[_]
  resource.type == "azurerm_storage_account"
  resource.change.actions[_] in ["create", "update"]
}

# ── DENY: HTTPS must be enforced ─────────────────────────────────────────────
deny[msg] if {
  sa := storage_accounts[_]
  not sa.change.after.https_traffic_only_enabled
  msg := sprintf(
    "Storage Account '%s' must have HTTPS-only traffic enabled.",
    [sa.address]
  )
}

# ── DENY: TLS version must be 1.2 or higher ──────────────────────────────────
deny[msg] if {
  sa := storage_accounts[_]
  sa.change.after.min_tls_version != "TLS1_2"
  msg := sprintf(
    "Storage Account '%s' must use min TLS version TLS1_2. Found: '%s'",
    [sa.address, sa.change.after.min_tls_version]
  )
}

# ── DENY: Public blob access must be disabled ─────────────────────────────────
deny[msg] if {
  sa := storage_accounts[_]
  sa.change.after.allow_nested_items_to_be_public == true
  msg := sprintf(
    "Storage Account '%s' must not allow public blob access.",
    [sa.address]
  )
}

# ── DENY: Required tags missing ──────────────────────────────────────────────
deny[msg] if {
  sa := storage_accounts[_]
  required_tags := ["environment", "project", "owner"]
  tag := required_tags[_]
  not sa.change.after.tags[tag]
  msg := sprintf(
    "Storage Account '%s' is missing required tag: '%s'",
    [sa.address, tag]
  )
}

# ── WARN: Shared access key should be disabled ────────────────────────────────
warn[msg] if {
  sa := storage_accounts[_]
  sa.change.after.shared_access_key_enabled == true
  msg := sprintf(
    "Storage Account '%s': shared access key is enabled. Prefer Azure AD auth.",
    [sa.address]
  )
}

# ── WARN: Replication type for prod ──────────────────────────────────────────
warn[msg] if {
  sa := storage_accounts[_]
  sa.change.after.account_replication_type == "LRS"
  msg := sprintf(
    "Storage Account '%s' uses LRS replication. Consider GRS/ZRS for production.",
    [sa.address]
  )
}
