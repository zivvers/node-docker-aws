output "elb_name" {
  value = "${aws_lb.elb.name}"
}

output "elb_dns_name" {
  value = "${aws_lb.elb.dns_name}"
}

output "security_group_id" {
  value = "${aws_security_group.elb.id}"
}

output "lb_target_group_arn" {
  value = "${aws_lb_target_group.elb_target_group.arn}"
}
