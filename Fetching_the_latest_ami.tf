#You can change regions and it will output you the latest ami in the region you are in
provider "aws"{
  region = "us-east-1"
}

/*
resource "aws_instance" "Myserver"{
ami = data.aws_ami.latest_ubunto20.id
instance_type = "t2.micro
}
*/

#Fetching latest ami id for the following ami types
data "aws_ami" "latest_ubuntu20"{
  owners = ["099720109477"]
  most_recent = true
  filter{
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}
data "aws_ami" "latest_amazonlinux" {
  owners = ["137112412989"]
  most_recent = true
  filter{
    name = "name"
    values = ["amzn-ami-hvm-*-x86_64-gp2"]
  }
}
data "aws_ami" "latest_windowserver2019" {
  owners = ["801119661308"]
  most_recent = true
  filter{
    name = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }
}

output "latest_ubuntu20"{
  value = data.aws_ami.latest_ubuntu20.id
}

output "latest_amazonlinux"{
  value = data.aws_ami.latest_amazonlinux.id
}

output "latest_windowserver2019"{
  value = data.aws_ami.latest_windowserver2019.id
}
