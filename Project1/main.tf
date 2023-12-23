# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = "my-access-key"
  secret_key = "my-secret-key"
}

resource "aws_instance" "web" {
  ami           = "ami_id"
  instance_type = "t2.micro"

  tags = {
    Name = "HelloWorld"
  }
}