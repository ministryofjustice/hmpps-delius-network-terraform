terragrunt = {

  include {
    path = "${find_in_parent_folders()}"
  }
}

whitelist_monitoring_ips = [
  "51.148.142.120/32",  #Brett Home
  "109.148.137.148/32", #Don Home
  "81.134.202.29/32",   #Moj VPN
  "217.33.148.210/32",  #Digital Studio
  "51.148.144.179/32", #Brett office
  "82.38.248.151/32",  #SMJ Office
]
