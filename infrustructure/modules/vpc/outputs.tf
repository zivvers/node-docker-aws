output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "private_subnet_ids" {
  value = [
    "${aws_subnet.availability_zone_1_private.id}",
    "${aws_subnet.availability_zone_2_private.id}",
    "${aws_subnet.availability_zone_3_private.id}"
  ]
}

output "public_subnet_ids" {
  value = [
    "${aws_subnet.availability_zone_1_public.id}",
    "${aws_subnet.availability_zone_2_public.id}",
    "${aws_subnet.availability_zone_3_public.id}"
  ]
}

output "public_cidr_blocks" {
  value = [
    "${aws_subnet.availability_zone_1_public.cidr_block}",
    "${aws_subnet.availability_zone_2_public.cidr_block}",
    "${aws_subnet.availability_zone_3_public.cidr_block}"
  ]
}

output "ssh_security_group_id" {
  value = "${aws_security_group.inbound_ssh.id}"
}
