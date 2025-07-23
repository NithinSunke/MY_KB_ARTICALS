# Import vmdk to LVM-thin storage (e.g., local-lvm) in Proxmox VE

If you're using LVM-thin storage (e.g., local-lvm) in Proxmox VE, you cannot directly place .qcow2 files in the storage path like you can with local (directory) storage. Instead, you must convert the image to raw and import it into the LVM-thin volume.


##  Step-by-Step for LVM-thin (local-lvm) Storage
Step 1: Convert .vmdk → .raw
After extracting your .box file:

```
qemu-img convert -f vmdk -O raw box-disk1.vmdk oel7.raw
```

## Step 2: Create a Blank VM in Proxmox
In the Proxmox Web UI, go to Create VM
Give it a name (e.g., OEL7)
Skip ISO image for now (we're importing a disk)
On the Hard Disk step:
Storage: local-lvm
Disk size: small (you’ll replace it)
Bus/Device: VirtIO or SCSI
Complete the VM creation
Note the VM ID (e.g., 100)

## Step 3: Remove the Placeholder Disk
In terminal:
```
qm disk unlink 100 scsi0
qm set 100 --delete scsi0
```
Or do this in GUI → VM → Hardware → Remove the disk.

Step 4: Import the .raw Disk into LVM-Thin
```
# Import raw disk into local-lvm storage for VM ID 100
qm importdisk 100 oel7.raw local-lvm
```
This will output something like
```
Successfully imported disk as 'vm-100-disk-0'
```

## Step 5: Attach the Imported Disk to the VM
```
qm set 105 --scsihw virtio-scsi-pci --scsi0 vmdata:vm-105-disk-0
```

Set the boot order:
```
qm set 105 --boot order=scsi0
```

Or use the Web UI → Hardware → Add → Hard Disk → Use Existing Volume.


## Step 6: Start the VM
```
qm start 100
```




