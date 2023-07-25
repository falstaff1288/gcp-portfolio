module "core" {
  source = "./modules/core"

  # service_projects = var.service_projects[terraform.workspace]
  # region = var.region
  organization = var.organization

}


module "shared_vpc" {
  source          = "./modules/shared_vpc"
  billing_account = var.billing_account
  organization    = var.organization
  region          = var.region
  project         = var.project
  folder_id       = module.core.folder_shared_vpc_sub_name
  name            = var.name
  # cloud_router_name = "cloud-router-${var.projects.app[terraform.workspace]}"
}

module "project_densnet_app" {
  source = "./modules/projects"

  # service_projects = var.service_projects[terraform.workspace]
  # region = var.region
  name            = var.name
  organization    = var.organization
  folder_id       = module.core.folder_apps_sub_name
  billing_account = var.billing_account

}
