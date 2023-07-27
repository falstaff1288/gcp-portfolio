### CORE
resource "google_folder" "apps" {
  display_name = "applications"
  parent       = "organizations/${var.organization}"
}

resource "google_folder" "apps_sub" {
depends_on = [ google_folder.apps ]

  display_name = "applications-${terraform.workspace}"
  parent       = google_folder.apps.name
}

resource "google_folder" "shared_vpc" {
  display_name = "shared_vpc"
  parent       = "organizations/${var.organization}"
}

resource "google_folder" "shared_vpc_sub" {
  depends_on = [ google_folder.shared_vpc ]

  display_name = "shared_vpc_${terraform.workspace}"
  parent       = google_folder.shared_vpc.name
}

resource "google_folder" "deploy" {
  display_name = "deploy"
  parent       = "organizations/${var.organization}"
}

resource "google_folder" "deploy_sub" {
depends_on = [ google_folder.deploy ]

  display_name = "deploy_${terraform.workspace}"
  parent       = google_folder.deploy.name
}

### PROJECTS
#### SHARED VPC
module "host_project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.2"

  name                           = "${var.org_name}-net-${terraform.workspace}"
  random_project_id              = true
  org_id                         = var.organization
  folder_id                      = "organizations/${var.organization}"
  billing_account                = var.billing_account
  enable_shared_vpc_host_project = true
  lien = false
  grant_network_role = true

    activate_apis = [
    "compute.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
}

#### TEAMS
module "service_projects_apps" {
  source  = "terraform-google-modules/project-factory/google//modules/svpc_service_project"
  version = "~> 14.2"

  name              = "${var.org_name}-apps-${terraform.workspace}"
  random_project_id = true
  org_id            = var.organization
  folder_id         = google_folder.apps_sub.name
  billing_account      = var.billing_account
  # svpc_host_project_id = var.host_project_id
  # grant_network_role = var.grant_network_role

  # shared_vpc = var.host_project_id
  # shared_vpc_subnets = [
  #   "projects/${var.host_project_id}/regions/${var.region}/subnetworks/${var.name}-${var.env}-${terraform.workspace}",
  # ]

    activate_apis = [
    "compute.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ]

}

module "service_projects_ml" {
  source  = "terraform-google-modules/project-factory/google//modules/svpc_service_project"
  version = "~> 14.2"

  name              = "${var.org_name}-ml-${terraform.workspace}"
  random_project_id = true
  org_id            = var.organization
  folder_id         = google_folder.apps_sub.name
  billing_account      = var.billing_account
  # svpc_host_project_id = var.host_project_id
  # grant_network_role = var.grant_network_role

  # shared_vpc = var.host_project_id
  # shared_vpc_subnets = [
  #   "projects/${var.host_project_id}/regions/${var.region}/subnetworks/${var.name}-${var.env}-${terraform.workspace}",
  # ]

    activate_apis = [
    "compute.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ]

}

### SHARED VPC NETWORK
module "network_shared_vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 7.1"

  project_id   = module.host_project.project_id
  network_name = "shared-vpc-${terraform.workspace}"
  shared_vpc_host = true

  subnets = [ 
    {
      subnet_name   = "${var.org_name}-apps-${terraform.workspace}"
      subnet_ip     = var.subnet_primary_apps[terraform.workspace].ip
      subnet_region = var.subnet_primary_apps[terraform.workspace].region
      description   = "subnet for applications (${var.org_name}-apps-${terraform.workspace})"
    },
    {
      subnet_name   = "${var.org_name}-ml-${terraform.workspace}"
      subnet_ip     = var.subnet_primary_ml[terraform.workspace].ip
      subnet_region = var.subnet_primary_ml[terraform.workspace].region
      description   = "subnet for applications (${var.org_name}-ml-${terraform.workspace})"
    },


  ]

  secondary_ranges = {
    "densnet-apps-${terraform.workspace}" = var.subnet_secondary_apps[terraform.workspace]
    "densnet-ml-${terraform.workspace}" = var.subnet_secondary_ml[terraform.workspace]
  }

}

#### Cloud Router
## Cloud Router with NAT
module "cloud_router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 5.0"

  depends_on = [ module.network_shared_vpc ]

  name    = "cloud-router-${var.org_name}-${terraform.workspace}"
  project = module.host_project.project_id
  region  = var.region
  network = module.network_shared_vpc.network_id
  nats = [
    {
      name = "nat-${module.network_shared_vpc.network_name}"
    }
  ]
  # log_config = {
  #     enable = false
  # }
}

# module "project_iam_bindings_apps" {
#   source = "terraform-google-modules/iam/google//modules/projects_iam"
#   projects          = [module.service_projects_apps.project_id]
#   mode             = "additive"

#   bindings = {
#     "roles/monitoring.metricWriter" = [
#       "serviceAccount:${module.service_projects_apps.service_account_email}",
#     ]
#     "roles/logging.logWriter" = [
#       "serviceAccount:${module.service_projects_apps.service_account_email}",
#     ]
#   }
# }

# module "project_iam_bindings_ml" {
#   source = "terraform-google-modules/iam/google//modules/projects_iam"
#   projects          = [module.service_projects_ml.project_id]
#   mode             = "additive"

#   bindings = {
#     "roles/monitoring.metricWriter" = [
#       "serviceAccount:${module.service_projects_ml.service_account_email}",
#     ]
#     "roles/logging.logWriter" = [
#       "serviceAccount:${module.service_projects_ml.service_account_email}",
#     ]
#   }
# }

# module "core" {
#   source = "./modules/core"

#   # service_projects = var.service_projects[terraform.workspace]
#   # region = var.region
#   organization = var.organization

# }

# module "shared_vpc" {
#   source          = "./modules/shared_vpc"
#   billing_account = var.billing_account
#   organization    = var.organization
#   region          = var.region
#   project         = var.project[terraform.workspace]
#   folder_id       = module.core.folder_shared_vpc_sub_name
#   name            = var.name
#   grant_network_role = false
#   # cloud_router_name = "cloud-router-${var.projects.app[terraform.workspace]}"
# }

# # module "project_densnet_deploy" {
# #   source = "./modules/projects"

# #   name            = var.name
# #   env             = "deploy"
# #   organization    = var.organization
# #   project         = var.project[terraform.workspace]
# #   folder_id       = module.core.folder_deploy_sub_name
# #   billing_account = var.billing_account
# #   host_project_id = module.shared_vpc.host_project_id
# #   grant_network_role = true

# # }

# module "project_densnet_app" {
#   source = "./modules/projects"

#   name            = var.name
#   env             = "apps"
#   organization    = var.organization
#   project         = var.project[terraform.workspace]
#   folder_id       = module.core.folder_apps_sub_name
#   billing_account = var.billing_account
#   host_project_id = module.shared_vpc.host_project_id
#   grant_network_role = true
# }

# module "project_densnet_ml" {
#   source = "./modules/projects"

#   name            = var.name
#   env             = "ml"
#   organization    = var.organization
#   project         = var.project[terraform.workspace]
#   folder_id       = module.core.folder_apps_sub_name
#   billing_account = var.billing_account
#   host_project_id = module.shared_vpc.host_project_id
#   grant_network_role = true

# }