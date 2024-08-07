#This is my Launch Template

resource "aws_launch_template" "ityourway-devops" {
  name_prefix   = "ityourway-instance"
  image_id      = "ami-0ba9883b710b05ac6"
  instance_type = "t2.micro"
}

#AWS Auto-Scaling Group

resource "aws_autoscaling_group" "ityourway" {
  availability_zones = ["us-east-1a"] 
  desired_capacity   = 4
  max_size           = 5
  min_size           = 2

  instance_maintenance_policy {
    min_healthy_percentage = 90
    max_healthy_percentage = 120
  }

  launch_template {
    id      = aws_launch_template.ityourway-devops.id
    version = "$Latest"
  }
}

#This is my Application Load Balancer

resource "aws_lb" "ityourway-devops-lb" {
  name               = "ityourway-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ityourway-sg.id]
  subnets            = [aws_subnet.ityourway-sub-a.id, aws_subnet.ityourway-sub-b.id]
  
  enable_deletion_protection = true
}

#This is my Security Group

resource "aws_security_group" "ityourway-sg" {
  name        = "ityourway-eng"
  description = "Allow inbound and outbound traffic"
  vpc_id      = aws_vpc.ityourway-vp.id
}

resource "aws_vpc_security_group_ingress_rule" "ityourway-sg" {
  security_group_id = aws_security_group.ityourway-sg.id
  cidr_ipv4         = aws_vpc.ityourway-vp.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "ityourway-sg-" {
  security_group_id = aws_security_group.ityourway-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

#This is my Subnet block

resource "aws_subnet" "ityourway-sub-a" {  
  vpc_id     = aws_vpc.ityourway-vp.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "ityourway-sub-b" {  
  vpc_id     = aws_vpc.ityourway-vp.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
}

#This is my VPC

resource "aws_vpc" "ityourway-vp" {
  cidr_block = "10.0.0.0/16"
}

#This is my Internet Gateway

resource "aws_internet_gateway" "ityourway-gw" {
  vpc_id = aws_vpc.ityourway-vp.id
}


#This is my IAM Role

resource "aws_iam_role" "ityourway-role" {
  name = "developers"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

#This my IAM Policy

resource "aws_iam_policy" "ityourway-policy" {
  name        = "developers"
  description = "My policy for developers"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

#This is my IAM Group

resource "aws_iam_group" "ityourway-developers" {
  name = "devops-engineers"
}

#This is my IAM user

resource "aws_iam_user" "ityourway-user" {
  name = "devops-user"
}