# Enterprise CI/CD Infrastructure

This directory contains the Terraform configuration for setting up the complete infrastructure required for the Enterprise CI/CD project.

## Infrastructure Components

The infrastructure consists of the following components:

1. **VPC and Networking**
   - VPC with public and private subnets
   - Internet Gateway and NAT Gateway
   - Route tables and security groups
   - Network ACLs

2. **EKS Cluster**
   - Managed EKS cluster
   - Node groups with auto-scaling
   - IAM roles and policies
   - Security groups

3. **CI/CD Infrastructure**
   - Jenkins server
   - Nexus repository manager
   - SonarQube server
   - S3 bucket for artifacts
   - IAM roles and policies

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.2.0
- kubectl
- AWS CLI
- An SSH key pair for EC2 instances

## Directory Structure

```
terraform/
├── main.tf              # Main Terraform configuration
├── variables.tf         # Variable definitions
├── terraform.tfvars     # Variable values
├── outputs.tf           # Output definitions
└── modules/
    ├── vpc/            # VPC module
    ├── eks/            # EKS module
    └── cicd/           # CI/CD infrastructure module
```

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Review the planned changes:
   ```bash
   terraform plan
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

4. Destroy the infrastructure:
   ```bash
   terraform destroy
   ```

## Module Details

### VPC Module
- Creates a VPC with public and private subnets
- Sets up Internet Gateway and NAT Gateway
- Configures route tables and network ACLs
- Creates security groups

### EKS Module
- Provisions an EKS cluster
- Creates node groups with auto-scaling
- Sets up IAM roles and policies
- Configures security groups

### CI/CD Module
- Deploys Jenkins server
- Sets up Nexus repository manager
- Configures SonarQube server
- Creates S3 bucket for artifacts
- Sets up IAM roles and policies

## Security Considerations

- All sensitive data is stored in AWS Secrets Manager
- IAM roles follow the principle of least privilege
- Security groups are configured with minimal required access
- Network ACLs provide an additional layer of security
- All services run in private subnets with controlled access

## Maintenance

- Regular security patches and updates
- Backup of critical data
- Monitoring and alerting
- Cost optimization

## Troubleshooting

Common issues and solutions:

1. **VPC Creation Fails**
   - Check if the CIDR block is available
   - Verify AWS account limits

2. **EKS Cluster Creation Fails**
   - Ensure IAM roles have correct permissions
   - Check if the VPC has sufficient IP addresses

3. **CI/CD Tools Not Accessible**
   - Verify security group rules
   - Check if instances are in the correct subnets
   - Ensure NAT Gateway is properly configured

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request