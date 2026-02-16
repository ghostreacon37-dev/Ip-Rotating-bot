#!/bin/bash

URL="https://free-proxy-list.net/en/"
ALL="proxies_all.txt"

mkdir -p workingproxy

curl -s "$URL" |
awk '
BEGIN { RS="<tr>"; FS="</td>" }
{
  for (i=1; i<=NF; i++) {
    gsub(/.*<td>/, "", $i)
  }
  if ($1 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ && $2 ~ /^[0-9]+$/) {
    print $1 ":" $2
  }
}
' > "$ALL"

echo "[+] Extracted $(wc -l < "$ALL") proxies"
echo


while read -r proxy; do
    echo -n "Checking $proxy ... "

    working=0


    if curl -s --proxy "http://$proxy" --max-time 5 https://api.ipify.org >/dev/null 2>&1; then
        echo "$proxy" >> workingproxy/http.txt
        working=1
    fi


    if curl -s --proxy "https://$proxy" --max-time 5 https://api.ipify.org >/dev/null 2>&1; then
        echo "$proxy" >> workingproxy/https.txt
        working=1
    fi

    if [ "$working" -eq 1 ]; then
        echo "WORKING"
    else
        echo "DEAD"
    fi

done < "$ALL"

echo
echo "[+] HTTP working proxies : $(wc -l < workingproxy/http.txt 2>/dev/null || echo 0)"
echo "[+] HTTPS working proxies: $(wc -l < workingproxy/https.txt 2>/dev/null || echo 0)"
