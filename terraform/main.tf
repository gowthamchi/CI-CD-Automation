provider "aws" {
  region = "ap-south-1"
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH and Jenkins UI"

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins Web UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jenkins_ec2" {
  ami                         = "ami-0f58b397bc5c1f2e8" # Ubuntu 22.04 in ap-south-1
  instance_type               = "t2.small"
  key_name                    = "jenkins1198"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  user_data                   = file("user_data.sh")

  tags = {
    Name = "jenkins-server"
  }
}
