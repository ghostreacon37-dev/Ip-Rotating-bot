#!/bin/bash

IFACE="wlp2s0"
WAIT=15

while true
do
  echo "[*] Bringing network down..."
  sudo ip link set $IFACE down
  sleep $WAIT

  echo "[*] Bringing network up..."
  sudo ip link set $IFACE up
  sleep $WAIT

  echo "[+] New IP:"
  curl -s ifconfig.me
  echo ""

  sleep 60
done
