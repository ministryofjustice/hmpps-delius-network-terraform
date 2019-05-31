
resource "aws_eip" "delius_ndelius_az1_lb" {
  vpc  = true
  tags = "${merge(var.tags, map("Name", "${var.environment_name}-delius-ndelius-az1-lb"), map("Do-Not-Delete", "true"))}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "delius_ndelius_az2_lb" {
  vpc  = true
  tags = "${merge(var.tags, map("Name", "${var.environment_name}-delius-ndelius-az2-lb"), map("Do-Not-Delete", "true"))}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "delius_ndelius_az3_lb" {
  vpc  = true
  tags = "${merge(var.tags, map("Name", "${var.environment_name}-delius-ndelius-az3-lb"), map("Do-Not-Delete", "true"))}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "delius_spg_az1_lb" {
  vpc  = true
  tags = "${merge(var.tags, map("Name", "${var.environment_name}-delius-spg-az1-lb"), map("Do-Not-Delete", "true"))}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "delius_spg_az2_lb" {
  vpc  = true
  tags = "${merge(var.tags, map("Name", "${var.environment_name}-delius-spg-az2-lb"), map("Do-Not-Delete", "true"))}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "delius_spg_az3_lb" {
  vpc  = true
  tags = "${merge(var.tags, map("Name", "${var.environment_name}-delius-spg-az3-lb"), map("Do-Not-Delete", "true"))}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "delius_interface_az1_lb" {
  vpc  = true
  tags = "${merge(var.tags, map("Name", "${var.environment_name}-delius-interface-az1-lb"), map("Do-Not-Delete", "true"))}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "delius_interface_az2_lb" {
  vpc  = true
  tags = "${merge(var.tags, map("Name", "${var.environment_name}-delius-interface-az2-lb"), map("Do-Not-Delete", "true"))}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "delius_interface_az3_lb" {
  vpc  = true
  tags = "${merge(var.tags, map("Name", "${var.environment_name}-delius-interface-az3-lb"), map("Do-Not-Delete", "true"))}"
  lifecycle {
    prevent_destroy = true
  }
}
