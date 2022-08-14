# Provision Highly Available web Cluster in any Region Default VPC
# Create:
#1. Security Group for Web Server and ELB
#2. Launch Configuration with Auto Ami Lookup
#3. Classic Load Balancer in 2 availability zones
#4. Classic Auto scaling in 2 availability zones
#Update t web Server will be via Green/Blue deployment strategy
provider "aws"{
  region = "us-east-1"
}

#Fetching aws availability zones
data "aws_availability_zones" "working"{}

#Fetching latest amazon linux ami
data "aws_ami" "latest_amazon_linux"{
  owners = ["137112412989"]
  most_recent = true
  filter{
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "web"{
  name = "Web Security Group"
  dynamic "ingress" {
    for_each = ["90", "800", "100", "300","80"]
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol= "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags ={
    Name = "Web Security Group"
    Owner = "Michael Liav"
  }
}
#creating ec2 instance
resource "aws_launch_configuration" "web" {
  name_prefix     = "WebServer-Highly-Available"
  image_id        = data.aws_ami.latest_amazon_linux.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.web.id]
  user_data       = file("user_data.sh")

  lifecycle {
    create_before_destroy = true
  }
}
#creating auto scaling group
resource "aws_autoscaling_group" "web"{
  name = "ASG-${aws_launch_configuration.web.name}"
  launch_configuration = aws_launch_configuration.web.name
  min_size = 1
  max_size = 3
  min_elb_capacity =3
  health_check_type = "ELB"
  vpc_zone_identifier =[aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  load_balancers = [aws_elb.web.name]

  dynamic "tag" {
    for_each = {
      Name   = "WebServer in ASG"
      owner  = "Michael Liav"
      TAGKEY = "TAGVALUE"
    }
    content {
      key = tag.key
      value = tag.value
      propagate_at_launch = true
    }
    }
  lifecycle {
      create_before_destroy = true
  }
}
#Creating elastic load balancer
resource "aws_elb" "web"{
  name ="WebServer-HighlyAvailable-ELB"
  availability_zones = [data.aws_availability_zones.working.names[0], data.aws_availability_zones.working.names[1]]
  security_groups = [aws_security_group.web.id]
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = 80
    instance_protocol = "http"
  }
  health_check {
    healthy_threshold = 1
    unhealthy_threshold = 0
    timeout = 3
    target = "HTTP:80/"
    interval = 10
  }
  tags = {
    Name = "WebServer-HighlyAvailable-ELB"
    Owner = "Michael Liav"
  }
}

#Adoptic subnets
resource "aws_default_subnet" "default_az1"{
  availability_zone = data.aws_availability_zones.working.names[0]
}
resource "aws_default_subnet" "default_az2"{
  availability_zone = data.aws_availability_zones.working.names[1]
}

output "web_loadbalancer_url"{
  value = aws_elb.web.dns_name
}