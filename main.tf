provider "aws" {
  region     = "us-east-2"
}
resource "aws_vpc" "ansiblevpc" {
  cidr_block = "11.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    "Name" = "Ansible-Terraform-VPC"
  }
}
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.ansiblevpc.id
  cidr_block        = "11.0.2.0/24"
  availability_zone = "us-east-2a"
  tags = {
    "Name" = "Ansible-Terraform-Subnet-Private"
  }
}
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.ansiblevpc.id
  cidr_block        = "11.0.1.0/24"
  availability_zone = "us-east-2a"
  tags = {
    "Name" = "Ansible-Terraform-Subnet-Public"
  }
}
resource "aws_route_table" "ansible-rt" {
  vpc_id = aws_vpc.ansiblevpc.id
  tags = {
    "Name" = "Ansible-Terraform-RT"
  }
}
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.ansible-rt.id
}
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.ansible-rt.id
}
resource "aws_internet_gateway" "ansible-igw" {
  vpc_id = aws_vpc.ansiblevpc.id
  tags = {
    "Name" = "Ansible-Terraform-IG"
  }
}
resource "aws_route" "internet-route" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.ansible-rt.id
  gateway_id             = aws_internet_gateway.ansible-igw.id
}
resource "aws_network_interface" "ansible-nic" {
  count           = var.number_of_instances
  subnet_id       = aws_subnet.public.id
  private_ips     = ["11.0.1.12${count.index}"]
  security_groups = [aws_security_group.web-pub-sg.id]
  tags = {
    "Name" = "Ansible-Terraform-NI"
  }
}
resource "aws_eip" "ip-one" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.ansible-nic.id
  depends_on                = [aws_instance.terraformvms]
  tags = {
    "Name" = "Ansible-Terraform-EIP"
  }
}
resource "aws_security_group" "web-pub-sg" {
  name        = "Ansible_SG"                ### Survey
  description = "allow inbound traffic"
  tags = {
    "Name" = "Ansible-Terraform-SG"
  }
  vpc_id      = aws_vpc.ansiblevpc.id
  ingress {
    description = "from my ip range"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS"
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    to_port     = "0"
  }
}
resource "aws_instance" "terraformvms" {
  instance_type = "t2.micro"
  count         = var.number_of_instances
  ami           = var.ami_map[var.rhel_version]
  network_interface {
    network_interface_id = aws_network_interface.ansible-nic[count.index].id
    device_index         = 0
delete_on_termination = false
  }
  key_name = "Shadowmankey"
  tags = {
      Name = "${var.instance_name_convention}${count.index}.shadowman.dev"
      owner: "adworjan"
      env: "dev"
      operating_system: var.rhel_version
      usage: "shadowmandemos"
      }
}
