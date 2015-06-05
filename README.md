# AWS ECS Terraform Module [![Circle CI](https://circleci.com/gh/TimeIncOSS/tf_aws_ecs/tree/master.svg?style=svg)](https://circleci.com/gh/TimeIncOSS/tf_aws_ecs/tree/master)

## Requirements

 - Terraform `0.6.0+`

## This is for demo purposes only

This module is intended for **demo purposes only**, it has a lot limitations making it useless for any live environment:

 - single AZ
 - single ECS service
 - single ELB
 - EC2 instances with public IPs

## Example

```ruby
module "ecs" {
  source = "git@github.com:TimeIncOSS/tf_aws_ecs"

  name_tag = "ECS-TF-demo"

  # Networking
  client_cidr = ".../32" # Your CIDR (Your IP/32)

  # AWS
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  aws_region = "us-west-2"
  aws_az_name = "us-west-2c"

  # EC2
  aws_instance_key_name = "ecs-test"
  desired_asg_capacity = 3

  # ECS
  cluster_name = "ecs-demo"
  definition_family_name = "ghost"
  service_name = "ghost_service"
  service_desired_count = 3
  service_port_number = 2368
  instance_port = 8080
  container_name = "ghost"
  container_definitions = <<DEFINITION
[
  {
    "cpu": 128,
    "essential": true,
    "image": "ghost:latest",
    "memory": 128,
    "name": "ghost",
    "portMappings": [
      {
        "containerPort": 2368,
        "hostPort": 8080
      }
    ]
  }
]
DEFINITION
}
```

## Output

 - `elb_hostname`
