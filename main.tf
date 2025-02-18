terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-west-1"
}

terraform {
  backend "s3" {
    bucket         = "terraform-state-boblabs"
    key            = "boblabs/s3/terraform.tfstate"
    region         = "us-west-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
}

data "aws_secretsmanager_secret" "private_key" {
  name = "tf-boblabs-private"  # The name of the secret in Secrets Manager
}

data "aws_secretsmanager_secret_version" "private_key_version" {
  secret_id = data.aws_secretsmanager_secret.private_key.id
}

output "name" {
  value = data.aws_secretsmanager_secret_version.private_key_version.secret_string
  sensitive = true
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_security_group" "deny_all" {
  name        = "deny-all-sg"
  description = "Security group that denies all traffic"
  vpc_id      = aws_vpc.main.id

  # Explicitly deny all inbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Explicitly deny all outbound traffic
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "deny-all"
  }
}