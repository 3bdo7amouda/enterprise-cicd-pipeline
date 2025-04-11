# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = var.eks_cluster_role_arn

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    security_group_ids      = [var.eks_security_group_id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  tags = {
    Name        = var.cluster_name
    Environment = var.environment
    Project     = var.project_name
  }
}

# Data source for EKS worker AMI
data "aws_ami" "eks_worker" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.cluster_version}-*"]
  }
}

# Security Group
resource "aws_security_group" "eks_cluster" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.cluster_name}-cluster-sg"
    Environment = var.environment
  }
}

resource "aws_security_group_rule" "eks_cluster_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_cluster.id
}

# Launch template for node group
resource "aws_launch_template" "eks_node_group" {
  name_prefix   = "${var.cluster_name}-node-group-"
  image_id      = data.aws_ami.eks_worker.id
  instance_type = var.node_instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups            = [var.eks_security_group_id]
  }

  key_name = var.key_name

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.cluster_name}-node"
      Environment = var.environment
      Project     = var.project_name
    }
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              /etc/eks/bootstrap.sh ${aws_eks_cluster.main.name}
              EOF
  )

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_security_group.eks_cluster
  ]
}

# EKS Node Group - This will be created last
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = var.eks_node_group_role_arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  launch_template {
    name    = aws_launch_template.eks_node_group.name
    version = aws_launch_template.eks_node_group.latest_version
  }

  update_config {
    max_unavailable_percentage = 33
  }

  tags = {
    Name        = "${var.cluster_name}-node-group"
    Environment = var.environment
    Project     = var.project_name
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_launch_template.eks_node_group,
    aws_security_group.eks_cluster
  ]

  lifecycle {
    create_before_destroy = true
  }
}