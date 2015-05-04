output "elb_hostname" {
  value = "${aws_elb.demo.dns_name}"
}

# -*- mode: ruby -*-
