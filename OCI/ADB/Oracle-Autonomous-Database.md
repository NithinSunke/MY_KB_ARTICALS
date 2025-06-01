# Oracle Autonomous Database

## Introduction
Oracle Autonomous Database provides an easy-to-use, fully autonomous database that scales elastically and delivers fast query performance. As a service, Autonomous Database does not require database administration.
With Autonomous Database you do not need to configure or manage any hardware or install any software. Autonomous Database handles provisioning the database, backing up the database, patching and upgrading the database, and growing or shrinking the database. Autonomous Database is a completely elastic service.
At any time you can scale, increase or decrease, either the compute or the storage capacity. When you make resource changes for your Autonomous Database instance, the resources automatically shrink or grow without requiring any downtime or service interruptions.
Autonomous Database is built upon Oracle Database, so that the applications and tools that support Oracle Database also support Autonomous Database. These tools and applications connect to Autonomous Database using standard SQL*Net connections.
The tools and applications can either be in your data center or in a public cloud. Oracle Analytics Cloud and other Oracle Cloud services provide support for Autonomous Database connections.

**Autonomous Database also includes the following**:
*	Oracle APEX: a low-code development platform that enables you to build scalable, secure enterprise apps with world-class features.
*	Oracle REST Data Services (ORDS): a Java Enterprise Edition based data service that makes it easy to develop modern REST interfaces for relational data and JSON Document Store.
*	Database Actions: is a web-based interface that uses Oracle REST Data Services to provide development, data tools, administration, and monitoring features
for Autonomous Database.
*	Oracle Machine Learning Notebooks Early Adopter is an enhanced web-based notebook platform for data engineers, data analysts, R and Python users, and data scientists. You can write code, text, create visualizations, and perform data analytics including machine learning. In Oracle Machine Learning, notebooks are available in a project within a workspace, where you can create, edit, delete, copy, move, and even save notebooks as templates.

## Key Features
*	**Managed**: Oracle simplifies end-to-end management of the database:
    *	Provisioning new databases
    *	Growing or shrinking storage and compute resources
    *	Patching and upgrades
    *	Backup and recovery  
*	Fully elastic scaling: Scale compute and storage independently to fit your database workload with no downtime:
*	Size the database to the exact compute and storage required
*	Scale the database on demand: Independently scale compute or storage
*	Shut off idle compute to save money
*	Auto scaling: Allows your database to use more CPU and IO resources or to use additional storage automatically when the workload or storage demand requires additional resources:
*	Specify the number of CPUs for your Autonomous Database workload.
*	Use compute auto scaling to allow the database to use up to three times more CPU and IO resources, depending on workload requirements.
Compute auto scaling is enabled by default when you create an Autonomous Database.
*	Use storage auto scaling to allow the database to expand to use up to three times the reserved base storage, depending on your storage requirements. Storage auto scaling is disabled by default when you create an Autonomous Database.
*	Manage auto scaling from the Oracle Cloud Infrastructure Console to enable or disable compute auto scaling or storage auto scaling for your Autonomous Database.
*	Autonomous Database supports:
*	Existing applications, running in the cloud or on-premise
*	Connectivity via SQL*Net, JDBC, ODBC
*	Third-party data-integration tools
*	Oracle cloud services: Oracle Analytics Cloud, Oracle GoldenGate Marketplace, and others
*	High-performance queries and concurrent workloads: Optimized query performance with preconfigured resource profiles for different types of users.
*	Oracle SQL: Autonomous Database is compatible with existing applications that support Oracle Database.
*	Built-in web-based data analysis tool: Web-based notebook tool for designing and sharing SQL based data-driven, interactive documents.
*	Database migration utility: Easily migrate from MySQL, Amazon AWS Redshift, PostgreSQL, SQL Server, and other databases.

## Simple Cloud-based Data Loading
**Autonomous Database provides**:
*	Fast, scalable data-loading from Oracle Cloud Infrastructure Object Storage, Azure Blob Storage, Amazon S3, Amazon S3-Compatible, GitHub Repository, Google Cloud Storage, or on-premise data sources.

## Oracle Database Actions
Database Actions is a web-based interface that uses Oracle REST Data Services to provide development, data tools, and administration and monitoring features
for Autonomous Database, including the following:
*	**Development Tools**
    *	SQL Navigator and Worksheet: view objects and enter and run SQL and PL/SQL statements, and create database objects
    *	Data Modeler: provides an integrated version of Oracle SQL Developer Data Modeler with basic reporting features. You can create diagrams from existing schemas, retrieve data dictionary information, generate DDL statements, and export diagrams
    *	REST: An IDE for your REST APIs that enables you to manage templates, handlers and OAuth clients, generate API documentation, and test APIs.
    *	LIQUIBASE: View ChangeLogs applied to your schema.
    *	JSON: Create collections, upload documents, query and filter your data, create diagrams for your JSON document structures, and create relational views and indexes.
    *	Charts: Use SQL queries to build rich charts and dashboards containing multiple charts.
    *	Scheduling: An interface for DBMS_SCHEDULER that enables you to monitor jobs, view execution history, forecast upcoming jobs, and visualize scheduler chains.
    *	Oracle Machine Learning: provides several components accessible through a common user interface. OML Notebooks supports Python, SQL, PL/SQL,and Markdown interpreters, with access to in-database ML through OML4Py and OML4SQL. OML Models supports managing and deploying in-database models. OML AutoML UI provides a no-code user interface to build, evaluate, and deploy in-database models using automated machine learning.
    *	APEX: Login to APEX, develop and run rich, low-code web applications.
    *	Graph Studio: Oracle Graph Studio lets you create property graph databases and automates the creation of graph models and in-memory graphs from database tables.


*	**Data Studio**
    *	Data Load: load or access data from local files or remote databases.
    *	Catalog: understand data dependencies and the impact of changes.
    *	Data Insights: discover anomalies, outliers and hidden patterns in your data.
    *	Data Analysis: analyze your data
    *	Data Transforms: transform data for analysis and other applications.


*	**Administration and Monitoring**
    *	Manage users
    *	Database Dashboard: Monitor database activity charts such as CPU usage, number of executing SQL statements, and wait events formerly found on your Autonomous Database Service Console.
    *	Performance Hub: Access SQL Monitoring reports and Active Session History (ASH) Analytics.

## Disaster Recovery Options
**Autonomous Data Guard**: Autonomous Database provides Autonomous Data Guard to enable a standby (peer) database to provide data protection and disaster recovery for your Autonomous Database instance.When you add an Autonomous Data
Guard standby database, the system creates a standby database that continuously gets updated with the changes from the primary database. You can use Autonomous Data Guard with a standby in the current region, a local standby, or with a standby in a different region, a cross-region standby. You can also use Autonomous Data Guard with both a local standby and a cross-region standby.
**Backup-Based Disaster** Recovery uses backups to instantiate a peer database at the time of switchover or failover. This enables you to have a lower cost and higher Recovery Time Objective (RTO) disaster recovery option for your Autonomous Database, as compared with Autonomous Data Guard. For local backup-based disaster recovery, existing local backups are utilized. There are no additional costs for a local Backup- Based Disaster Recovery. Cross-Region Backup-Based Disaster Recovery incurs an additional cost.

