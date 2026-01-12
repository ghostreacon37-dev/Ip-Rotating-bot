import base64, csv, os, random, signal, subprocess, time, urllib.request, json

# Pick your target countries (VPN Gate uses country short codes like US, JP, KR, DE, FR, GB, NL, CA, AU, SG...)
TARGET_COUNTRIES = TARGET_COUNTRIES = {
    "US", "GB", "CA", "DE", "FR", "NL", "AU", "SG", "JP", "KR",
    "IT", "ES", "SE", "NO", "FI", "IE",
    "PL", "CZ", "AT", "CH",
    "IN", "MY", "TH", "ID", "VN", "PH",
    "BR", "MX"
}

ROTATE_EVERY_SECONDS = 300   # 5 minutes
CONNECT_TIMEOUT = 45         # seconds

API_URL = "https://www.vpngate.net/api/iphone/"  # CSV-like output, includes base64 OpenVPN config

openvpn_proc = None

def cleanup():
    global openvpn_proc
    if openvpn_proc and openvpn_proc.poll() is None:
        openvpn_proc.terminate()
        try:
            openvpn_proc.wait(timeout=10)
        except subprocess.TimeoutExpired:
            openvpn_proc.kill()
    openvpn_proc = None

def get_public_ip_info():
    # Lightweight check
    with urllib.request.urlopen("https://ipinfo.io/json", timeout=15) as r:
        data = json.loads(r.read().decode("utf-8", errors="ignore"))
    return data.get("ip"), data.get("country"), data.get("org")

def fetch_servers():
    with urllib.request.urlopen(API_URL, timeout=30) as r:
        raw = r.read().decode("utf-8", errors="ignore").splitlines()

    # Skip comments; find CSV header row
    rows = [line for line in raw if line and not line.startswith("*") and not line.startswith("#")]
    reader = csv.reader(rows)
    header = next(reader)

    # Useful columns typically include: CountryShort, Ping, Score, OpenVPN_ConfigData_Base64
    idx = {name: i for i, name in enumerate(header)}
    servers = []
    for row in reader:
        try:
            cc = row[idx["CountryShort"]].strip()
            b64 = row[idx["OpenVPN_ConfigData_Base64"]].strip()
            score = int(row[idx["Score"]])
            ping = int(row[idx["Ping"]])
            if cc in TARGET_COUNTRIES and b64:
                servers.append({"cc": cc, "b64": b64, "score": score, "ping": ping})
        except Exception:
            continue

    # Prefer higher score + lower ping a bit
    servers.sort(key=lambda s: (-s["score"], s["ping"]))
    return servers

def connect_with_ovpn(ovpn_text: str):
    global openvpn_proc
    # Write temp ovpn
    path = "/tmp/vpngate.ovpn"
    with open(path, "w", encoding="utf-8") as f:
        f.write(ovpn_text)

    # Kill old connection
    cleanup()

    # Start OpenVPN (needs sudo). Using --auth-nocache to avoid caching creds (VPN Gate configs usually don't need creds).
    cmd = ["sudo", "openvpn", "--config", path, "--auth-nocache", "--verb", "3"]
    openvpn_proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)

    # Wait for "Initialization Sequence Completed"
    start = time.time()
    while time.time() - start < CONNECT_TIMEOUT:
        line = openvpn_proc.stdout.readline()
        if not line:
            time.sleep(0.2)
            continue
        if "Initialization Sequence Completed" in line:
            return True
        if openvpn_proc.poll() is not None:
            return False
    return False

def main():
    print("[*] Fetching VPN Gate servers...")
    servers = fetch_servers()
    if not servers:
        print("[-] No matching servers found. Try expanding TARGET_COUNTRIES.")
        return

    print(f"[*] Found {len(servers)} matching servers. Rotating every {ROTATE_EVERY_SECONDS}s.\n")

    while True:
        # pick from top N to reduce dead servers
        pool = servers[:50] if len(servers) > 50 else servers
        s = random.choice(pool)

        try:
            ovpn = base64.b64decode(s["b64"]).decode("utf-8", errors="ignore")
        except Exception:
            continue

        print(f"[+] Connecting… target country={s['cc']} score={s['score']} ping={s['ping']}ms")
        ok = connect_with_ovpn(ovpn)

        if ok:
            try:
                ip, cc, org = get_public_ip_info()
                print(f"[✓] Connected. IP={ip} country={cc} org={org}")
            except Exception:
                print("[!] Connected, but IP check failed.")
        else:
            print("[-] Connection failed. Trying another server...")
            continue

        time.sleep(ROTATE_EVERY_SECONDS)

if __name__ == "__main__":
    signal.signal(signal.SIGINT, lambda *_: (cleanup(), exit(0)))
    signal.signal(signal.SIGTERM, lambda *_: (cleanup(), exit(0)))
    main()
