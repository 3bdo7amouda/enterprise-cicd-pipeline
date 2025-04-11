variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "jenkins_ami" {
  description = "AMI ID for Jenkins server"
  type        = string
  default     = "ami-0c7217cdde317cfec" # Ubuntu 20.04 LTS
}

variable "jenkins_instance_type" {
  description = "Instance type for Jenkins server"
  type        = string
  default     = "t3.medium"
}

variable "nexus_ami" {
  description = "AMI ID for Nexus server"
  type        = string
  default     = "ami-0c7217cdde317cfec" # Ubuntu 20.04 LTS
}

variable "nexus_instance_type" {
  description = "Instance type for Nexus server"
  type        = string
  default     = "t3.medium"
}

variable "sonarqube_ami" {
  description = "AMI ID for SonarQube server"
  type        = string
  default     = "ami-0c7217cdde317cfec" # Ubuntu 20.04 LTS
}

variable "sonarqube_instance_type" {
  description = "Instance type for SonarQube server"
  type        = string
  default     = "t3.medium"
} 