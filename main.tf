provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}


# Networking
resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr}"

  tags {
    Name = "${var.name_tag}"
  }
}

resource "aws_subnet" "main" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.subnet_cidr}"
  availability_zone = "${var.aws_az_name}"

  tags {
    Name = "${var.name_tag}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
      Name = "${var.name_tag}"
  }
}

resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags {
    Name = "${var.name_tag}"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id = "${aws_subnet.main.id}"
  route_table_id = "${aws_route_table.main.id}"
}

# Security
resource "aws_security_group" "elb" {
  name = "emo_elb"
  description = "Allow 80 on ELB for everyone"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    from_port = 0
    to_port = 65535
    protocol = "TCP"
    self = true
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name_tag} ELB"
  }
}

resource "aws_security_group" "instance" {
  name = "ecs_instance"
  description = "Allow SSH for admins"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["${var.client_cidr}"]
  }

  ingress {
    from_port = 0
    to_port = 65535
    protocol = "TCP"
    security_groups = ["${aws_security_group.elb.id}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name_tag} instance"
  }
}

# EC2
resource "aws_launch_configuration" "main" {
  image_id = "${var.aws_ecs_ami_id}"
  instance_type = "${var.aws_instance_type}"
  iam_instance_profile = "${var.aws_ecs_iam_instance_profile}"
  security_groups = ["${aws_security_group.instance.id}"]
  key_name = "${var.aws_instance_key_name}"
  associate_public_ip_address = true

  user_data = <<USER_DATA
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.main.name} >> /etc/ecs/ecs.config
USER_DATA
}

resource "aws_elb" "main" {
  name = "tf-ecs-service-elb"
  subnets = ["${aws_subnet.main.id}"]
  security_groups = ["${aws_security_group.elb.id}"]

  listener {
    instance_port = "${var.instance_port}"
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
}

resource "aws_autoscaling_group" "main" {
  availability_zones = ["${var.aws_az_name}"]
  vpc_zone_identifier = ["${aws_subnet.main.id}"]
  name = "tf-ecs-asg"
  min_size = "${var.asg_min_size}"
  max_size = "${var.asg_max_size}"
  desired_capacity = "${var.desired_asg_capacity}"
  launch_configuration = "${aws_launch_configuration.main.name}"

  tag {
    key = "Name"
    value = "${var.name_tag}"
    propagate_at_launch = true
  }
}

# ECS
resource "aws_ecs_task_definition" "main" {
  family = "${var.definition_family_name}"
  container_definitions = "${var.container_definitions}"
}

resource "aws_ecs_cluster" "main" {
  name = "${var.cluster_name}"
}

resource "aws_ecs_service" "main" {
  name = "tf-ecs-service"
  cluster = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.main.arn}"
  desired_count = "${var.service_desired_count}"
  iam_role = "${var.aws_ecs_iam_service_role}"

  load_balancer {
    elb_name = "${aws_elb.main.id}"
    container_name = "${var.container_name}"
    container_port = "${var.service_port_number}"
  }
}

# -*- mode: ruby -*-
