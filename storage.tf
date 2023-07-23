resource "google_storage_bucket" "test_bucket" {
  name          = "densnet-test-bucket"
  location      = upper(var.region[terraform.workspace])
  storage_class = "STANDARD"

  public_access_prevention = "enforced"
}