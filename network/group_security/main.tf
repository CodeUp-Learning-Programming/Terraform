resource "aws_security_group" "grupo_seguranca_padrao_tf" {
  name        = "grupo_seguranca_padrao_tf"
  description = "Grupo de seguranca das EC2"
  vpc_id      = var.vpc_id  # Substitua pelo ID da sua VPC

  // Regras de entrada
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Acesso SSH de qualquer lugar
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Acesso HTTP de qualquer lugar
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Acesso MySQL de qualquer lugar
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Acesso HTTP de qualquer lugar
  }

  // Regras de saída
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"            # Todos os protocolos
    cidr_blocks = ["0.0.0.0/0"]   # Permitir saída para qualquer lugar
  }

  tags = {
    Name = "grupo_seguranca_padrao"
  }
}