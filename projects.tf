resource "google_folder" "apps" {
  display_name = "Applications"
  parent       = "organizations/${var.organization}"
}

module "projects" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.2"

  depends_on = [google_folder.apps, module.shared_vpc_densnet_apps]

  name              = var.project[terraform.workspace]
  random_project_id = true
  org_id            = var.organization
  folder_id         = google_folder.apps.name
  #   usage_bucket_name    = "densnet-shared-network-test-usage-report-bucket"
  #   usage_bucket_prefix  = "pf/test/1/integration"
  billing_account      = "017CB9-ECCEBC-A2CCF8"
  svpc_host_project_id = module.project_densnet_shared_vpc_host.project_id

  shared_vpc_subnets = [
    "projects/${var.project[terraform.workspace]}/regions/us-central1/subnetworks/${var.project[terraform.workspace]}",
  ]

}