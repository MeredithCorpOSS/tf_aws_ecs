output "elb_hostname" {
  value = "${aws_elb.main.dns_name}"
}

# -*- mode: ruby -*-
