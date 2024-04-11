#Atualiza os pacotes
sudo apt update
echo "Sistema atualizado com sucesso"

#Instala o NGINX
yes | sudo apt install nginx
echo "Nginx instalado com sucesso!"
#Instalando o unzip
sudo apt install unzip
echo "Unzip instalado com sucesso"
#Colocando nosso site no nginx
unzip dist.zip
cd dist
sudo cp -r * /var/www/html
cd /var/www/html
sudo rm index.nginx-debian.html
echo "Site estático no ar"

#Colocando o arquivo de configuracao
cd 
sudo cp meu_site.conf /etc/nginx/conf.d
echo "Arquivo de configuracao dentro da conf.d"