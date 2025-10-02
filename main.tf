data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

locals {
  tags = {

    Name     = "TR_Jenkins_EC2"
    User     = "Thejana"
    Duration = "24h"

  }
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH and Jenkins UI"

  ingress {
    description = "SSH"
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

  tags = {
    Name = "jenkins-sg"
  }
}

resource "aws_instance" "TR_Jenkins_EC2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  user_data              = base64encode(file("userdata1.sh"))
  key_name               = "test_rnd"

  tags        = local.tags
  volume_tags = local.tags

}

output "jenkins_public_ip" {
  description = "Public IP of Jenkins server"
  value       = aws_instance.TR_Jenkins_EC2.public_ip
}

output "jenkins_url" {
  description = "Jenkins URL"
  value       = "http://${aws_instance.TR_Jenkins_EC2.public_ip}:8080"
}

output "ssh_command" {
  description = "SSH command to connect to Jenkins server"
  value       = "ssh -i <your-key.pem> ec2-user@${aws_instance.TR_Jenkins_EC2.public_ip}"
}
