# Enterprise CI/CD Infrastructure

This repository contains the Terraform configuration for setting up a complete enterprise-grade CI/CD infrastructure on AWS. The infrastructure is designed to be scalable, secure, and follows AWS best practices.

## Architecture Overview

The infrastructure consists of three main components:

### 1. Networking (VPC Module)
- VPC with public and private subnets across multiple AZs
- Internet Gateway for public subnets
- NAT Gateway for private subnets
- Route tables and security groups
- Network ACLs for additional security

### 2. CI/CD Tools (CICD Module)
- Jenkins server for continuous integration and deployment
- SonarQube server for code quality analysis
- Nexus repository manager for artifact storage
- S3 bucket for additional artifact storage
- IAM roles and security groups for each service
- All services deployed in private subnets with controlled access

### 3. Kubernetes Platform (EKS Module)
- Amazon EKS cluster for container orchestration
- Managed node groups with auto-scaling capabilities
- Private networking with VPC integration
- IAM roles and security groups for cluster and nodes
- Proper dependencies to ensure correct resource creation order

## Prerequisites

Before deploying this infrastructure, ensure you have:

1. **AWS Account and Credentials**
   - AWS CLI installed and configured
   - Appropriate IAM permissions to create resources

2. **Required Tools**
   - Terraform >= 1.2.0
   - AWS CLI >= 2.0.0
   - kubectl (for EKS cluster management)

3. **SSH Key Pair**
   - Create or import an SSH key pair in AWS
   - This will be used to access EC2 instances

## Quick Start

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd terraform
   ```

2. **Configure Variables**
   - Copy `terraform.tfvars.example` to `terraform.tfvars`
   - Update the variables according to your requirements:
     ```hcl
     aws_region = "us-east-1"
     environment = "dev"
     project_name = "enterprise-cicd"
     vpc_cidr = "10.0.0.0/16"
     key_name = "your-key-pair-name"
     ```

3. **Initialize and Apply**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Module Details

### VPC Module (`./modules/vpc`)
- Creates a VPC with configurable CIDR block
- Public and private subnets across multiple AZs
- NAT Gateway for private subnet internet access
- Security groups and NACLs for network security

### CI/CD Module (`./modules/cicd`)
- Deploys Jenkins, SonarQube, and Nexus servers
- Each service has its own:
  - Security group with minimal required access
  - IAM role with necessary permissions
  - Private subnet placement
- S3 bucket for artifact storage with versioning enabled

### EKS Module (`./modules/eks`)
- Managed Kubernetes cluster
- Node groups with auto-scaling
- Private networking configuration
- Cluster and node security groups
- IAM roles for cluster and node groups

## Security Features

1. **Network Security**
   - All services in private subnets
   - Security groups with minimal required access
   - Network ACLs for additional security layer

2. **Access Control**
   - IAM roles following principle of least privilege
   - SSH access restricted to specified CIDR blocks
   - Security group ingress rules limited to necessary ports

3. **Data Security**
   - S3 bucket with versioning and encryption
   - Private VPC endpoints for AWS services
   - No direct internet access to private resources

## Available Endpoints

After successful deployment, you can access:

- Jenkins: http://<jenkins_public_ip>
- SonarQube: http://<sonarqube_public_ip>
- Nexus: http://<nexus_public_ip>
- EKS Cluster: Available through kubectl after configuring kubeconfig

## Terraform State Management

The infrastructure state is managed using:
- S3 bucket for state storage
- DynamoDB table for state locking
- Encryption enabled for state files
- Versioning enabled for state history

## Maintenance and Operations

### Updating Infrastructure
```bash
# Pull latest changes
git pull

# Plan changes
terraform plan

# Apply changes
terraform apply
```

### Scaling
- EKS node groups can be scaled by modifying:
  - `node_desired_size`
  - `node_max_size`
  - `node_min_size`
- Instance types can be modified through variables

### Backup and Recovery
- S3 bucket versioning enabled for artifacts
- AMI backups recommended for EC2 instances
- EKS cluster state managed by AWS

## Troubleshooting

1. **VPC/Networking Issues**
   - Check route tables and NAT Gateway
   - Verify security group rules
   - Ensure CIDR ranges don't overlap

2. **EKS Issues**
   - Verify IAM roles and policies
   - Check node group status
   - Review cluster security group rules

3. **CI/CD Tool Access**
   - Confirm security group ingress rules
   - Verify instance health
   - Check route table configurations

## Cost Optimization

- Use appropriate instance sizes
- Implement auto-scaling policies
- Monitor and adjust resources as needed
- Consider reserved instances for stable workloads

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and feature requests:
1. Check existing issues
2. Create a new issue with:
   - Clear description
   - Steps to reproduce
   - Expected behavior
   - Actual behavior