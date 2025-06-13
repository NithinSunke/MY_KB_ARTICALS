# ☁️ SQL Server Migration to OCI Using Backup and Restore

**migrating a standalone SQL Server instance to Oracle Cloud Infrastructure (OCI)** using the **Backup and Restore** method. This is one of the most straightforward and reliable approaches for dev/test environments, and small-to-medium databases.

> Move your standalone SQL Server from on-premises or a homelab to Oracle Cloud Infrastructure (OCI) using a simple yet reliable method: **Backup and Restore**.

---

## 📌 Overview

Migrating SQL Server to OCI can be done in many ways—Data Pump, Replication, Always On—but for small to medium workloads, **Backup and Restore** is easy, fast, and gives you full control.

This blog post covers:

* Preparing your SQL Server backup
* Creating an OCI Compute VM
* Installing SQL Server in OCI
* Transferring and restoring backups

---

## 🧱 Prerequisites

### 🔹 On-Prem / Source Server:

* Standalone SQL Server instance (any edition)
* `.bak` files for each database (full backups)
* RDP or local access

### 🔹 OCI Environment:

* OCI account and VCN setup
* Windows Server Compute instance in OCI
* Installed SQL Server (same or higher version as source)

---

## 🛠️ Step-by-Step Migration Using Backup and Restore

---

### ✅ Step 1: Backup SQL Server Databases on Source

Open SQL Server Management Studio (SSMS) and run this command:

```sql
BACKUP DATABASE [YourDatabaseName]
TO DISK = 'C:\Backups\YourDatabaseName.bak'
WITH INIT, COMPRESSION, STATS = 10;
```

> 📁 Tip: Store backups on a dedicated folder like `C:\Backups`.

Repeat this for all databases you want to migrate.

---

### ✅ Step 2: Create a Windows VM in OCI

1. **Login to OCI Console**
2. Go to **Compute → Instances → Create Instance**
3. Choose:

   * Image: Windows Server (2019/2022)
   * Shape: VM.Standard.E3.Flex (2 OCPUs, 8GB+ for SQL)
   * Networking: Use an existing VCN or create one
4. Open ports: RDP (3389), SQL Server (default: 1433) in your security list/network security group

---

### ✅ Step 3: Install SQL Server on OCI VM

1. Connect to the VM via RDP
2. Download and install **SQL Server (Developer or Standard edition)**
3. Choose:

   * Mixed mode authentication
   * Enable SQL Server Agent
4. Install **SQL Server Management Studio (SSMS)**

> 🛡️ Don't forget to allow TCP port 1433 in Windows Firewall for remote SQL access (if needed).

---

### ✅ Step 4: Transfer `.bak` Files to OCI VM

#### Option A: Use WinSCP or RDP

* Use WinSCP or drag-and-drop via RDP to copy `.bak` files from local machine to OCI VM (e.g., `C:\Backups`)

#### Option B: Use Object Storage (Alternative)

1. Upload `.bak` to OCI Object Storage bucket
2. Download it inside your OCI VM using the **OCI CLI or browser**

---

### ✅ Step 5: Restore Database on OCI SQL Server

In SSMS (connected to SQL Server on OCI):

```sql
RESTORE DATABASE [YourDatabaseName]
FROM DISK = 'C:\Backups\YourDatabaseName.bak'
WITH MOVE 'YourDatabaseName' TO 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\YourDatabaseName.mdf',
     MOVE 'YourDatabaseName_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\YourDatabaseName_log.ldf',
     RECOVERY, STATS = 10;
```

> 📎 You may need to check the logical file names using:

```sql
RESTORE FILELISTONLY
FROM DISK = 'C:\Backups\YourDatabaseName.bak';
```

---

## 🔄 Post-Migration Checklist

| Task                             | Status |
| -------------------------------- | ------ |
| Backup taken from source         | ✅      |
| OCI VM created and SQL installed | ✅      |
| Backup copied to cloud VM        | ✅      |
| Database restored                | ✅      |
| SQL logins recreated (if needed) | ✅      |
| App connected to new SQL server  | ✅      |

---

## 🔐 Bonus: Restore SQL Logins

SQL logins aren’t stored inside `.bak` files. Recreate them using this script on the source server:

```sql
SELECT 'CREATE LOGIN [' + sp.name + '] WITH PASSWORD = ''' + 
    CONVERT(VARCHAR(MAX), LOGINPROPERTY(sp.name, 'PasswordHash')) + ''', CHECK_POLICY = OFF;'
FROM sys.sql_logins AS sp
WHERE sp.name NOT IN ('sa');
```

Then run the generated `CREATE LOGIN` scripts on the OCI SQL Server.

> 🔁 You can also use tools like dbatools PowerShell module for automated login migration.

---

## 🚀 You're Done!

You’ve successfully migrated your SQL Server instance to Oracle Cloud Infrastructure using the Backup and Restore method. This approach is especially effective for dev/test environments and simplifies DR test scenarios.

---

## 🔗 Related Resources

* [OCI Free Tier – Start with free compute](https://www.oracle.com/cloud/free/)
* [How to Secure SQL Server in OCI](#)
* [PowerShell Script for Backup/Restore Automation](#)

---