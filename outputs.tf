output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "database_type" {
  description = "Type of database created by the RDS module"
  value       = module.rds.database_type
}

output "database_engine" {
  description = "Database engine"
  value       = module.rds.engine
}

output "database_endpoint" {
  description = "Primary database endpoint"
  value       = module.rds.endpoint
}

output "database_reader_endpoint" {
  description = "Aurora reader endpoint; null for standard RDS"
  value       = module.rds.reader_endpoint
}

output "database_port" {
  description = "Database port"
  value       = module.rds.port
}

output "database_security_group_id" {
  description = "Security group ID attached to the database"
  value       = module.rds.security_group_id
}

output "database_subnet_group_name" {
  description = "DB subnet group name"
  value       = module.rds.db_subnet_group_name
}

output "database_connection_string" {
  description = "Database connection string without credentials"
  value       = module.rds.connection_string
}
