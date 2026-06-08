# ============================================================
# variables.tf — Root module input variables
# ============================================================

variable "environment" {
  description = "Deployment environment (dev | qa | prod)"
  type        = string
  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "environment must be dev, qa, or prod."
  }
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the Resource Group"
  type        = string
}

variable "storage_account_name" {
  description = "Name of the Storage Account (3-24 chars, lowercase alphanumeric)"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name must be 3-24 lowercase alphanumeric characters."
  }
}

variable "storage_account_tier" {
  description = "Storage account performance tier (Standard | Premium)"
  type        = string
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Storage replication type (LRS | GRS | ZRS | RAGRS)"
  type        = string
  default     = "LRS"
}

variable "project" {
  description = "Project name — used in tags"
  type        = string
  default     = "myproject"
}

variable "owner" {
  description = "Team / owner tag"
  type        = string
  default     = "platform-team"
}
