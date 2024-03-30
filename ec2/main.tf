#EC2 Publica
resource "aws_instance" "ec2_publica_tf" {
  ami           = "ami-080e1f13689e07408"  
  instance_type = var.tipo_instancia_ec2_publica 
  subnet_id = id_subnet_publica             

  tags = {
    Name = var.nome_ec2_publica
  }
}