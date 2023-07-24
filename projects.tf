# resource "google_project" "portfolio_dev" {
#   name       = "densnet-portfolio-dev"
#   project_id = "densnet-portfolio-dev"
#   org_id     = "914921624150"
# }

# resource "google_project" "portfolio_prod" {
#   name       = "densnet-portfolio-prod"
#   project_id = "densnet-portfolio-prod"
#   org_id     = "914921624150"
# }

module "project_densnet_shared_vpc_host" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.2"

  name              = "densnet-host-vpc-${terraform.workspace}"
  random_project_id = true
  org_id            = var.organization
  folder_id         = "649529978270"
  billing_account                = "017CB9-ECCEBC-A2CCF8"
  enable_shared_vpc_host_project = true
}

module "shared_vpc_densnet_mgmt" {
    source  = "terraform-google-modules/network/google"
    version = "~> 7.1"

    depends_on = [ module.project_densnet_shared_vpc_host ]

    project_id = module.project_densnet_shared_vpc_host.project_id
    network_name = "vpc-densnet-apps-${var.project[terraform.workspace]}"

    subnets = [
        {
            subnet_name = "${var.project[terraform.workspace]}"
            subnet_ip = "10.140.0.0/20"
            subnet_region = "us-central1"
            description = "subnet for applications (${var.project[terraform.workspace]})"
        }
    ]
}


########

resource "google_folder" "apps" {
  display_name = "Applications"
  parent       = "organizations/${var.organization}"
}

module "projects" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.2"

  depends_on = [ google_folder.apps, module.shared_vpc_densnet_mgmt ]

  name              = var.project[terraform.workspace]
  random_project_id = true
  org_id            = var.organization
  folder_id         = google_folder.apps.name
  #   usage_bucket_name    = "densnet-shared-network-test-usage-report-bucket"
  #   usage_bucket_prefix  = "pf/test/1/integration"
  billing_account                = "017CB9-ECCEBC-A2CCF8"
  svpc_host_project_id = module.project_densnet_shared_vpc_host.project_id

    shared_vpc_subnets = [
      "projects//regions/us-central1/subnetworks/default",
    ]

}