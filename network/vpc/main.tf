resource "aws_vpc" "vpc_tf"{
    cidr_block       = var.mascara_vpc
    #
    instance_tenancy = "default"

    tags = {
        Name = var.nome_vpc 
    }
}