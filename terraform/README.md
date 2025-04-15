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
- Managed node groups with t3.micro/t2.micro instances using SPOT pricing
- Private networking with VPC integration
- IAM roles and security groups for cluster and nodes
- Proper dependencies to ensure correct resource creation order

## Prerequisites

Before running Terraform, you must manually create the S3 bucket and DynamoDB table for state management:

1. Run the provided setup script:
   ```bash
   chmod +x terraform-setup.sh
   ./terraform-setup.sh
```

## Quick Start

### 1. Set Up Terraform State Management (REQUIRED FIRST STEP)

You must create an S3 bucket and DynamoDB table manually for state management:

```bash
# Create S3 bucket for state storage
aws s3 mb s3://enterprise-cicd-terraform-state --region us-east-1

# Enable versioning on the bucket
aws s3api put-bucket-versioning \
  --bucket enterprise-cicd-terraform-state \
  --versioning-configuration Status=Enabled

# Enable encryption on the bucket
aws s3api put-bucket-encryption \
  --bucket enterprise-cicd-terraform-state \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }'

# Block public access to the bucket
aws s3api put-public-access-block \
  --bucket enterprise-cicd-terraform-state \
  --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name enterprise-cicd-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

### 2. Clone the Repository
```bash
git clone <repository-url>
cd terraform
```

### 3. Configure Variables
- Copy `terraform.tfvars.example` to `terraform.tfvars`
- Update the variables according to your requirements:
  ```hcl
  aws_region = "us-east-1"
  environment = "dev"
  project_name = "enterprise-cicd"
  vpc_cidr = "10.0.0.0/16"
  key_name = "your-key-pair-name"
  ```

### 4. Initialize and Apply
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
- Node groups with t3.micro/t2.micro instances using SPOT pricing
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

## Support

For issues and feature requests:
1. Check existing issues
2. Create a new issue with:
   - Clear description
   - Steps to reproduce
   - Expected behavior
   - Actual behavior