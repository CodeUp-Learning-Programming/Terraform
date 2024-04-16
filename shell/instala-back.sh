#!/bin/bash

ip_bd=$1

echo "Atualizando pacotes"
sudo apt update -y

# Instalando Maven, JDK e JRE
sudo apt install -y maven openjdk-18-jdk default-jre 


# Diretório do projeto
project_dir="api"

# Se o diretório já existe, atualiza o repositório
if [ -d "$project_dir" ]; then
  echo "Atualizando Repositório"
  cd "$project_dir" && git pull
else
  # Se não existir, clona o repositório
  echo "Clonando Repositório"
  git clone https://github.com/CodeUp-Learning-Programming/CodeUp_BackEnd.git "$project_dir"
  cd api
  git checkout -f desenvolvimento
fi

#Trocando para o ip do banco
sed -i "s/jdbc:mysql:\/\/localhost:3306/jdbc:mysql:\/\/$ip_bd:3306/g" src/main/resources/application.properties

# Compilação e empacotamento com Maven,Criando jar
echo "Compilando e empacotando com Maven"
mvn clean package -DskipTests

# Executando o arquivo JAR
cd target
chmod +x "codeup-0.0.1-SNAPSHOT.jar"
java -jar "codeup-0.0.1-SNAPSHOT.jar" &