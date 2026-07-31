output "database_type" {
  description = "Type of database created by the module"
  value       = var.use_aurora ? "aurora" : "rds"
}

output "engine" {
  description = "Database engine"
  value       = var.engine
}

output "port" {
  description = "Database port"
  value       = local.database_port
}

output "endpoint" {
  description = "Primary database endpoint"
  value = var.use_aurora ? (
    aws_rds_cluster.this[0].endpoint
    ) : (
    aws_db_instance.this[0].address
  )
}

output "reader_endpoint" {
  description = "Aurora reader endpoint; null for a standard RDS instance"
  value = var.use_aurora ? (
    aws_rds_cluster.this[0].reader_endpoint
  ) : null
}

output "database_name" {
  description = "Name of the initial database"
  value       = var.database_name
}

output "security_group_id" {
  description = "ID of the database security group"
  value       = aws_security_group.this.id
}

output "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  value       = aws_db_subnet_group.this.name
}

output "rds_instance_id" {
  description = "ID of the standard RDS instance; null when Aurora is enabled"
  value = var.use_aurora ? null : (
    aws_db_instance.this[0].id
  )
}

output "aurora_cluster_id" {
  description = "ID of the Aurora cluster; null when standard RDS is used"
  value = var.use_aurora ? (
    aws_rds_cluster.this[0].id
  ) : null
}

output "connection_string" {
  description = "Database connection string without credentials"
  value = format(
    "%s://%s:%s/%s",
    local.is_postgresql ? "postgresql" : "mysql",
    var.use_aurora ? aws_rds_cluster.this[0].endpoint : aws_db_instance.this[0].address,
    local.database_port,
    var.database_name
  )
}
