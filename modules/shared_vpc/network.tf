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

### Cloud Router with NAT
# module "cloud_router" {
#   source  = "terraform-google-modules/cloud-router/google"
#   version = "~> 5.0"

#   depends_on = [ module.network_shared_vpc ]

#   name    = "cloud-router"
#   project = module.shared_vpc[each.value.name].project_id
#   region  = each.value.region
#   network = module.shared_vpc_densnet_apps.network_name
#   nats = [{
#     name = "nat-${each.value.region}"
#     # log_config = {
#     #     enable = false
#     # }
#   }]
# }