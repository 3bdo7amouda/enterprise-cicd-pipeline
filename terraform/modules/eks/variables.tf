variable "project_name" {
  description = "Name of the project for resource tagging"
  type        = string
  default     = "enterprise-cicd"
}

variable "eks_cluster_role_arn" {
  description = "ARN of the IAM role for the EKS cluster"
  type        = string
}

variable "eks_node_group_role_arn" {
  description = "ARN of the IAM role for the EKS node group"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of public subnets from the networking module"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "IDs of private subnets from the networking module"
  type        = list(string)
}

variable "eks_security_group_id" {
  description = "ID of the EKS security group from the networking module"
  type        = string
}

variable "eks_cluster_policy_attachment_id" {
  description = "ID of the EKS cluster policy attachment"
  type        = string
}

variable "eks_service_policy_attachment_id" {
  description = "ID of the EKS service policy attachment"
  type        = string
}

variable "eks_worker_node_policy_attachment_id" {
  description = "ID of the EKS worker node policy attachment"
  type        = string
}

variable "eks_cni_policy_attachment_id" {
  description = "ID of the EKS CNI policy attachment"
  type        = string
}

variable "ec2_container_registry_policy_attachment_id" {
  description = "ID of the EC2 container registry policy attachment"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "node_instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type        = string
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}