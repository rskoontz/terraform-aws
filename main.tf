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
  profile = "tf-ops-lab"
}

terraform {
  backend "s3" {
    bucket         = "terraform-state-bob-garage"
    key            = "global/s3/terraform.tfstate"
    region         = "us-west-1"
    dynamodb_table = "tf-state-lock-table"
    encrypt        = true
  }
}

data "external" "available_cidr" {
  program = ["python3", "free_ips.py"]
}

resource "aws_vpc" "main" {
  cidr_block = data.external.available_cidr.result["cidr_block"]
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "DynamicVPC"
  }
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
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

resource "aws_flow_log" "vpc_flow_logs" {
  log_destination      = "arn:aws:s3:::my-vpc-flow-logs-bucket"
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id              = aws_vpc.main.id

  tags = {
    Name = "vpc-flow-logs"
  }
}
