#!/bin/bash

sudo apt-get install openvpn -y
sudo cp client.ovpn /etc/openvpn/
sudo cp userpass.txt /etc/openvpn/
sudo sed -i 's/#AUTOSTART="all"/AUTOSTART="all"/g' /etc/default/openvpn
# Following https://www.raspberrypi.org/documentation/configuration/wireless/access-point-routed.md

sudo apt-get update && sudo apt-get install hostapd -y

sudo systemctl unmask hostapd
sudo systemctl enable hostapd

# Following http://www.intellamech.com/RaspberryPi-projects/rpi3_simple_wifi_ap.html

sudo apt-get install dnsmasq -y


sudo DEBIAN_FRONTEND=noninteractive apt install -y netfilter-persistent iptables-persistent

# Configure DHCP
sudo cat <<EOT >> /etc/dhcpcd.conf
interface wlan0
    static ip_address=192.168.4.1/24
    nohook wpa_supplicant
EOT


sudo cat <<EOT > /etc/sysctl.d/routed-ap.conf
# https://www.raspberrypi.org/documentation/configuration/wireless/access-point-routed.md
# Enable IPv4 routing
net.ipv4.ip_forward=1
EOT

sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
sudo iptables -A FORWARD -s 192.168.4.0/24 -i wlan0 -o eth0 -m conntrack --ctstate NEW -j REJECT
sudo iptables -A FORWARD -s 192.168.4.0/24 -i wlan0 -o tun0 -m conntrack --ctstate NEW -j ACCEPT

sudo netfilter-persistent save

sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig

sudo cat <<EOT > /etc/dnsmasq.conf
interface=wlan0 # Listening interface
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h
                # Pool of IP addresses served via DHCP
domain=wlan     # Local wireless DNS domain
address=/gw.wlan/192.168.4.1
	                # Alias for this router
EOT

sudo rfkill unblock wlan

sudo cp hostapd.conf /etc/hostapd/hostapd.conf

