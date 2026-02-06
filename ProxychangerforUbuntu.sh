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
    echo "    $proxy"
}


mapfile -t PROXIES < <(cat "$HTTP_FILE" "$HTTPS_FILE" 2>/dev/null | sort -u | shuf)

if [ "${#PROXIES[@]}" -eq 0 ]; then
    echo "[-] No proxies found"
    return 1
fi

echo "[+] Selecting a random proxy..."


for proxy in "${PROXIES[@]}"; do
    echo -n "Testing $proxy ... "

    if check_proxy "$proxy"; then
        echo "WORKING"
        set_system_proxy "$proxy"
        return 0
    else
        echo "DEAD"
    fi
done

echo
echo "[-] No working proxy found"
return 1
