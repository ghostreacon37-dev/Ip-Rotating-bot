#!/bin/bash
URL="https://free-proxy-list.net/en/"
OUT="proxy.txt"

#curl -s "$URL" | grep -oP '(?<=<td>)(\d{1,3}.){3}\d{1,3}(?=</td>)|(?<=</td><td>)\d{2,5}(?=</td>)' | paste - - | awk '{print $1 ":" $2}' | tee "$OUT"
curl -s "https://free-proxy-list.net/en/" | awk -F'<td>|</td>' '/<tbody>/{f=1} f && /<tr>/{ip="";port=""} f && $2 ~ /^[0-9.]+$/ {ip=$2} f && $4 ~ /^[0-9]+$/ {port=$4; if(ip!="") print ip ":" port} /</tbody>/{f=0}'
