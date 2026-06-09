# ============================================================
# main.tf — Root module
# Provisions: 1 Resource Group + 1 Storage Account per env
# ============================================================

terraform {
  required_version = "~> 1.7"

  required_providers {   
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    # All backend config injected at runtime via -backend-config flags.
    # azure/login OIDC action sets ARM_USE_OIDC=true, ARM_CLIENT_ID,
    # ARM_TENANT_ID, ARM_SUBSCRIPTION_ID as env vars automatically.
  }
}

provider "azurerm" {
  features {}

  # azure/login@v2 with OIDC sets these environment variables automatically:
  #   ARM_USE_OIDC=true
  #   ARM_CLIENT_ID
  #   ARM_TENANT_ID
  #   ARM_SUBSCRIPTION_ID
  # No need to repeat them here — provider picks them up from env.
  use_oidc = true
  use_cli  = false
  storage_use_azuread = true
}

# ── Resource Group ────────────────────────────────────────────
module "resource_group" {
  source = "./modules/resource_group"

  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# ── Storage Account ───────────────────────────────────────────
module "storage_account" {
  source = "./modules/storage_account"

  name                     = var.storage_account_name
  resource_group_name      = module.resource_group.name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_replication_type
  tags                     = local.common_tags

  depends_on = [module.resource_group]
}
