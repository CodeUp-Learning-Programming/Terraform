#Atualiza os pacotes
sudo apt update -y

#Instala o NGINX
sudo apt install nginx -y

#Instalando o unzip
sudo apt install unzip

#Colocando nosso site no nginx
unzip dist.zip
cd dist
sudo cp -r * /var/www/html
cd /var/www/html
sudo rm index.nginx-debian.html

#Colocando o arquivo de configuracao
cd 
sudo cp meu_site.conf /etc/nginx/conf.d