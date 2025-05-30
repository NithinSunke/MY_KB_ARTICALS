# Migrating Oracle Database 12c to 19c Online with Zero Downtime Migration
## Table of Contents
1. [Introduction](##Introduction)
1. [Understanding Logical Online Migration](#understanding-logical-online-migration)

## Introduction
Migrating production databases is a critical task, often complicated by the need to minimize disruption to business operations. Oracle Zero Downtime Migration (ZDM) is a powerful tool designed to address this challenge, offering robust, flexible, and resumable methods to move Oracle databases to Oracle Cloud or Exadata environments with minimal downtime.
This post focuses on migrating from an Oracle Database 12c (specifically supported versions like 12.1.0.2 or 12.2.0.1) to a target Oracle Database 19c, using ZDM's Logical Online Migrationapproach. 
This method is ideal for keeping your source database available during most of the migration process, leveraging Oracle Data Pump for the initial data transfer and Oracle GoldenGate for ongoing replication.

## Understanding Logical Online Migration
Logical Online Migration uses Oracle Data Pump to export data from the source database and import it into the target. Crucially, it then configures and starts Oracle GoldenGate replication between the source and target databases to capture and apply changes that occur on the source while the initial data load is in progress. This keeps the target database synchronized with the source. The actual downtime required for the final switchover is typically very short, often less than 15 minutes or so.
 
## Prerequisites for a Smooth Migration
Before embarking on your ZDM migration journey, several prerequisites must be met to ensure success:  
    1. **Database Versions**: Your source must be a supported 12c version (12.1.0.2 or 12.2.0.1) [Sources imply compatibility as 12c is a common source] and the target a supported 19c environment.  
    2. **Source Database Configuration**:   
        * The source database must be in ARCHIVELOG mode.  
        * Ensure the STREAMS_POOL_SIZE parameter is set to at least 2GB for online logical migrations.  
        * Avoid Data Definition Language (DDL) operations during the core migration process for optimal replication.  
        * Apply mandatory RDBMS patches on the source database, particularly for older versions like 11.2 (11.2.0.4).  
    3. **Target Database Configuration**:   
        * Provision a placeholder target database environment (e.g., Autonomous Database like ADB-S/ADB-D or ADB@Customer, or a Co-managed VMDB/Bare Metal system).  
        * The database user performing the Data Pump import on the target requires the DATAPUMP_IMP_FULL_DATABASE role.  
        * The character set on the target should match the source.  
        * Ensure the default shell on non-Autonomous targets is bash.  
        * Configure an Oracle GoldenGate Microservices hub (often from the OCI Marketplace or Docker) and grant necessary privileges to the GoldenGate admin user (e.g., GRANT_ADMIN_PRIVILEGE).  
        * The target placeholder database's time zone file version must be the same as or higher than the source.  
        * For Oracle RAC targets, ensure SSH connectivity without a passphrase between the Oracle RAC servers for the oracle user. Check disk group or file system size and usage for adequate storage.  
    4. **ZDM Service Host**: A standalone Linux server (Oracle Linux 7, 8 or RHEL 8, 9 on x86-64) with sufficient free space (>= 100 GB) and required OS packages (expect, glibc-devel) [Implied requirements]. Create a dedicated zdmuser and zdm group.  
    5. **Network Connectivity**:   
        * SSH (Port 22 TCP): From the ZDM host to the source and target database servers for authentication-based operations.  
        * SQL*Net (Port 1521, 2484(ADB Dedicated), or SCAN Listener Port TCP): From the ZDM host to the source and target database servers for logical migrations.  
        * SQL*Net (Ports 1521, 1522, 2484, or user-defined TCP/TCPS): From the GoldenGate hub to the source and target database servers [Implied GoldenGate requirement].  
        * HTTPS (Port 443 SSL): From the ZDM host to the GoldenGate hub for REST API calls, and from the ZDM host and/or source/target servers to OCI REST endpoints (Core, IAM, Database, Object Storage).  
    6. **User Access and Authentication**: 
        * The zdmuser on the ZDM host needs SSH key-based access to the source and target database servers. This can be as user with sudo privileges.  
        * For logical migration, connecting as the Oracle software owner (dbuser) is supported for source and target by setting RUNCPATREMOTELY to TRUE [F.123, Implied usage].  
        * SSH keys should be set up without a passphrase.  
        * Credentials can be provided interactively or stored in wallets for non-interactive runs. Wallet parameters like WALLET_OGGADMIN , WALLET_SOURCEADMIN [G.50], WALLET_TARGETADMIN [G.51] are used.  
    7. **Data Transfer Medium**: For logical migrations, supported media include Object Storage (OSS), NFS, Database Link (DBLINK), COPY, and AMAZONS3 (if source is AWS RDS).   
        * OSS: A common choice for Cloud targets. Requires Port 443 connectivity. May require SSL wallet configuration on the source for HTTPS access using DUMPTRANSFERDETAILS_SOURCE_OCIWALLETLOC. Using OCI CLI for dump transfer with OSS is recommended for speed and resilience, requiring OCI CLI installation and configuration.  
        * DBLINK: Supported for online/offline to all targets, but not recommended for very large databases. Requires direct network connectivity. Can be created by ZDM if it doesn't exist.  
        * NFS/FSS: Supported, including for migrations to ADB@Customer. Requires NFS/FSS setup and mount points.  
        * COPY: Secure copy method supported for co-managed and user-managed targets. Requires Port 22 connectivity to the target storage server.  
