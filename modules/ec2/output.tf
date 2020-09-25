locals {
    mysql_private_ip = compact(coalescelist(aws_instance.ec2.*.private_ip, [""]))
    apache_public_ip = compact(coalescelist(aws_instance.ec2.*.public_ip, [""]))
}

output "private_ip" {
  description = "List of private IP addresses assigned to the instances"
  value       = local.mysql_private_ip
}

output "public_ip" {
  description = "List of private IP addresses assigned to the instances"
  value       = local.apache_public_ip
}
