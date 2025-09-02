variable "env" {}
variable "vpc_id" {}
variable "subnets" { type = list(string) }
variable "app_sg" {}

resource "aws_security_group" "rds" {
  name   = "pi-credit-${var.env}-sg-rds"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    description     = "Allow Postgres from App SG"
    security_groups = [var.app_sg]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "pi-credit-${var.env}-sg-rds" }
}

resource "aws_db_subnet_group" "this" {
  name       = "pi-credit-${var.env}-db-subnet"
  subnet_ids = var.subnets
  tags = { Name = "pi-credit-${var.env}-db-subnet" }
}

resource "aws_db_instance" "this" {
  identifier              = "pi-credit-${var.env}-rds"
  engine                  = "postgres"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  username                = "admin"
  password                = "Password123!"     # demo only; use Secrets Manager in prod
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  skip_final_snapshot     = true
  backup_retention_period = 7
  multi_az                = false
  publicly_accessible     = false

  tags = { Name = "pi-credit-${var.env}-rds" }
}

output "endpoint" {
  value = aws_db_instance.this.endpoint
}
