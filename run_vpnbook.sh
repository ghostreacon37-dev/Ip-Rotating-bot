#!/bin/bash

while true; do
  for file in *.ovpn; do
    echo "Connecting using $file"
    sudo openvpn --config "$file" &
    VPN_PID=$!

    sleep 10

    echo "Disconnecting $file"
    sudo kill $VPN_PID
    sleep 2
  done
done
