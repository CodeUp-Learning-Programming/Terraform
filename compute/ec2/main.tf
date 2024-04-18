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
    destination = "/home/ubuntu/myssh.pem"

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
    source      = "./shell/meu_site.conf"
    destination = "/home/ubuntu/meu_site.conf"

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
    source      = "./shell/instala-front.sh"
    destination = "/home/ubuntu/instala-front.sh"

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

resource "null_resource" "exec_ec2_publica" {
  depends_on = [ aws_instance.ec2_publica_tf, aws_instance.ec2_privada1_tf, null_resource.exec_ec2_privada1, null_resource.exec_ec2_privada2 ]

  # Provisionador para executar comandos na instância EC2 remotamente
  provisioner "remote-exec" {
    # Comandos a serem executados na instância EC2
    inline = [
      "sudo sed -i 's|http://10.0.0.185:8080|http://${aws_instance.ec2_privada1_tf.private_ip}:8080|g' /home/ubuntu/meu_site.conf",
      "echo 'Ip apontando para o back-end trocado com sucesso ${aws_instance.ec2_privada1_tf.private_ip}'",
      "bash instala-front.sh"
      # sed -i "s/http:\/\/10.18.32.128:8080\/api/http:\/\/${aws_instance.ec2_publica_tf.ip}\/api/g" "src/api.jsx" Altera o script do front
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
      host        = aws_instance.ec2_publica_tf.public_ip
    
    }
  }
  
}



resource "aws_instance" "ec2_privada1_tf" {
  ami           = "ami-080e1f13689e07408"  
  instance_type = var.tipo_instancia_ec2_privada1
  subnet_id = var.subnet_privada1_id
  vpc_security_group_ids = [var.grupo_seguranca_id]
  key_name = "myssh"  
  associate_public_ip_address = false

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

  provisioner "file" {
    source      = "./shell/instala-back.sh"
    destination = "/home/ubuntu/instala-back.sh"
  }

  /*provisioner "remote-exec" {
    inline = [
      "bash instala-back.sh",
      ]
      connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./myssh.pem")
    host        = self.private_ip
    agent       = false
    bastion_host = aws_instance.ec2_publica_tf.public_ip
  } 
  }*/

  

  tags = {
    Name = var.nome_ec2_privada1
  }
}

resource "null_resource" "exec_ec2_privada1" {
  depends_on = [ aws_instance.ec2_privada2_tf, null_resource.exec_ec2_privada2]

  # Provisionador para executar comandos na instância EC2 remotamente
  provisioner "remote-exec" {
    # Comandos a serem executados na instância EC2
    inline = [
      "bash instala-back.sh ${aws_instance.ec2_privada2_tf.private_ip}"
      # sed -i "s/http:\/\/10.18.32.128:8080\/api/http:\/\/${aws_instance.ec2_publica_tf.ip}\/api/g" "src/api.jsx" Altera o script do front
      ]

    # Configuração de conexão SSH para se conectar à instância EC2
    connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./myssh.pem")
    host        = aws_instance.ec2_privada1_tf.private_ip
    agent       = false
    bastion_host = aws_instance.ec2_publica_tf.public_ip
  }       

  }
  
}

resource "aws_instance" "ec2_privada2_tf" {
  ami           = "ami-080e1f13689e07408"  
  instance_type = var.tipo_instancia_ec2_privada2
  subnet_id = var.subnet_privada2_id
  vpc_security_group_ids = [var.grupo_seguranca_id] 
  key_name = "myssh" 
  associate_public_ip_address = false        

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./myssh.pem")
    host        = self.private_ip
    agent       = false
    bastion_host = aws_instance.ec2_publica_tf.public_ip
  }       

  provisioner "file" {
    source      = "./shell/instala-banco.sh"
    destination = "/home/ubuntu/instala-banco.sh"
  }

  provisioner "file" {
    source      = "./shell/script.sql"
    destination = "/home/ubuntu/script.sql"
  }


  tags = {
    Name = var.nome_ec2_privada2
  }
}

resource "null_resource" "exec_ec2_privada2" {
  depends_on = [ aws_instance.ec2_privada2_tf ]

  # Provisionador para executar comandos na instância EC2 remotamente
  provisioner "remote-exec" {
    # Comandos a serem executados na instância EC2
    inline = [
      "bash instala-banco.sh "
      ]

    # Configuração de conexão SSH para se conectar à instância EC2
    connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./myssh.pem")
    host        = aws_instance.ec2_privada2_tf.private_ip
    agent       = false
    bastion_host = aws_instance.ec2_publica_tf.public_ip
  }       

  }
  
}