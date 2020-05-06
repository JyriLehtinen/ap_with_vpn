Tested with fresh Raspbian GNU/Linux 10 (buster)


Make sure you have the openvpn client configuration as "client.ovpn", and test that it works.

If there's errors with DNS resolution (as there was in my case), make sure the client.ovpn includes


script-security 2
  up /etc/openvpn/update-resolv-conf
  down /etc/openvpn/update-resolv-conf

Edit the AP parameters (SSID, password) in hostapd.conf

Then, you may run the shell script to install and configure the access point with forwarding to the virtual adapter.

Reboot at the end and that should be it.
