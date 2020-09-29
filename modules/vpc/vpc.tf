provider "aws" {
  region = "${var.region}"
}

resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc-cidr}"
  instance_tenancy = "${var.instance-tenancy}"

  tags = {
    Name= "${var.vpc-name}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name= "${var.ig-name}"

  }
}

resource "aws_subnet" "public-subnets" {
  availability_zone = "${element(data.aws_availability_zones.azs.names,count.index)}"
  count = "${length(var.vpc-public-subnet-cidr)}"
  cidr_block = "${element(var.vpc-public-subnet-cidr,count.index)}"
  vpc_id = "${aws_vpc.vpc.id}"
  map_public_ip_on_launch = "${var.map_pub_ip}"

  tags = {
    Name = "${var.public-subnets-name}-${count.index+1}"
  }
}

resource "aws_route_table" "public-routes" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
  tags = {
    Name = "${var.public-subnet-routes-name}"
  }
}

resource "aws_route_table_association" "public-association" {
  count = "${length(data.aws_availability_zones.azs.names)}"
  route_table_id = "${aws_route_table.public-routes.id}"
  subnet_id = "${element(aws_subnet.public-subnets.*.id, count.index)}"
}

resource "aws_subnet" "private-subnets" {
  availability_zone = "${element(data.aws_availability_zones.azs.names,count.index)}"
  count = "${length(var.vpc-private-subnet-cidr)}"
  cidr_block = "${element(var.vpc-private-subnet-cidr,count.index)}"
  vpc_id = "${aws_vpc.vpc.id}"


  tags = {
    Name = "${var.private-subnet-name}-${count.index+1}"
    
  }
}

resource "aws_eip" "eip-ngw" {
  count = "${var.nat_count}"
  tags = {
    Name = "${var.eip-name}-${count.index+1}"
  }
}
resource "aws_nat_gateway" "ngw" {
  count = "${var.nat_count}"
  allocation_id = "${element(aws_eip.eip-ngw.*.id,count.index)}"
  subnet_id = "${element(aws_subnet.public-subnets.*.id, count.index)}"
  tags = {
    Name = "${var.nat-name}-${count.index+1}"
  }
}

resource "aws_route_table" "private-routes" {
  count = "${length(data.aws_availability_zones.azs.names)}"
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "${var.private-route-cidr}"
    nat_gateway_id = "${element(aws_nat_gateway.ngw.*.id,count.index)}"
  }
  tags = {
    Name = "${var.private-route-name}-${count.index+1}"
  }

}
#############ERRRR
resource "aws_route_table_association" "private-routes-linking" {
  count = "${length(data.aws_availability_zones.azs.names)}"
  route_table_id = "${element(aws_route_table.private-routes.*.id, 1)}"
  subnet_id = "${element(aws_subnet.private-subnets.*.id,count.index)}"
}

resource "aws_security_group" "http" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    description = "http from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http"
  }
}

resource "aws_security_group" "mysql" {
  name        = "allow_mysql"
  description = "Allow http inbound traffic"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    description = "http from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc-cidr}"]
  }

  ingress {
    description = "http from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = ["${aws_security_group.http.id}"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_mysql"
  }
}

output "allow_http"{
    value = "${aws_security_group.http.id}"
}

output "allow_mysql"{
    value = "${aws_security_group.mysql.id}"
}