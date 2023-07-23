terraform {
  backend "gcs" {
    bucket = "densnet-mgmt-tfstate"
    prefix = "gcp-portfolio"
  }
}