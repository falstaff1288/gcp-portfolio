module "service_projects" {
  source  = "terraform-google-modules/project-factory/google//modules/svpc_service_project"
  version = "~> 14.2"

  name              = "${var.name}-${var.env}-${terraform.workspace}"
  random_project_id = true
  org_id            = var.organization
  folder_id         = var.folder_id
  billing_account      = var.billing_account
  # svpc_host_project_id = var.host_project_id
  grant_network_role = var.grant_network_role

  shared_vpc = var.host_project_id
  shared_vpc_subnets = [
    "projects/${var.host_project_id}/regions/us-central1/subnetworks/${var.name}-${var.env}-${terraform.workspace}",
  ]

    activate_apis = [
    "compute.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ]

}

module "project-iam-bindings" {
  source = "terraform-google-modules/iam/google//modules/projects_iam"
  projects          = [module.service_projects.project_id]
  mode             = "additive"

  bindings = {
    "roles/monitoring.metricWriter" = [
      "serviceAccount:${module.service_projects.service_account_email}",
    ]
    "roles/logging.logWriter" = [
      "serviceAccount:${module.service_projects.service_account_email}",
    ]
  }
}