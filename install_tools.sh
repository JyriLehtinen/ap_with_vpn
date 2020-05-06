#!/bin/bash

echo "Please read through the README before running the script for the first time"
read -r -p "Have you installed OpenVPN and checked that your client connects properly? [Y/n]" response
response=${response,,} # tolower
if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
	read -r -p "You're not bluffing, are you? [Y/n]" confirm
	confirm=${confirm,,} # tolower
	if [[ $confirm =~ ^(no|n) ]]; then
		echo "Alright then... "	
	else
		echo "Go a head a do it, then try again"
		exit 0
	fi
else
	exit 0
fi

sudo cp client.ovpn /etc/openvpn/autoclient.conf
sudo cp userpass.txt /etc/openvpn/
sudo sed -i 's/#AUTOSTART="all"/AUTOSTART="all"/g' /etc/default/openvpn

sudo systemctl enable openvpn@autoclient.service
# Following https://www.raspberrypi.org/documentation/configuration/wireless/access-point-routed.md

sudo apt-get update && sudo apt-get install hostapd -y

sudo systemctl unmask hostapd
sudo systemctl enable hostapd

# Following http://www.intellamech.com/RaspberryPi-projects/rpi3_simple_wifi_ap.html

sudo apt-get install dnsmasq -y


sudo DEBIAN_FRONTEND=noninteractive apt install -y netfilter-persistent iptables-persistent

# Configure DHCP
sudo bash -c 'cat <<EOT >> /etc/dhcpcd.conf
interface wlan0
    static ip_address=192.168.4.1/24
    nohook wpa_supplicant
EOT'


sudo bash -c 'cat <<EOT > /etc/sysctl.d/routed-ap.conf
# https://www.raspberrypi.org/documentation/configuration/wireless/access-point-routed.md
# Enable IPv4 routing
net.ipv4.ip_forward=1
EOT'

#sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
#sudo iptables -A FORWARD -s 192.168.4.0/24 -i wlan0 -o eth0 -m conntrack --ctstate NEW -j REJECT
sudo iptables -A FORWARD -s 192.168.4.0/24 -i wlan0 -o tun0 -m conntrack --ctstate NEW -j ACCEPT

sudo netfilter-persistent save

sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig

sudo bash -c 'cat <<EOT > /etc/dnsmasq.conf
interface=wlan0 # Listening interface
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h
                # Pool of IP addresses served via DHCP
domain=wlan     # Local wireless DNS domain
address=/gw.wlan/192.168.4.1
	                # Alias for this router
EOT'

sudo rfkill unblock wlan

sudo cp hostapd.conf /etc/hostapd/hostapd.conf


echo "Now go ahead and reboot the Pi"
