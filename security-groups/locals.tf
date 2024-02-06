locals {
  counterpart_mp_env_cidr = {
    delius-mis-dev  = "10.26.24.0/21" #mp hmpps-development
    delius-test     = "10.26.8.0/21"  #mp hmpps-test
    delius-training = "10.26.8.0/21"  #mp hmpps-test
    delius-stage    = "10.27.0.0/21"  #mp hmpps-preproduction
    delius-pre-prod = "10.27.0.0/21"  #mp hmpps-preproduction
    delius-prod     = "10.27.8.0/21"  #mp hmpps-production
  }
}