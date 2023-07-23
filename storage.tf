resource "google_storage_bucket" "test_bucket" {
  name          = "densnet-test-bucket"
  location      = "US-CENTRAL1"

  public_access_prevention = "enforced"
}