resource "aws_eip" "spg_az1_lb" {
  vpc = true
  tags = merge(
    var.tags,
    {
      "Name" = "${var.environment_name}-spg-az1-lb"
    },
    {
      "Do-Not-Delete" = "true"
    },
  )
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "spg_az2_lb" {
  vpc = true
  tags = merge(
    var.tags,
    {
      "Name" = "${var.environment_name}-spg-az2-lb"
    },
    {
      "Do-Not-Delete" = "true"
    },
  )
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "spg_az3_lb" {
  vpc = true
  tags = merge(
    var.tags,
    {
      "Name" = "${var.environment_name}-spg-az3-lb"
    },
    {
      "Do-Not-Delete" = "true"
    },
  )
  lifecycle {
    prevent_destroy = true
  }
}

