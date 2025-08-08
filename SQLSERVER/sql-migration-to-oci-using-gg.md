## 🚀 GOAL:

Migrate SQL Server database with **low downtime**, using BCP and GoldenGate.

---

## 📦 ENVIRONMENT OVERVIEW:

| Item      | Source (On-Prem)                                  | Target (OCI)                    |
| --------- | ------------------------------------------------- | ------------------------------- |
| DB Engine | SQL Server 2019                                   | SQL Server 2019 or higher       |
| Tables    | 31 total (17 system-versioned, 14 normal)         | Same                            |
| Tools     | `bcp.exe`, SSMS, Oracle GoldenGate for SQL Server | Oracle GoldenGate Cloud Service |

---

## 🗺️ MIGRATION FLOW OVERVIEW

```
            ┌────────────────────┐
            │ 1. Prepare Schema  │
            └────────┬───────────┘
                     ↓
            ┌────────────────────┐
            │ 2. Enable CDC      │
            └────────┬───────────┘
                     ↓
            ┌────────────────────┐
            │ 3. Start GG Extract│◀─────┐
            └────────┬───────────┘      │
                     ↓                  │ (Capture LSN before BCP)
            ┌────────────────────┐      │
            │ 4. Export via BCP  │──────┘
            └────────┬───────────┘
                     ↓
            ┌────────────────────┐
            │ 5. Import via BCP  │ (on OCI)
            └────────┬───────────┘
                     ↓
            ┌────────────────────┐
            │ 6. Start Replicat  │ (with HANDLECOLLISIONS)
            └────────┬───────────┘
                     ↓
            ┌────────────────────┐
            │ 7. Validate & Cutover │
            └────────────────────┘
```

---

## 🔧 STEP-BY-STEP INSTRUCTIONS

---

### 🧱 STEP 1: Prepare Schema on Target (OCI)

1. Use SSMS or `Generate Scripts` wizard to script the **structure only**.
    * Databases -> select the database -> Tasks -> Generate Scripts
    * a wizard will open, select:
      - **select the database objects to script**
        - Script entire database and all database objects or Select specific database objects
      - Save to file or clipboard

2. Recreate tables (non-temporal and temporal) **manually** on the OCI SQL Server.
**Execute the Generated script on target OCI SQL Server**

   * For **temporal tables**, use:

   ```sql
   CREATE TABLE Application.Cities_Archive (
       -- your columns
       SysStartTime DATETIME2 GENERATED ALWAYS AS ROW START,
       SysEndTime DATETIME2 GENERATED ALWAYS AS ROW END,
       PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime)
   )
   WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = Application.Cities));
   ```

3. Do this for all  system-versioned `*_Archive` tables and  non-temporal tables.

---

### 🧰 STEP 2: Enable CDC on Source Tables

Enable CDC at **DB level**:

```sql
USE YourDB;
EXEC sys.sp_cdc_enable_db;
```
to validate cdc is enabled
```
SELECT name, is_cdc_enabled
FROM sys.databases;
```

Then on each table (system-versioned or non-temporal):

```sql
EXEC sys.sp_cdc_enable_table   
@source_schema = N'Application',   
@source_name   = N'Cities_Archive',   
@role_name     = NULL,   
@supports_net_changes = 0;
```
Repeat for all tables.


**to view the cdc enabled tables**
SELECT 
    capture_instance,
    object_name(source_object_id) AS source_table_name,
    source_object_id AS object_id,
    start_lsn,
    supports_net_changes
FROM cdc.change_tables;

SELECT * FROM cdc.change_tables;


