# EKS Cluster and Helm Deployment (Lesson 7)

Цей проєкт містить модульну Terraform-структуру для створення AWS EKS кластера, Amazon ECR репозиторію, Helm-чарту для Django-застосунку та налаштування віддаленого Terraform state у S3 з блокуванням через DynamoDB.

---

## 🏗️ Структура проєкту

```
.
├── backend.tf               # Віддалений Terraform backend (S3 + DynamoDB)
├── main.tf                  # Головний Terraform файл
├── variables.tf             # Глобальні змінні
├── outputs.tf               # Outputs Terraform
├── modules/
│   ├── s3-backend/
│   ├── vpc/
│   ├── ecr/
│   └── eks/
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
├── core/
├── manage.py
├── Dockerfile
├── requirements.txt
└── README.md
```

---

## 🚀 Розгортання інфраструктури

```bash
terraform init
terraform apply --auto-approve
```

---

## Налаштування kubectl

```bash
aws eks update-kubeconfig \
  --region us-west-2 \
  --name lesson-7-eks
```

---

## Завантаження Docker image в ECR

```bash
aws ecr get-login-password --region us-west-2 \
| docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com

docker build -t django-app .

docker tag django-app:latest <ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com/lesson-5-ecr:latest

docker push <ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com/lesson-5-ecr:latest
```

---

## Деплой через Helm

```bash
helm upgrade --install django-app ./charts/django-app \
  --set image.repository=<ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com/lesson-5-ecr
```

---

## Реалізовано

- Terraform modules
- AWS VPC
- Remote State (S3 + DynamoDB)
- Amazon ECR
- AWS EKS
- Helm Chart
- ConfigMap
- Secret
- Horizontal Pod Autoscaler
- LoadBalancer Service
- Liveness Probe
- Readiness Probe
