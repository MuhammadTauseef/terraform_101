# Introduction to Terraform

## To install Terraform

Go to https://www.terraform.io/ click Download and choose your platform

## First project using AWS provder

Login to AWS Console and navigate to Profile name(top right)->Security Credentials->Access key

If one is not there then create one and copy Access key and secret key into Project1/main.tf file as below

```
# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = "my-access-key"
  secret_key = "my-secret-key"
}
```

Then define a resource in the file e.g. EC2_instance. Details of which can be obtainerd from https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance

```
resource "aws_instance" "web" {
  ami           = "ami_id"
  instance_type = "t2.micro"

  tags = {
    Name = "HelloWorld"
  }
}
```
Please note that ami_id will have to be copied from AWS which signifies id of the image need to run EC2 instance.

Once all values are plugged in then navigate to Project1 folder in terminal and enter all below commands

```
terraform init
terraform plan
terraform apply
```

Where init is used to initialize the provider, which in this case is AWS, plan is used to see what changes will be done in dry run fashion and apply will actually create/modify resources.

To destroy/delete enter 
```
terraform destroy
```

Additionally, we can also remove a resource defined in the file and after that when we perform terraform apply, terraform will automatically remove that resource
