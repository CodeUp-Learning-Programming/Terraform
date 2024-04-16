#!/bin/bash

# Atualizando os pacotes
echo "Atualizando os pacotes..."
if sudo apt update; then
    echo "Pacotes atualizados com sucesso."
else
    echo "Erro ao atualizar os pacotes. Código de erro: $?"
    exit 1
fi

# Instalando o docker.io
echo "Instalando o Docker.io..."
if yes | sudo apt install docker.io; then
    echo "Docker.io instalado com sucesso."
else
    echo "Erro ao instalar o Docker.io. Código de erro: $?"
    exit 1
fi

# Adicionando o usuário ao grupo do Docker
echo "Adicionando o usuário ao grupo do Docker..."
if sudo usermod -a -G docker $(whoami); then
    echo "Usuário adicionado ao grupo Docker com sucesso."
else
    echo "Erro ao adicionar o usuário ao grupo Docker. Código de erro: $?"
    exit 1
fi

echo "Esperando inicialização do docker"
sleep 10

# Executando o contêiner MySQL
echo "Executando o contêiner MySQL..."
if sudo docker run --name bd_ec2 -e MYSQL_ROOT_PASSWORD=urubu100 -p 3306:3306 -d mysql:latest; then
    echo "Contêiner MySQL executado com sucesso."
else
    echo "Erro ao executar o contêiner MySQL. Código de erro: $?"
    exit 1
fi

echo "Esperando inicialização do container"
sleep 20

echo "Verificando status do contêiner MySQL..."
sudo docker ps | grep bd_ec2

# Executando o script SQL
echo "Executando o script SQL..."
if sudo docker exec -i bd_ec2 mysql -u root -purubu100 --protocol=tcp -h localhost -P3306 < /home/ubuntu/script.sql; then
    echo "Script SQL executado com sucesso."
else
    echo "Erro ao executar o script SQL. Código de erro: $?"
    exit 1
fi



