## Cloud Router with NAT
module "cloud_router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 5.0"

  depends_on = [ module.network_shared_vpc ]

  name    = "cloud-router-${var.name}-${terraform.workspace}"
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