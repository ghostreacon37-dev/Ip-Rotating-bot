#!/bin/bash
chmod +x Ip-taker.sh Proxy-changer.sh
gnome-terminal -- bash -c "./ip-taker.sh; exec bash"
gnome-terminal -- bash -c "./proxy-changer.sh; exec bash"
