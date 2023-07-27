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
  random_project_id              = false
  org_id                         = var.organization
  folder_id                      = google_folder.shared_vpc_sub.name
  billing_account                = var.billing_account
  enable_shared_vpc_host_project = true
  lien = false
  grant_network_role = true

    activate_apis = [
    "compute.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "container.googleapis.com"
  ]
}

#### TEAMS
module "service_projects_deploy" {
  source  = "terraform-google-modules/project-factory/google//modules/svpc_service_project"
  version = "~> 14.2"

  name              = "${var.org_name}-deploy-${terraform.workspace}"
  random_project_id = false
  org_id            = var.organization
  folder_id         = google_folder.deploy_sub.name
  billing_account      = var.billing_account

  shared_vpc = module.host_project.project_id
  shared_vpc_subnets = [
    "projects/${module.host_project.project_id}/regions/${var.region}/subnetworks/${var.org_name}-deploy-${terraform.workspace}",
  ]

    activate_apis = [
    "compute.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "container.googleapis.com"
  ]

}

module "service_projects_apps" {
  source  = "terraform-google-modules/project-factory/google//modules/svpc_service_project"
  version = "~> 14.2"

  name              = "${var.org_name}-apps-${terraform.workspace}"
  random_project_id = false
  org_id            = var.organization
  folder_id         = google_folder.apps_sub.name
  billing_account      = var.billing_account

  shared_vpc = module.host_project.project_id
  shared_vpc_subnets = [
    "projects/${module.host_project.project_id}/regions/${var.region}/subnetworks/${var.org_name}-apps-${terraform.workspace}",
  ]

    activate_apis = [
    "compute.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "container.googleapis.com"
  ]

}

module "service_projects_ml" {
  source  = "terraform-google-modules/project-factory/google//modules/svpc_service_project"
  version = "~> 14.2"

  name              = "${var.org_name}-ml-${terraform.workspace}"
  random_project_id = false
  org_id            = var.organization
  folder_id         = google_folder.apps_sub.name
  billing_account      = var.billing_account

  shared_vpc = module.host_project.project_id
  shared_vpc_subnets = [
    "projects/${module.host_project.project_id}/regions/${var.region}/subnetworks/${var.org_name}-ml-${terraform.workspace}",
  ]

    activate_apis = [
    "compute.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "container.googleapis.com"
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
    {
      subnet_name   = "${var.org_name}-deploy-${terraform.workspace}"
      subnet_ip     = var.subnet_primary_deploy[terraform.workspace].ip
      subnet_region = var.subnet_primary_deploy[terraform.workspace].region
      description   = "subnet for applications (${var.org_name}-deploy-${terraform.workspace})"
    },


  ]

