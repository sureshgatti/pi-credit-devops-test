variable "account_id" {
  description = "AWS account ID"
  type        = string
  default     = "015800952701"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "env" {
  description = "Environment name"
  type        = string
  default     = "stagging"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "ecr_image" {
  description = "ECR image (account-specific) to use on ASG user-data"
  type        = string
  default     = "015800952701.dkr.ecr.eu-north-1.amazonaws.com/pi-credit-app:latest"
}

variable "key_name" {
  description = "EC2 Key pair name (existing in the region)"
  type        = string
  default     = "Suresh"
}

variable "ami_id" {
  description = "AMI id to use for launch template"
  type        = string
  default     = "ami-0c4fc5dcabc9df21d"
}
