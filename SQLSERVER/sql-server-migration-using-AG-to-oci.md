# Add OCI SQL Server Node to On-Premises AG Cluster and Migrate to OCI

## Prerequisites and Migration Guide
Integrating Oracle Cloud Infrastructure (OCI) into your SQL Server Always On Availability Group (AG) topology provides a seamless hybrid cloud architecture for **disaster recovery, high availability, or migration staging**. This guide walks through all prerequisites and step-by-step instructions to add an OCI-based SQL Server node to an existing on-premises AG cluster.

### Use Case
*   You have an on-premises SQL Server AG (2-node or more)
*   You want to add an OCI Windows VM running SQL Server as an additional replica in the AG
*   Goal: Create a hybrid HA/DR solution or migrate to OCI gradually

### Prerequisites
**On-Prem SQL Server Setup:**
*   SQL Server Enterprise Edition (2016+ recommended)
*   Existing Always On AG configured with Windows Failover Cluster
*   AD Domain joined servers
*   Quorum configured with shared witness or file share

**OCI Infrastructure:**
*   Compute VM (Windows Server) with:
    *   Matching SQL Server version and edition
    *   Static private IP (or reserved public IP if cross-VPN)
    *   Network connectivity to on-prem SQL Servers (via VPN, FastConnect, or IPsec tunnel)
*   Joined to the same Active Directory domain
*   NTFS + firewall rules to allow SQL and cluster ports:
    *   TCP 1433 (SQL)
    *   TCP/UDP 5022 (AG endpoint)
    *   ICMP (for health check and clustering)
    *   RPC/SMB 135, 445, 49152-65535 (if needed for cluster communication)

##  Step-by-Step: Add OCI SQL Node to On-Prem AG Cluster
### Step 1: Prepare OCI SQL Server Node
*   Provision Windows Server VM in OCI
*   Install SQL Server Enterprise Edition (same version as on-prem)
*   Join to the on-prem AD domain
*   Set a static private IP( vnic add two secoundary priviate ips for failover cluster and AG)
*   Configure Windows Firewall and OCI NSGs

### Step 2: Add Node to Windows Failover Cluster
On an existing on-prem node:
*   Open Failover Cluster Manager
*   Right-click the cluster → Add Node

### Step 3: Enable Always On in SQL Configuration Manager (OCI Node)
*   Open SQL Server Configuration Manager
*   Right-click SQL Server instance → Properties
*   Enable Always On Availability Groups
*   Restart SQL Server service

### Step 4: Restore Database on OCI Node
*   Backup the AG database from the primary:
```
BACKUP DATABASE [MyDB] TO DISK = 'D:\Backup\MyDB.bak' WITH INIT;
BACKUP LOG [MyDB] TO DISK = 'D:\Backup\MyDB.trn';
```
> if posible setup a file share between onprimse server to the oci vm for backup and restore.
*   Transfer .bak and .trn files to OCI node if backup taken to the local storage.
*   Restore on OCI SQL Server in NORECOVERY mode:
```
RESTORE DATABASE [MyDB] FROM DISK = 'D:\Backup\MyDB.bak' WITH NORECOVERY;
RESTORE LOG [MyDB] FROM DISK = 'D:\Backup\MyDB.trn' WITH NORECOVERY;
```
###  Step 5: Add OCI Replica to Availability Group
**use SSMS:**
Connect to primary → Always On High Availability → AG → Add Replica

### Step 6: Join the Database to AG (on OCI node)
**use SSMS:**
Connet to primary → Always On High Availability → Avaliablity Group → Avaliablity Databases → Add Database to AG.

You should now see the OCI node as a healthy secondary in synchronous or asynchronous mode.

### Step 7: Test and Validate
*   Use AG Dashboard in SSMS to monitor sync state
*   Validate ping, port access, and DNS resolution between nodes
*   Perform manual failover test if desired (for DR validation)

## Final Steps to Migrate SQL Server Database to OCI

## Step 1: Confirm OCI Replica Is Fully Synchronized

On the primary (on-prem) SQL Server:
*   Open SQL Server Management Studio (SSMS)
*   Go to:
    Always On High Availability → Availability Groups → AGName → Availability Replicas
*   Check:
    *   The OCI node is in "Synchronized" state
    *   The AG database on OCI is "Synchronized"
    *   No errors in replication or health events
## Step 2: Plan the Cutover
Schedule a planned maintenance window

Inform application and support teams

Ensure backups of the on-prem and OCI nodes