resource "aws_instance" "ec2" {

  count                  = var.instance_count

  ami                    = var.ami
  instance_type          = var.instance_type
  user_data              = var.user_data
  subnet_id              = var.subnet_id                   #distinct(compact(concat([var.subnet_id], var.subnet_ids)))[count.index]
  #region                 = var.region
  key_name               = var.key_name
  vpc_security_group_ids = var.vpc_security_group_ids
  associate_public_ip_address = var.associate_public_ip_address

    tags = {
    Name = "${var.tags}-${count.index +1}"
  }
  
}


