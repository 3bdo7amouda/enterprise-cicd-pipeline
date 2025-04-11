# Prerequisites for Terraform State Management
# This file contains both the backend configuration and the resources needed for Terraform state management

# Terraform Configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"

  backend "s3" {
    bucket         = "enterprise-cicd-terraform-state"  # This will be created below
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "enterprise-cicd-terraform-locks"  # This will be created below
    encrypt        = true

    # Enable state locking
    enable_locking = true

    # Enable state file versioning
    versioning = true
  }
}

# S3 bucket for Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "enterprise-cicd-terraform-state"  # Match the name in the backend configuration

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "enterprise-cicd-terraform-state"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Enable versioning for state files
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "enterprise-cicd-terraform-locks"  # Match the name in the backend configuration
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "enterprise-cicd-terraform-locks"
    Environment = var.environment
    Project     = var.project_name
  }
} 