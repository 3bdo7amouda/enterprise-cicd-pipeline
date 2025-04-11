# Provider Configuration
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  environment         = var.environment
  project_name        = var.project_name
}

# CI/CD Infrastructure Module
module "cicd_infrastructure" {
  source = "./modules/cicd"
  
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  environment         = var.environment
  project_name        = var.project_name
  key_name           = var.key_name
  instance_type      = var.instance_type
  ami_id             = var.ami_id
  sonarqube_version  = var.sonarqube_version

  depends_on = [module.vpc]
}

# EKS Module
module "eks" {
  source = "./modules/eks"
  
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  environment     = var.environment
  project_name    = var.project_name
  key_name        = var.key_name

  # Node group configuration
  node_instance_type = var.node_instance_type
  node_desired_size  = var.node_desired_size
  node_max_size      = var.node_max_size
  node_min_size      = var.node_min_size

  # IAM roles and security group
  eks_cluster_role_arn    = aws_iam_role.eks_cluster.arn
  eks_node_group_role_arn = aws_iam_role.eks_node_group.arn
  eks_security_group_id   = aws_security_group.eks.id

  # Ensure EKS node group is created last
  depends_on = [
    module.vpc,
    module.cicd_infrastructure,
    aws_iam_role.eks_cluster,
    aws_iam_role.eks_node_group,
    aws_security_group.eks
  ]
}

# Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_id" {
  description = "ID of the EKS cluster"
  value       = module.eks.cluster_id
}

output "jenkins_endpoint" {
  description = "Public IP address of the Jenkins server"
  value       = "http://${module.cicd_infrastructure.jenkins_public_ip}"
}

output "sonarqube_endpoint" {
  description = "Public IP address of the SonarQube server"
  value       = "http://${module.cicd_infrastructure.sonarqube_public_ip}"
}

output "nexus_endpoint" {
  description = "Public IP address of the Nexus server"
  value       = "http://${module.cicd_infrastructure.nexus_public_ip}"
}