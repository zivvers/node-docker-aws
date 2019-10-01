# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN SUBNET GROUP ACROSS ALL THE SUBNETS OF THE DEFAULT ASG TO HOST THE RDS INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.name}"
  subnet_ids = flatten(["${var.subnet_ids}"])

  tags = {
    Name = "${var.name}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP TO ALLOW ACCESS TO THE RDS INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "db_instance" {
  name   = "${var.name}"
  vpc_id = "${var.vpc_id}"
}

resource "aws_security_group_rule" "allow_db_access" {
  type              = "ingress"
  from_port         = "${var.port}"
  to_port           = "${var.port}"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.db_instance.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE DATABASE INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_db_instance" "db_instance" {
  identifier                = "${var.name}"
  engine                    = "${var.engine_name}"
  engine_version            = "${var.engine_version}"
  port                      = "${var.port}"
  name                      = "${var.database_name}"
  username                  = "${var.username}"
  password                  = "${var.password}"
  instance_class            = "db.t2.micro"
  allocated_storage         = "${var.allocated_storage}"
  db_subnet_group_name      = "${aws_db_subnet_group.db_subnet_group.id}"
  vpc_security_group_ids    = ["${aws_security_group.db_instance.id}"]
  apply_immediately         = "true"
  skip_final_snapshot       = true
  final_snapshot_identifier = "${var.name}-final"

  tags = {
    Name = "${var.name}"
  }
}
