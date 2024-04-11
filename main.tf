#TODO: Organizar o codigo
#TODO: Construir os shells scripts
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
  source = "./network/vpc"

  nome_vpc    = "vpc_tf"
  mascara_vpc = "10.0.0.0/24"
}

module "acl" {
  source            = "./network/acl"
  vpc_id            = module.vpc.id_vpc
  nome_acl_publica  = "acl_publica_tf"
  nome_acl_privada  = "acl_privada_tf"
  subnet_publica_id = module.subnet.subnet_publica_id
  subnet_privada_id = module.subnet.subnet_privada1_id
}

module "internet_gateway" {
  source   = "./network/internet_gateway"
  vpc_id   = module.vpc.id_vpc
  nome_igw = "minha_ig_tf"
}

module "route_table" {
  source             = "./network/route_table"
  vpc_id             = module.vpc.id_vpc
  igw_id             = module.internet_gateway.igw_id
  subnet_publica_id  = module.subnet.subnet_publica_id
  subnet_privada1_id = module.subnet.subnet_privada1_id

  nome_rt_publica = "rt_publica_tf"
  nome_rt_privada = "rt_privada_tf"
  nat_gateway_id = module.nat_gateway.nat_gateway_id
}

module "nat_gateway" {
  source            = "./network/nat_gateway"
  subnet_publica_id = module.subnet.subnet_publica_id

  nome_nat_gtw = "nat_01_tf"
  nome_eip     = "eip-tf"

}

module "subnet" {
  source = "./network/subnet"
  vpc_id = module.vpc.id_vpc

  nome_subnet_publica  = "subnet_publica_tf"
  nome_subnet_privada1 = "subnet_privada1_tf"
  nome_subnet_privada2 = "subnet_privada2_tf"
}

module "group_security" {
  source = "./network/group_security"
  vpc_id = module.vpc.id_vpc
}

module "ec2" {
  source             = "./compute/ec2"
  vpc_id             = module.vpc.id_vpc
  grupo_seguranca_id = module.group_security.grupo_seguranca_id

  #ECS Publica
  nome_ec2_publica           = "ec2_publica_tf"
  tipo_instancia_ec2_publica = "t2.micro"
  subnet_publica_id          = module.subnet.subnet_publica_id

  #ECS Privada1
  nome_ec2_privada1           = "ec2_privada1_tf"
  tipo_instancia_ec2_privada1 = "t2.micro"
  subnet_privada1_id          = module.subnet.subnet_privada1_id

  #ECS Privada2
  nome_ec2_privada2           = "ec2_privada2_tf"
  tipo_instancia_ec2_privada2 = "t2.micro"
  subnet_privada2_id          = module.subnet.subnet_privada2_id
}