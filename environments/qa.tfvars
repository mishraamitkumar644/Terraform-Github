# environments/qa.tfvars

environment    = "qa"
location       = "eastus"
instance_count = 2
sku            = "Standard_B4ms"
tags = {
  Environment = "qa"
  ManagedBy   = "terraform"
  Pipeline    = "github-actions"
}
