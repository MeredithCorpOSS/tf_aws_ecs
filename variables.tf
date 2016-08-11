variable "name_tag" {}

# AWS
variable "aws_region" {}
variable "aws_az_name" {}

# Networking
variable "vpc_cidr" {
  default = "10.10.0.0/16"
}
variable "subnet_cidr" {
  default = "10.10.0.0/24"
}
variable "client_cidr" {}

# EC2
variable "aws_instance_key_name" {}
variable "desired_asg_capacity" {}
variable "aws_ecs_ami_id" {
  default = "ami-4188a071" # amzn-ami-2015.03.a-amazon-ecs-optimized
}
variable "aws_instance_type" {
  default = "t2.micro"
}
variable "asg_min_size" {
  default = 1
}
variable "asg_max_size" {
  default = 5
}

# ECS
variable "cluster_name" {}
variable "definition_family_name" {}
variable "container_definitions" {}
variable "container_name" {}
variable "service_name" {}
variable "service_desired_count" {}
variable "service_port_number" {}
variable "instance_port" {}

# -*- mode: ruby -*-
