# Steps to migrate tables from ms SQL server to oracle database ATP using oci gg service 

## Step 1: Enable CDC on SQL Server

### Enable CDC at the database level
EXEC sys.sp_cdc_enable_db;

### Enable CDC on the required table
EXEC sys.sp_cdc_enable_table  
   @source_schema = N'dbo',  
   @source_name   = N'PATIENT_DETAILS',  
   @role_name     = NULL;

### Verify CDC status:

SELECT * FROM cdc.change_tables;

### create replication user
USE master;
GO
CREATE LOGIN ggadmin WITH PASSWORD = 'Nevi#Nihaan#0712';
GO

USE scsdb;
GO
CREATE USER ggadmin FOR LOGIN ggadmin;
GO

### Grant Minimum Required Permissions
-- Membership in db_owner is easiest for full access
ALTER ROLE db_owner ADD MEMBER ggadmin;

-- Required system-level permissions
USE master;
GRANT VIEW SERVER STATE TO ggadmin;

**For least privilege approach:**
-- Permissions required for GoldenGate Extract using CDC
GRANT SELECT ON SCHEMA :: [cdc] TO ggadmin;
GRANT EXECUTE ON SCHEMA :: [cdc] TO ggadmin;

-- Permissions on specific tables or schemas
GRANT SELECT ON SCHEMA :: [dbo] TO ggadmin;

### Verify Permissions and CDC Status
-- Verify CDC is enabled
SELECT name, is_cdc_enabled FROM sys.databases;

-- Check CDC-enabled tables
SELECT * FROM cdc.change_tables;

-- Test access
EXECUTE AS USER = 'ggadmin';
SELECT * FROM cdc.dbo_PATIENT_DETAILS;
REVERT;


## step 2 Prepare Oracle Target Database ATP
unlock the ggadmin user and set password

## create goldengate deployment
one for mssql server
one for oracle database

## create connections in oci gg services
one for mssql server
one for oracle database

*   assign the connections to the deployments.
*   test the connection it should be success.

> Note: create connction to use shared endpoint 

