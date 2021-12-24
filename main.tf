
locals {
    common_tags = {
        "Name"      = "Desafio_Final_EC2"
        "Ambiente"  = "Dev"
        "Time"      = "Mackenzie"
        "Aplicacao" = "Frontend"
        "BU"        = "Conta Digital"
    }
}

# Create a VPC
resource "aws_vpc" "desafio_final_opc2_vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = "true"
    tags = {
        Name = "VPC Desafio Final Opc2"
    }
}

# Create Internet Gateway
resource "aws_internet_gateway" "desafio_final_opc2_igw" {
  vpc_id = aws_vpc.desafio_final_opc2_vpc.id
  tags = {
    Name = "IGW Desafio Final Opc2 "
  }
}

# Create Subnet Public
resource "aws_subnet" "opc2_subnet_1a" {
  vpc_id            = aws_vpc.desafio_final_opc2_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Subnet Public Opc2 AZ 1a"
  }
}

# Create Subnet Public
resource "aws_subnet" "opc2_subnet_1b" {
  vpc_id            = aws_vpc.desafio_final_opc2_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Subnet Public Opc2 AZ 1b"
  }
}

# Create Route table
resource "aws_route_table" "opc2_rtb" {
  vpc_id = aws_vpc.desafio_final_opc2_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.desafio_final_opc2_igw.id
  }
  tags = {
    Name = "Route Table Opc2"
  }
}

# Route table association with public subnet AZ 1a
resource "aws_route_table_association" "opc2_rtb_association_1a" {
  subnet_id      = aws_subnet.opc2_subnet_1a.id
  route_table_id = aws_route_table.opc2_rtb.id
}

# Route table association with public subnet AZ 1b
resource "aws_route_table_association" "opc2_rtb_association_1b" {
  subnet_id      = aws_subnet.opc2_subnet_1b.id
  route_table_id = aws_route_table.opc2_rtb.id
}

# Create Security Group
resource "aws_security_group" "allow_ports_desafio_final_opc2" {
  name        = "SG-Desafio-Final-Opc2"
  description = "SG Desafio Final Opcao 2 via Terraform"
  vpc_id      = aws_vpc.desafio_final_opc2_vpc.id
  
  dynamic "ingress"{
      for_each = var.sg_ports
      iterator = porta # Alias do Dynamic
      content {
          from_port   = porta.value # ingress.value
          to_port     = porta.value # ingress.value
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"] 
      }
  }

  dynamic "egress"{
      for_each = var.sg_ports
      content {
          from_port   = egress.value
          to_port     = egress.value
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"] 
      }
  }

  tags = {
    Name = "sg_allow_ports_opc2"
  }

}


module "ec2_instance_1a" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name          = "desafio_final_ec2_1a"
  ami           = "ami-04902260ca3d33422"
  instance_type = "t3.medium"
  key_name      = "vockey"
  subnet_id     = aws_subnet.opc2_subnet_1a.id
  vpc_security_group_ids = [aws_security_group.allow_ports_desafio_final_opc2.id]
  associate_public_ip_address = "true"

  tags = local.common_tags
  /*
  provisioner "remote-exec" {
      inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras install -y nginx1.12",
      "sudo systemctl start nginx"
      ]
  }

  connection {
      type     = "ssh"
      user     = "ec2-user"
      private_key = file("./labsuser.pem")
      host     = self.public_ip
  }
  */
}

module "ec2_instance_1b" {
    source  = "terraform-aws-modules/ec2-instance/aws"
    version = "~> 3.0"

    name          = "desafio_final_ec2_1b"
    ami           = "ami-04902260ca3d33422"
    instance_type = "t2.micro"
    key_name      = "vockey"
    subnet_id     = aws_subnet.opc2_subnet_1b.id
    vpc_security_group_ids = [aws_security_group.allow_ports_desafio_final_opc2.id]
    associate_public_ip_address = "true"

    tags = {
        Name = "Desafio_Final_EC2_1b"
    }
    
    /*
    provisioner "remote-exec" {
        inline = [
        "sudo yum update -y",
        "sudo amazon-linux-extras install -y nginx1.12",
        "sudo systemctl start nginx"
        ]
    }

    connection {
        type     = "ssh"
        user     = "ec2-user"
        private_key = file("./labsuser.pem")
        host     = self.public_ip
    }
    */
}

# Some info about the first instance
output "instance_desafio_ec2_1a_arn" {
    value = module.ec2_instance_1a.arn    
}

output "instance_desafio_ec2_1a_ip" {
    value = module.ec2_instance_1a.public_ip
}

output "instance_desafio_ec2_1a_dns" {
    value = module.ec2_instance_1a.public_dns
}

# Some info about the second instance
output "instance_desafio_ec2_1b_arn" {
    value = module.ec2_instance_1b.arn    
}

output "instance_desafio_ec2_1b_ip" {
    value = module.ec2_instance_1b.public_ip
}

output "instance_desafio_ec2_1b_dns" {
    value = module.ec2_instance_1b.public_dns
}
