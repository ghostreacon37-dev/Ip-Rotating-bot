#!/bin/bash

HTTP_FILE="workingproxy/http.txt"
HTTPS_FILE="workingproxy/https.txt"

TEST_URL="https://api.ipify.org"
TIMEOUT=5

check_proxy() {
    local proxy=$1

    curl --silent --fail \
         --proxy "http://$proxy" \
         --connect-timeout "$TIMEOUT" \
         --max-time "$TIMEOUT" \
         "$TEST_URL" >/dev/null 2>&1
}

set_system_proxy() {
    local proxy=$1

    export http_proxy="http://$proxy"
    export https_proxy="http://$proxy"
    export HTTP_PROXY="http://$proxy"
    export HTTPS_PROXY="http://$proxy"

    echo
    echo "[+] Proxy set successfully:"
    echo "    http_proxy=$http_proxy"
    echo "    https_proxy=$https_proxy"
}

echo "[+] Trying HTTP proxies..."
while read -r proxy; do
    echo -n "Testing $proxy ... "

    if check_proxy "$proxy"; then
        echo "WORKING"
        set_system_proxy "$proxy"
        return 0
    else
        echo "DEAD"
    fi
done < "$HTTP_FILE"

echo
echo "[+] Trying HTTPS proxies..."
while read -r proxy; do
    echo -n "Testing $proxy ... "

    if check_proxy "$proxy"; then
        echo "WORKING"
        set_system_proxy "$proxy"
        return 0
    else
        echo "DEAD"
    fi
done < "$HTTPS_FILE"

echo
echo "[-] No working proxy found"
return 1
