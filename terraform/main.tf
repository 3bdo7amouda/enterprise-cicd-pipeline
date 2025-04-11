terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
  
  # Temporarily comment out S3 backend until we create the bucket
  # backend "s3" {
  #   bucket = "enterprise-cicd-terraform-state"
  #   key    = "terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "aws" {
  region = var.aws_region
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  environment          = var.environment
  project_name         = var.project_name
}

# EKS Module
module "eks" {
  source = "./modules/eks"
  
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids
  environment     = var.environment
  project_name    = var.project_name

  # Node group configuration
  node_instance_type = var.node_instance_type
  node_desired_size  = var.node_desired_size
  node_max_size      = var.node_max_size
  node_min_size      = var.node_min_size

  # IAM roles and policies
  eks_cluster_role_arn     = aws_iam_role.eks_cluster.arn
  eks_node_group_role_arn  = aws_iam_role.eks_node_group.arn

  # Security group
  eks_security_group_id = aws_security_group.eks.id

  # Policy attachments
  eks_cluster_policy_attachment_id            = aws_iam_role_policy_attachment.eks_cluster_policy.id
  eks_service_policy_attachment_id            = aws_iam_role_policy_attachment.eks_service_policy.id
  eks_worker_node_policy_attachment_id        = aws_iam_role_policy_attachment.eks_worker_node_policy.id
  eks_cni_policy_attachment_id                = aws_iam_role_policy_attachment.eks_cni_policy.id
  ec2_container_registry_policy_attachment_id = aws_iam_role_policy_attachment.ec2_container_registry_policy.id

  # Subnet IDs
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
}

# CI/CD Infrastructure Module
module "cicd_infrastructure" {
  source = "./modules/cicd"
  
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids
  environment     = var.environment
  project_name    = var.project_name
  key_name        = var.key_name
}