**Automate by sql script to enable cdc on all applicable tables**
```
USE WideWorldImporters;  -- Replace with your database name
GO

DECLARE @SchemaName SYSNAME,
        @TableName SYSNAME,
        @SQL NVARCHAR(MAX);

-- Cursor: Only base tables that are eligible for CDC
DECLARE CDC_CURSOR CURSOR FOR
SELECT s.name AS schema_name,
       t.name AS table_name
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE 
    t.is_ms_shipped = 0
    AND t.temporal_type = 0                          -- Exclude system-versioned base tables
    AND t.is_memory_optimized = 0                    -- Exclude memory-optimized tables
    AND NOT EXISTS (
        SELECT 1
        FROM sys.tables base
        WHERE base.history_table_id = t.object_id    -- Exclude temporal history tables
    )
    AND NOT EXISTS (
        SELECT 1
        FROM cdc.change_tables c
        WHERE c.source_object_id = t.object_id       -- Exclude already CDC-enabled tables
    )
    AND NOT EXISTS (
        SELECT 1
        FROM sys.indexes i
        WHERE i.object_id = t.object_id
          AND i.type_desc = 'CLUSTERED COLUMNSTORE'  -- Exclude clustered columnstore index tables
    );

OPEN CDC_CURSOR;

FETCH NEXT FROM CDC_CURSOR INTO @SchemaName, @TableName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = N'
    PRINT ''Enabling CDC on ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + '''; 
    EXEC sys.sp_cdc_enable_table
        @source_schema = N''' + @SchemaName + ''',
        @source_name = N''' + @TableName + ''',
        @role_name = NULL,
        @supports_net_changes = 1;
    ';
    
    BEGIN TRY
        EXEC sp_executesql @SQL;
    END TRY
    BEGIN CATCH
        PRINT '❌ Error enabling CDC on ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ': ' + ERROR_MESSAGE();
    END CATCH;

    FETCH NEXT FROM CDC_CURSOR INTO @SchemaName, @TableName;
END;

CLOSE CDC_CURSOR;
DEALLOCATE CDC_CURSOR;

PRINT 'CDC has been enabled on all valid base tables (excluding temporal, history, memory-optimized, CCI, and CDC-enabled tables).';

```

---

### 🔄 STEP 3: Start GoldenGate Extract (Log Capture)

1. Install GoldenGate service for SQL Server **on OCI**.
2. Add Extract using LSN *before BCP* to avoid missing changes.

Example parameter file:

```
EXTRACT extsql
SOURCEDB YourDBUser, PASSWORD YourPassword
TRANLOGOPTIONS MANAGESECONDARYTRUNCATIONPOINT
TABLE Application.Cities_Archive;
TABLE Purchasing.Suppliers_Archive;
TABLE Sales.Orders;
...
```

Command-line:

```bash
ADD EXTRACT extsql, TRANLOG, BEGIN NOW
ADD EXTTRAIL ./dirdat/aa, EXTRACT extsql
```

> This **starts log capture**, even before BCP export.

---

### 📤 STEP 4: Export Data with BCP

On the **source server**, export data:

```bash
bcp YourDB.Application.Cities_Archive out C:\bcp\Cities_Archive.txt -c -t, -T -S YOURSERVER
bcp YourDB.Sales.Orders out C:\bcp\Orders.txt -c -t, -T -S YOURSERVER
```

Repeat for all 31 tables.

Transfer these `.txt` files to OCI server via WinSCP/SCP.

---

### 📥 STEP 5: Import Data with BCP (on OCI)

On the **OCI SQL Server**:

```bash
bcp YourDB.Application.Cities_Archive in C:\bcp\Cities_Archive.txt -c -t, -T -S OCISERVER
bcp YourDB.Sales.Orders in C:\bcp\Orders.txt -c -t, -T -S OCISERVER
```

> Use `SET IDENTITY_INSERT` if identity columns exist.

---

### 🟢 STEP 6: Configure and Start GoldenGate Replicat

Example Replicat parameter file:

```
REPLICAT repoci
TARGETDB YourDBUser, PASSWORD YourPassword
HANDLECOLLISIONS
MAP Application.Cities_Archive, TARGET Application.Cities_Archive;
MAP Sales.Orders, TARGET Sales.Orders;
...
```

Command:

```bash
ADD REPLICAT repoci, EXTTRAIL ./dirdat/aa
START REPLICAT repoci
```

> `HANDLECOLLISIONS` is critical to skip duplicate inserts that were already loaded by BCP.

---

### 🔍 STEP 7: Validate and Cutover

1. Wait until Extract and Replicat are **caught up** (0 lag)
2. Run checksum or row count check:

```sql
SELECT COUNT(*) FROM Application.Cities_Archive;
```

3. Stop application writes to source DB
4. Let Replicat apply remaining changes
5. Switch applications to point to **OCI SQL Server**
6. Stop GoldenGate Extract & Replicat
7. Disable `HANDLECOLLISIONS` (optional cleanup)

---

## ✅ OPTIONAL: Table List Script Generator

To generate your full table list for BCP or GoldenGate params:

```sql
SELECT 
    'TABLE ' + s.name + '.' + t.name + ';'
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE t.temporal_type IN (0, 1)
ORDER BY s.name, t.name;
```

---

## 🧾 Summary

| Phase          | Tools               |
| -------------- | ------------------- |
| Schema Prep    | SSMS                |
| Initial Load   | BCP                 |
| Real-Time Sync | GoldenGate          |
| Validation     | SQL Queries         |
| Switchover     | Manual (App Update) |

---

Would you like:

* A ready-made PowerShell or Bash script to auto-run BCP for all 31 tables?
* A GoldenGate parameter file template pre-filled with your table list?

Let me know and I’ll generate it!
