output "name" {
  value = azurerm_storage_account.this.name
}

output "id" {
  value = azurerm_storage_account.this.id
}

output "primary_blob_endpoint" {
  value = azurerm_storage_account.this.primary_blob_endpoint
}

output "principal_id" {
  description = "System-assigned managed identity principal ID"
  value       = azurerm_storage_account.this.identity[0].principal_id
}
