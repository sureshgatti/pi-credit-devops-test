variable "env" {}
variable "vpc_id" {}
variable "subnets" { type = list(string) }
variable "alb_target_group" {}
variable "ecr_image" {}
variable "key_name" {}
variable "ami_id" {}
variable "region" {
  description = "AWS region for ECR login"
  type        = string
}

# Security group for app instances
resource "aws_security_group" "app" {
  name   = "pi-credit-${var.env}-sg-app"
  vpc_id = var.vpc_id

  # Allow incoming traffic from ALB (App listens on 3000)
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ⚠️ For demo only. In production, restrict to ALB SG.
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pi-credit-${var.env}-sg-app"
  }
}

# Launch template to install Docker & run app container
resource "aws_launch_template" "this" {
  name_prefix   = "pi-credit-${var.env}-lt-"
  image_id      = var.ami_id
  instance_type = "t3.micro"
  key_name      = var.key_name

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install -y docker
              systemctl start docker
              systemctl enable docker

              # ECR login
              $(aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com)

              # Run container
              docker pull ${var.ecr_image} || true
              docker rm -f pi-credit-app || true
              docker run -d -p 3000:3000 --name pi-credit-app ${var.ecr_image}
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "pi-credit-${var.env}-app"
    }
  }
}

# AutoScaling Group
resource "aws_autoscaling_group" "this" {
  name                      = "pi-credit-${var.env}-asg"
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 2
  vpc_zone_identifier       = var.subnets

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  target_group_arns = [var.alb_target_group]
  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "pi-credit-${var.env}-asg"
    propagate_at_launch = true
  }
}

# Outputs
output "asg_name" {
  value = aws_autoscaling_group.this.name
}

output "app_sg_id" {
  value = aws_security_group.app.id
}
