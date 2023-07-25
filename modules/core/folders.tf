resource "google_folder" "apps" {
  display_name = "Applications"
  parent       = "organizations/${var.organization}"
}

resource "google_folder" "apps_sub" {
depends_on = [ google_folder.apps ]

  display_name = "Applications-${terraform.workspace}"
  parent       = google_folder.apps.name
}

resource "google_folder" "shared_vpc" {
  display_name = "SharedVPC"
  parent       = "organizations/${var.organization}"
}

resource "google_folder" "shared_vpc_sub" {
  depends_on = [ google_folder.shared_vpc ]

  display_name = "SharedVPC-${terraform.workspace}"
  parent       = google_folder.shared_vpc.name
}