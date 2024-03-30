#TODO: Adicionar o group security
resource "aws_security_group" "grupo_seguranca_padrao-tf" {
  name        = "grupo_seguranca_padrao-tf"
  description = "Grupo de segurança das EC2"

  vpc_id      = var.vpc_id  # Substitua pelo ID da sua VPC

  // Regras de entrada
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Acesso SSH de qualquer lugar
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Acesso HTTP de qualquer lugar
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

#EC2 Publica
resource "aws_instance" "ec2_publica_tf" {
  ami           = "ami-080e1f13689e07408"  
  instance_type = var.tipo_instancia_ec2_publica 
  subnet_id = var.subnet_publica_id
  vpc_security_group_ids = [aws_security_group.grupo_seguranca_padrao]     
  key_name = "myssh"
  tags = {
    Name = var.nome_ec2_publica
  }
}

#EC2 Privada1
resource "aws_instance" "ec2_privada1_tf" {
  ami           = "ami-080e1f13689e07408"  
  instance_type = var.tipo_instancia_ec2_privada1
  subnet_id = var.subnet_privada1_id
  vpc_security_group_ids = [aws_security_group.grupo_seguranca_padrao]
  key_name = "myssh"  
  associate_public_ip_address = false          

  tags = {
    Name = var.nome_ec2_privada1
  }
}

#ECS Privada2
resource "aws_instance" "ec2_privada2_tf" {
  ami           = "ami-080e1f13689e07408"  
  instance_type = var.tipo_instancia_ec2_privada2
  subnet_id = var.subnet_privada2_id
  vpc_security_group_ids = [aws_security_group.grupo_seguranca_padrao]  
  key_name = "myssh" 
  associate_public_ip_address = false        

  tags = {
    Name = var.nome_ec2_privada2
  }
}