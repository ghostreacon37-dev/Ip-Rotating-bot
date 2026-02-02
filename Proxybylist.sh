#!/bin/bash

URL="https://free-proxy-list.net/en/"
ALL="proxies_all.txt"
WORKING="working.txt"


curl -s "$URL" |
awk '
BEGIN{RS="<tr>"; FS="</td>"}
{
  for(i=1;i<=NF;i++){
    gsub(/.*<td>/,"",$i)
  }
  if($1 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ && $2 ~ /^[0-9]+$/){
    print $1 ":" $2
  }
}
' > "$ALL"

echo "[+] Extracted $(wc -l < "$ALL") proxies"


touch "$WORKING"


rm -f dead.txt


while read -r proxy; do
    echo -n "Checking $proxy ... "

    # First attempt with http
    if curl -s --proxy "http://$proxy" --max-time 5 https://api.ipify.org >/dev/null 2>&1; then
        echo "WORKING"
        echo "$proxy" >> "$WORKING"
    # Second attempt with socks4
    elif curl -s --proxy "socks4://$proxy" --max-time 5 https://api.ipify.org >/dev/null 2>&1; then
        echo "WORKING"
        echo "$proxy" >> "$WORKING"
    # Third attempt with socks5
    elif curl -s --proxy "socks5://$proxy" --max-time 5 https://api.ipify.org >/dev/null 2>&1; then
        echo "WORKING"
        echo "$proxy" >> "$WORKING"
    elif curl -s --proxy "https://$proxy" --max-time 5 https://api.ipify.org >/dev/null 2>&1; then
        echo "WORKING"
        echo "$proxy" >> "$WORKING"
    else
        echo "DEAD"
    fi
done < "$ALL"

echo
echo "[+] Total Working proxies stored in $WORKING: $(wc -l < "$WORKING")"
