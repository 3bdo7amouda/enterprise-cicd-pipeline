variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of private subnets"
  type        = list(string)
}

variable "key_name" {
  description = "Name of the SSH key pair for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instances"
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
}

variable "sonarqube_version" {
  description = "Version of SonarQube to install"
  type        = string
}

variable "jenkins_role_arn" {
  description = "ARN of the Jenkins IAM role"
  type        = string
}

variable "jenkins_instance_profile_name" {
  description = "Name of the Jenkins instance profile"
  type        = string
}

variable "sonarqube_role_arn" {
  description = "ARN of the SonarQube IAM role"
  type        = string
}

variable "sonarqube_instance_profile_name" {
  description = "Name of the SonarQube instance profile"
  type        = string
}

variable "nexus_role_arn" {
  description = "ARN of the Nexus IAM role"
  type        = string
}

variable "nexus_instance_profile_name" {
  description = "Name of the Nexus instance profile"
  type        = string
}