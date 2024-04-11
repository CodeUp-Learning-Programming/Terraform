# IP elástico para o NAT Gateway
resource "aws_eip" "eip-tf" {
  vpc = true
  tags = {
    Name = var.nome_eip
  }
}


#NAT Gateway
resource "aws_nat_gateway" "nat_01_tf" {
  allocation_id = aws_eip.eip-tf.id
  subnet_id = var.subnet_publica_id
  #subnet_id = aws_subnet.subnet_publica_tf.id

  tags = {
    Name = var.nome_nat_gtw
  }
}

