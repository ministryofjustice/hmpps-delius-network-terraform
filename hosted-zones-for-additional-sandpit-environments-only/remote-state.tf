data "terraform_remote_state" "vpc_main_sandpit" {
  backend = "s3"

  config {
    bucket = "tf-eu-west-2-hmpps-delius-core-sandpit-remote-state"
    key    = "vpc/terraform.tfstate"
    region = "${var.region}"
  }
}


