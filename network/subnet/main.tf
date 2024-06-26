#Sub_net publica
resource "aws_subnet" "subnet_publica_tf"{
    vpc_id     = var.vpc_id
    cidr_block = "10.0.0.0/25"

    tags = {
    Name = var.nome_subnet_publica
  }
}

#Sub_net privada 1
resource "aws_subnet" "subnet_privada1_tf"{
    vpc_id     = var.vpc_id
    cidr_block = "10.0.0.128/26"

    tags = {
    Name = var.nome_subnet_privada1
  }
}

#Sub_net privada 2
resource "aws_subnet" "subnet_privada2_tf"{
    vpc_id     = var.vpc_id
    cidr_block = "10.0.0.192/26"

    tags = {
    Name = var.nome_subnet_privada2
  }
}