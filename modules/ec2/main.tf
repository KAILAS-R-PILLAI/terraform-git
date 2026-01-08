resource "aws_iam_role" "ssm_role" {
  name = "ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "this" {
  name = "ec2-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_security_group" "this" {
  name   = "ec2-sg"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
  }
}

resource "aws_instance" "this" {
  ami                    = "ami-04808bdb94be6720e" 
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.this.id]
  iam_instance_profile   = aws_iam_instance_profile.this.name
  associate_public_ip_address = true

  tags = {
    Name = "ec2-prod"
  }
}
resource "null_resource" "ssm_bootstrap" {
  depends_on = [aws_instance.this]

  triggers = {
    instance_id = aws_instance.this.id
  }

  provisioner "local-exec" {
  command = <<EOT
sleep 60 && aws ssm send-command --document-name "AWS-RunShellScript" --targets "Key=instanceIds,Values=${aws_instance.this.id}" --parameters 'commands=["sudo amazon-linux-extras enable nginx1","sudo yum clean metadata","sudo yum install -y nginx","sudo systemctl start nginx","sudo systemctl enable nginx"]' --region ap-south-1
EOT
}
}
