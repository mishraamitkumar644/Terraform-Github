# ============================================================
# environments/prod.tfvars
# ============================================================
environment              = "prod"
location                 = "East US"
resource_group_name      = "rg-myproject-prod"
storage_account_name     = "stmyprojectprod001"
storage_account_tier     = "Standard"
storage_replication_type = "GRS" # Geo-redundant for prod
project                  = "myproject"
owner                    = "platform-team"
