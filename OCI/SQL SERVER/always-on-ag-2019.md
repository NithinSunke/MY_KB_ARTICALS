# Setting Up SQL Server 2019 Always On High Availability in OCI

## Introduction:
Always On Availability Groups (AG) is a high-availability and disaster recovery feature of SQL Server Enterprise Edition. When paired with Oracle Cloud Infrastructure (OCI), you get a robust, scalable, and resilient HA solution for mission-critical SQL workloads.
In this tutorial, we'll walk through deploying a 2-node AG cluster + domain controller in OCI with a listener for automatic failover.
The architecture needed for deploying SQL Server Always On availability groups. There are some specifics to deploying SQL Server on OCI that customers need to be aware of to make sure their SQL Server Always On availability groups deployment is successful.

The step-by-step procedures for deploying a two-node SQL Server Always On availability group. This constitutes the bulk of the tutorial. The same procedures can be used for deployments that use more than two nodes. This tutorial documents the procedures using the Windows Operating System graphical interface, which makes it adequate for non-advanced users. If you are an advanced user, you can implement the configuration using Windows PowerShell.

## Architecture
This tutorial uses the following architecture:
*	Single Region: The deployment comprises a single OCI region. The deployment could be extended to other OCI regions, but such configurations fall outside the scope of this tutorial.
*	Private Subnets: With the exception of an OCI Bastion virtual machine (VM), all resources are placed in private regional subnets.
*	SQL Server Nodes on Multiple Subnets: Each of the two nodes of the SQL Server deployment is placed in a different subnet as per Microsoft recommendations. For more information, see Prerequisites for availability groups in multiple subnets (SQL Server on Azure VMs). SQL Server Always On availability groups could be deployed in a single subnet but this is not a recommended architecture by Microsoft. Additionally, it will require the use of a load balancer and functionality not supported by OCI (direct server return).
*	Windows Server Failover Cluster Quorum Witness: Always On availability groups runs on a Windows Server Failover Cluster (WSFC). WSFC requires the use of a cluster quorum witness, for which there are several deployment options. This tutorial uses a file share witness, as it is optimal for an OCI deployment. To achieve this, I have used DC as a quorum witness VM.
*	SQL Server IPs needed: Each of the SQL Server VMs needs the following IPs in the primary Virtual Network Interface Cards (VNIC).
*	Primary IP: Operating System access (created automatically upon VM provisioning).
*	Secondary IP 1: Windows Server Failover Cluster IP. To be created in this tutorial.
*	Secondary IP 2: SQL Server Always On availability groups listener. To be created in this tutorial.
*	Accounts needed
*	Domain Administrator: Domain administrator performs all configuration tasks in this tutorial. This account also needs to be configured both as a local administrator on each SQL Server VM and as a member of SQL Server sysadmin fixed server role for each SQL Server instance.
*	Service Account: It is used for SQL Server service to operate on both SQL Server nodes.

## Firewall considerations

### Key Considerations
*	All VMs (SQLNode1, SQLNode2, QuorumVM) are in private subnets
*	AD and DNS are managed by DC01 (your Domain Controller)
*	SQL Server runs Always On AG with Windows Server Failover Cluster (WSFC)
*	You're using static port 1433 for SQL traffic (recommended)
 
### Inbound and Outbound Port Requirements
1. SQL Server Ports  


|Port |	Protocol |	Direction |	Purpose |  
|:----|:---------|:-----------|:--------|
| 1433 | TCP |	Inbound | Default SQL Server instance |
|1433 | TCP | Outbound | SQL client to peer node |
|1434 | TCP | Inbound  | SQL Server Browser (if used) |

 
> 📝 Use static port 1433 and disable dynamic ports to simplify firewall configs.
 
2. Always On AG & WSFC Ports  

|Port |	Protocol |	Direction |	Purpose |
|:----|:---------|:-----------|:--------|
|5022 |	TCP	| Inbound/Outbound	|AG data replication between nodes |
|135 |	TCP |	Inbound/Outbound |	RPC Endpoint Mapper (cluster, WMI) |
|3343 |	TCP/UDP |	Inbound/Outbound |	WSFC heartbeats |
 
 
3. Active Directory (DNS, Domain Join, etc.)

