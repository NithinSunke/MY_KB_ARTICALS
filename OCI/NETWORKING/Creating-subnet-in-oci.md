# Understanding Subnets in Oracle Cloud Infrastructure (OCI)

## Introduction:
When building a cloud network in Oracle Cloud Infrastructure (OCI), subnets are fundamental building blocks. They allow you to segment your Virtual Cloud Network (VCN), isolate resources, and control traffic — enabling secure and scalable architecture.

This Blog dives into what subnets are, the types of subnets available in OCI, and when to use them.

## What is a Subnet?
A subnet (sub-network) is a logical subdivision of an IP network. In OCI, subnets are used to divide a VCN’s IP address space into smaller chunks, each acting like a small network where resources like compute instances, databases, and load balancers can be deployed.

**Each subnet in OCI**:
* Has its own CIDR block (a subset of the parent VCN)
* Is tied to a specific Availability Domain (AD) or Regional
* Can be public or private
* Has its own routing rules and security rules

**Components of a Subnet**
When you create a subnet, you define or associate the following:
*  **CIDR block**: Defines the subnet’s IP range (e.g., 172.16.1.0/24)
*  **Route Table**: Controls traffic leaving the subnet
*  **Security List or NSG**: Acts like a firewall for ingress/egress rules
*  **DHCP Options**: Controls domain name settings


## Types of Subnets in OCI
OCI offers two main types of subnets based on their accessibility:

### 1. Public Subnet
A public subnet is a subnet whose resources can have public IP addresses and directly access the internet (via Internet Gateway).

**Main characteristics**:
* Allows instances to have public IPs
* Usually used for bastion hosts, load balancers, and public-facing applications
* Must have a route to the Internet Gateway
* Security lists must allow appropriate ingress/egress

**Example use case**:
> A bastion server for SSH access or a web server open to the public internet.

### 2. Private Subnet
A private subnet hosts resources that do not have public IPs and are not accessible from the internet directly.

**Main characteristics**:
* No public IPs for instances
* Internet access (if needed) is only via NAT Gateway
* More secure; used for backend or sensitive services
* Commonly used for databases, app servers, or internal tools

**Example use case** :
> An Oracle Database server or an internal application not exposed to the public.

## Regional vs AD-Specific Subnets
OCI also allows subnets to be created in two scopes:
### Regional Subnet (Recommended)
* Spans all Availability Domains (ADs) in a region
* Offers greater flexibility, especially in multi-AD deployments
* Now the default and recommended option in OCI

### AD-Specific Subnet
* Tied to a single Availability Domain
* Useful for legacy setups or AD-specific deployments
* Limited in flexibility and not ideal for failover/resiliency

## Summary
Subnets in OCI help you organize, secure, and scale your cloud resources. Choosing the right type of subnet (public vs private) is critical to ensuring that your infrastructure is both functional and secure.

|Type |	Internet Access|	Public IPs |	Use Cases |
|:----|:----------------|:-------------|:--------------|
|Public Subnet|	Yes (via Internet Gateway)|	Allowed	|Bastion host, public web apps|
|Private Subnet| 	No direct access (use NAT)| 	Not allowed|	Databases, app servers, backend services|

