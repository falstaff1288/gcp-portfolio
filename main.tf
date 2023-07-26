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
  project         = var.project[terraform.workspace]
  folder_id       = module.core.folder_shared_vpc_sub_name
  name            = var.name
  grant_network_role = false
  # cloud_router_name = "cloud-router-${var.projects.app[terraform.workspace]}"
}

# module "project_densnet_deploy" {
#   source = "./modules/projects"

#   name            = var.name
#   env             = "deploy"
#   organization    = var.organization
#   project         = var.project[terraform.workspace]
#   folder_id       = module.core.folder_deploy_sub_name
#   billing_account = var.billing_account
#   host_project_id = module.shared_vpc.host_project_id
#   grant_network_role = true

# }

module "project_densnet_app" {
  source = "./modules/projects"

  name            = var.name
  env             = "apps"
  organization    = var.organization
  project         = var.project[terraform.workspace]
  folder_id       = module.core.folder_apps_sub_name
  billing_account = var.billing_account
  host_project_id = module.shared_vpc.host_project_id
  grant_network_role = true
}

module "project_densnet_ml" {
  source = "./modules/projects"

  name            = var.name
  env             = "ml"
  organization    = var.organization
  project         = var.project[terraform.workspace]
  folder_id       = module.core.folder_apps_sub_name
  billing_account = var.billing_account
  host_project_id = module.shared_vpc.host_project_id
  grant_network_role = true

}