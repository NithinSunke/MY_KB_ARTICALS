**1. System-Versioned Temporal Tables**
SELECT 
    s.name AS SchemaName,
    t.name AS TableName
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE t.temporal_type = 2 -- System-versioned temporal table
ORDER BY SchemaName, TableName;

**2. Memory-Optimized Tables**
SELECT 
    s.name AS SchemaName,
    t.name AS TableName
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE t.is_memory_optimized = 1
ORDER BY SchemaName, TableName;

**3. Tables with Clustered Columnstore Indexes**
SELECT 
    s.name AS SchemaName,
    t.name AS TableName,
    i.name AS IndexName
FROM sys.indexes i
JOIN sys.tables t ON i.object_id = t.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE i.type_desc = 'CLUSTERED COLUMNSTORE'
ORDER BY SchemaName, TableName;

**4. Tables with FileTables (Not supported)**
SELECT 
    s.name AS SchemaName,
    t.name AS TableName
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE t.is_filetable = 1
ORDER BY SchemaName, TableName;

**5. Natively Compiled Stored Procedures**
SELECT 
    s.name AS SchemaName,
    p.name AS ProcedureName
FROM sys.procedures p
JOIN sys.schemas s ON p.schema_id = s.schema_id
WHERE OBJECTPROPERTY(p.object_id, 'IsNativelyCompiled') = 1
ORDER BY SchemaName, ProcedureName;


**consolidated query**
SELECT 
    'Temporal Tables' AS Feature,
    COUNT(*) AS ObjectCount
FROM sys.tables
WHERE temporal_type = 2
UNION ALL
SELECT 'Memory-Optimized Tables', COUNT(*) FROM sys.tables WHERE is_memory_optimized = 1
UNION ALL
SELECT 'Columnstore Indexed Tables', COUNT(*) 
FROM sys.indexes WHERE type_desc = 'CLUSTERED COLUMNSTORE'
UNION ALL
SELECT 'FileTables', COUNT(*) FROM sys.tables WHERE is_filetable = 1
UNION ALL
SELECT 'Natively Compiled Procs', COUNT(*) 
FROM sys.procedures WHERE OBJECTPROPERTY(object_id, 'IsNativelyCompiled') = 1;

