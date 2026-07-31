locals {
  is_postgresql = contains(
    ["postgres", "aurora-postgresql"],
    var.engine
  )

  database_port = var.port != null ? var.port : (
    local.is_postgresql ? 5432 : 3306
  )

  common_tags = merge(
    {
      Project   = var.name
      ManagedBy = "Terraform"
    },
    var.tags
  )
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-subnet-group"
    }
  )
}

resource "aws_security_group" "this" {
  name        = "${var.name}-database-sg"
  description = "Security group for ${var.name} database"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-database-sg"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "cidr" {
  for_each = toset(var.allowed_cidr_blocks)

  security_group_id = aws_security_group.this.id
  description       = "Database access from ${each.value}"
  cidr_ipv4         = each.value
  from_port         = local.database_port
  to_port           = local.database_port
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "security_group" {
  for_each = toset(var.allowed_security_group_ids)

  security_group_id            = aws_security_group.this.id
  description                  = "Database access from security group ${each.value}"
  referenced_security_group_id = each.value
  from_port                    = local.database_port
  to_port                      = local.database_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.this.id
  description       = "Allow all outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_db_parameter_group" "this" {
  count = var.use_aurora ? 0 : 1

  name        = "${var.name}-db-parameters"
  family      = var.parameter_group_family
  description = "Parameter group for ${var.name} RDS instance"

  parameter {
    name         = "max_connections"
    value        = var.max_connections
    apply_method = "pending-reboot"
  }

  dynamic "parameter" {
    for_each = local.is_postgresql ? [1] : []

    content {
      name         = "log_statement"
      value        = var.log_statement
      apply_method = "immediate"
    }
  }

  dynamic "parameter" {
    for_each = local.is_postgresql ? [1] : []

    content {
      name         = "work_mem"
      value        = var.work_mem
      apply_method = "immediate"
    }
  }

  tags = local.common_tags
}

resource "aws_rds_cluster_parameter_group" "this" {
  count = var.use_aurora ? 1 : 0

  name        = "${var.name}-aurora-parameters"
  family      = var.parameter_group_family
  description = "Cluster parameter group for ${var.name} Aurora cluster"

  parameter {
    name         = "max_connections"
    value        = var.max_connections
    apply_method = "pending-reboot"
  }

  dynamic "parameter" {
    for_each = local.is_postgresql ? [1] : []

    content {
      name         = "log_statement"
      value        = var.log_statement
      apply_method = "immediate"
    }
  }

  dynamic "parameter" {
    for_each = local.is_postgresql ? [1] : []

    content {
      name         = "work_mem"
      value        = var.work_mem
      apply_method = "immediate"
    }
  }

  tags = local.common_tags
}
