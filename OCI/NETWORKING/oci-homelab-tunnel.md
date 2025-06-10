To create a **site-to-site VPN using WireGuard** between your homelab (behind double NAT) and an **Oracle Cloud Infrastructure (OCI)** instance, you'll use a **reverse connection** technique. Here's a complete, detailed guide covering:

* WireGuard installation
* Configuration (keys, peers, etc.)
* NAT forwarding
* firewalld configuration
* OCI security list rules

---

## ✅ Topology Recap

| Component            | IP Address                                      | OS             | Role                    |
| -------------------- | ----------------------------------------------- | -------------- | ----------------------- |
| Homelab WireGuard VM | `192.168.1.31`                                  | Oracle Linux 8 | Client (behind CG-NAT)  |
| OCI WireGuard VM     | `10.0.1.230` (private), `152.67.74.55` (public) | Oracle Linux 9 | Server (relay endpoint) |

---

## 🛠 Step-by-Step Setup

### Step 1: Install WireGuard on Both VMs

**On both VMs (OEL8 and OEL9):**

```bash
sudo dnf install -y epel-release
sudo dnf install -y wireguard-tools
```

Verify installation:

```bash
wg --version
```

---

### Step 2: Generate WireGuard Keys

**On both VMs:**

```bash
umask 077
wg genkey | tee privatekey | wg pubkey > publickey
```

* You'll use these in the next steps.
* Save the keys:

  * `homelab_private`, `homelab_public`
  * `oci_private`, `oci_public`

---

### Step 3: Configure WireGuard Interfaces

#### 🖥 OCI VM (Act as relay server)

Edit `/etc/wireguard/wg0.conf`:

```ini
[Interface]
PrivateKey = <oci_private>
Address = 10.100.100.1/24
ListenPort = 51820
SaveConfig = true

[Peer]
PublicKey = <homelab_public>
AllowedIPs = 10.100.100.2/32, 192.168.1.0/24
```

Enable IP forwarding:

```bash
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

Start and enable WireGuard:

```bash
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0
```

#### 🏠 Homelab VM (Acts as client)

Edit `/etc/wireguard/wg0.conf`:

```ini
[Interface]
PrivateKey = <homelab_private>
Address = 10.100.100.2/24
DNS = 1.1.1.1

[Peer]
PublicKey = <oci_public>
Endpoint = 152.67.74.55:51820
AllowedIPs = 10.0.1.0/24, 10.100.100.1/32
PersistentKeepalive = 25
```

Start WireGuard:

```bash
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0
```

**Note:** Homelab initiates the connection using `PersistentKeepalive`.

---

## 🔥 Configure firewalld (both VMs)

### OCI VM (Server)

```bash
sudo firewall-cmd --permanent --add-port=51820/udp
sudo firewall-cmd --permanent --add-masquerade
sudo firewall-cmd --reload
```

Enable NAT for forwarding to OCI subnet:

```bash
sudo firewall-cmd --permanent --direct --add-rule ipv4 nat POSTROUTING 0 -s 10.100.100.0/24 -o ens3 -j MASQUERADE
sudo firewall-cmd --reload
```

(Assuming `ens3` is the OCI public NIC; confirm with `ip a`)

### Homelab VM

```bash
sudo firewall-cmd --permanent --add-masquerade
sudo firewall-cmd --reload
```

---

## 🌐 OCI Security List Rules

Go to **VCN > Subnet > Security Lists** and ensure:

* **Ingress Rules**:

  * Source: `0.0.0.0/0`, Protocol: `UDP`, Port: `51820`

* **Egress Rules**:

  * Destination: `0.0.0.0/0`, Protocol: `All`

---

## 🔄 Enable Routing/NAT

### OCI VM

Already enabled above (firewalld + IP forwarding).

### Homelab VM

If you want to allow LAN clients to reach OCI subnet:

```bash
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

sudo firewall-cmd --permanent --add-masquerade
sudo firewall-cmd --reload
```

Forward traffic from LAN (192.168.1.0/24) via homelab WireGuard:

```bash
sudo firewall-cmd --permanent --direct --add-rule ipv4 nat POSTROUTING 0 -s 192.168.1.0/24 -o wg0 -j MASQUERADE
sudo firewall-cmd --reload
```

---

## ✅ Test Connectivity

From **homelab WireGuard VM**:

```bash
ping 10.100.100.1     # OCI WG VM (VPN address)
ping 10.0.1.230       # OCI private IP
```

From **OCI WireGuard VM**:

```bash
ping 10.100.100.2     # Homelab WG VM (VPN address)
ping 192.168.1.1      # If LAN NAT routing is enabled
```

---

## ✅ Optional: Static Routing on Clients

To allow homelab clients to access OCI:

* Set the **default gateway** or static route to `192.168.1.31` (the WireGuard VM).
* Or use iptables to SNAT traffic as shown above.

EG:
 ### Method 1: Use nmcli (NetworkManager)
If your system uses NetworkManager (most desktop Linux distros and recent RHEL-based systems):

nmcli connection modify <connection-name> +ipv4.routes "10.0.1.0/24 192.168.1.31"
nmcli connection up <connection-name>
To find the connection name:
nmcli connection show

### For Windows Clients
You can use route -p to make it persistent:
route -p add 10.0.1.0 mask 255.255.255.0 192.168.1.31