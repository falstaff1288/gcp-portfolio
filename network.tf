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
    network_name = "vpc-densnet-apps-${terraform.workspace}"

    subnets = [
        {
            subnet_name = "${var.project[terraform.workspace]}"
            subnet_ip = "10.140.0.0/20"
            subnet_region = "us-central1"
            description = "subnet for applications (${var.project[terraform.workspace]})"
        }
    ]
}