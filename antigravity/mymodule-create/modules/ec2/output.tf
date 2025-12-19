output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.this.public_ip
}

output "key_name" {
  description = "Name of the key pair"
  value       = aws_key_pair.this.key_name
}