  secondary_ranges = {
    "densnet-apps-${terraform.workspace}" = var.subnet_secondary_apps[terraform.workspace]
    "densnet-ml-${terraform.workspace}" = var.subnet_secondary_ml[terraform.workspace]
    "densnet-deploy-${terraform.workspace}" = var.subnet_secondary_deploy[terraform.workspace]
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

### GKE

data "google_client_config" "deploy" {}
data "google_client_config" "apps" {}


provider "kubernetes" {
  alias = "deploy"
  host                   = "https://${module.gke_deploy.endpoint}"
  token                  = data.google_client_config.deploy.access_token
  cluster_ca_certificate = base64decode(module.gke_deploy.ca_certificate)
}

provider "kubernetes" {
  alias = "apps"
  host                   = "https://${module.gke_apps.endpoint}"
  token                  = data.google_client_config.apps.access_token
  cluster_ca_certificate = base64decode(module.gke_deploy.ca_certificate)
}

#### DEPLOY
module "gke_deploy" {
  source                     = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  
  depends_on = [ module.network_shared_vpc ]
  
  project_id                 = module.service_projects_deploy.project_id
  name                       = "deploy"
  # region                     = "us-central1"
  regional = false
  zones                      = ["us-central1-a", "us-central1-b", "us-central1-f"]
  network                    = module.network_shared_vpc.network_name
  network_project_id         = module.host_project.project_id
  subnetwork                 = "densnet-deploy-dev"
  ip_range_pods              = "densnet-deploy-01"
  ip_range_services          = "densnet-deploy-02"
  master_authorized_networks = [
    {
      display_name = "allow-all"
      cidr_block = "0.0.0.0/0"
    }
  ]
  http_load_balancing        = false
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false
  enable_private_endpoint    = false
  enable_private_nodes       = true
  # master_ipv4_cidr_block     = "10.0.0.0/28"

  node_pools = [
    {
      name                      = "main-pool01"
      machine_type              = "e2-medium"
      node_locations            = "us-central1-a,us-central1-b,us-central1-c"
      min_count                 = 1
      max_count                 = 1
      local_ssd_count           = 0
      spot                      = true
      disk_size_gb              = 100
      disk_type                 = "pd-standard"
      image_type                = "COS_CONTAINERD"
      enable_gcfs               = false
      enable_gvnic              = false
      auto_repair               = true
      auto_upgrade              = true
      service_account           = module.service_projects_deploy.service_account_email
      preemptible               = false
      initial_node_count        = 1
    },
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  # node_pools_labels = {
  #   all = {}

  #   general-nodepool01 = {
  #     hello = "moto"
  #   }
  # }

  # node_pools_metadata = {
  #   all = {}

  #   default-node-pool = {
  #     node-pool-metadata-custom-value = "my-node-pool"
  #   }
  # }

  # node_pools_taints = {
  #   all = []

  #   default-node-pool = [
  #     {
  #       key    = "default-node-pool"
  #       value  = true
  #       effect = "PREFER_NO_SCHEDULE"
  #     },
  #   ]
  # }

  # node_pools_tags = {
  #   all = []

  #   default-node-pool = [
  #     "default-node-pool",
  #   ]
  # }
}

#### APPS


module "gke_apps" {
  source                     = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  
  depends_on = [ module.network_shared_vpc ]
  
  project_id                 = module.service_projects_deploy.project_id
  name                       = "deploy"
  # region                     = "us-central1"
  regional = false
  zones                      = ["us-central1-a", "us-central1-b", "us-central1-f"]
  network                    = module.network_shared_vpc.network_name
  network_project_id         = module.host_project.project_id
  subnetwork                 = "densnet-apps-dev"
  ip_range_pods              = "densnet-apps-01"
  ip_range_services          = "densnet-apps-02"
  master_authorized_networks = [
    {
      display_name = "allow-all"
      cidr_block = "0.0.0.0/0"
    }
  ]
  http_load_balancing        = false
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false
  enable_private_endpoint    = false
  enable_private_nodes       = true
  # master_ipv4_cidr_block     = "10.0.0.0/28"

  node_pools = [
    {
      name                      = "main-pool01"
      machine_type              = "e2-medium"
      node_locations            = "us-central1-a,us-central1-b,us-central1-c"
      min_count                 = 1
      max_count                 = 1
      local_ssd_count           = 0
      spot                      = true
      disk_size_gb              = 100
      disk_type                 = "pd-standard"
      image_type                = "COS_CONTAINERD"
      enable_gcfs               = false
      enable_gvnic              = false
      auto_repair               = true
      auto_upgrade              = true
      service_account           = module.service_projects_apps.service_account_email
      preemptible               = false
      initial_node_count        = 1
    },
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  # node_pools_labels = {
  #   all = {}

  #   general-nodepool01 = {
  #     hello = "moto"
  #   }
  # }

  # node_pools_metadata = {
  #   all = {}

  #   default-node-pool = {
  #     node-pool-metadata-custom-value = "my-node-pool"
  #   }
  # }

  # node_pools_taints = {
  #   all = []

  #   default-node-pool = [
  #     {
  #       key    = "default-node-pool"
  #       value  = true
  #       effect = "PREFER_NO_SCHEDULE"
  #     },
  #   ]
  # }

  # node_pools_tags = {
  #   all = []

  #   default-node-pool = [
  #     "default-node-pool",
  #   ]
  # }
}