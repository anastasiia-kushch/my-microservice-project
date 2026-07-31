# Universal Terraform RDS Module

## Project Overview

This project contains a reusable Terraform module for creating either:

* a standard Amazon RDS instance;
* an Amazon Aurora cluster.

The database type is selected using the `use_aurora` variable.

The module automatically creates:

* DB Subnet Group;
* Security Group;
* DB Parameter Group;
* standard RDS instance or Aurora cluster;
* Aurora cluster instances;
* outputs for endpoint, port, engine, subnet group and security group.

The module supports:

* PostgreSQL;
* MySQL;
* Aurora PostgreSQL;
* Aurora MySQL.

---

## Project Structure

```text
.
├── backend.tf
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── modules/
│   ├── s3-backend/
│   ├── vpc/
│   ├── ecr/
│   ├── eks/
│   ├── jenkins/
│   ├── argo_cd/
│   └── rds/
│       ├── rds.tf
│       ├── aurora.tf
│       ├── shared.tf
│       ├── variables.tf
│       └── outputs.tf
└── charts/
    └── django-app/
```

---

## RDS Module Structure

```text
modules/rds/
├── rds.tf
├── aurora.tf
├── shared.tf
├── variables.tf
└── outputs.tf
```

### File responsibilities

* `rds.tf` creates a standard `aws_db_instance`.
* `aurora.tf` creates an `aws_rds_cluster` and Aurora instances.
* `shared.tf` creates the subnet group, security group and parameter groups.
* `variables.tf` contains typed module variables, descriptions, defaults and validations.
* `outputs.tf` returns database connection information and resource identifiers.

---

## Conditional Database Creation

The main switch is:

```hcl
use_aurora = false
```

When:

```hcl
use_aurora = false
```

Terraform creates one standard RDS instance:

```hcl
resource "aws_db_instance" "this"
```

When:

```hcl
use_aurora = true
```

Terraform creates:

```hcl
resource "aws_rds_cluster" "this"
resource "aws_rds_cluster_instance" "this"
```

The conditional logic uses the Terraform `count` argument.

Example:

```hcl
count = var.use_aurora ? 1 : 0
```

---

## Standard PostgreSQL RDS Example

```hcl
module "rds" {
  source = "./modules/rds"

  name       = "lesson-db"
  use_aurora = false

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  engine                 = "postgres"
  engine_version         = "16.3"
  parameter_group_family = "postgres16"
  instance_class         = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"

  database_name = "appdb"
  username      = "dbadmin"
  password      = var.db_password

  multi_az            = false
  publicly_accessible = false

  allowed_cidr_blocks = []

  tags = {
    Environment = "dev"
    Lesson      = "db-module"
  }
}
```

This configuration creates one PostgreSQL RDS instance.

---

## Standard MySQL RDS Example

To create a MySQL instance, change the engine and parameter group family:

```hcl
module "rds" {
  source = "./modules/rds"

  name       = "lesson-mysql"
  use_aurora = false

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  engine                 = "mysql"
  engine_version         = "8.0"
  parameter_group_family = "mysql8.0"
  instance_class         = "db.t3.micro"

  database_name = "appdb"
  username      = "dbadmin"
  password      = var.db_password

  multi_az            = false
  publicly_accessible = false
}
```

The module automatically uses port `3306` for MySQL when the `port` variable is not provided.

---

## Aurora PostgreSQL Example

```hcl
module "rds" {
  source = "./modules/rds"

  name       = "lesson-aurora-postgres"
  use_aurora = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  engine                 = "aurora-postgresql"
  engine_version         = "16.3"
  parameter_group_family = "aurora-postgresql16"
  instance_class         = "db.r6g.large"

  aurora_instance_count = 1

  database_name = "appdb"
  username      = "dbadmin"
  password      = var.db_password

  publicly_accessible = false
}
```

This configuration creates:

* one Aurora cluster;
* one Aurora writer instance;
* one cluster parameter group;
* one security group;
* one DB subnet group.

To create more Aurora instances:

```hcl
aurora_instance_count = 2
```

Aurora automatically selects a writer instance. Additional cluster instances can act as readers.

---

## Aurora MySQL Example

```hcl
module "rds" {
  source = "./modules/rds"

  name       = "lesson-aurora-mysql"
  use_aurora = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  engine                 = "aurora-mysql"
  engine_version         = "8.0.mysql_aurora.3.08.0"
  parameter_group_family = "aurora-mysql8.0"
  instance_class         = "db.r6g.large"

  aurora_instance_count = 1

  database_name = "appdb"
  username      = "dbadmin"
  password      = var.db_password

  publicly_accessible = false
}
```

