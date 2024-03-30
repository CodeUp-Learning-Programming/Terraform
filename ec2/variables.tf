#Variaveis security group
variable "vpc_id" {
  description = "ID da VPC"
}


#Variaveis da EC2 Publica 
variable "nome_ec2_publica" {
  description = "Nome da EC2 publica"
}

variable "tipo_instancia_ec2_publica" {
  description = "Tipo da instância da EC2 publica"
}

variable "subnet_publica_id" {
  description = "ID da subnet publica"
}

#Variaveis da EC2 Privada 1
variable "nome_ec2_privada1" {
  description = "Nome da EC2 publica"
}

variable "tipo_instancia_ec2_privada1" {
  description = "Tipo da instância da EC2 publica"
}

variable "subnet_privada1_id" {
  description = "ID da subnet publica"
}

#Variaveis da EC2 Privada 2
variable "nome_ec2_privada2" {
  description = "Nome da EC2 publica"
}

variable "tipo_instancia_ec2_privada2" {
  description = "Tipo da instância da EC2 publica"
}

variable "subnet_privada2_id" {
  description = "ID da subnet publica"
}