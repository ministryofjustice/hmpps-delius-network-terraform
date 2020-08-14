# define security groups only for mis

# db
resource "aws_security_group" "mis_db_in" {
  name        = "${var.environment_name}-delius-core-${var.mis_app_name}-db-in"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "db incoming"
  tags = merge(
    data.terraform_remote_state.vpc.outputs.tags,
    {
      "Name" = "${var.environment_name}_${var.mis_app_name}_db_in"
      "Type" = "DB"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

#Common
resource "aws_security_group" "mis_common" {
  name        = "${var.environment_name}-delius-core-${var.mis_app_name}-common-in"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "common sg"
  tags = merge(
    data.terraform_remote_state.vpc.outputs.tags,
    {
      "Name" = "${var.environment_name}_${var.mis_app_name}_common_in"
      "Type" = "WEB"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

#App
resource "aws_security_group" "mis_app_lb" {
  name        = "${var.environment_name}-delius-core-${var.mis_app_name}-api-lb-in"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "api incoming"
  tags = merge(
    data.terraform_remote_state.vpc.outputs.tags,
    {
      "Name" = "${var.environment_name}_${var.mis_app_name}_api_lb_in"
      "Type" = "API"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "mis_app_in" {
  name        = "${var.environment_name}-delius-core-${var.mis_app_name}-api-instance-in"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "api incoming"
  tags = merge(
    data.terraform_remote_state.vpc.outputs.tags,
    {
      "Name" = "${var.environment_name}_${var.mis_app_name}_api_instance_in"
      "Type" = "API"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

#LDAP
resource "aws_security_group" "ldap_lb" {
  name        = "${var.environment_name}-delius-core-${var.mis_app_name}-ldap-lb"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "api lb incoming"
  tags = merge(
    data.terraform_remote_state.vpc.outputs.tags,
    {
      "Name" = "${var.environment_name}_${var.mis_app_name}_ldap_lb"
      "Type" = "API"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

# LDAP Proxy
resource "aws_security_group" "ldap_proxy" {
  name        = "${var.environment_name}-delius-core-${var.mis_app_name}-ldap-proxy"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "api proxy incoming"
  tags = merge(
    data.terraform_remote_state.vpc.outputs.tags,
    {
      "Name" = "${var.environment_name}_${var.mis_app_name}_ldap_proxy"
      "Type" = "API"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "ldap_inst" {
  name        = "${var.environment_name}-delius-core-${var.mis_app_name}-ldap-inst"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "api instance"
  tags = merge(
    data.terraform_remote_state.vpc.outputs.tags,
    {
      "Name" = "${var.environment_name}_${var.mis_app_name}_ldap_inst"
      "Type" = "API"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

# jumphost
resource "aws_security_group" "mis_jumphost" {
  name        = "${var.environment_name}-delius-core-${var.mis_app_name}-jumphost"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "jumphost sg for rdp"
  tags = merge(
    data.terraform_remote_state.vpc.outputs.tags,
    {
      "Name" = "${var.environment_name}_${var.mis_app_name}_jumphost"
      "Type" = "RDP"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

# nextcloud
resource "aws_security_group" "nextcloud_lb" {
  name        = "${var.environment_name}-delius-core-${var.mis_app_name}-nextcloud-lb"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "nextcloud lb incoming"
  tags = merge(
    data.terraform_remote_state.vpc.outputs.tags,
    {
      "Name" = "${var.environment_name}-${var.mis_app_name}-nextcloud-lb"
      "Type" = "API"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

# nextcloud efs
resource "aws_security_group" "nextcloud_efs" {
  name        = "${var.environment_name}-delius-core-${var.mis_app_name}-nextcloud-efs"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "sg for nextcloud efs"
  tags = merge(
    data.terraform_remote_state.vpc.outputs.tags,
    {
      "Name" = "${var.environment_name}-${var.mis_app_name}-nextcloud-efs"
      "Type" = "EFS"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

#nextcloud db
resource "aws_security_group" "nextcloud_db" {
  name        = "${var.environment_name}-delius-core-${var.mis_app_name}-nextcloud-db"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "sg for nextcloud db"
  tags = merge(
    data.terraform_remote_state.vpc.outputs.tags,
    {
      "Name" = "${var.environment_name}-${var.mis_app_name}-nextcloud-db"
      "Type" = "DB"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

#nextcloud samba
resource "aws_security_group" "samba_lb" {
  name        = "${var.environment_name}-delius-core-${var.mis_app_name}-samba"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "samba sg"
  tags = merge(
    data.terraform_remote_state.vpc.outputs.tags,
    {
      "Name" = "${var.environment_name}-${var.mis_app_name}-samba"
      "Type" = "SAMBA"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

#bws to ldap
resource "aws_security_group" "bws_ldap" {
  name        = "${var.environment_name}-delius-core-${var.mis_app_name}-ldap-out"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "sg for bws ldap out"
  tags = merge(
    data.terraform_remote_state.vpc.outputs.tags,
    {
      "Name" = "${var.environment_name}_${var.mis_app_name}_ldap"
      "Type" = "LDAP"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

