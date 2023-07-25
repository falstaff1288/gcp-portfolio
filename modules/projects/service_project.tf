module "service_projects" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.2"

  name              = "${var.name}-${var.env}-${terraform.workspace}"
  random_project_id = true
  org_id            = var.organization
  folder_id         = var.folder_id
  billing_account      = var.billing_account
  # svpc_host_project_id = module.shared_vpc.project_id

  shared_vpc_subnets = [
    "projects/${var.name}/regions/us-central1/subnetworks/${var.name}",
  ]

}