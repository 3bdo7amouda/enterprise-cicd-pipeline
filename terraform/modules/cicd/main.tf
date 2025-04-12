# Jenkins Instance
resource "aws_instance" "jenkins" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.private_subnet_ids[0]
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.jenkins.id]
  iam_instance_profile = var.jenkins_instance_profile_name

  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y openjdk-11-jdk
              wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | apt-key add -
              sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
              apt-get update
              apt-get install -y jenkins
              systemctl enable jenkins
              systemctl start jenkins
              EOF
  )

  tags = {
    Name        = "${var.project_name}-jenkins"
    Environment = var.environment
  }
}

# Nexus Instance
resource "aws_instance" "nexus" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.private_subnet_ids[0]
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.nexus.id]
  iam_instance_profile   = var.nexus_instance_profile_name

  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y openjdk-8-jdk
              wget -O /tmp/nexus.tar.gz https://download.sonatype.com/nexus/3/latest-unix.tar.gz
              mkdir -p /opt/nexus
              tar xzf /tmp/nexus.tar.gz -C /opt/nexus --strip-components=1
              useradd -M -d /opt/nexus nexus
              chown -R nexus:nexus /opt/nexus
              cat > /etc/systemd/system/nexus.service << 'EOL'
              [Unit]
              Description=Nexus Repository Manager
              After=network.target
              
              [Service]
              Type=forking
              LimitNOFILE=65536
              ExecStart=/opt/nexus/bin/nexus start
              ExecStop=/opt/nexus/bin/nexus stop
              User=nexus
              Restart=on-abort
              
              [Install]
              WantedBy=multi-user.target
              EOL
              systemctl enable nexus
              systemctl start nexus
              EOF
  )

  tags = {
    Name        = "${var.project_name}-nexus"
    Environment = var.environment
  }
}

# SonarQube Instance
resource "aws_instance" "sonarqube" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.private_subnet_ids[0]
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.sonarqube.id]
  iam_instance_profile   = var.sonarqube_instance_profile_name

  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y openjdk-11-jdk unzip
              wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${var.sonarqube_version}.zip -P /tmp
              unzip /tmp/sonarqube-${var.sonarqube_version}.zip -d /opt
              mv /opt/sonarqube-${var.sonarqube_version} /opt/sonarqube
              useradd -M -d /opt/sonarqube sonar
              chown -R sonar:sonar /opt/sonarqube
              cat > /etc/systemd/system/sonarqube.service << 'EOL'
              [Unit]
              Description=SonarQube service
              After=syslog.target network.target
              
              [Service]
              Type=forking
              ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
              ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
              User=sonar
              Group=sonar
              Restart=always
              
              [Install]
              WantedBy=multi-user.target
              EOL
              systemctl enable sonarqube
              systemctl start sonarqube
              EOF
  )

  tags = {
    Name        = "${var.project_name}-sonarqube"
    Environment = var.environment
  }
}

# Security Groups
resource "aws_security_group" "jenkins" {
  name        = "${var.project_name}-jenkins-sg"
  description = "Security group for Jenkins"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-jenkins-sg"
    Environment = var.environment
  }
}

resource "aws_security_group" "nexus" {
  name        = "${var.project_name}-nexus-sg"
  description = "Security group for Nexus"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-nexus-sg"
    Environment = var.environment
  }
}

resource "aws_security_group" "sonarqube" {
  name        = "${var.project_name}-sonarqube-sg"
  description = "Security group for SonarQube"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-sonarqube-sg"
    Environment = var.environment
  }
}

# Add to modules/cicd/variables.tf
variable "artifacts_bucket_name" {
  description = "Name of the artifacts S3 bucket"
  type        = string
}

variable "cache_bucket_name" {
  description = "Name of the cache S3 bucket"
  type        = string
}

module "cicd_infrastructure" {
  source = "./modules/cicd"
  
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  artifacts_bucket_name = var.artifacts_bucket_name
  cache_bucket_name     = aws_s3_bucket.cache.id
  # ... other parameters
}