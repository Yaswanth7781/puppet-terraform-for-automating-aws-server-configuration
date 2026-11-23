# Register the SSH public key in AWS
resource "aws_key_pair" "uniguard_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)

  tags = {
    Name = "UniGuard-Application-Key"
  }
}

# Security group for application EC2
resource "aws_security_group" "application_sg" {
  name        = "UniGuard-Application-SG"
  description = "Security group for UniGuard application server"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH from DevOps EC2 only"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.control_security_group_id]
  }
  ingress {
    description = "HTTP web access"
    from_port   = 80
    to_port     = 80
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
    Name = "UniGuard-Application-SG"
  }
}

# Allow Puppet Agent to contact Puppet Server on EC2-1
resource "aws_vpc_security_group_ingress_rule" "puppet_server" {
  security_group_id            = var.control_security_group_id
  referenced_security_group_id = aws_security_group.application_sg.id

  description = "Puppet Agent to Puppet Server"
  from_port   = 8140
  to_port     = 8140
  ip_protocol = "tcp"
}

# Application EC2 instance
resource "aws_instance" "application" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.application_sg.id]
  key_name                    = aws_key_pair.uniguard_key.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name        = "UniGuard-Application"
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}
