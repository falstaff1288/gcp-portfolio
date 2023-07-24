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

module "project_densnet_shared_vpc_host_test" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.2"

  name              = "densnet-host-vpc-test"
  random_project_id = true
  org_id            = "914921624150"
  #   usage_bucket_name    = "densnet-shared-network-test-usage-report-bucket"
  #   usage_bucket_prefix  = "pf/test/1/integration"
  billing_account                = "017CB9-ECCEBC-A2CCF8"
  enable_shared_vpc_host_project = true
  #   svpc_host_project_id = "shared_vpc_host_name"

  #   shared_vpc_subnets = [
  #     "projects/base-project-196723/regions/us-east1/subnetworks/default",
  #     "projects/base-project-196723/regions/us-central1/subnetworks/default",
  #     "projects/base-project-196723/regions/us-central1/subnetworks/subnet-1",
  #   ]

}