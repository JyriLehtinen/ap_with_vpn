Tested with fresh Raspbian GNU/Linux 10 (buster)


Make sure you have the openvpn client installed and configuration file "client.ovpn" in the same directory as this README.md (and test that it works).
```
sudo apt-get install openvpn
sudo openvpn client.openvpn
```
If the server requires username and password, include them in auth-file named "userpass.txt"
The conf file should have the line
```
auth-user-pass userpass.txt
```

If there's errors with DNS resolution (as there was in my case), make sure the client.ovpn includes
```
script-security 2
  up /etc/openvpn/update-resolv-conf
  down /etc/openvpn/update-resolv-conf
```

Edit the AP parameters (SSID, password) in hostapd.conf

Then, you may run the shell script to install and configure the access point with forwarding to the virtual adapter.

Reboot at the end, make sure the ethernet cable is plugged and that should be it. Just connect your devices to the new WiFi AP and their traffic should be routed through the VPN client
