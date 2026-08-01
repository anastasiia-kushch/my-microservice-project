terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.32"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.14"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr_block = "10.0.0.0/16"

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]

  private_subnets = [
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24"
  ]

  availability_zones = [
    "us-west-2a",
    "us-west-2b",
    "us-west-2c"
  ]

  vpc_name = "lesson-7-vpc"
}

module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = var.ecr_name
  scan_on_push = true
}

module "eks" {
  source             = "./modules/eks"
  cluster_name       = "lesson-7-eks"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  depends_on         = [module.vpc, module.ecr]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name

  depends_on = [
    module.eks
  ]
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name

  depends_on = [
    module.eks
  ]
}

provider "kubernetes" {
  host = data.aws_eks_cluster.cluster.endpoint

  cluster_ca_certificate = base64decode(
    data.aws_eks_cluster.cluster.certificate_authority[0].data
  )

  token = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {

    host = data.aws_eks_cluster.cluster.endpoint

    cluster_ca_certificate = base64decode(
      data.aws_eks_cluster.cluster.certificate_authority[0].data
    )

    token = data.aws_eks_cluster_auth.cluster.token
  }
}

# Jenkins
module "jenkins" {
  source = "./modules/jenkins"

  cluster_name        = module.eks.cluster_name
  oidc_provider       = module.eks.oidc_provider
  oidc_provider_arn   = module.eks.oidc_provider_arn
  aws_account_id      = "889951087627"
  aws_region          = var.aws_region
  ecr_repository_name = var.ecr_name

  depends_on = [
    module.eks,
    kubernetes_storage_class_v1.gp3
  ]
}

# Argo CD
module "argo_cd" {
  source = "./modules/argo_cd"

  cluster_name = module.eks.cluster_name

  depends_on = [
    module.eks,
    module.jenkins
  ]
}

module "rds" {
  source = "./modules/rds"

  name       = "lesson-db"
  use_aurora = false

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  engine                 = "postgres"
  engine_version         = "16.14"
  parameter_group_family = "postgres16"
  instance_class         = "db.t3.micro"

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

module "monitoring" {
  source = "./modules/monitoring"

  namespace              = "monitoring"
  release_name           = "monitoring"
  grafana_admin_password = var.grafana_admin_password

  grafana_storage_size    = "5Gi"
  prometheus_storage_size = "10Gi"
  prometheus_retention    = "7d"
  grafana_service_type    = "ClusterIP"
  enable_alertmanager     = true

  depends_on = [
    module.eks
  ]
}
