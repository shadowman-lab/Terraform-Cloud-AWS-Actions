provider "aws" {
  region     = "us-east-2"
}

data "aws_ami" "rhelami" {
  most_recent      = true
  owners           = ["309956199498"]

  filter {
    name   = "name"
    values = ["${var.lookup_map[var.rhel_version]}*HVM*-*Access2*"]
  }
   filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_vpc" "ansiblevpc" {
  cidr_block = "11.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    "Name" = "Ansible-Terraform-VPC"
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
  ami           = data.aws_ami.rhelami.id
  associate_public_ip_address = true
  subnet_id       = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web-pub-sg.id]
  key_name = "Shadowmankey"
  tags = {
      Name = "${var.instance_name_convention}${count.index}.shadowman.dev"
      owner: "adworjan"
      env: "dev"
      operating_system: var.rhel_version
      usage: "shadowmandemos"
      }

  lifecycle {
    action_trigger {
      events = [after_create]
      actions = [action.aap_eda_eventstream_post.create[count.index]]
    }
    # action_trigger {
    #  events = [after_create]
    #  actions = [action.aap_workflow_job_launch.aftercreate[count.index]]
    # }
    # action_trigger {
    #  events = [before_destroy]
    #  actions = [action.aap_workflow_job_launch.beforedestroy[count.index]]
    # }
    # action_trigger {
    #  events = [after_destroy]
    #  actions = [action.aap_job_launch.afterdestroy[count.index]]
    # }
  }
}

action "aap_eda_eventstream_post" "create" {
  count         = var.number_of_instances
  config {
    template_type = "workflow_job"
    limit = aws_instance.terraformvms[count.index].tags.Name
    workflow_job_template_name = "Config VM, Deploy Web App with Failure Paths Citrix TF Actions"
    organization_name = "Infrastructure"
    event_stream_config = {
      url = var.aap_eda_eventstream_url
      username = var.aap_eda_eventstream_username
      password = var.aap_eda_eventstream_password
    }
  }
}
#   action "aap_workflow_job_launch" "aftercreate" {
#   count                 = var.number_of_instances
#   config {
#     job_template_id     = 1279
#     wait_for_completion = true
#     extra_vars          = jsonencode({
#       vm_name           = aws_instance.terraformvms[count.index].tags.Name
#       ticket_number     = var.ticket_number
#       shadowman_provision_hypervisor = "AWS"
#     })
#   }
#   }
#   action "aap_workflow_job_launch" "beforedestroy" {
#   count                 = var.number_of_instances
#   config {
#     job_template_id     = 958
#     wait_for_completion = true
#     extra_vars          = jsonencode({
#       vm_name           = aws_instance.terraformvms[count.index].tags.Name
#       ticket_number     = var.ticket_number
#     })
#   }
# }
#   action "aap_job_launch" "afterdestroy" {
#   count                 = var.number_of_instances
#   config {
#     job_template_id     = 1282
#     wait_for_completion = true
#     extra_vars          = jsonencode({
#       shadowman_provision_hypervisor = "AWS"
#     })
#   }
# }
