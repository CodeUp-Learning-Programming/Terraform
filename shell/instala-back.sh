#!/bin/bash

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
  git checkout desenvolvimentoNuvem
# Mudança de branch
  git branch
  cd "$project_dir"
fi

# Compilação e empacotamento com Maven,Criando jar
echo "Compilando e empacotando com Maven"
mvn clean package -DskipTests

# Executando o arquivo JAR
jar_name="api.jar"
chmod +x "$jar_name"
java -jar "$jar_name"