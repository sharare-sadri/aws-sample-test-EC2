provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "mypvc" {
  id = "vpc-id"
}

resource "aws_key_pair" "test" { ### we use to ssh to the ec2 vm 
  key_name   = "test"
  public_key = ""

}



resource "aws_instance" "test" {
  ami           = "ami-052efd3df9dad4825"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.test.key_name
  user_data     = <<EOL
  #!/usr/bin/bash        #### or echo test > /opt/test.txt
apt-get update
apt-get install puppet
EOL
  security_groups = [
    aws_security_group.test.name
  ]
  tags = {
    Name = "test"
  }
}

resource "aws_security_group" "test" {
  name        = "test"
  description = "Allow TLS inbound traffic"
  vpc_id      = data.aws_vpc.mypvc.id
  ingress {
    description = "Access ssh"
    to_port     = 22
    from_port   = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    to_port     = 0
    from_port   = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

output "test_ip" {
  value = aws_instance.test.public_ip
}