---

## Changing the Database Type

### Standard PostgreSQL

```hcl
use_aurora            = false
engine                = "postgres"
parameter_group_family = "postgres16"
```

### Standard MySQL

```hcl
use_aurora            = false
engine                = "mysql"
parameter_group_family = "mysql8.0"
```

### Aurora PostgreSQL

```hcl
use_aurora            = true
engine                = "aurora-postgresql"
parameter_group_family = "aurora-postgresql16"
```

### Aurora MySQL

```hcl
use_aurora            = true
engine                = "aurora-mysql"
parameter_group_family = "aurora-mysql8.0"
```

The `engine`, `engine_version` and `parameter_group_family` values must be compatible with each other.

---

## Changing the Instance Class

The instance type is controlled by:

```hcl
instance_class = "db.t3.micro"
```

Example for a larger standard RDS instance:

```hcl
instance_class = "db.t3.small"
```

Example for Aurora:

```hcl
instance_class = "db.r6g.large"
```

Aurora does not support every RDS instance class. The selected class must support the chosen Aurora engine and AWS region.

---

## Multi-AZ Configuration

For a standard RDS instance:

```hcl
multi_az = true
```

This creates a standby database instance in another Availability Zone.

The `multi_az` variable applies only to standard RDS.

Aurora provides high availability through multiple cluster instances distributed across Availability Zones.

---

## Network Access

The database is placed inside the subnets provided through:

```hcl
subnet_ids = module.vpc.private_subnet_ids
```

The module creates an AWS DB Subnet Group from these subnets.

At least two subnet IDs must be provided.

### Allow access from CIDR blocks

```hcl
allowed_cidr_blocks = [
  "10.0.0.0/16"
]
```

### Allow access from another Security Group

```hcl
allowed_security_group_ids = [
  module.eks.node_security_group_id
]
```

For production environments, access should be limited to trusted application security groups instead of large CIDR ranges.

---

## Public Access

By default, the database is private:

```hcl
publicly_accessible = false
```

This is the recommended configuration.

Setting it to `true` does not automatically make the database reachable from the Internet. Public subnets, routing and security group rules must also allow access.

---

## Parameter Groups

The module creates a parameter group automatically.

For standard RDS:

```hcl
aws_db_parameter_group
```

For Aurora:

```hcl
aws_rds_cluster_parameter_group
```

The following base parameters are supported:

```hcl
max_connections = "100"
log_statement   = "ddl"
work_mem        = "4096"
```

`log_statement` and `work_mem` are added only for PostgreSQL-compatible engines.

`max_connections` is used for both PostgreSQL and MySQL-compatible engines.

---

## Module Variables

| Variable                     | Type           |         Default | Description                                     |
| ---------------------------- | -------------- | --------------: | ----------------------------------------------- |
| `name`                       | `string`       |   `"lesson-db"` | Prefix used for database resource names         |
| `use_aurora`                 | `bool`         |         `false` | Selects Aurora instead of standard RDS          |
| `vpc_id`                     | `string`       |        Required | VPC ID where database resources are created     |
| `subnet_ids`                 | `list(string)` |        Required | Subnets used by the DB Subnet Group             |
| `allowed_security_group_ids` | `list(string)` |            `[]` | Security groups allowed to access the database  |
| `allowed_cidr_blocks`        | `list(string)` |            `[]` | IPv4 CIDR blocks allowed to access the database |
| `engine`                     | `string`       |    `"postgres"` | Database engine                                 |
| `engine_version`             | `string`       |          `null` | Database engine version                         |
| `parameter_group_family`     | `string`       |        Required | AWS parameter group family                      |
| `instance_class`             | `string`       | `"db.t3.micro"` | RDS or Aurora instance class                    |
| `allocated_storage`          | `number`       |            `20` | Initial RDS storage in GiB                      |
| `max_allocated_storage`      | `number`       |           `100` | Maximum RDS storage autoscaling limit           |
| `storage_type`               | `string`       |         `"gp3"` | Standard RDS storage type                       |
| `database_name`              | `string`       |       `"appdb"` | Initial database name                           |
| `username`                   | `string`       |     `"dbadmin"` | Master database username                        |
| `password`                   | `string`       |        Required | Master database password                        |
| `port`                       | `number`       |          `null` | Custom database port                            |
| `multi_az`                   | `bool`         |         `false` | Enables Multi-AZ for standard RDS               |
| `aurora_instance_count`      | `number`       |             `1` | Number of Aurora instances                      |
| `publicly_accessible`        | `bool`         |         `false` | Enables public accessibility                    |
| `backup_retention_period`    | `number`       |             `7` | Backup retention period in days                 |
| `deletion_protection`        | `bool`         |         `false` | Protects the database from deletion             |
| `skip_final_snapshot`        | `bool`         |          `true` | Skips the final snapshot during deletion        |
| `apply_immediately`          | `bool`         |         `false` | Applies modifications immediately               |
| `storage_encrypted`          | `bool`         |          `true` | Enables database storage encryption             |
| `max_connections`            | `string`       |         `"100"` | Maximum database connections parameter          |
| `log_statement`              | `string`       |         `"ddl"` | PostgreSQL statement logging parameter          |
| `work_mem`                   | `string`       |        `"4096"` | PostgreSQL work memory parameter                |
| `tags`                       | `map(string)`  |            `{}` | Additional resource tags                        |

