# Migrating Oracle Database 12c to 19c Online with Zero Downtime Migration
## Table of Contents
1. [Introduction](##Introduction)
1. [Understanding Logical Online Migration](#understanding-logical-online-migration)

## Introduction
Migrating production databases is a critical task, often complicated by the need to minimize disruption to business operations. Oracle Zero Downtime Migration (ZDM) is a powerful tool designed to address this challenge, offering robust, flexible, and resumable methods to move Oracle databases to Oracle Cloud or Exadata environments with minimal downtime.
This post focuses on migrating from an Oracle Database 12c (specifically supported versions like 12.1.0.2 or 12.2.0.1) to a target Oracle Database 19c, using ZDM's Logical Online Migration approach. 
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
    6. **User Access and Authentication** :   
        * The zdmuser on the ZDM host needs SSH key-based access to the source and target database servers. This can be as user with sudo privileges.  
        * For logical migration, connecting as the Oracle software owner (dbuser) is supported for source and target by setting RUNCPATREMOTELY to TRUE.  
        * SSH keys should be set up without a passphrase.  
        * Credentials can be provided interactively or stored in wallets for non-interactive runs. Wallet parameters like WALLET_OGGADMIN , WALLET_SOURCEADMIN , WALLET_TARGETADMIN  are used.  
    7. **Data Transfer Medium**: For logical migrations, supported media include Object Storage (OSS), NFS, Database Link (DBLINK), COPY, and AMAZONS3 (if source is AWS RDS).   
        * OSS: A common choice for Cloud targets. Requires Port 443 connectivity. May require SSL wallet configuration on the source for HTTPS access using DUMPTRANSFERDETAILS_SOURCE_OCIWALLETLOC. Using OCI CLI for dump transfer with OSS is recommended for speed and resilience, requiring OCI CLI installation and configuration.  
        * DBLINK: Supported for online/offline to all targets, but not recommended for very large databases. Requires direct network connectivity. Can be created by ZDM if it doesn't exist.  
        * NFS/FSS: Supported, including for migrations to ADB@Customer. Requires NFS/FSS setup and mount points.  
        * COPY: Secure copy method supported for co-managed and user-managed targets. Requires Port 22 connectivity to the target storage server.  

## Preparing the Migration Plan with the Response File
ZDM jobs are configured using a response file (zdm_template.rsp). You'll need to populate this file with parameters specific to your environment and migration type.  
### Key parameters for a 12c to 19c online logical migration include:
    • MIGRATION_METHOD=ONLINE_LOGICAL.
    • DATA_TRANSFER_MEDIUM: Choose your data transfer method (e.g., OSS, DBLINK, NFS).
    • Source Database Details: SOURCEDATABASE_ADMINUSERNAME, SOURCEDATABASE_CONNECTIONDETAILS_HOST, SOURCEDATABASE_CONNECTIONDETAILS_PORT, SOURCEDATABASE_CONNECTIONDETAILS_SERVICENAME, SOURCEDATABASE_ENVIRONMENT_NAME=ORACLE , SOURCEDATABASE_ENVIRONMENT_DBTYPE . If source is ADB, use SOURCEDATABASE_OCID . Include SOURCEDATABASE_GGADMINUSERNAME for GoldenGate .
    • Target Database Details: TARGETDATABASE_ADMINUSERNAME . If targeting OCI Cloud database (non-ADB), use TARGETDATABASE_OCID . If targeting ADB and not providing OCID, along with connection details (TARGETDATABASE_CONNECTIONDETAILS_HOST, _PORT, _SERVICENAME). Include TARGETDATABASE_GGADMINUSERNAME for GoldenGate .
    • GoldenGate Details: GOLDENGATEHUB_ADMINUSERNAME, GOLDENGATEHUB_SOURCEDEPLOYMENTNAME, GOLDENGATEHUB_TARGETDEPLOYMENTNAME.
    • Authentication Parameters: These are typically provided via command-line arguments like -srcauth, -tgtauth specifying zdmauth or dbuser and the identity file/sudo location.
    • Data Pump Settings: Parameters like DATAPUMPSETTINGS_EXPORTVERSION, DATAPUMPSETTINGS_DATAPUMPPARAMETERS_EXPORTPARALLELISMDEGREE, DATAPUMPSETTINGS_DATAPUMPPARAMETERS_IMPORTPARALLELISMDEGREE, DATAPUMPSETTINGS_RETAINDUMPS, DATAPUMPSETTINGS_DELETEDUMPSINOSS, DATAPUMPSETTINGS_FIXINVALIDOBJECTS, INCLUDEOBJECTS-LIST_ELEMENT_NUMBER or EXCLUDEOBJECTS-LIST_ELEMENT_NUMBER if migrating specific schemas, DATAPUMPSETTINGS_METADATAREMAPS-LIST_ELEMENT_NUMBER.
    • Data Transfer Settings: Relevant DUMPTRANSFERDETAILS_* parameters based on your chosen medium (e.g., DUMPTRANSFERDETAILS_SOURCE_OCIWALLETLOC for OSS over HTTPS, DUMPTRANSFERDETAILS_PUBLICREAD for NFS dumps).
    • Flashback: Control flashback on the target using FLASHBACK_ON.
    • Source Shutdown: Optionally configure source shutdown after migration with SHUTDOWN_SRC.

## Crucial First Step: Run CPAT  
Before initiating the migration, you must run the Cloud Premigration Advisor Tool (CPAT)using ZDM. CPAT analyses your source database for potential migration issues and suitability for the target environment. Run the ZDMCLI command with the -eval -advisor options: 
```
zdmuser> $ZDM_HOME/bin/zdmcli migrate database -rsp /path/to/your/response_file.rsp \
-sourcedb your_source_db_name -sourcenode source_host \
-targetnode target_host \
-srcauth zdmauth -srcarg1 user:opc -srcarg2 identity_file:/home/zdmuser/.ssh/id_rsa.pub -srcarg3 sudo_location:/usr/bin/sudo \
-tgtauth zdmauth -tgtarg1 user:opc -tgtarg2 identity_file:/home/zdmuser/.ssh/id_rsa.pub -tgtarg3 sudo_location:/usr/bin/sudo \
-eval -advisor
```
Address any errors or action required items reported by CPAT before proceeding.

## Executing the Migration Job  
Once prerequisites are met and the response file is prepared, execute the migration using the zdmcli migrate database command:  
```
zdmuser> $ZDM_HOME/bin/zdmcli migrate database -rsp /path/to/your/response_file.rsp \
-sourcedb your_source_db_unique_name -sourcenode source_host \
-targetnode target_host \
-srcauth zdmauth -srcarg1 user:opc -srcarg2 identity_file:/home/zdmuser/.ssh/zdm_service_host.ppk -srcarg3 sudo_location:/usr/bin/sudo \
-tgtauth zdmauth -tgtarg1 user:opc -tgtarg2 identity_file:/home/zdmuser/.ssh/zdm_service_host.ppk -tgtarg3 sudo_location:/usr/bin/sudo \
-schedule NOW
```  
You can use the -schedule NOW option to start immediately or For example, 2016-12-21T19:13:17+05 . The command output will provide a job ID.  
For logical online migrations, it's often advisable to use the -pauseafter option after the GoldenGate replication setup and monitoring phases are complete. This allows you to manually perform the application switchover before resuming the ZDM job.  

## Monitoring the Migration  
Monitor the migration job status using the job ID obtained after execution:  
```
zdmuser> $ZDM_HOME/bin/zdmcli query job -jobid <your_job_id>
```
You can view the phases of the job using zdmcli migrate database -listphases. Key phases for logical online migration include:  
    • ZDM_PREPARE_DATAPUMP_SRC: Prepares for Data Pump export on the source.  
    • ZDM_DATAPUMP_EXPORT_SRC: Starts and monitors Data Pump export.  
    • ZDM_UPLOAD_DUMPS_SRC: Uploads dump files to OSS or transfers via other media if not DBLINK.  
    • ZDM_DATAPUMP_IMPORT_TGT: Imports data to the target.  
    • ZDM_PREPARE_GG_HUB: Registers database connection details with GoldenGate Microservices.  
    • ZDM_START_GG_EXTRACT_SRC: Starts the GoldenGate Extract process on the source.  
    • ZDM_START_GG_REPLICAT_TGT: Starts the GoldenGate Replicat process on the target.  
    • ZDM_MONITOR_GG_LAG: Monitors the GoldenGate replication lag.  
    • ZDM_SWITCHOVER_APP: The phase where application switchover typically happens (often manual).  

When using zdmcli query job, you can also see GoldenGate metrics like extract/replicat status and end-to-end heartbeat lag once the relevant phases are completed.

## Application Switchover and Post-Migration  
As mentioned, the actual application switchover is usually a manual step in logical online migration. After ZDM has established GoldenGate replication and the lag is minimal (monitored via ZDM_MONITOR_GG_LAG), you would:  
    1. Stop application connections to the source database.  
    2. Wait for GoldenGate to apply any remaining changes, ensuring the target is fully synchronised.  
    3. Redirect your applications to connect to the new 19c target database.  
    4. If you paused the ZDM job (e.g., with -pauseafter ZDM_MONITOR_GG_LAG), resume it using zdmcli resume job -jobid <your_job_id>.  
ZDM handles post-migration cleanup tasks like fixing invalid objects or removing temporary credentials/DBLinks. You can also configure parameters like SHUTDOWN_SRC to shut down the source database if desired.  

## Conclusion
Migrating your Oracle Database 12c to 19c online using Zero Downtime Migration provides a powerful, automated way to achieve your database modernisation goals with minimal impact on your users and business operations. The Logical Online Migration method, leveraging Data Pump and GoldenGate, ensures your source database remains available throughout most of the process.
Always refer to the official Oracle documentation for the most current and detailed information on ZDM prerequisites, parameter definitions, and troubleshooting, as the information herein is subject to change.