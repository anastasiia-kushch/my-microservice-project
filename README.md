# Final DevOps Project – AWS Infrastructure with Terraform

## Project Overview

This project demonstrates a complete production-ready DevOps infrastructure on AWS built with Terraform.

The infrastructure includes networking, Kubernetes, container registry, relational database, CI/CD pipeline, GitOps deployment, and monitoring.

All infrastructure components are provisioned automatically using Infrastructure as Code (IaC).

---

# Project Architecture

```
Developer
     │
     ▼
 GitHub Repository
     │
     ▼
   Jenkins
(Build & Push Docker Image)
     │
     ▼
 Amazon ECR
     │
     ▼
   Argo CD
 (GitOps Sync)
     │
     ▼
 Amazon EKS
     │
     ▼
 Django Application
     │
     ├──────────────┐
     ▼              ▼
 Prometheus      Grafana
     │
     ▼
 Monitoring
```

---

# Technologies

- Terraform
- AWS VPC
- Amazon EKS
- Amazon ECR
- Amazon RDS (PostgreSQL)
- Jenkins
- Argo CD
- Helm
- Kubernetes
- Prometheus
- Grafana
- Docker
- Django

---

# Project Structure

```text
.
├── backend.tf
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── Dockerfile
├── Jenkinsfile
├── README.md
│
├── charts/
│   └── django-app/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│
├── modules/
│   ├── s3-backend/
│   ├── vpc/
│   ├── ecr/
│   ├── eks/
│   ├── rds/
│   ├── jenkins/
│   ├── argo_cd/
│   └── monitoring/
│
├── core/
├── manage.py
└── requirements.txt
```

---

# Terraform Modules

## S3 Backend

Creates:

- S3 bucket for Terraform remote state
- DynamoDB table for state locking

---

## VPC

Creates:

- VPC
- Public subnets
- Private subnets
- Internet Gateway
- NAT Gateway
- Route Tables

---

## EKS

Creates:

- Amazon EKS Cluster
- Managed Node Group
- IAM Roles
- OIDC Provider
- AWS EBS CSI Driver

---

## ECR

Creates:

- Amazon Elastic Container Registry
- Lifecycle Policy
- Repository Policy

---

## RDS

Universal Terraform module supporting:

- Standard PostgreSQL / MySQL
- Aurora PostgreSQL / Aurora MySQL

Features:

- DB Subnet Group
- Security Group
- Parameter Group
- Conditional deployment using:

```hcl
use_aurora = true
```

or

```hcl
use_aurora = false
```

---

## Jenkins

Installs Jenkins using Helm.

Features:

- Persistent storage
- IAM Role for Service Account (IRSA)
- Kaniko Docker builds
- Amazon ECR authentication
- Kubernetes Agents

---

## Argo CD

Installs Argo CD using Helm.

Features:

- GitOps deployment
- Automatic synchronization
- Self-healing
- Automatic pruning

---

## Monitoring

Installs kube-prometheus-stack.

Includes:

- Prometheus
- Grafana
- Alertmanager
- Node Exporter
- kube-state-metrics

---

# Deployment

Initialize Terraform:

```bash
terraform init
```

Validate configuration:

```bash
terraform validate
```

Review execution plan:

```bash
terraform plan
```

Deploy infrastructure:

```bash
terraform apply
```

---

# Configure kubectl

```bash
aws eks update-kubeconfig \
  --region us-west-2 \
  --name lesson-7-eks
```

---

# Verify Infrastructure

Check Kubernetes resources:

```bash
kubectl get nodes

kubectl get all -n jenkins

kubectl get all -n argocd

kubectl get all -n monitoring
```

---

# Access Services

## Jenkins

```bash
kubectl port-forward svc/jenkins 8080:8080 -n jenkins
```

Open:

```
http://localhost:8080
```

---

## Argo CD

```bash
kubectl port-forward svc/argocd-server 8081:443 -n argocd
```

Open:

```
https://localhost:8081
```

Default username:

```
admin
```

Retrieve initial password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
-o jsonpath='{.data.password}' | base64 -d
```

---

## Grafana

```bash
kubectl port-forward svc/grafana 3000:80 -n monitoring
```

Open:

```
http://localhost:3000
```

---

# CI/CD Workflow

1. Developer pushes code to GitHub.
2. Jenkins detects changes.
3. Docker image is built using Kaniko.
4. Image is pushed to Amazon ECR.
5. Jenkins updates Helm chart.
6. Changes are pushed to GitHub.
7. Argo CD detects repository changes.
8. Argo CD synchronizes the application.
9. Updated application is deployed to Amazon EKS.

---

# Monitoring

Prometheus collects metrics from:

- Kubernetes
- Nodes
- Pods
- Services

Grafana provides dashboards for:

- Cluster health
- CPU usage
- Memory usage
- Pod metrics
- Node metrics

---

# Destroy Infrastructure

To avoid unnecessary AWS charges:

```bash
terraform destroy
```

If the Terraform backend (S3 bucket and DynamoDB table) has already been deleted, recreate it before running Terraform again.

---

# Implemented Features

- Infrastructure as Code with Terraform
- Remote Terraform State
- Modular Terraform architecture
- Amazon VPC
- Amazon EKS
- Amazon ECR
- Amazon RDS
- Jenkins CI
- Argo CD GitOps
- Helm Deployments
- Docker & Kaniko
- AWS IRSA
- Prometheus Monitoring
- Grafana Dashboards
- Horizontal Pod Autoscaler
- Persistent Volumes
- StorageClass (gp3)
- AWS EBS CSI Driver
