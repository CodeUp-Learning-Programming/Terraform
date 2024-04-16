resource "aws_route_table" "rt_publica_tf" {
  vpc_id = var.vpc_id

  tags = {
    Name = var.nome_rt_publica
  }
}

#Rota
resource "aws_route" "aws_internet_gateway_route_tf" {
  route_table_id = aws_route_table.rt_publica_tf.id
  destination_cidr_block =   "0.0.0.0/0"
  gateway_id = var.igw_id
}

#Associando a Rota de tabela a subnet publica
resource "aws_route_table_association" "associacao_rt_publica" {
  subnet_id = var.subnet_publica_id
  route_table_id = aws_route_table.rt_publica_tf.id
}

#Route table privada
resource "aws_route_table" "rt_privada_tf" {
  vpc_id = var.vpc_id

  tags = {
    Name = var.nome_rt_privada
  }
}

resource "aws_route" "aws_nat_gateway_route_tf_privada1" {
  route_table_id = aws_route_table.rt_privada_tf.id
  destination_cidr_block =   "0.0.0.0/0"
  nat_gateway_id = var.nat_gateway_id
}

#Associando a Rota de tabela a subnet privada #Fazer
resource "aws_route_table_association" "associacao_rt_privada" {
  subnet_id = var.subnet_privada1_id
  route_table_id = aws_route_table.rt_privada_tf.id
}

resource "aws_route_table_association" "associacao_rt_privada2" {
  subnet_id = var.subnet_privada2_id
  route_table_id = aws_route_table.rt_privada_tf.id
}