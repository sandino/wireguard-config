#!/usr/bin/env sh

DEFAULT_DIRECTORY=/etc/wireguard
DEFAULT_CONFIG_FILE=wg0.conf
DEFAULT_ADDRESS=10.0.1.1
DEFAULT_PORT=51820
DEFAULT_INTERFACE=en0

echo
read -p "Please enter WireGuard directory [$DEFAULT_DIRECTORY]: " directory
read -p "Please enter the address for the new endpoint [$DEFAULT_ADDRESS]: " address
read -p "Please enter the port [${DEFAULT_PORT}]: " port
read -p "Please enter network interface name [${DEFAULT_INTERFACE}]: " iface

directory=${directory:-$DEFAULT_DIRECTORY}
config_file=${config_file:-$DEFAULT_CONFIG_FILE}
address=${address:-$DEFAULT_ADDRESS}
port=${port:-$DEFAULT_PORT}

iface=${iface:-$DEFAULT_INTERFACE}
config_path="${directory}/${config_file}"
privatekey_path="${directory}/privatekey"
publickey_path="${directory}/publickey"

wg genkey | tee ${privatekey_path} | wg pubkey | tee ${publickey_path}
echo "[Interface]" > $config_path
echo "PrivateKey = $(cat ${privatekey_path})" >> $config_path
echo "Address = $address/24" >> $config_path
echo "ListenPort = $port" >> $config_path
echo "PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o $iface -j MASQUERADE" >> $config_path
echo "PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o $iface -j MASQUERADE" >> $config_path
echo "\n" >> $config_path"

echo
echo "New config saved at ${config_path}"
echo

echo "Restarting WireGuard..."
systemctl restart wg-quick@wg0.service
