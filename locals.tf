# ============================================================
# locals.tf — Computed / derived values
# ============================================================

locals {
  common_tags = {
    environment = var.environment
    project     = var.project
    owner       = var.owner
    managedBy   = "Terraform"
  }
}
