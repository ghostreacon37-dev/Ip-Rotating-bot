#!/bin/bash
URL="https://free-proxy-list.net/en/"
OUT="proxy.txt"

curl -s "$URL" | grep -oP '(?<=<td>)(\d{1,3}.){3}\d{1,3}(?=</td>)|(?<=</td><td>)\d{2,5}(?=</td>)' | paste - - | awk '{print $1 ":" $2}' | tee "$OUT"
