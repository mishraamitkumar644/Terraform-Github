variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "account_tier" {
  type    = string
  default = "Standard"
}

variable "account_replication_type" {
  type    = string
  default = "LRS"
}

variable "blob_delete_retention_days" {
  description = "Soft delete retention period for blobs (days)"
  type        = number
  default     = 7
}

# variable "network_default_action" {
#   description = "Default network action: Allow or Deny"
#   type        = string
#   default     = "Deny"
# }

# variable "allowed_ip_rules" {
#   description = "List of allowed IP ranges for storage firewall"
#   type        = list(string)
#   default     = []
# }

variable "tags" {
  type    = map(string)
  default = {}
}
