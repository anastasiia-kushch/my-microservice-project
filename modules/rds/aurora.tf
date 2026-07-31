resource "aws_rds_cluster" "this" {
  count = var.use_aurora ? 1 : 0

  cluster_identifier = "${var.name}-aurora"

  engine         = var.engine
  engine_version = var.engine_version

  database_name   = var.database_name
  master_username = var.username
  master_password = var.password
  port            = local.database_port

  db_subnet_group_name            = aws_db_subnet_group.this.name
  vpc_security_group_ids          = [aws_security_group.this.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this[0].name

  backup_retention_period = var.backup_retention_period

  storage_encrypted   = var.storage_encrypted
  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot
  apply_immediately   = var.apply_immediately

  copy_tags_to_snapshot = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-aurora"
    }
  )

  lifecycle {
    precondition {
      condition = contains(
        ["aurora-postgresql", "aurora-mysql"],
        var.engine
      )

      error_message = "When use_aurora is true, engine must be aurora-postgresql or aurora-mysql."
    }
  }
}

resource "aws_rds_cluster_instance" "this" {
  count = var.use_aurora ? var.aurora_instance_count : 0

  identifier = "${var.name}-aurora-${count.index + 1}"

  cluster_identifier = aws_rds_cluster.this[0].id

  instance_class = var.instance_class
  engine         = aws_rds_cluster.this[0].engine
  engine_version = aws_rds_cluster.this[0].engine_version

  db_subnet_group_name = aws_db_subnet_group.this.name

  publicly_accessible        = var.publicly_accessible
  auto_minor_version_upgrade = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-aurora-${count.index + 1}"
    }
  )
}
