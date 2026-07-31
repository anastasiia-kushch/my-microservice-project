variable "name" {
  description = "Name prefix for RDS resources"
  type        = string
  default     = "lesson-db"
}

variable "use_aurora" {
  description = "Create an Aurora cluster instead of a standard RDS instance"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "ID of the VPC where the database will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of private subnet IDs for the DB subnet group"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least two subnet IDs must be provided."
  }
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to connect to the database"
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to connect to the database"
  type        = list(string)
  default     = []
}

variable "engine" {
  description = "Database engine: postgres, mysql, aurora-postgresql or aurora-mysql"
  type        = string
  default     = "postgres"

  validation {
    condition = contains([
      "postgres",
      "mysql",
      "aurora-postgresql",
      "aurora-mysql"
    ], var.engine)

    error_message = "Engine must be postgres, mysql, aurora-postgresql or aurora-mysql."
  }
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = null
}

variable "parameter_group_family" {
  description = "Parameter group family, for example postgres16, mysql8.0 or aurora-postgresql16"
  type        = string
}

variable "instance_class" {
  description = "Instance class used by RDS or Aurora instances"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GiB for a standard RDS instance"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum storage in GiB for RDS storage autoscaling; 0 disables autoscaling"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Storage type for a standard RDS instance"
  type        = string
  default     = "gp3"
}

variable "database_name" {
  description = "Name of the initial database"
  type        = string
  default     = "appdb"
}

variable "username" {
  description = "Master database username"
  type        = string
  default     = "dbadmin"
}

variable "password" {
  description = "Master database password"
  type        = string
  sensitive   = true
}

variable "port" {
  description = "Database port. When null, the module selects the default port for the engine"
  type        = number
  default     = null
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment for a standard RDS instance"
  type        = bool
  default     = false
}

variable "aurora_instance_count" {
  description = "Number of instances in the Aurora cluster"
  type        = number
  default     = 1

  validation {
    condition     = var.aurora_instance_count >= 1
    error_message = "Aurora instance count must be at least 1."
  }
}

variable "publicly_accessible" {
  description = "Whether the database instance is publicly accessible"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups"
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip the final snapshot when deleting the database"
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Apply database modifications immediately"
  type        = bool
  default     = false
}

variable "storage_encrypted" {
  description = "Enable encryption for database storage"
  type        = bool
  default     = true
}

variable "max_connections" {
  description = "Value of the max_connections database parameter"
  type        = string
  default     = "100"
}

variable "log_statement" {
  description = "Value of the PostgreSQL log_statement parameter"
  type        = string
  default     = "ddl"
}

variable "work_mem" {
  description = "Value of the PostgreSQL work_mem parameter"
  type        = string
  default     = "4096"
}

variable "tags" {
  description = "Tags applied to all supported resources"
  type        = map(string)
  default     = {}
}
