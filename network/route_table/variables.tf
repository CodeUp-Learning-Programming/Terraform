variable "vpc_id" {
  description = "ID da VPC"
}

variable "igw_id" {
  description = "ID do Internet Gateway"
}

variable "subnet_publica_id" {
  description = "ID da subnet publica"
  
}

variable "subnet_privada1_id" {
  description = "ID da subnet privada"
}

variable "nome_rt_publica" {
  description = "Nome da route table publica"  
}

variable "nome_rt_privada" {
  description = "Nome da route table privada"  
}

variable "nat_gateway_id" {
  description = "Id do NatGateway"
}