---

## Module Outputs

| Output                 | Description                                       |
| ---------------------- | ------------------------------------------------- |
| `database_type`        | Returns `rds` or `aurora`                         |
| `engine`               | Selected database engine                          |
| `port`                 | Database port                                     |
| `endpoint`             | Primary database endpoint                         |
| `reader_endpoint`      | Aurora reader endpoint or `null` for standard RDS |
| `database_name`        | Initial database name                             |
| `security_group_id`    | Database security group ID                        |
| `db_subnet_group_name` | DB Subnet Group name                              |
| `rds_instance_id`      | Standard RDS instance ID                          |
| `aurora_cluster_id`    | Aurora cluster ID                                 |
| `connection_string`    | Connection string without credentials             |

---

## Password Configuration

The database password is declared as a sensitive root variable:

```hcl
variable "db_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}
```

Create a local `terraform.tfvars` file:

```hcl
db_password = "ChangeMe123!"
```

The following files should be excluded from Git:

```gitignore
terraform.tfvars
*.auto.tfvars
```

Do not commit real database credentials to the repository.

For production environments, credentials should be stored in AWS Secrets Manager or another dedicated secrets management system.

---

## Terraform Backend

Terraform state is stored remotely using:

* Amazon S3;
* Amazon DynamoDB for state locking.

Initialize Terraform:

```bash
terraform init
```

If backend settings have changed:

```bash
terraform init -reconfigure
```

---

## Validation

Format all Terraform files:

```bash
terraform fmt -recursive
```

Validate the configuration:

```bash
terraform validate
```

Create an execution plan:

```bash
terraform plan
```

The project has been validated successfully with:

```text
Success! The configuration is valid.
```

---

## Infrastructure Deployment

Create an execution plan:

```bash
terraform plan
```

Apply the infrastructure:

```bash
terraform apply
```

Review the planned changes before confirming the deployment.

Do not use `--auto-approve` unless the plan has been reviewed carefully.

---

## Important Cost Warning

This project can create billable AWS resources, including:

* Amazon RDS;
* Amazon Aurora;
* Amazon EKS;
* NAT Gateway;
* Load Balancers;
* EC2-backed Kubernetes worker nodes.

Aurora, EKS and NAT Gateway can generate significant costs.

Do not leave unused infrastructure running.

---

## Destroying Infrastructure

Delete all Terraform-managed resources after testing:

```bash
terraform destroy
```

Review the destroy plan and confirm the operation.

The project also manages the S3 bucket and DynamoDB table used by the Terraform backend.

Deleting the backend resources can make the remote state unavailable.

A safer order is:

1. destroy application and infrastructure resources;
2. keep the remote backend until the main infrastructure is removed;
3. delete the backend separately only when it is no longer required.

If the backend was deleted, recreate the S3 bucket and DynamoDB table before using the same backend configuration again.

---

## Implemented Features

* Reusable Terraform RDS module;
* conditional RDS or Aurora creation;
* PostgreSQL support;
* MySQL support;
* Aurora PostgreSQL support;
* Aurora MySQL support;
* typed variables;
* variable descriptions;
* default values;
* variable validation;
* DB Subnet Group;
* database Security Group;
* CIDR-based ingress rules;
* Security Group-based ingress rules;
* standard DB Parameter Group;
* Aurora Cluster Parameter Group;
* encrypted storage;
* automated backups;
* storage autoscaling for standard RDS;
* Multi-AZ support for standard RDS;
* Aurora reader endpoint;
* reusable module outputs;
* Terraform remote state in S3;
* DynamoDB state locking.

