# environments/dev.tfvars
# Development environment variables — low cost, minimal redundancy

environment    = "dev"
location       = "eastus"
instance_count = 1
sku            = "Standard_B2s"
tags = {
  Environment = "dev"
  ManagedBy   = "terraform"
  Pipeline    = "github-actions"
}
