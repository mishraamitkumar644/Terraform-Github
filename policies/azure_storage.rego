# ============================================================
# policies/azure_storage.rego
# OPA policy for Azure Storage Account Terraform resources
# Evaluated against tfplan.json (terraform show -json output)
# ============================================================

package terraform

import future.keywords.in
import future.keywords.if

# ── Helper: get all resource_changes of a given type ─────────
storage_accounts[resource] if {
  resource := input.resource_changes[_]
  resource.type == "azurerm_storage_account"
  resource.change.actions[_] in ["create", "update"]
}

# ──────────────────────────────────────────────────────────────
# DENY RULES (pipeline fails if any trigger)
# ──────────────────────────────────────────────────────────────

# D1: HTTPS must be enforced
deny[msg] if {
  sa := storage_accounts[_]
  sa.change.after.https_traffic_only_enabled == false
  msg := sprintf("DENY [D1] Storage Account '%s': https_traffic_only_enabled must be true", [sa.address])
}

# D2: Minimum TLS version must be TLS1_2
deny[msg] if {
  sa := storage_accounts[_]
  sa.change.after.min_tls_version != "TLS1_2"
  msg := sprintf("DENY [D2] Storage Account '%s': min_tls_version must be TLS1_2 (found: %s)", [sa.address, sa.change.after.min_tls_version])
}

# D3: Public blob access must be disabled
deny[msg] if {
  sa := storage_accounts[_]
  sa.change.after.allow_nested_items_to_be_public == true
  msg := sprintf("DENY [D3] Storage Account '%s': allow_nested_items_to_be_public must be false", [sa.address])
}

# D4: Shared access key must be disabled (enforce Azure AD auth)
deny[msg] if {
  sa := storage_accounts[_]
  sa.change.after.shared_access_key_enabled == true
  msg := sprintf("DENY [D4] Storage Account '%s': shared_access_key_enabled must be false (use Azure AD auth)", [sa.address])
}

# D5: Network default action must be Deny (no open storage accounts)
deny[msg] if {
  sa := storage_accounts[_]
  rules := sa.change.after.network_rules[_]
  rules.default_action != "Deny"
  msg := sprintf("DENY [D5] Storage Account '%s': network_rules.default_action must be 'Deny'", [sa.address])
}

# D6: Tags must include Environment, Project, ManagedBy
required_tags := {"Environment", "Project", "ManagedBy"}

deny[msg] if {
  sa := storage_accounts[_]
  missing := required_tags - {k | sa.change.after.tags[k]}
  count(missing) > 0
  msg := sprintf("DENY [D6] Storage Account '%s': missing required tags: %v", [sa.address, missing])
}

# ──────────────────────────────────────────────────────────────
# WARN RULES (non-blocking, logged in pipeline summary)
# ──────────────────────────────────────────────────────────────

# W1: Prod should use GRS replication
warn[msg] if {
  sa := storage_accounts[_]
  sa.change.after.tags.Environment == "prod"
  sa.change.after.account_replication_type == "LRS"
  msg := sprintf("WARN [W1] Storage Account '%s': prod environment should use GRS not LRS", [sa.address])
}

# W2: Soft delete retention should be >= 7 days
warn[msg] if {
  sa := storage_accounts[_]
  bp := sa.change.after.blob_properties[_]
  bp.delete_retention_policy[_].days < 7
  msg := sprintf("WARN [W2] Storage Account '%s': blob soft delete retention should be >= 7 days", [sa.address])
}

# W3: System-assigned identity recommended
warn[msg] if {
  sa := storage_accounts[_]
  count(sa.change.after.identity) == 0
  msg := sprintf("WARN [W3] Storage Account '%s': no managed identity configured — system-assigned identity recommended", [sa.address])
}
