output "id_vpc" {
  value = aws_vpc.vpc_tf.id
}

output "id_subnet_publica" {
  value = aws_subnet.subnet_publica_tf.id
}

output "id_subnet_privada1" {
  value = aws_subnet.subnet_privada1_tf.id
}

output "id_subnet_privada2" {
  value = aws_subnet.subnet_privada2_tf.id
}
