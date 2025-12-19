output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.net.vpc_id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = module.ec2.instance_public_ip
}

output "key_name" {
  description = "Name of the key pair"
  value       = module.ec2.key_name
}
