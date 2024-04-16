# Definindo algumas cores com códigos de escape ANSI
CYAN_BOLD='\033[1;36m'
RESET='\033[0m' # Restaura a cor padrão

# Atualiando o sistema
echo -e "${CYAN_BOLD}Atualizando o sistema...${RESET}"
sudo apt update
echo -e "${CYAN_BOLD}Sistema atualizado com sucesso!!${RESET}"

#Instala o NGINX
echo -e "${CYAN_BOLD}Instalando o NGINX...${RESET}"
yes | sudo apt install nginx -y
echo "Nginx instalado com sucesso!"
echo -e "${CYAN_BOLD}NGINX instalado com sucesso!!${RESET}"


#Instalando o NVM
echo -e "${CYAN_BOLD}Instalando o nvm...${RESET}"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

# Codigo para o nvm funcionar sem precisar resetar o terminal
export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
echo -e "${CYAN_BOLD}NVM instalado com sucesso!!${RESET}"

# Baixando a versao 21 do node
echo -e "${CYAN_BOLD}Instalando a versão 21 do Node com o nvm${RESET}"
nvm install 21 -y
echo -e "${CYAN_BOLD}Versão do 21 do node instalada com sucesso!!${RESET}"

# Instalando o NPM
echo -e "${CYAN_BOLD}Instalando o NPM...${RESET}"
yes | sudo apt install npm -y

echo -e "${CYAN_BOLD}NPM instalado com sucesso${RESET}"
# Baixar o front do GitHub
echo -e "${CYAN_BOLD}Clonando repositório do projeto${RESET}"
wget https://github.com/CodeUp-Learning-Programming/CodeUp_FrontEnd/archive/refs/heads/dev.zip

echo -e "${CYAN_BOLD}Repositorio clonado com sucesso!!${RESET}"
# Baixando o unzip
echo -e "${CYAN_BOLD}Baixando o unzip...${RESET}"

yes | sudo apt install unzip -y

echo -e "${CYAN_BOLD}Unzip baixado com sucesso!!${RESET}"
# Descompactar o arquivo
echo -e "${CYAN_BOLD}Descompactando o projeto...${RESET}"
unzip dev.zip

echo -e "${CYAN_BOLD}Projeto descompactado!!${RESET}"
# Mover para o diretório do projeto
cd CodeUp_FrontEnd-dev/

# Instalando o projeto
echo -e "${CYAN_BOLD}Instalando projeto com NPM...${RESET}"
npm i

echo -e "${CYAN_BOLD}Projeto instalando!!${RESET}"

# Obter o IP público da instância EC2 a partir do serviço de metadados
echo -e "${CYAN_BOLD}Alterando IP da API...${RESET}"
ip=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# Verifique se o comando curl foi bem-sucedido
if [ $? -ne 0 ]; then
  echo "Erro ao obter o IP público da instância EC2."
  exit 1
fi

# Modificar a linha correspondente ao padrão com o novo IP público
sed -i "s/http:\/\/10.18.32.128:8080\/api/http:\/\/$ip\/api/g" "src/api.jsx"

# Avisar que a operação foi concluída
echo -e "${CYAN_BOLD}Arquivo modificado com o IP público da EC2: $ip${RESET}"

#Buildando o projeto
npm run build
echo "Diretório atual antes de mudar para 'dist': $(pwd)"

# Mudar para o diretório 'dist'
cd dist

# Verifique se a mudança de diretório foi bem-sucedida
if [ $? -ne 0 ]; then
  echo "Erro ao mudar para o diretório 'dist'."
  exit 1
fi

# Verifique o diretório atual
echo "Diretório atual após mudar para 'dist': $(pwd)"

# Copiando a dist para o nginx
sudo cp -r * /var/www/html

# Verifique se a cópia foi bem-sucedida
if [ $? -ne 0 ]; then
  echo "Erro ao copiar arquivos para /var/www/html."
  exit 1
else
  echo "Arquivos copiados com sucesso para /var/www/html."
fi

#Colocando nosso site no nginx
cd /var/www/html
sudo rm index.nginx-debian.html
echo "Site estático no ar"

#Colocando o arquivo de configuracao
cd 
sudo cp meu_site.conf /etc/nginx/sites-enabled
echo "Arquivo de configuracao dentro do sites-enabled"