|Port |	Protocol |	Direction |	Purpose |
|:----|:---------|:-----------|:---------|
|53 |	TCP/UDP |	Inbound/Outbound |	DNS |
|88 |	TCP/UDP |	Inbound/Outbound |	Kerberos authentication |
|389 |	TCP/UDP	| Inbound/Outbound |	LDAP (domain queries) |
|445 |	TCP	| Inbound/Outbound |	SMB (file sharing, AD comm) |
|139 |	TCP	| Inbound/Outbound |	NetBIOS Session |
|137-138 |	UDP	| Inbound/Outbound |	NetBIOS Name/Datagram |
 
 
4. File Share Witness (Quorum)  

|Port |	Protocol |	Direction |	Purpose |
|:----|:---------|:-----------|:--------|
|445 |	TCP |	Inbound/Outbound |	SMB (file share access) |
|135	| TCP	| Inbound/Outbound	| RPC for file share comm|

## Setup Architecture

![](./images/AG1.jpg)

## Objectives
### Create and configure the following:
*   A Domain Controller
*   Two SQL Server Nodes
*   Quorum Witness Share
*	Users and accounts needed for SQL Server Always On availability groups.
*	A Windows Server Failover Cluster for Always On availability groups.
*	A SQL Server Always On availability group.


### Networking Considerations:
#### Provision OCI Infrastructure
Networking configured according to the architecture diagram.
*	1 VCN.
*	1 public subnet and 3 private subnets.
Create VCN and Subnets
*	CIDR: 11.0.0.0/16
*	Subnets:
    *	11.0.0.0/24 – Bastion VM
    *	11.0.1.0/24 – Domain Controller
    *	11.0.2.0/24 – SQL Node 1
    *	11.0.3.0/24 – SQL Node 2
*	Security list rules configured for implementing SQL Server Always On availability groups - 1433 and 5022 ports open.

