module "network_shared_vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 7.1"

  project_id   = module.host_project.project_id
  network_name = "shared-vpc-${terraform.workspace}"
  shared_vpc_host = true

  subnets = [ 
    for sub in var.project:
      {
        subnet_name   = "${var.name}-${sub.name}"
        subnet_ip     = sub.subnet
        subnet_region = sub.region
        description   = "subnet for applications (${var.name}-${sub.name})"
      }
  ]
}