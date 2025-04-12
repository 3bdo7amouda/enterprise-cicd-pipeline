# EKS Cluster IAM Role
resource "aws_iam_role" "eks_cluster" {
  name = "${var.project_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-eks-cluster-role"
    Environment = var.environment
    Project     = var.project_name
  }
}

# EKS Node Group IAM Role
resource "aws_iam_role" "eks_node_group" {
  name = "${var.project_name}-eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-eks-node-group-role"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Jenkins IAM Role
resource "aws_iam_role" "jenkins" {
  name = "${var.project_name}-jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-jenkins-role"
    Environment = var.environment
    Project     = var.project_name
  }
}

# SonarQube IAM Role
resource "aws_iam_role" "sonarqube" {
  name = "${var.project_name}-sonarqube-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-sonarqube-role"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Nexus IAM Role
resource "aws_iam_role" "nexus" {
  name = "${var.project_name}-nexus-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-nexus-role"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Instance profiles for EC2 instances
resource "aws_iam_instance_profile" "jenkins" {
  name = "${var.project_name}-jenkins-profile"
  role = aws_iam_role.jenkins.name
}

resource "aws_iam_instance_profile" "sonarqube" {
  name = "${var.project_name}-sonarqube-profile"
  role = aws_iam_role.sonarqube.name
}

resource "aws_iam_instance_profile" "nexus" {
  name = "${var.project_name}-nexus-profile"
  role = aws_iam_role.nexus.name
}

# Attach required policies to EKS Cluster Role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# Attach required policies to EKS Node Group Role
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group.name
}

# Attach required policies to Jenkins Role
resource "aws_iam_role_policy_attachment" "jenkins_eks" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.jenkins.name
}

resource "aws_iam_role_policy_attachment" "jenkins_ecr_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  role       = aws_iam_role.jenkins.name
}

resource "aws_iam_role_policy_attachment" "jenkins_s3_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.jenkins.name
}

# Attach required policies to SonarQube Role
resource "aws_iam_role_policy_attachment" "sonarqube_s3_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = aws_iam_role.sonarqube.name
}

# Attach required policies to Nexus Role
resource "aws_iam_role_policy_attachment" "nexus_s3_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.nexus.name
}

# Security Group for EKS
resource "aws_security_group" "eks" {
  name        = "${var.project_name}-eks-cluster"
  description = "Security group for EKS cluster"
  vpc_id      = module.vpc.vpc_id

  # Allow all inbound traffic from within the VPC
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow all inbound traffic from within the VPC"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.project_name}-eks-cluster"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Security Group Rule for EKS Cluster API Server
resource "aws_security_group_rule" "eks_cluster_api" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.admin_cidr]
  security_group_id = aws_security_group.eks.id
  description       = "Allow HTTPS access to EKS cluster API server"
}