# Introduction to Terraform

## To install Terraform

Go to https://www.terraform.io/ click Download and choose your platform

## First project using AWS provider

Login to AWS Console and navigate to Profile name(top right)->Security Credentials->Access key

If one is not there then create one and copy Access key and secret key. Then download AWS CLI and enter below command to enter Access key and secret key.

```
# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
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

Furthermore, apply and destroy can be scoped to an individual resource also with -target option while running command e.g. below will create only the specified instance
```
terraform apply -target aws_instance.web-server-instance
```
To reference a resource e.g. to reference a vpc_id of name main while creating subnet
```
vpc_id = aws_vpc.main.id
```

To create an output or a printout while creating resources e.g. output elastic IP
```
output server_public_ip {
  value = aws_eip.one.public_ip
}
```
This output will be created while you apply or you can see just the output with terraform output command
## terraform Files

**.tf** is main extension file where you can create resources

**.tfvars** is used for storing varaibles

**.tfstate** is used to store the state of created resources

## Terraform commands
|Command  | Description
| ------| -------
|state   | working with state of resources created
|fmt      | Reformat your configuration in the standard style
|output   | Show output values from your root module
| refresh  | Update the state to match remote systems

## Variables

Variables can be defined as below.

```
variable "name_of_variable" {
  description = "optional description"
  default = "optional default value"
  type = String
}
```

Variable values can be specified by -var "name_of_variable=Value of variable" flag while using terraform apply, via terraform.tfvars file or by using user input if left unspecified.

terraform.tfvars example:
```
name_of_variable = "Value of variable" 
```

## Webserver project

The webserver project will have following tasks

1. Create VPC
```
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}
```
2. Create Internet Gateway
```
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}
```
3. Custom Route Table
```
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.gw.id
  }

  tags = {
    Name = "example"
  }
}
```
4. Subnet
```
resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main"
  }
}
```
5. Assocition of subnet with Route table
```
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}
```
6. Security group to allow ports 80 and 443
```
resource "aws_security_group" "allow_web" {
   name        = "allow_web_traffic"
   description = "Allow Web inbound traffic"
   vpc_id      = aws_vpc.vpc.id

   ingress {
     description = "HTTPS"
     from_port   = 443
     to_port     = 443
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }
   ingress {
     description = "HTTP"
     from_port   = 80
     to_port     = 80
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

   ingress {
     description = "SSH"
     from_port   = 22
     to_port     = 22
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

   egress {
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
   }

   tags = {
     Name = "allow_web"
   }
 }
```
7. Create a network interface with an IP in the subnet that was created before

```
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet.id
  private_ips     = ["10.0.1.150"]
  security_groups = [aws_security_group.allow_web.id]

}
```

8. Create elastic IP and associate with AWS instance
```
resource "aws_eip" "one" {
  vpc      = true
}

# resource block for ec2 and eip association #
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.web-server-instance.id
  allocation_id = aws_eip.one.id
}

output server_public_ip {
  value = aws_eip.one.public_ip
}
```
9. Create Amazon Linux server and enable web server (httpd)
```
resource "aws_instance" "web-server-instance" {
  ami               = "ami-079db87dc4c10ac91"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = "main-key"
  network_interface {
    network_interface_id = aws_network_interface.web-server-nic.id
    device_index         = 0
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo dnf update -y
              sudo dnf install -y httpd
              sudo systemctl start httpd
              sudo bash -c "echo your very first web server > /var/www/html/index.html"
              EOF
}
```
