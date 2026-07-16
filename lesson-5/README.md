# AWS Infrastructure Automation with Terraform

This project provides a modular Terraform configuration for automatically provisioning a basic AWS cloud infrastructure using the Infrastructure as Code (IaC) approach. The infrastructure is designed to ensure high availability, secure Terraform state management, and readiness for deploying containerized applications.

---

## Project Structure

```text
lesson-5/
│
├── main.tf                  # Main configuration file (calls and connects modules)
├── backend.tf               # Remote state configuration (S3 + DynamoDB Lock)
├── outputs.tf               # Aggregated infrastructure outputs
├── README.md                # Project documentation
│
└── modules/
    ├── s3-backend/
    │   ├── s3.tf
    │   ├── dynamodb.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── vpc/
    │   ├── vpc.tf
    │   ├── routes.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    └── ecr/
        ├── ecr.tf
        ├── variables.tf
        └── outputs.tf
```

---

# Infrastructure Modules

## 1. S3 Backend (`modules/s3-backend`)

This module manages the remote Terraform state.

### Features

- Creates an **S3 Bucket** for storing `terraform.tfstate`
- Enables **versioning** to recover previous state versions
- Uses **AES-256 encryption** for secure state storage
- Creates a **DynamoDB table** for Terraform state locking
- Prevents concurrent Terraform executions using the `LockID` primary key

---

## 2. VPC Networking (`modules/vpc`)

Creates a highly available networking environment in the **AWS us-west-2** region.

### Resources

- **VPC**
- **3 Public Subnets**
  - Distributed across Availability Zones:
    - us-west-2a
    - us-west-2b
    - us-west-2c
  - Connected to the Internet through an Internet Gateway
  - Intended for Load Balancers, Nginx, Bastion Hosts, etc.

- **3 Private Subnets**
  - One subnet per Availability Zone
  - No direct Internet access
  - Outbound traffic routed through a NAT Gateway
  - Intended for application servers (e.g. Django) and databases (PostgreSQL)

- **Internet Gateway**
- **NAT Gateway**
- **Route Tables and Associations**

This architecture follows AWS best practices for High Availability.

---

## 3. Elastic Container Registry (`modules/ecr`)

Creates a private Amazon ECR repository for Docker images.

### Features

- Private Docker image repository
- `scan_on_push = true`
  - Automatically scans pushed images for vulnerabilities (CVEs)
- Image tag mutability set to **MUTABLE**

---

# Terraform Workflow

Before running Terraform, make sure your AWS credentials are configured.

Example:

```text
~/.aws/credentials
```

---

## 1. Initialize Terraform

Downloads required providers and initializes the remote backend.

```bash
terraform init
```

---

## 2. Preview Infrastructure Changes

Shows the execution plan without modifying infrastructure.

```bash
terraform plan
```

Terraform will display resources that will be:

- `+` created
- `~` modified
- `-` destroyed

---

## 3. Deploy Infrastructure

Creates all AWS resources.

```bash
terraform apply
```

Terraform will ask for confirmation:

```text
Enter a value: yes
```

---

## 4. Destroy Infrastructure

Removes every resource created by this project.

```bash
terraform destroy
```

---

# Infrastructure Summary

The project provisions the following AWS resources:

- Remote Terraform backend using S3
- DynamoDB table for state locking
- Custom VPC
- 3 Public Subnets
- 3 Private Subnets
- Internet Gateway
- NAT Gateway
- Route Tables
- Amazon Elastic Container Registry (ECR)

---

# Technologies

- Terraform
- AWS VPC
- Amazon S3
- Amazon DynamoDB
- Amazon ECR
- Infrastructure as Code (IaC)

---

# Architecture Overview

```
                 Internet
                     │
             Internet Gateway
                     │
        ┌──────────────────────────┐
        │          VPC             │
        │                          │
        │  Public Subnets (3 AZs)  │
        │        │                 │
        │     NAT Gateway          │
        │        │                 │
        │ Private Subnets (3 AZs)  │
        │                          │
        └──────────────────────────┘

Terraform State
     │
     ├── S3 Bucket
     └── DynamoDB Lock Table

Docker Images
     │
     └── Amazon ECR
```
