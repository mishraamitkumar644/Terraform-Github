# ============================================================
# outputs.tf — Root module outputs
# ============================================================

output "resource_group_name" {
  description = "Name of the provisioned Resource Group"
  value       = module.resource_group.name
}

output "resource_group_id" {
  description = "Resource ID of the Resource Group"
  value       = module.resource_group.id
}

output "storage_account_name" {
  description = "Name of the provisioned Storage Account"
  value       = module.storage_account.name
}

output "storage_account_id" {
  description = "Resource ID of the Storage Account"
  value       = module.storage_account.id
}

output "storage_primary_endpoint" {
  description = "Primary blob endpoint of the Storage Account"
  value       = module.storage_account.primary_blob_endpoint
}
