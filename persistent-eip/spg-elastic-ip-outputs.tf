# outputs

output "spg_az1_lb_eip" {
  value = {
      allocation_id = "${aws_eip.spg_az1_lb.id}",
      public_ip     = "${aws_eip.spg_az1_lb.public_ip}"
    }
}

output "spg_az2_lb_eip" {
  value = {
      allocation_id = "${aws_eip.spg_az2_lb.id}",
      public_ip     = "${aws_eip.spg_az2_lb.public_ip}"
    }
}

output "spg_az3_lb_eip" {
  value = {
      allocation_id = "${aws_eip.spg_az3_lb.id}",
      public_ip     = "${aws_eip.spg_az3_lb.public_ip}"
    }
}



