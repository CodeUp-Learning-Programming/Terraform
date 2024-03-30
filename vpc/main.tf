#VPC
resource "aws_vpc" "vpc_tf"{
    cidr_block       = "10.0.0.0/24"
    #
    instance_tenancy = "default"

    tags = {
        Name = var.nome_vpc 
    }
}

#Internet Gateway
resource "aws_internet_gateway" "minha_ig_tf" {
  vpc_id = aws_vpc.vpc_tf

  tags = {
    Name = "minha_ig_tf"
  }
}

#Route table publica
resource "aws_route_table" "rt_publica_tf" {
  vpc_id = aws_vpc.vpc_tf

  tags = {
    Name = "rt_publica_tf"
  }
}

#Associando a Rota de tabela a subnet publica
resource "aws_route_table_association" "associacao_rb" {
  subnet_id = aws_subnet.subnet_publica_tf
  route_table_id = aws_route_table.rt_publica_tf
}

#NAT Gateway
resource "aws_nat_gateway" "nat_01_tf" {
  allocation_id = aws_eip.example_eip
  subnet_id = aws_subnet.subnet_publica_tf

  tags = {
    Name = "nat_01_tf"
  }
}

# IP elástico para o NAT Gateway
resource "aws_eip" "example_eip" {
  tags = {
    Name = "eip-tf"
  }
}

#Route table privada
resource "aws_route_table" "rt_privada_tf" {
  vpc_id = aws_vpc.vpc_tf

  tags = {
    Name = "rt_privada_tf"
  }
}

#Associando a Rota de tabela a subnet privada
resource "aws_route_table_association" "associacao_rb" {
  subnet_id = aws_subnet.subnet_privada1_tf
  route_table_id = aws_route_table.rt_privada1_tf
}

#Sub_net
#Sub_net publica
resource "aws_subnet" "subnet_publica_tf"{
    vpc_id     = aws_vpc.vpc_tf.id
    cidr_block = "10.0.0.0/25"

    tags = {
    Name = var.nome_subnet_publica
  }
}

#Sub_net privada 1
resource "aws_subnet" "subnet_privada1_tf"{
    vpc_id     = aws_vpc.vpc_tf.id
    cidr_block = "10.0.0.128/26"

    tags = {
    Name = var.nome_subnet_privada1
  }
}

#Sub_net privada 2
resource "aws_subnet" "subnet_privada2_tf"{
    vpc_id     = aws_vpc.vpc_tf.id
    cidr_block = "10.0.0.192/26"

    tags = {
    Name = var.nome_subnet_privada2
  }
}