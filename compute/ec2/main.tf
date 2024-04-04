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

#EC2 Publica
resource "aws_instance" "ec2_publica_tf" {
  ami           = "ami-080e1f13689e07408"  
  instance_type = var.tipo_instancia_ec2_publica 
  subnet_id = var.subnet_publica_id
  vpc_security_group_ids = ["${aws_security_group.grupo_seguranca_padrao_tf.id}"]     
  key_name = "myssh"
  associate_public_ip_address = true

  # Provisionador para executar comandos na instância EC2 remotamente
  provisioner "remote-exec" {
    # Comandos a serem executados na instância EC2
    inline = [file("./shell/ec2-publica.sh")]

    # Configuração de conexão SSH para se conectar à instância EC2
    connection {
      # Tipo de conexão SSH
      type        = "ssh"
      # Usuário SSH para conectar à instância (padrão: ec2-user para instâncias Amazon Linux)
      user        = "ubuntu"
      # Caminho para a chave privada usada para autenticação SSH
      private_key = file("/home/eduardo/Documents/Eduardo/Faculdade/Codeup/Terraform/compute/ec2/myssh.pem")
      # Endereço IP público da instância EC2
      host        = aws_instance.ec2_publica_tf.public_ip
    }
  }

  tags = {
    Name = var.nome_ec2_publica
  }
}

resource "aws_instance" "ec2_privada1_tf" {
  ami           = "ami-080e1f13689e07408"  
  instance_type = var.tipo_instancia_ec2_privada1
  subnet_id = var.subnet_privada1_id
  vpc_security_group_ids = ["${aws_security_group.grupo_seguranca_padrao_tf.id}"]
  key_name = "myssh"  
  associate_public_ip_address = false          

  tags = {
    Name = var.nome_ec2_privada1
  }
}

resource "aws_instance" "ec2_privada2_tf" {
  ami           = "ami-080e1f13689e07408"  
  instance_type = var.tipo_instancia_ec2_privada2
  subnet_id = var.subnet_privada2_id
  vpc_security_group_ids = ["${aws_security_group.grupo_seguranca_padrao_tf.id}"] 
  key_name = "myssh" 
  associate_public_ip_address = false        

  tags = {
    Name = var.nome_ec2_privada2
  }
}