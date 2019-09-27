terragrunt = {
  include {
    path = "${find_in_parent_folders()}"
  }
}

whitelist_monitoring_ips = [
  "109.148.137.148/32", #Don Home
  "81.134.202.29/32",   #Moj VPN
  "217.33.148.210/32",  #Digital Studio
  "82.38.248.151/32",   #SMJ Office
  "194.75.210.208/28",  #BCL
  "213.48.246.99/32",   #BCL
]
