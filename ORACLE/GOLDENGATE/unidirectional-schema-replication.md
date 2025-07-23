# Unidirectional Schema Replication with Oracle GoldenGate 23ai

In the era of real-time data streaming and hybrid cloud architectures, Oracle GoldenGate 23ai Microservices provides a powerful, flexible, and scalable solution for data replication. One of the most common use cases is Unidirectional Schema Replication—replicating changes from one source schema to a target schema in near real-time.

In this blog post, we'll explore how to set up unidirectional schema-level replication using Oracle GoldenGate 23ai Microservices Architecture (MA), ideal for scenarios like reporting databases, cloud migration, or read-scale out.

## What is Unidirectional Replication?
Unidirectional replication is a one-way data flow where changes from a source database are continuously captured and applied to a target database. This ensures both systems are in sync, but only the source system is actively updated by applications.

**Use Cases:**
*   Migrating from on-prem to cloud (e.g., Oracle to Oracle ATP)
*   Creating reporting instances
*   Load balancing read operations

## Prerequisites
*   Oracle GoldenGate 23ai installed on saperate vm different from database servers.
*   Oracle Database 19c or higher on both ends.
*   Network connectivity between source,target and gg servers.
*   Credentials with appropriate privileges.

## Configuration Steps
### Setup for oracle databases involved in Goldengate 

We need to enable supplemental logging. It can be  at entire database level or at schema level. Here for now am enabling at database level at both source and target database.

```
alter database force logging;
select force_logging from v$database;
alter database add supplemental log data;

set parameter enable_goldengate_replication to true:
show parameter enable_goldengate_replication;
alter system set enable_goldengate_replication=true scope=both;

set the stream_pool_size to atleast 1g this is used by Goldengate:
show parameter stream
alter system set streams_pool_size=1024m scope=both;
```


create c##ggadmin user in oracle database on source and target
```
create user C##GGADMIN identified by xxxxx container=all;
```
grant the privilleges to c##ggadmin user
```
EXEC DBMS_GOLDENGATE_AUTH.GRANT_ADMIN_PRIVILEGE(grantee => 'C##GGADMIN', container => 'ALL');
-- For all containers manually, run in CDB$ROOT and PDBs if needed
EXEC DBMS_STREAMS_AUTH.GRANT_ADMIN_PRIVILEGE('C##GGADMIN');


grant insert on system.logmnr_restart_ckpt$ to C##GGADMIN container=all;
grant update on streams$_capture_process to C##GGADMIN container=all;
grant become user to C##GGADMIN container=all;
grant select any table to C##GGADMIN container=all;
GRANT CONNECT, RESOURCE TO C##GGADMIN container=all;
GRANT SELECT ANY DICTIONARY, SELECT ANY TABLE TO C##GGADMIN container=all;
GRANT CREATE TABLE TO C##GGADMIN container=all;
GRANT FLASHBACK ANY TABLE TO C##GGADMIN container=all;
GRANT EXECUTE ON dbms_flashback TO C##GGADMIN container=all;
GRANT EXECUTE ON utl_file TO C##GGADMIN container=all;
GRANT CREATE ANY TABLE TO C##GGADMIN container=all;
GRANT INSERT ANY TABLE TO C##GGADMIN container=all;
GRANT UPDATE ANY TABLE TO C##GGADMIN container=all;
GRANT DELETE ANY TABLE TO C##GGADMIN container=all;
GRANT DROP ANY TABLE TO C##GGADMIN container=all;
GRANT ALTER ANY TABLE TO C##GGADMIN container=all;
GRANT ALTER SYSTEM TO C##GGADMIN container=all;
GRANT LOCK ANY TABLE TO C##GGADMIN container=all;
GRANT SELECT ANY TRANSACTION to C##GGADMIN container=all;
ALTER USER C##GGADMIN QUOTA UNLIMITED ON users container=all;
alter user C##GGADMIN quota unlimited on users container=all;
exec dbms_goldengate_auth.grant_admin_privilege('C##GGADMIN','*', grant_optional_privileges=>'*');
```

**Below grants run on each pdb invloved in gg configuration**
```
exec dbms_goldengate_auth.grant_admin_privilege('C##GGADMIN');
exec dbms_streams_auth.grant_admin_privilege('C##GGADMIN') ;
exec dbms_goldengate_auth.grant_admin_privilege('C##GGADMIN','*', grant_optional_privileges=>'*');
```

next step is to create credential alias
from admin console of gg navigate to DB Connections  
<img src="./images/gg20.jpg" alt="Description" width="600"/>  
add new db connection  
<img src="./images/gg21.jpg" alt="Description" width="600"/>
<img src="./images/gg22.jpg" alt="Description" width="600"/>  
connect to the database  
<img src="./images/gg23.jpg" alt="Description" width="600"/>
<img src="./images/gg24.jpg" alt="Description" width="600"/>  
Follow same steps to add target database also  
<img src="./images/gg25.jpg" alt="Description" width="600"/>  
ADD CDB and PDB connections:  
<img src="./images/gg28.jpg" alt="Description" width="600"/>


Add  schema trandata  
<img src="./images/gg26.jpg" alt="Description" width="600"/>  
validate schema trandata  
<img src="./images/gg27.jpg" alt="Description" width="600"/>

## create cdc extract
