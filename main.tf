# Crate a AWS VPC which contains the following
#   - VPC
#   - Public subnet(s)
#   - Private subnet(s)
#   - Internet Gateway
#   - Routing table

resource "aws_vpc" "testapp" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true # Internal domain name
  enable_dns_hostnames = true # Internal host name

  tags = {
    Name = "testapp-vpc"
  }
}

resource "aws_subnet" "testapp_public_subnet" {
  # Number of public subnet is defined in vars.t
  count = var.number_of_public_subnets

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index + 2}.0/24"
  vpc_id                  = aws_vpc.testapp.id
  map_public_ip_on_launch = true # This makes the subnet public

  tags = {
    Name = "testapp-public-subnet-${count.index}"
  }
}

resource "aws_subnet" "testapp_private_subnet" {
  # Number of private subnet is defined in vars.t
  count = var.number_of_private_subnets

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.testapp.id

  tags = {
    Name = "testapp-private-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "testapp_internet_gateway" {
  vpc_id = aws_vpc.testapp.id

  tags = {
    Name = "testapp-internet-gateway"
  }
}

resource "aws_route_table" "testapp_route_table" {
  vpc_id = aws_vpc.testapp.id

  route {
    # Associated subet can reach public internet
    cidr_block = "0.0.0.0/0"

    # Which internet gateway to use
    gateway_id = aws_internet_gateway.testapp_internet_gateway.id
  }

  tags = {
    Name = "testapp-public-custom-rtb"
  }
}

resource "aws_route_table_association" "testapp-custom-rtb-public-subnet" {
  count          = 2
  route_table_id = aws_route_table.testapp_route_table.id
  subnet_id      = aws_subnet.testapp_public_subnet.*.id[count.index]
}







# IAM.TF-------------------------------------
resource "aws_iam_role" "test_role" {
  name = "test_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
      "Effect": "Allow",
      "Principal": {"Service": "ssm.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }
}
EOF
}

resource "aws_iam_role_policy_attachment" "test_attach" {
  role       = aws_iam_role.test_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = aws_iam_role.test_role.name
}

resource "aws_ssm_activation" "foo" {
  name               = "test_ssm_activation"
  description        = "Test"
  iam_role           = aws_iam_role.test_role.id
  registration_limit = "5"
  depends_on         = [aws_iam_role_policy_attachment.test_attach]
}

resource "aws_instance" "web" {
  count = 1
  ami                    = "ami-0e4d9ed95865f3b40"
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.test_profile.name
  subnet_id              = aws_subnet.testapp_private_subnet.*.id[count.index]
}
/*
--1a
data "aws_ami" "ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }
}

resource "aws_instance" "web" {
    depends_on = [
    aws_vpc.testapp,
    aws_subnet.testapp_public_subnet,
    aws_subnet.testapp_private_subnet
  ]

  ami           = "ami-090fa75af13c156b4"
  instance_type = "t2.micro"

  tags = {
    Name = "HelloWorld"
  }
}

*/