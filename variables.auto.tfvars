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

org_name = "densnet"

region = "us-central1"

organization = "914921624150"

billing_account = "017CB9-ECCEBC-A2CCF8"

subnet_primary_apps = {
  dev = {
    ip = "10.128.0.0/20"
    region = "us-central1"
  }
}

subnet_primary_ml = {
  dev = {
    ip = "10.132.0.0/20"
    region = "us-central1"
  }
}

subnet_secondary_apps = {
  dev = [ 
    {
      range_name    = "densnet-apps-01"
      ip_cidr_range = "192.168.8.0/24"    
    },
    {
      range_name    = "densnet-apps-02"
      ip_cidr_range = "192.168.16.0/24"
    },
  ]
}

subnet_secondary_ml = {
  dev = [ 
    {
      range_name    = "densnet-apps-01"
      ip_cidr_range = "192.168.24.0/24"    
    },
    {
      range_name    = "densnet-apps-02"
      ip_cidr_range = "192.168.32.0/24"
    },
  ]
}