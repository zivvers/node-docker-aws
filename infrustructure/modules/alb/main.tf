resource "aws_lb" "elb" {
  name               = "${var.name}"
  internal           = false
  load_balancer_type = "application"
  subnets            = flatten(["${var.subnet_ids}"])
  security_groups    = ["${aws_security_group.elb.id}"]

  tags = {
    Name = "${var.name}"
  }
}

resource "aws_lb_target_group" "elb_target_group" {
  name                 = "${var.name}"
  port                 = "${var.instance_port}"
  protocol             = "HTTP"
  vpc_id               = "${var.vpc_id}"
  target_type          = "instance"
  deregistration_delay = 15

  health_check {
    path     = "${var.health_check_path}"
    protocol = "HTTP"
    matcher  = "200-299"
  }

  depends_on = ["aws_lb.elb"]
}

resource "aws_alb_listener" "elb_listener" {
  load_balancer_arn = "${aws_lb.elb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.elb_target_group.arn}"
    type             = "forward"
  }
}

resource "aws_security_group" "elb" {
  name        = "${var.name}"
  description = "The security group for the ${var.name} ELB"
  vpc_id      = "${var.vpc_id}"
}

resource "aws_security_group_rule" "all_outbound_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.elb.id}"
}

resource "aws_security_group_rule" "all_inbound_all" {
  type              = "ingress"
  from_port         = "${var.lb_port}"
  to_port           = "${var.lb_port}"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.elb.id}"
}
