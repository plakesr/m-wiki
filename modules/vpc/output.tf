output "vpc-id" {
  value = "${aws_vpc.vpc.id}"
}

output "public-subnet-ids" {
  value = "${aws_subnet.public-subnets.*.id}"
}

output "private-subnet-ids" {
  value = "${aws_subnet.private-subnets.*.id}"
}

output "aws-availability-zones" {
  value = "${data.aws_availability_zones.azs.names}"
}

output "public-sg" {
  value = "${aws_security_group.http.id}"
}

output "mysql-sg" {
  value = "${aws_security_group.mysql.id}"
}