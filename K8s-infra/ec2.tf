
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.public_key
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "master" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.main.id
  key_name      = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  associate_public_ip_address = true

  tags = {
    Name = "k8s-master"
  }
}

resource "aws_instance" "worker" {
  count         = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.main.id
  key_name      = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  associate_public_ip_address = true

  tags = {
    Name = "k8s-worker-${count.index}"
  }
}
