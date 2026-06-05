# environments/prod.tfvars

environment    = "prod"
location       = "eastus"
instance_count = 3
sku            = "Standard_D4s_v3"
tags = {
  Environment = "prod"
  ManagedBy   = "terraform"
  Pipeline    = "github-actions"
}
