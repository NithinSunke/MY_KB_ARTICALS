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
 
