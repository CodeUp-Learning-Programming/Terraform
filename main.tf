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
  nome_ec2_publica = "ec2_public_tf"
  tipo_instancia_ec2_publica = "t2.micro"
}