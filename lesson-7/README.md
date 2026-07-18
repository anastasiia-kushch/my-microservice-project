# EKS Cluster and Helm Deployment (Lesson 7)

Цей проєкт містить оновлену модульну Terraform-структуру для створення кластера AWS EKS у межах існуючої мережі VPC, а також Helm-чарт для деплою Django-застосунку з підтримкою HPA, ConfigMap та Ingress TLS.

---

## 🏗️ Структура проєкту

lesson-7/
│
├── main.tf                  # Головний файл (ініціалізація та зв'язування всіх модулів)
├── backend.tf               # Конфігурація віддаленого стейту (S3 + DynamoDB)
├── variables.tf             # Глобальні змінні проєкту
├── outputs.tf               # Виведення даних ECR та EKS
├── README.md                # Документація проєкту
│
├── modules/                 # Модулі інфраструктури
│   ├── s3-backend/          # Модуль S3 + DynamoDB для стейтів
│   ├── vpc/                 # Мережева інфраструктура (VPC, subnets, IGW, NAT)
│   ├── ecr/                 # Репозиторій ECR із шифруванням та життєвим циклом
│   └── eks/                 # Новий модуль для створення кластера AWS EKS
│       ├── eks.tf           # Конфігурація кластера та Managed Node Groups (2-6 нод)
│       ├── variables.tf     # Вхідні змінні для підключення VPC
│       └── outputs.tf       # Аутупути кластера
│
└── charts/                  # Директорія для Helm-чартів
    └── django-app/          # Helm-чарт додатка
        ├── Chart.yaml       # Метадані чарта
        ├── values.yaml      # Централізовані змінні (env з теми 4, HPA, Ingress)
        └── templates/       # Шаблони маніфестів
            ├── configmap.yaml   # Перенесені змінні оточення додатку
            ├── deployment.yaml  # Деплоймент Django з envFrom
            ├── service.yaml     # Зовнішній балансувальник LoadBalancer
            ├── hpa.yaml         # Автомасштабування 2-6 подів (>70% CPU)
            └── ingress.yaml     # Бонус: Ingress-ресурс із TLS (cert-manager)

---

## 🚀 Команди для керування та завантаження образу

1. Розгортання інфраструктури:
   terraform init
   terraform apply --auto-approve

2. Оновлення kubeconfig для доступу через kubectl:
   aws eks update-kubeconfig --region us-west-2 --name lesson-7-eks

3. Автентифікація в ECR та завантаження образу Django (з Темы 4):
   aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <YOUR_ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com
   docker tag django-app:latest <YOUR_ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com/lesson-5-ecr:latest
   docker push <YOUR_ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com/lesson-5-ecr:latest

4. Деплой застосунку через Helm:
   helm upgrade --install django-app ./charts/django-app
