#EC2 Publica
resource "aws_instance" "ec2_publica_tf" {
  ami           = "ami-080e1f13689e07408"  
  instance_type = var.tipo_instancia_ec2_publica 
  subnet_id = var.subnet_publica_id
  vpc_security_group_ids = [var.grupo_seguranca_id]     
  key_name = "myssh"
  associate_public_ip_address = true

  # Transferir a chave privada para a instância EC2 pública
  # Configurações da instância EC2...
  provisioner "file" {
    source      = "./myssh.pem"
    destination = "/home/ubuntu/chave.pem"

    connection {
      # Tipo de conexão SSH
      type        = "ssh"
      # Usuário SSH para conectar à instância (padrão: ec2-user para instâncias Amazon Linux)
      user        = "ubuntu"
      # Caminho para a chave privada usada para autenticação SSH
      private_key = file("./myssh.pem")
      # Endereço IP público da instância EC2
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "./shell/dist.zip"
    destination = "/home/ubuntu/chave.pem"

    connection {
      # Tipo de conexão SSH
      type        = "ssh"
      # Usuário SSH para conectar à instância (padrão: ec2-user para instâncias Amazon Linux)
      user        = "ubuntu"
      # Caminho para a chave privada usada para autenticação SSH
      private_key = file("./myssh.pem")
      # Endereço IP público da instância EC2
      host        = self.public_ip
    }
  }

  # Provisionador para executar comandos na instância EC2 remotamente
  provisioner "remote-exec" {
    # Comandos a serem executados na instância EC2
    inline = [
      file("./shell/instala-front.sh")
      #TODO: Adicionar o script de instalação do Front-end
      ]

    # Configuração de conexão SSH para se conectar à instância EC2
    connection {
      # Tipo de conexão SSH
      type        = "ssh"
      # Usuário SSH para conectar à instância (padrão: ec2-user para instâncias Amazon Linux)
      user        = "ubuntu"
      # Caminho para a chave privada usada para autenticação SSH
      private_key = file("./myssh.pem")
      # Endereço IP público da instância EC2
      host        = self.public_ip
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
  vpc_security_group_ids = [var.grupo_seguranca_id]
  key_name = "myssh"  
  associate_public_ip_address = true

  /*connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./myssh.pem")
    host        = self.private_ip
    agent       = false
    bastion_host {
      host        = aws_instance.bastion_host.public_ip
      user        = "ubuntu"
      private_key = file("./myssh.pem")
    }
  }*/
   connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./myssh.pem")
    host        = self.private_ip
    agent       = false
    bastion_host = aws_instance.ec2_publica_tf.public_ip
  }         

  provisioner "remote-exec" {
    inline = [
      "mkdir deubom"
      #TODO: Adicionar o script de instalação do back-end
      ]
  }

  tags = {
    Name = var.nome_ec2_privada1
  }
}

resource "aws_instance" "ec2_privada2_tf" {
  ami           = "ami-080e1f13689e07408"  
  instance_type = var.tipo_instancia_ec2_privada2
  subnet_id = var.subnet_privada2_id
  vpc_security_group_ids = [var.grupo_seguranca_id] 
  key_name = "myssh" 
  associate_public_ip_address = false        

  tags = {
    Name = var.nome_ec2_privada2
  }
}