## to start ATP database
oci db autonomous-database start --autonomous-database-id ocid1.autonomousdatabase.oc1.me-jeddah-1.anvgkljrzjgvoqyatnez7svdczduv3m3mvnzztdetqdgdnxgafl7tgh66k3a

## to start vm
**jump box**
```
 oci compute instance action --instance-id ocid1.instance.oc1.me-jeddah-1.anvgkljrzjgvoqycabavx24q4x4cb2lwfiku4jd7bbtfk35mmjtoyaj2n4ia --action START --wait-for-state RUNNING
```

**sql server (mssqlserver01)**
```
 oci compute instance action --instance-id ocid1.instance.oc1.me-jeddah-1.anvgkljrzjgvoqyckwhdxtfgffefbxjqrfgpx5a63clmc364yaa4xuuzbxsa --action START --wait-for-state RUNNING
```  
**sql server (mssqlserver02)**
```
 oci compute instance action --instance-id ocid1.instance.oc1.me-jeddah-1.anvgkljrzjgvoqycijo3th7yxmuu2oiafiuw2py7h6ty2jlexauavehf4sza --action START --wait-for-state RUNNING
```  
