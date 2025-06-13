# 🧪 Nithin's Homelab

A flexible and powerful homelab setup designed for exploring enterprise-grade virtualization, Windows Server administration, networking, and cloud integration.

---

## 💻 Primary Workstation

- **CPU:** Intel Xeon E5-2630 v3 @ 2.40GHz  
- **RAM:** 64 GB  
- **OS:** Windows Server 2022 Datacenter  
- **Virtualization:** VMware Workstation  
- **Nested Hypervisor:** Proxmox VE (running inside a VM)

---

## 🗃️ Storage Layout

| Device              | Size   | Purpose                    |
|---------------------|--------|----------------------------|
| SSD                 | 250 GB | Operating System           |
| Internal HDD        | 2 TB   | Virtual Machine provisioning |
| External HDD        | 1 TB   | VM backups                 |
| External HDD        | 2 TB   | File/document storage      |
| Additional HDD      | 3 TB   | General/bulk storage       |

---

## 🧠 Virtualized Lab Infrastructure

- **Domain:** `scslabs.com`
- **Certificate Authority:** Internal CA issuing certs to domain-joined VMs
- **Virtual Machines:**
  - Active Directory Domain Controller
  - DNS & DHCP Server
  - IIS Web Server
  - Remote Desktop Services (RDS)
  - Windows Server Update Services (WSUS)
  - Windows Client

---

## 🌐 Networking Overview

- **Local Network:** `192.168.1.0/24`
- **Key Devices:**
  - Windows Client: `192.168.1.10`
  - Linux Client: `192.168.1.21`
  - WireGuard VM (Oracle Linux 8): `192.168.1.31`

---

## 🔐 VPN and Remote Access

- **Technologies Used:**
  - **WireGuard**: Active tunnel (site-to-site style) using OCI relay
- **NAT Note:** Homelab is behind double NAT (CG-NAT); using OCI as VPN entry point

---

## 🛠️ Key Projects and Experiments

- Full Windows Server Lab (AD, DNS, DHCP, IIS, RDS, WSUS)
- SQL Server AG with Hybrid Cloud DR
- Internal PKI with domain-issued certificates
- Hybrid Cloud Networking with WireGuard/IPSec/OpenVPN

---

## 📌 Summary

Nithin's homelab is a comprehensive learning and development platform capable of simulating real-world enterprise infrastructure, integrating seamlessly with Oracle Cloud, and supporting complex multi-tier architectures with security, redundancy, and remote access.
