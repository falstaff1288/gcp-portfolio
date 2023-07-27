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

subnet_primary_deploy = {
  dev = {
    ip = "10.136.0.0/20"
    region = "us-central1"
  }
}

subnet_secondary_apps = {
  dev = [ 
    {
      range_name    = "densnet-apps-01"
      ip_cidr_range = "192.168.8.0/21"    
    },
    {
      range_name    = "densnet-apps-02"
      ip_cidr_range = "192.168.16.0/21"
    },
  ]
}

subnet_secondary_ml = {
  dev = [ 
    {
      range_name    = "densnet-apps-01"
      ip_cidr_range = "192.168.24.0/21"    
    },
    {
      range_name    = "densnet-apps-02"
      ip_cidr_range = "192.168.32.0/21"
    },
  ]
}

subnet_secondary_deploy = {
  dev = [ 
    {
      range_name    = "densnet-deploy-01"
      ip_cidr_range = "192.168.40.0/21"    
    },
    {
      range_name    = "densnet-deploy-02"
      ip_cidr_range = "192.168.48.0/21"
    },
  ]
}