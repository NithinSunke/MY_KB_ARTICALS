# Understanding Virtual Network Interface Cards (VNICs) in Oracle Cloud Infrastructure (OCI)
## Introduction
In Oracle Cloud Infrastructure (OCI), Virtual Network Interface Cards (VNICs) are essential networking components that enable compute instances to connect to Virtual Cloud Networks (VCNs). A VNIC acts as a bridge between the VM and the subnet it is attached to. Whether you're deploying a single-instance workload or a multi-tier application, a strong understanding of VNICs — including primary and secondary IPs, ephemeral vs reserved IP addresses, and limitations — is crucial for designing resilient and scalable cloud architectures.

## What is a VNIC?
A VNIC in OCI represents a network adapter attached to a compute instance. Each VNIC is associated with a specific subnet, private IP address, and optionally, a public IP address.

When you launch a compute instance in OCI:
*   A primary VNIC is automatically created and attached to the instance.
*   Each VNIC must be attached to exactly one subnet.
*   Each VNIC supports multiple private IPs (1 primary, multiple secondary).

## Primary vs Secondary Private IP Addresses
### Primary Private IP
*   Automatically assigned when a VNIC is created.
*   Used by the OS as the default IP for routing and communication.
*   Cannot be removed from the VNIC.
*   Must be unique within the subnet.
   
### Secondary Private IPs
*   Additional private IPs you can manually assign to a VNIC.
*   Useful for:
    *   Hosting multiple services or websites.
    *   Load balancer configurations.
    *   Application-level failover or VIPs (virtual IPs).
*   Can be moved between VNICs (even across instances in the same subnet).
*   Must also be unique within the subnet.

## Moving IP Addresses for High Availability
Secondary IPs can be reassigned between VNICs or instances. This is especially useful for:
*   Failover between active-passive instances.
*   Manually implementing high availability for services like databases.

## Public IPs in OCI
There are two types of public IP addresses you can assign to VNICs:
### Ephemeral Public IP
*   Automatically assigned when you create a VM with public internet access.
*   Attached to the primary private IP by default.
*   Released when the instance or VNIC is terminated.
*   **Use case**: Short-lived workloads or testing environments.

### Reserved Public IP
*   Manually created and assigned.
*   Persists beyond the lifecycle of the instance.
*   Can be moved to other instances or VNICs.
*   Best for production workloads, static endpoints, or DNS mapping.

> There is no charge associated with reserved public ip's even if they are  unassociated.

## Limitations and Quotas
|Resource	|Limit (Default) |	Notes |
|:----------|:---------------|:-------|
|Primary IPs|	1 per VNIC	|Cannot be changed
|Secondary IPs|	32 per VNIC (varies by shape)|	Can be moved
|VNICs per Instance |	Depends on shape (e.g., 2 for VM.Standard2.1)|	Includes primary VNIC
|Public IPs	|Quota-limited |	Separate quotas for reserved and ephemeral
|Public IP per private IP|	1:1|	One public IP per private IP

> Check your limits via OCI Console → Governance → Limits, Quotas, and Usage.

## Use Cases
|Scenario|	Solution
|:--------|:--------
|Host multiple services	|Assign secondary private IPs to one VNIC
|Implement VIP failover |	Use secondary private IP and move it between VMs
|Retain external identity after VM deletion	| Use reserved public IP
|Secure internal communication	|Use only private IPs and avoid public exposure
|Network segmentation	|Attach multiple VNICs to access different subnets or security lists

## Best Practices
*   Use private IPs for backend services; assign public IPs only when necessary.
*   Use reserved public IPs for stable DNS and long-lived endpoints.
*   Use secondary private IPs for flexible failover strategies.
*   Monitor and manage your IP quotas and usage in the tenancy.



## Conclusion
Understanding how VNICs, IPs, and networking features work in OCI is key to building secure, scalable, and resilient infrastructure. Primary and secondary IPs allow you to create multi-service nodes and plan for failover. Ephemeral and reserved public IPs give you the flexibility to match both dynamic and static workloads. By combining these features wisely, you can achieve both performance and operational agility in your cloud network design.

