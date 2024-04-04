# Obtém o endereço IP da instância EC2 como primeiro argumento
instace_ip=$1

# Agora você pode usar a variável instance_ip como necessário no seu script
#echo "Tentando conexão IP $instace_ip"
ssh -i "../myssh.pem" ubuntu@$instace_ip 'echo "Teste"'

# ssh -i "myssh.pem" ubuntu@54.146.85.214
echo "Teste"


