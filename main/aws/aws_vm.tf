provider "aws" {
  region = "eu-north-1"
}

resource "aws_instance" "wireguard_aws" {
  ami           = "ami-07a64b147d3500b6a"  # Amazon Linux 2 AMI
  instance_type = "t3.micro"
  key_name      = "awskey"
  
  vpc_security_group_ids = [aws_security_group.wireguard_sg.id]
  associate_public_ip_address = true 
  tags = {
    Name = "WireGuardAWS"
  }
}

resource "aws_security_group" "wireguard_sg" {
  name        = "wireguard_sg"
  description = "Allow WireGuard VPN traffic"

  ingress {
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["10.1.0.0/16"]  # Change this to Azure IP later
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict SSH to your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}