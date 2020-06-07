provider "aws" {
  region     = "us-west-1"
  access_key = var.access-key
  secret_key = var.secret-key
}

resource "aws_instance" "myec2" {
  ami = "ami-04e59c05167ea7bd5"
  instance_type = "t2.micro"
  subnet_id = "subnet-0d3153178b1dfee72"
}
