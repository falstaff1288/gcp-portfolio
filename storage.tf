resource "google_storage_bucket" "test_bucket" {
  name          = "densnet-test-bucket-${terraform.workspace}"
  location      = upper(var.region)
  storage_class = "STANDARD"
  project = var.project[terraform.workspace]

  public_access_prevention = "enforced"
}