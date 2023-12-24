# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web" {
  ami           = "ami-03643cf1426c9b40b"
  instance_type = "t2.micro"

  tags = {
    Name = "HelloWorld"
  }
}