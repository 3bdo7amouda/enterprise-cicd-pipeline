terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
  
  backend "s3" {
    bucket = "enterprise-cicd-terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
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
}

# CI/CD Infrastructure Module
module "cicd_infrastructure" {
  source = "./modules/cicd"
  
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids
  environment     = var.environment
  project_name    = var.project_name
}

module "networking" {
  source              = "./modules/networking"
  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones  = var.availability_zones
  admin_cidr          = var.admin_cidr
}

module "iam" {
  source          = "./modules/iam"
  project_name    = var.project_name
  artifact_bucket = var.artifact_bucket
}

module "ec2" {
  source                    = "./modules/ec2"
  project_name              = var.project_name
  ami_id                    = var.ami_id
  instance_type             = var.instance_type
  private_subnet_ids        = module.networking.private_subnet_ids
  tools_security_group_id   = module.networking.tools_security_group_id
  tools_instance_profile_name = module.iam.tools_instance_profile_name
  sonarqube_version         = var.sonarqube_version
}