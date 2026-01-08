output "public_ip" {
  value       = module.ec2.public_ip
  description = "Public IP of the EC2 instance"
}

output "ssm_command" {
  value       = "aws ssm start-session --target ${module.ec2.instance_id} --region ${var.aws_region} --profile kailas"
  description = "SSM command to connect to the EC2 instance"
}