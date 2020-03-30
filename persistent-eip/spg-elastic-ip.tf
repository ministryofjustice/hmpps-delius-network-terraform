
resource "aws_eip" "spg_az1_lb" {
  vpc  = true
  tags = "${merge(var.tags, map("Name", "${var.environment_name}-spg-az1-lb"), map("Do-Not-Delete", "true"))}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "spg_az2_lb" {
  vpc  = true
  tags = "${merge(var.tags, map("Name", "${var.environment_name}-spg-az2-lb"), map("Do-Not-Delete", "true"))}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "spg_az3_lb" {
  vpc  = true
  tags = "${merge(var.tags, map("Name", "${var.environment_name}-spg-az3-lb"), map("Do-Not-Delete", "true"))}"
  lifecycle {
    prevent_destroy = true
  }
}


resource "aws_eip" "spg_dpg_az1_lb" {
  vpc  = true
  tags = "${merge(var.tags, map("Name", "${var.environment_name}-spg-dpg-az1-lb"), map("Do-Not-Delete", "true"))}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "spg_dpg_az2_lb" {
  vpc  = true
  tags = "${merge(var.tags, map("Name", "${var.environment_name}-spg-dpg-az2-lb"), map("Do-Not-Delete", "true"))}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "spg_dpg_az3_lb" {
  vpc  = true
  tags = "${merge(var.tags, map("Name", "${var.environment_name}-spg-dpg-az3-lb"), map("Do-Not-Delete", "true"))}"
  lifecycle {
    prevent_destroy = true
  }
}
