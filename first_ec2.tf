provider "aws" {
  region     = "us-west-1"
  version    = ">=2.65"
  access_key = var.access-key
  secret_key = var.secret-key
}

resource "aws_instance" "barebones-ec2" {
  ami = "ami-04e59c05167ea7bd5"
  instance_type = "t2.micro"
  subnet_id = "subnet-0d3153178b1dfee72"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "vpc-0453b2a20efa68c8e"
}


resource "aws_eip" "a1" {
  vpc    = true
}

output "eip_id" {
  value = aws_eip.a1.id
}

##output "eip_public_dns" {
##  value = aws_eip.a1.public_dns
##}

resource "aws_s3_bucket" "lab-s3" {
  bucket = "bk-lab-003"
}

output "labs3bucket_domain" {
  value = aws_s3_bucket.lab-s3.bucket_domain_name
}

output "labs3bucket_region" {
  value = aws_s3_bucket.lab-s3.region
}

resource "aws_eip_association" "eip_assoc" {
  instance_id    = aws_instance.barebones-ec2.id
  allocation_id  = aws_eip.a1.id
}
