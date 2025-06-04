# Step-by-Step WireGuard VPN Setup (Oracle Linux 8 Server + Homelab Client)

## Part 1: Setup WireGuard Server on Oracle Linux 8 (OCI)
### Step 1: Install WireGuard
Oracle Linux 8 supports WireGuard via EPEL repository.
```
sudo dnf install -y epel-release
sudo dnf install -y wireguard-tools 
```
To confirm WireGuard is working:
```
which wg
which wg-quick
```
Then try:
```
wg --version
```
If those work, your installation is successful.


### Step 2: Enable IP Forwarding
Enable IP forwarding so your VPN server can route packets between VPN clients and OCI resources.
```
sudo sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
```

### Step 3: Generate Server Keys
```
umask 077
wg genkey | tee server_private.key | wg pubkey > server_public.key
```

### Step 4: Create WireGuard Config File /etc/wireguard/wg0.conf
```
[Interface]
PrivateKey = CGsxczNFNH8q9GQ1L1hQsNJhmdgSLvpZX6FcpBvkc28=
Address = 10.100.0.1/24
ListenPort = 51820

[Peer]
PublicKey = <homelab_public_key>
AllowedIPs = 10.100.0.2/32

```
* Replace <server_private_key> with the content of server_private.key.
* <homelab_public_key> will be generated on your homelab client.

### Step 5: Configure Firewall and OCI Security Lists
* Allow UDP port 51820 in Oracle Linux firewall:
```
sudo firewall-cmd --add-port=51820/udp --permanent
sudo firewall-cmd --reload
```
* In OCI Console, update VCN subnet security list or Network Security Group to allow inbound UDP 51820 to this VM.

<img src="./images/vpn1.jpg" alt="Description" width="800"/>  

### Step 6: Start and Enable WireGuard Service
```
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0
```