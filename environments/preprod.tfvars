# environments/preprod.tfvars

environment    = "preprod"
location       = "eastus"
instance_count = 2
sku            = "Standard_B4ms"
tags = {
  Environment = "preprod"
  ManagedBy   = "terraform"
  Pipeline    = "github-actions"
}
