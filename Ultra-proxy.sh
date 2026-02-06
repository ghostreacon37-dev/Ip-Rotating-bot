#!/bin/bash
sudo apt install gnome-terminal -y
chmod +x Ip-taker.sh Proxy-changer.sh ip-taker.sh proxy-changer.sh
gnome-terminal -- bash -c "./ip-taker.sh; exec bash"
gnome-terminal -- bash -c "./proxy-changer.sh; exec bash"
