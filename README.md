# CI/CD Pipeline with Jenkins, Terraform, Helm and Argo CD (Lesson 9)

## Project Overview

This project demonstrates a complete CI/CD pipeline for deploying a Django application to Amazon EKS using Terraform, Helm, Jenkins, and Argo CD.

The infrastructure is fully managed with Terraform. Jenkins automatically builds and publishes Docker images to Amazon ECR, updates the Helm chart, and pushes changes to GitHub. Argo CD continuously monitors the Git repository and automatically synchronizes the application with the Kubernetes cluster.

---

# Project Structure

```
.
├── backend.tf
├── main.tf
├── variables.tf
├── outputs.tf
├── Jenkinsfile
├── Dockerfile
├── manage.py
├── requirements.txt
├── core/
├── charts/
│   └── django-app/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── configmap.yaml
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── secret.yaml
│           ├── hpa.yaml
│           └── ingress.yaml
└── modules/
    ├── s3-backend/
    ├── vpc/
    ├── ecr/
    ├── eks/
    ├── jenkins/
    └── argo_cd/
```

---

# Technologies

* Terraform
* AWS VPC
* Amazon S3
* Amazon DynamoDB
* Amazon ECR
* Amazon EKS
* Docker
* Helm
* Jenkins
* Argo CD
* Kubernetes
* Django

---

# Infrastructure Deployment

Initialize Terraform:

```bash
terraform init
```

Deploy infrastructure:

```bash
terraform apply --auto-approve
```

After deployment, configure kubectl:

```bash
aws eks update-kubeconfig \
  --region us-west-2 \
  --name lesson-7-eks
```

---

# Jenkins Pipeline

The Jenkins pipeline performs the following steps:

1. Clones the GitHub repository.
2. Builds the Docker image using Kaniko.
3. Pushes the image to Amazon ECR.
4. Updates the Docker image tag in the Helm chart.
5. Commits the updated Helm chart.
6. Pushes changes to the main branch.

Pipeline definition is located in:

```
Jenkinsfile
```

---

# Helm Deployment

Deploy the Django application:

```bash
helm upgrade --install django-app ./charts/django-app
```

Upgrade deployment after changes:

```bash
helm upgrade django-app ./charts/django-app
```

---

# Argo CD

Argo CD continuously monitors the Git repository.

Whenever Jenkins updates the Helm chart and pushes a new commit, Argo CD automatically synchronizes the application with the Kubernetes cluster.

The Argo CD Application is defined inside:

```
modules/argo_cd/charts/
```

---

# CI/CD Workflow

```
Developer
     │
     ▼
 GitHub Repository
     │
     ▼
   Jenkins
     │
     ├── Build Docker image
     ├── Push image to Amazon ECR
     ├── Update Helm values.yaml
     └── Push changes to GitHub
                │
                ▼
            Argo CD
                │
                ▼
        Amazon EKS Cluster
                │
                ▼
         Django Application
```

---

# Destroy Infrastructure

To avoid unnecessary AWS charges, remove all resources after testing:

```bash
terraform destroy
```

If the backend infrastructure (S3 bucket and DynamoDB table) has already been removed, recreate it before running Terraform again.

---

# Implemented Features

* Modular Terraform infrastructure
* Remote Terraform State (S3 + DynamoDB)
* AWS VPC
* Amazon ECR
* Amazon EKS
* Helm deployment
* Jenkins installed with Helm
* Kubernetes Jenkins Agent
* Kaniko image build
* Automatic Docker image publishing to ECR
* Automatic Helm chart update
* GitOps workflow
* Argo CD deployment
* Automatic application synchronization
* ConfigMap
* Secret
* Horizontal Pod Autoscaler
* LoadBalancer Service
* Ingress support

