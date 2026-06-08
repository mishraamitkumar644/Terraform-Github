# ============================================================
# modules/storage_account/main.tf
# azurerm ~3.100 — all attribute names verified
# ============================================================

resource "azurerm_storage_account" "this" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  # ── Security hardening (OPA policies validate these) ─────
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false   # Force Azure AD auth only
  blob_properties {
    delete_retention_policy {
      days = var.blob_delete_retention_days
    }
    versioning_enabled = true
  }

  network_rules {
    default_action = var.network_default_action
    bypass         = ["AzureServices"]
    ip_rules       = var.allowed_ip_rules
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
