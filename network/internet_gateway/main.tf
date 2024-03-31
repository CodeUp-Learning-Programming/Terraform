resource "aws_internet_gateway" "minha_ig_tf" {
  vpc_id = var.vpc_id

  tags = {
    Name = var.nome_igw
  }
}