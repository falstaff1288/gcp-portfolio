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