#!/usr/bin/env sh

DEFAULT_DIRECTORY=/etc/wireguard
DEFAULT_IP=10.0.1.2
DEFAULT_CONFIG_FILE=wg0.conf
DEFAULT_PORT=51820

echo
read -p "Please enter WireGuard directory [$DEFAULT_DIRECTORY]: " directory
read -p "Please enter client name: " client_name
read -p "Please enter cient IP [$DEFAULT_IP]: " client_ip
read -p "Please enter server public key: " server_pubkey
read -p "Please enter server endpoint IP: " endpoint_ip
read -p "Please enter server endpoint port [${DEFAULT_PORT}]:" endpoint_port

directory=${directory:-$DEFAULT_DIRECTORY}
client_ip=${client_ip:-$DEFAULT_IP}
server_config_file=${server_config_file:-$DEFAULT_CONFIG_FILE}
endpoint_port=${endpoint_port:-$DEFAULT_PORT}

client_config_path="${directory}/clients/${client_name}.conf"
privatekey_path="${directory}/clients/${client_name}_privatekey"
publickey_path="${directory}/clients/${client_name}_publickey"
server_config_path="${directory}/${server_config_file}"

sudo sh -c "wg genkey | tee ${privatekey_path} | wg pubkey > ${publickey_path}"

sudo sh -c "echo '' >> ${server_config_path}"
sudo sh -c "echo '[Peer]' >> ${server_config_path}"
sudo sh -c "echo 'PublicKey = $(cat $publickey_path)' >> ${server_config_path}"
sudo sh -c "echo 'AllowedIPs = ${client_ip}/32' >> ${server_config_path}"
sudo sh -c "echo"

echo "New client added to server config at ${server_config_path}"

sudo sh -c "echo '[Interface]' > ${client_config_path}"
sudo sh -c "echo 'PrivateKey = $(cat $privatekey_path)' >> ${client_config_path}"
sudo sh -c "echo 'Address = ${client_ip}/32' >> ${client_config_path}"
sudo sh -c "echo 'DNS = 8.8.8.8' >> ${client_config_path}"
sudo sh -c "echo '' >> ${client_config_path}"
sudo sh -c "echo '[Peer]' >> ${client_config_path}"
sudo sh -c "echo 'PublicKey = ${server_pubkey}' >> ${client_config_path}"
sudo sh -c "echo 'Endpoint = ${endpoint_ip}:${endpoint_port}' >> ${client_config_path}"
sudo sh -c "echo 'AllowedIPs = 0.0.0.0/0' >> ${client_config_path}"
sudo sh -c "echo 'PersistentKeepalive = 20' >> ${client_config_path}"
sudo sh -c "echo '' >> ${client_config_path}"

echo "New client config created at ${client_config_path}"
echo
