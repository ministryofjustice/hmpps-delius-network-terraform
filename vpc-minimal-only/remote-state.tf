data "terraform_remote_state" "vpc_main" {
  backend = "s3"

  config {
    bucket = "${var.network_and_legacy_spg_remote_state_bucket_name}"
    key    = "vpc/terraform.tfstate"
    region = "${var.region}"
  }
}


