resource "aws_network_acl" "acl_publica_tf" {
  vpc_id = var.vpc_id

  # Regra de entrada
    # Regra de entrada para todo o tráfego
  ingress {
     rule_no     = 100
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    action = "allow"
    cidr_block  = "0.0.0.0/0"
  }

  # Regra de entrada para HTTP (porta 80)
  ingress {
     rule_no     = 110
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    action = "allow"
    cidr_block  = "0.0.0.0/0"
  }

  # Regra de entrada para HTTPS (porta 443)
  ingress {
    rule_no     = 120
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    action = "allow"
    cidr_block  = "0.0.0.0/0"
  }

  # Regra de entrada para SSH (porta 22)
  ingress {
    rule_no     = 130
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    action = "allow"
    cidr_block  = "0.0.0.0/0"
  }

  # Regra de saída
  egress {
    rule_no     = 140
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    action = "allow"
    cidr_block  = "0.0.0.0/0"
  }

  # Outras configurações...
  tags = {
    Name = var.nome_acl_publica
  }
}

# Associe a ACL a uma subnet
resource "aws_network_acl_association" "association_subnet_publica" {
  subnet_id          = var.subnet_publica_id
  network_acl_id     = aws_network_acl.acl_publica_tf.id
}

resource "aws_network_acl" "acl_privada_tf" {
  vpc_id = var.vpc_id

  # Regra de entrada para HTTP (porta 80) da sub-rede privada
  ingress {
    rule_no     = 150
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    action = "allow"
    cidr_block  = "10.0.0.0/25"  # Permitindo apenas do intervalo específico
  }

  # Regra de entrada para HTTPS (porta 443) da sub-rede privada
  ingress {
    rule_no     = 160
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    action = "allow"
    cidr_block  = "10.0.0.0/25"  # Permitindo apenas do intervalo específico
  }

  # Regra de entrada para SSH (porta 22) da sub-rede privada
  ingress {
    rule_no     = 170
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    action = "allow"
    cidr_block  = "10.0.0.0/25"  # Permitindo apenas do intervalo específico
  }

  # Regra de saída
  egress {
    rule_no     = 180
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    action = "allow"
    cidr_block  = "0.0.0.0/0"
  }

  # Outras configurações...
  tags = {
    Name = var.nome_acl_privada
  }
}

resource "aws_network_acl_association" "association_subnet_privada" {
  subnet_id          = var.subnet_privada_id
  network_acl_id     = aws_network_acl.acl_privada_tf.id
}