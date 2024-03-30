terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

module "vpc" {
    source = "./vpc"

    #Atribuindo valores as váriaveis que foram declaradas em ./vpc/variables
    nome_vpc = "vpc_tf"
    nome_subnet_publica = "subnet_publica_tf"
    nome_subnet_privada1 = "subnet_privada1_tf"
    nome_subnet_privada2 = "subnet_privada2_tf"
}

module "ec2"{
  source = "./ec2"
  
  #VPC
  vpc_id = module.vpc.id_vpc

  #ECS Publica
  nome_ec2_publica = "ec2_publica_tf"
  tipo_instancia_ec2_publica = "t2.micro"
  subnet_publica_id = module.vpc.id_subnet_publica

  #ECS Privada1
  nome_ec2_privada1 = "ec2_privada1_tf"
  tipo_instancia_ec2_privada1 = "t2.micro"
  subnet_privada1_id = module.vpc.id_subnet_privada1

  #ECS Privada2
  nome_ec2_privada2 = "ec2_privada2_tf"
  tipo_instancia_ec2_privada2 = "t2.micro"
  subnet_privada2_id = module.vpc.id_subnet_privada2
}