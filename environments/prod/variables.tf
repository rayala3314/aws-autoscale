variable "region" {
  default = "us-west-1"
}

variable "instance_name" {
        description = "Name of the instance to be created"
        default = "awsbuilder-demo-prod"
}

variable "instance_type" {
        default = "t2.micro"
}

variable "subnet_id" {
        description = "The VPC subnet the instance(s) will be created in"
        default = "subnet-07ebbe60"
}

variable "ami_id" {
        description = "The AMI to use"
        default = "ami-0b0dcb5067f052a63"
}

variable "number_of_instances" {
        description = "number of instances to be created"
        default = 1
}


variable "ami_key_pair_name" {
        default = "tomcat"
}