resource "aws_db_instance" "this" {
  count = var.use_aurora ? 0 : 1

  identifier = "${var.name}-rds"

  engine         = var.engine
  engine_version = var.engine_version

  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted

  db_name  = var.database_name
  username = var.username
  password = var.password
  port     = local.database_port

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  parameter_group_name   = aws_db_parameter_group.this[0].name

  multi_az            = var.multi_az
  publicly_accessible = var.publicly_accessible

  backup_retention_period = var.backup_retention_period

  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot
  apply_immediately   = var.apply_immediately

  auto_minor_version_upgrade = true
  copy_tags_to_snapshot      = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-rds"
    }
  )

  lifecycle {
    precondition {
      condition = contains(
        ["postgres", "mysql"],
        var.engine
      )

      error_message = "When use_aurora is false, engine must be postgres or mysql."
    }
  }
}
