# outputs

output "delius_ndelius_az1_lb_eip" {
  value = {
    allocation_id = "${aws_eip.delius_ndelius_az1_lb.id}",
    public_ip     = "${aws_eip.delius_ndelius_az1_lb.public_ip}"
  }
}

output "delius_ndelius_az2_lb_eip" {
  value = {
    allocation_id = "${aws_eip.delius_ndelius_az2_lb.id}",
    public_ip     = "${aws_eip.delius_ndelius_az2_lb.public_ip}"
  }
}

output "delius_ndelius_az3_lb_eip" {
  value = {
    allocation_id = "${aws_eip.delius_ndelius_az3_lb.id}",
    public_ip     = "${aws_eip.delius_ndelius_az3_lb.public_ip}"
  }
}

output "delius_spg_az1_lb_eip" {
  value = {
    allocation_id = "${aws_eip.delius_spg_az1_lb.id}",
    public_ip     = "${aws_eip.delius_spg_az1_lb.public_ip}"
  }
}

output "delius_spg_az2_lb_eip" {
  value = {
    allocation_id = "${aws_eip.delius_spg_az2_lb.id}",
    public_ip     = "${aws_eip.delius_spg_az2_lb.public_ip}"
  }
}

output "delius_spg_az3_lb_eip" {
  value = {
    allocation_id = "${aws_eip.delius_spg_az3_lb.id}",
    public_ip     = "${aws_eip.delius_spg_az3_lb.public_ip}"
  }
}


output "delius_interface_az1_lb_eip" {
  value = {
    allocation_id = "${aws_eip.delius_interface_az1_lb.id}",
    public_ip     = "${aws_eip.delius_interface_az1_lb.public_ip}"
  }
}

output "delius_interface_az2_lb_eip" {
  value = {
    allocation_id = "${aws_eip.delius_interface_az2_lb.id}",
    public_ip     = "${aws_eip.delius_interface_az2_lb.public_ip}"
  }
}

output "delius_interface_az3_lb_eip" {
  value = {
    allocation_id = "${aws_eip.delius_interface_az3_lb.id}",
    public_ip     = "${aws_eip.delius_interface_az3_lb.public_ip}"
  }
}

output "delius_pwm_az1_lb_eip" {
  value = {
    allocation_id = "${aws_eip.delius_pwm_az1_lb.id}",
    public_ip     = "${aws_eip.delius_pwm_az1_lb.public_ip}"
  }
}

output "delius_pwm_az2_lb_eip" {
  value = {
    allocation_id = "${aws_eip.delius_pwm_az2_lb.id}",
    public_ip     = "${aws_eip.delius_pwm_az2_lb.public_ip}"
  }
}

output "delius_pwm_az3_lb_eip" {
  value = {
    allocation_id = "${aws_eip.delius_pwm_az3_lb.id}",
    public_ip     = "${aws_eip.delius_pwm_az3_lb.public_ip}"
  }
}
