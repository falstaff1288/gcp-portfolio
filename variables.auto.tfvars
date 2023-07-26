project = {
  dev = [
    {
      name   = "apps-dev"
      env    = "apps"
      subnet = "10.128.0.0/20"
      secondary_range = "192.168.16.0/24"
      region = "us-central1"
    },
    {
      name   = "ml-dev"
      env    = "ml"
      subnet = "10.132.0.0/20"
      secondary_range = "192.168.32.0/24"
      region = "us-central1"
    }
  ]
  prod = [
    {
      name   = "apps-prod"
      subnet = "10.200.0.0/20"
      region = "us-central1"
    },
    {
      name   = "ml-prod"
      subnet = "10.204.0.0/20"
      region = "us-central1"
    }
  ]
}

name = "densnet"
# env = "app"

region = "us-central1"

organization = "914921624150"

billing_account = "017CB9-ECCEBC-A2CCF8"