> Document to configured using [Oracle Documentation for configuring DC in OCI]( https://docs.oracle.com/en-us/iaas/Content/Resources/Assets/whitepapers/creating-active-directory-domain-services-in-oci.pdf)

## Domain Controller on OCI Compute vm
<img src="./images/AG2.png" alt="Description" width="800"/>
<img src="./images/AG3.png" alt="Description" width="800"/>
<img src="./images/AG4.png" alt="Description" width="800"/>
<img src="./images/AG5.png" alt="Description" width="800"/>
<img src="./images/AG6.png" alt="Description" width="800"/>
<img src="./images/AG7.png" alt="Description" width="800"/>
<img src="./images/AG8.png" alt="Description" width="800"/>
<img src="./images/AG9.png" alt="Description" width="800"/>
<img src="./images/AG10.png" alt="Description" width="800"/>

Continue next until network  

<img src="./images/AG11.png" alt="Description" width="800"/>
<img src="./images/AG12.png" alt="Description" width="800"/>
<img src="./images/AG13.png" alt="Description" width="800"/>
<img src="./images/AG14.png" alt="Description" width="800"/>
<img src="./images/AG15.png" alt="Description" width="800"/>
<img src="./images/AG16.png" alt="Description" width="800"/>  
<p>&nbsp;</p>  



<img src="./images/AG17.png" alt="Description" width="800"/>  
<img src="./images/AG18.png" alt="Description" width="800"/>
<p>&nbsp;</p>  
to make the ip address static reserve the ip address    
<p>&nbsp;</p>  
<img src="./images/AG19.png" alt="Description" width="800"/>    
 
<p>&nbsp;</p>  

>Use bastion service / bastion host to connect to the domain controler vm  
For this example I have created a jump host vm(windows) in public network and did rdp from there

From the Jump Box vm RDP to Domain Controller Server  
<p>&nbsp;</p>
<img src="./images/AG20.png" alt="Description" width="600"/> 
<img src="./images/AG21.png" alt="Description" width="600"/>   
Enable the administrator account and set password   
<p>&nbsp;</p>
<img src="./images/AG22.png" alt="Description" width="600"/>    
 <p>&nbsp;</p>
Select Computer management > Local Users and Groups > Users 
<p>&nbsp;</p>
<img src="./images/AG23.png" alt="Description" width="600"/>   
<img src="./images/AG24.png" alt="Description" width="600"/>   
<img src="./images/AG25.png" alt="Description" width="600"/>  
<p>&nbsp;</p>
Uncheck account is disabled  
<p>&nbsp;</p>
<img src="./images/AG26.png" alt="Description" width="600"/>
<img src="./images/AG27.png" alt="Description" width="600"/>
<img src="./images/AG28.png" alt="Description" width="600"/>
<img src="./images/AG29.png" alt="Description" width="600"/>
<p>&nbsp;</p>  

### Install Domain controller Feature 
<p>&nbsp;</p>
<img src="./images/AG30.png" alt="Description" width="600"/>
<img src="./images/AG31.png" alt="Description" width="600"/>
<img src="./images/AG32.png" alt="Description" width="600"/>
<img src="./images/AG33.png" alt="Description" width="600"/>
<img src="./images/AG34.png" alt="Description" width="600"/>
<img src="./images/AG35.png" alt="Description" width="600"/>
<img src="./images/AG36.png" alt="Description" width="600"/>
<img src="./images/AG37.png" alt="Description" width="600"/>
<img src="./images/AG38.png" alt="Description" width="600"/>
<img src="./images/AG39.png" alt="Description" width="600"/>
<img src="./images/AG40.png" alt="Description" width="600"/>
<img src="./images/AG41.png" alt="Description" width="600"/>
<img src="./images/AG42.png" alt="Description" width="600"/>
<img src="./images/AG43.png" alt="Description" width="600"/>
<img src="./images/AG44.png" alt="Description" width="600"/>
<img src="./images/AG45.png" alt="Description" width="600"/>
<img src="./images/AG46.png" alt="Description" width="600"/>
<img src="./images/AG47.png" alt="Description" width="600"/>
<img src="./images/AG48.png" alt="Description" width="600"/>
<p>&nbsp;</p>
Modify the dhcp options to point dns to our domain controller ip address by which it resolves using dns names.
<p>&nbsp;</p>
<img src="./images/AG49.png" alt="Description" width="600"/>
<img src="./images/AG50.png" alt="Description" width="600"/>
<img src="./images/AG51.png" alt="Description" width="600"/>
<img src="./images/AG52.png" alt="Description" width="600"/>
<img src="./images/AG53.png" alt="Description" width="600"/>
<img src="./images/AG54.png" alt="Description" width="600"/>
<p>&nbsp;</p>
Create a user(DBA) with administration privileges and add user as member of administrator group. 
<p>&nbsp;</p>  
Active Directory Users and Computers  

<img src="./images/AG55.png" alt="Description" width="600"/>
<img src="./images/AG56.png" alt="Description" width="600"/>
<img src="./images/AG57.png" alt="Description" width="600"/>
<img src="./images/AG58.png" alt="Description" width="600"/>
<img src="./images/AG58.png" alt="Description" width="600"/>
<img src="./images/AG60.png" alt="Description" width="600"/>
<img src="./images/AG61.png" alt="Description" width="600"/>
<img src="./images/AG62.png" alt="Description" width="600"/>
<img src="./images/AG63.png" alt="Description" width="600"/>
<img src="./images/AG64.png" alt="Description" width="600"/>
<img src="./images/AG65.png" alt="Description" width="600"/>

### Create SQL Service Account
1.	On DC01, open Active Directory Users and Computers.
2.	Create user: mssqlsvc@ocilift.com , mssqlagent@ocilift.com
3.	Password never expires, cannot change password.
4.	Add sqlsvc to:
    *	Local Administrators on both SQL nodes  

<img src="./images/AG66.png" alt="Description" width="600"/>
<img src="./images/AG67.png" alt="Description" width="600"/>
<img src="./images/AG68.png" alt="Description" width="600"/>

<p>&nbsp;</p>
<img src="./images/AG69.png" alt="Description" width="600"/>

## Sql server nodes setup
Provision two window 2019 server nodes to setup always on AG.  
As we deployed domain controler same deploy two vms sqlsrv01, sqlsrv02  and Join the sql server to domain controler.  
<p>&nbsp;</p>
<img src="./images/AG70.png" alt="Description" width="600"/>
<img src="./images/AG71.png" alt="Description" width="600"/>
<img src="./images/AG72.png" alt="Description" width="600"/>
<img src="./images/AG73.png" alt="Description" width="600"/>
<img src="./images/AG74.png" alt="Description" width="600"/>
<img src="./images/AG75.png" alt="Description" width="600"/>
<p>&nbsp;</p>

Login as administration  
Open computer management:  
<p>&nbsp;</p>
<img src="./images/AG76.png" alt="Description" width="600"/>
<img src="./images/AG77.png" alt="Description" width="600"/>

Logout and login as your user  
<img src="./images/AG78.png" alt="Description" width="600"/>
<p>&nbsp;</p>
Attach secound IP's for Failover Cluster and AG listener.  
In oci console on sql node1 attach two secoundary ip's to vnic.    
<p>&nbsp;</p>
<img src="./images/AG79.png" alt="Description" width="600"/>
<img src="./images/AG80.png" alt="Description" width="600"/>
<img src="./images/AG81.png" alt="Description" width="600"/>
<img src="./images/AG82.png" alt="Description" width="600"/>
<p>&nbsp;</p>
Repeat same steps to Configure secoundary ip addres on SQL Node2.
<p>&nbsp;</p>  

## CONFIGURE FILE SHARE WITNESS Quorum
In a Windows Failover Cluster, quorum determines the number of elements that must be online for the cluster to remain operational. For a 2-node cluster (like most SQL Server Always On AG setups in OCI or on-prem), adding a File Share Witness (FSW) is highly recommended to avoid split-brain scenarios and ensure high availability.
### Prerequisites
*	A third server (e.g., Domain Controller or utility VM) that both SQL nodes can access.
*	The SQL nodes and the witness server must be in the same Active Directory domain.
*	You must have Failover Clustering feature installed on SQL nodes.

For this tutorial am using DC as quorum server  
<img src="./images/AG83.png" alt="Description" width="600"/>
<img src="./images/AG84.png" alt="Description" width="500"/>
<img src="./images/AG85.png" alt="Description" width="400"/>
<img src="./images/AG86.png" alt="Description" width="500"/>
<img src="./images/AG87.png" alt="Description" width="500"/>
<img src="./images/AG88.png" alt="Description" width="500"/>

**Share Location** : \\OCISQLDC01\Quorum
<p>&nbsp;</p>
<img src="./images/AG89.png" alt="Description" width="500"/>
 
 Login to sql server  nodes and validate the access of share  
 Example: on sqlserver node1 try to access the share
 <img src="./images/AG90.png" alt="Description" width="500"/>
<p>&nbsp;</p>
Create a AGshare to sync the secoundry replica during inital setting of AG.
<p>&nbsp;</p>
 <img src="./images/AG91.png" alt="Description" width="500"/>

**AGShare Location** : \\OCISQLDC01\AGshare

## Install sql server 2019:

Before proceed with installation configure the necessary storage on all sql server nodes

Add block volumes for data, logs, temp for all the nodes
* Data volume 50gb
* Log volume 50gb
* Temp volume 50gb

For OCI Console under storage section select block volumes and create necessary block volumes.
 <img src="./images/AG92.png" alt="Description" width="500"/>

> Create storage under same AD i.e: AD-2 in over case where the vm is provisioned.  

 <img src="./images/AG93.png" alt="Description" width="500"/>
Make other option default and create block volume
<p>&nbsp;</p>
 <img src="./images/AG94.png" alt="Description" width="500"/>
Repeat same for log and tempfile block volumes
<p>&nbsp;</p>
 <img src="./images/AG95.png" alt="Description" width="500"/>

Now add the block volumes to sqlserver node1
<img src="./images/AG96.png" alt="Description" width="500"/>
<img src="./images/AG97.png" alt="Description" width="500"/>
<img src="./images/AG98.png" alt="Description" width="500"/>
Keep remaining options default.  
<img src="./images/AG99.png" alt="Description" width="500"/>
Attach other two block volumes using same steps:
<img src="./images/AG100.png" alt="Description" width="500"/>

Repeat same steps to node2 also First create block volumes.
<img src="./images/AG101.png" alt="Description" width="500"/>
Attach them to sqlsrv02
<img src="./images/AG102.png" alt="Description" width="500"/>

### Initialize disks:

<img src="./images/AG103.png" alt="Description" width="500"/>
<img src="./images/AG104.png" alt="Description" width="500"/>
<img src="./images/AG105.png" alt="Description" width="500"/>
<img src="./images/AG106.png" alt="Description" width="500"/>
<img src="./images/AG107.png" alt="Description" width="500"/>
<img src="./images/AG108.png" alt="Description" width="500"/>
<img src="./images/AG109.png" alt="Description" width="500"/>
<img src="./images/AG110.png" alt="Description" width="500"/>
<img src="./images/AG111.png" alt="Description" width="500"/>
<img src="./images/AG112.png" alt="Description" width="500"/>
Repeat same for logs and tempfiles:
<img src="./images/AG113.png" alt="Description" width="500"/>
Repeat same on sql server node2
<img src="./images/AG114.png" alt="Description" width="500"/>
<p>&nbsp;</p>  

[Download sql server 2019](https://www.microsoft.com/en-us/evalcenter/download-sql-server-2019)

<img src="./images/AG115.png" alt="Description" width="500"/>
<p>&nbsp;</p>  
<img src="./images/AG116.png" alt="Description" width="500"/>
<p>&nbsp;</p>  

### Installation steps
<img src="./images/AG117.png" alt="Description" width="500"/>
<p>&nbsp;</p>  
<img src="./images/AG118.png" alt="Description" width="500"/>
<p>&nbsp;</p>  
<img src="./images/AG119.png" alt="Description" width="500"/>
<p>&nbsp;</p>  
<img src="./images/AG120.png" alt="Description" width="500"/>
<p>&nbsp;</p>  
<img src="./images/AG121.png" alt="Description" width="500"/>
<p>&nbsp;</p>  
<img src="./images/AG122.png" alt="Description" width="500"/>
<p>&nbsp;</p>  
<img src="./images/AG123.png" alt="Description" width="500"/>
<p>&nbsp;</p>  
<img src="./images/AG124.png" alt="Description" width="500"/>
<p>&nbsp;</p>  
<img src="./images/AG125.png" alt="Description" width="500"/>
<p>&nbsp;</p>  
<img src="./images/AG126.png" alt="Description" width="500"/>
<p>&nbsp;</p>  
<img src="./images/AG127.png" alt="Description" width="500"/>
<p>&nbsp;</p>  
<img src="./images/AG128.png" alt="Description" width="500"/>
<p>&nbsp;</p>  
<img src="./images/AG129.png" alt="Description" width="500"/>
<p>&nbsp;</p>  
<img src="./images/AG130.png" alt="Description" width="500"/>
<p>&nbsp;</p>  
<img src="./images/AG131.png" alt="Description" width="500"/>
<p>&nbsp;</p>  
<img src="./images/AG132.png" alt="Description" width="500"/>
<p>&nbsp;</p>  
<img src="./images/AG133.png" alt="Description" width="500"/>
<p>&nbsp;</p>  
<img src="./images/AG134.png" alt="Description" width="500"/>
<p>&nbsp;</p>  
<img src="./images/AG135.png" alt="Description" width="500"/>
<p>&nbsp;</p>  
<img src="./images/AG136.png" alt="Description" width="500"/>
<p>&nbsp;</p>  
<img src="./images/AG137.png" alt="Description" width="500"/>
<p>&nbsp;</p>  
<img src="./images/AG138.png" alt="Description" width="500"/>
<p>&nbsp;</p>  
<img src="./images/AG139.png" alt="Description" width="500"/>
<p>&nbsp;</p>  
Proceed with next
<img src="./images/AG140.png" alt="Description" width="500"/>
<p>&nbsp;</p>  
Create the Directory Structure at OS level.  
<img src="./images/AG141.png" alt="Description" width="500"/>
<img src="./images/AG142.png" alt="Description" width="500"/>
<img src="./images/AG143.png" alt="Description" width="500"/>
<img src="./images/AG144.png" alt="Description" width="500"/>
<img src="./images/AG145.png" alt="Description" width="500"/>
<img src="./images/AG146.png" alt="Description" width="500"/>
<img src="./images/AG147.png" alt="Description" width="500"/>

Repeat same steps on node2.  

Install ssms on sqlserver optional  
Install ssms on jump server

<img src="./images/AG148.png" alt="Description" width="500"/>
<img src="./images/AG1_1.png" alt="Description" width="500"/>
Run the setupfile
<img src="./images/AG149.png" alt="Description" width="500"/>
<img src="./images/AG150.png" alt="Description" width="500"/>
<img src="./images/AG151.png" alt="Description" width="500"/>
<img src="./images/AG152.png" alt="Description" width="500"/>
<img src="./images/AG153.png" alt="Description" width="500"/>
<img src="./images/AG154.png" alt="Description" width="500"/>
<img src="./images/AG155.png" alt="Description" width="500"/>
<img src="./images/AG156.png" alt="Description" width="500"/>
<img src="./images/AG157.png" alt="Description" width="500"/>
<img src="./images/AG158.png" alt="Description" width="500"/>
<img src="./images/AG159.png" alt="Description" width="500"/>

## Download sample database

[Download sample database from here](https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0)
<p>&nbsp;</p>  
<img src="./images/AG160.png" alt="Description" width="500"/>
<img src="./images/AG161.png" alt="Description" width="500"/>
<img src="./images/AG162.png" alt="Description" width="500"/>
<img src="./images/AG163.png" alt="Description" width="500"/>
<img src="./images/AG164.png" alt="Description" width="500"/>
<img src="./images/AG165.png" alt="Description" width="500"/>
<img src="./images/AG166.png" alt="Description" width="500"/>

## Install WINDOWS SERVER FAILOVER CLUSTER
<img src="./images/AG167.png" alt="Description" width="500"/>
<img src="./images/AG168.png" alt="Description" width="500"/>
<img src="./images/AG169.png" alt="Description" width="500"/>
<img src="./images/AG170.png" alt="Description" width="500"/>
<img src="./images/AG171.png" alt="Description" width="500"/>
<img src="./images/AG172.png" alt="Description" width="500"/>
<img src="./images/AG173.png" alt="Description" width="500"/>
Repeat same steps on node2 to install windows failover cluster.
<p>&nbsp;</p>  
<img src="./images/AG174.png" alt="Description" width="500"/>
<img src="./images/AG175.png" alt="Description" width="500"/>
<img src="./images/AG176.png" alt="Description" width="500"/>
<img src="./images/AG177.png" alt="Description" width="500"/>
<img src="./images/AG178.png" alt="Description" width="500"/>
<img src="./images/AG179.png" alt="Description" width="500"/>
<img src="./images/AG180.png" alt="Description" width="500"/>
<img src="./images/AG181.png" alt="Description" width="500"/>
<img src="./images/AG182.png" alt="Description" width="500"/>
<img src="./images/AG183.png" alt="Description" width="500"/>
<img src="./images/AG184.png" alt="Description" width="500"/>
<img src="./images/AG185.png" alt="Description" width="500"/>
<img src="./images/AG186.png" alt="Description" width="500"/>
<img src="./images/AG187.png" alt="Description" width="500"/>
<img src="./images/AG188.png" alt="Description" width="500"/>
<img src="./images/AG189.png" alt="Description" width="500"/>
<img src="./images/AG190.png" alt="Description" width="500"/>

On node 2 open failover cluster  
<img src="./images/AG191.png" alt="Description" width="500"/>
<img src="./images/AG192.png" alt="Description" width="500"/>
<img src="./images/AG193.png" alt="Description" width="500"/>
<img src="./images/AG194.png" alt="Description" width="500"/>
<img src="./images/AG195.png" alt="Description" width="500"/>
<img src="./images/AG196.png" alt="Description" width="500"/>
<img src="./images/AG197.png" alt="Description" width="500"/>
<img src="./images/AG198.png" alt="Description" width="500"/>
<img src="./images/AG199.png" alt="Description" width="500"/>

Notice that the status of the cluster is **Offline in Cluster Core Resources** section. Expand the resources and find the cluster IP addresses not yet configured. We will do it in a few steps from now.

<img src="./images/AG200.png" alt="Description" width="500"/>

We will associate the IPs created  to the cluster. This will bring the cluster up and make it operational. On the **Failover Cluster Manager**, expand the **Cluster Core Resources** and right-click on the IP address with **Failed** status and then click **Properties**.

<img src="./images/AG201.png" alt="Description" width="500"/>
<img src="./images/AG202.png" alt="Description" width="500"/>
<img src="./images/AG203.png" alt="Description" width="500"/>
<img src="./images/AG204.png" alt="Description" width="500"/>

### Grant permissions to the Cluster Domain Computer Object
<img src="./images/AG205.png" alt="Description" width="500"/>
<img src="./images/AG206.png" alt="Description" width="500"/>
<img src="./images/AG207.png" alt="Description" width="500"/>
<img src="./images/AG208.png" alt="Description" width="500"/>
<img src="./images/AG209.png" alt="Description" width="500"/>
<img src="./images/AG210.png" alt="Description" width="500"/>
<img src="./images/AG211.png" alt="Description" width="500"/>
<img src="./images/AG212.png" alt="Description" width="500"/>
<img src="./images/AG213.png" alt="Description" width="500"/>

## Enable always on  high availability feature 
<img src="./images/AG214.png" alt="Description" width="500"/>

Select  SQL Server 2019 Configuration Manger

<img src="./images/AG215.png" alt="Description" width="500"/>
<img src="./images/AG216.png" alt="Description" width="500"/>
<img src="./images/AG217.png" alt="Description" width="500"/>

Restart 

<img src="./images/AG218.png" alt="Description" width="500"/>

Repeat same steps on all the nodes  
Modify the recovery model to Full
<img src="./images/AG219.png" alt="Description" width="500"/>
<img src="./images/AG220.png" alt="Description" width="500"/>

Take backup of database on primary replica
<img src="./images/AG221.png" alt="Description" width="500"/>
<img src="./images/AG222.png" alt="Description" width="500"/>
<img src="./images/AG223.png" alt="Description" width="500"/>
<img src="./images/AG224.png" alt="Description" width="500"/>
<img src="./images/AG225.png" alt="Description" width="500"/>
<img src="./images/AG226.png" alt="Description" width="500"/>
<img src="./images/AG227.png" alt="Description" width="500"/>
<img src="./images/AG228.png" alt="Description" width="500"/>
<img src="./images/AG229.png" alt="Description" width="500"/>
<img src="./images/AG230.png" alt="Description" width="500"/>
<img src="./images/AG231.png" alt="Description" width="500"/>
<img src="./images/AG232.png" alt="Description" width="500"/>
<img src="./images/AG233.png" alt="Description" width="500"/>
<img src="./images/AG234.png" alt="Description" width="500"/>
<img src="./images/AG235.png" alt="Description" width="500"/>
<img src="./images/AG236.png" alt="Description" width="500"/>
<img src="./images/AG237.png" alt="Description" width="500"/>
<img src="./images/AG238.png" alt="Description" width="500"/>
<img src="./images/AG239.png" alt="Description" width="500"/>
<img src="./images/AG240.png" alt="Description" width="500"/>
<img src="./images/AG241.png" alt="Description" width="500"/>
<img src="./images/AG242.png" alt="Description" width="500"/>
<img src="./images/AG243.png" alt="Description" width="500"/>
<img src="./images/AG244.png" alt="Description" width="500"/>
<img src="./images/AG245.png" alt="Description" width="500"/>


## Enable always on  high availability feature 
<img src="./images/AG246.png" alt="Description" width="500"/>
<img src="./images/AG247.png" alt="Description" width="500"/>
<img src="./images/AG248.png" alt="Description" width="500"/>
<img src="./images/AG249.png" alt="Description" width="500"/>

Restart sql server
<img src="./images/AG250.png" alt="Description" width="500"/>
<img src="./images/AG251.png" alt="Description" width="500"/>
<img src="./images/AG252.png" alt="Description" width="500"/>
<img src="./images/AG253.png" alt="Description" width="500"/>
<img src="./images/AG254.png" alt="Description" width="500"/>
<img src="./images/AG255.png" alt="Description" width="500"/>
<img src="./images/AG256.png" alt="Description" width="500"/>
<img src="./images/AG257.png" alt="Description" width="500"/>
<img src="./images/AG258.png" alt="Description" width="500"/>
<img src="./images/AG259.png" alt="Description" width="500"/>
<img src="./images/AG260.png" alt="Description" width="500"/>
<img src="./images/AG261.png" alt="Description" width="500"/>
<img src="./images/AG262.png" alt="Description" width="500"/>
<img src="./images/AG263.png" alt="Description" width="500"/>
<img src="./images/AG264.png" alt="Description" width="500"/>
<img src="./images/AG265.png" alt="Description" width="500"/>
<img src="./images/AG266.png" alt="Description" width="500"/>
<img src="./images/AG267.png" alt="Description" width="500"/>
<img src="./images/AG268.png" alt="Description" width="500"/>
<img src="./images/AG269.png" alt="Description" width="500"/>
<img src="./images/AG270.png" alt="Description" width="500"/>
<img src="./images/AG271.png" alt="Description" width="500"/>
<img src="./images/AG272.png" alt="Description" width="500"/>
<img src="./images/AG273.png" alt="Description" width="500"/>
<img src="./images/AG274.png" alt="Description" width="500"/>

## Conclusion
Setting up SQL Server 2019 Always On Availability Groups on Oracle Cloud Infrastructure ensures that your databases are highly available, fault-tolerant, and ready for mission-critical workloads. With native support for multi-subnet architectures and integrated cloud networking, OCI is a strong foundation for SQL Server HA/DR architectures.