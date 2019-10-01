output "rds_host_name" {
  value = "${aws_db_instance.db_instance.address}"
}
