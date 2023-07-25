module "host_project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.2"

  name                           = "${var.name}-net-${terraform.workspace}"
  random_project_id              = true
  org_id                         = var.organization
  folder_id                      = var.folder_id
  billing_account                = var.billing_account
  enable_shared_vpc_host_project = true
  lien = false
}