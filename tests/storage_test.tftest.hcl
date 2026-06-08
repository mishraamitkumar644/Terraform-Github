# ============================================================
# tests/storage_test.tftest.hcl
# Terraform native tests for storage_account module
# Run: terraform test -var-file="environments/dev.tfvars"
# ============================================================

variables {
  environment              = "dev"
  location                 = "East US"
  resource_group_name      = "rg-myproject-dev"
  storage_account_name     = "stmyprojectdev001"
  storage_account_tier     = "Standard"
  storage_replication_type = "LRS"
  project                  = "myproject"
  owner                    = "platform-team"
}

# Test: storage account name validation
run "valid_storage_account_name" {
  command = plan

  assert {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name must be 3-24 lowercase alphanumeric chars"
  }
}

# Test: environment must be valid
run "valid_environment_value" {
  command = plan

  assert {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "Environment must be dev, qa, or prod"
  }
}
