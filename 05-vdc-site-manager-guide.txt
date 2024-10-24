
# Guide for VDC First Time Setup

## Important Setup Requirements
- Ensure both cluster names are different when created; otherwise, it will create problems.
- Ensure the Ceph storage name is the SAME on both clusters, and that both are configured for either replication or erasure coding.

## Configuration Examples

### For Replication
```bash
echo "starceph" > /etc/webmin/vdcsitemanager/ceph-storage-name
echo "0" > /etc/webmin/vdcsitemanager/ceph-erasure-code
```

### For Erasure Coding
```bash
echo "cephdata" > /etc/webmin/vdcsitemanager/ceph-storage-name
echo "1" > /etc/webmin/vdcsitemanager/ceph-erasure-code
```

## SSH Auto Login Setup
- Set up one-time SSH auto-login to all Site1 PVE (DC)and Site2 PVE (DR) for automatic login between them and from the VDC VM. This is essential for inter-process communication and to trigger root processes for data synchronization.

### Example Command
```bash
ssh-copy-id root@192.168.30.112
```
- Test the SSH connection:
```bash
ssh root@192.168.30.112
```
It should log in automatically.

## Login Requirements
- Login from all PVE servers of Site1 Cluster to each server of Site2 Cluster PVE.
- Login from all PVE servers of Site2 Cluster to each server of Site1 Cluster PVE.
- Login from VDC VM to each server of Site1 Cluster PVE.
- Login from VDC VM to each server of Site2 Cluster PVE.

### Example Commands
```bash
ssh-copy-id root@site1
ssh-copy-id root@site2
```

## Site Configuration for VDC
1. Navigate to the folder on the VDC VM:
   ```bash
   cd /usr/local/src/vdcsitemanager-tools/manager-tools/
   ```
2. Create the site configuration for VDC to manage all nodes via Webmin (this is a one-time activity).

### For Site1 (any one IP)
```bash
php onetime-site-build-for-manager.php 1 192.168.30.113
```

### For Site2 (any one IP)
```bash
php onetime-site-build-for-manager.php 2 192.168.40.144
```

## Webmin Login
- Now, log in to Webmin of VDC (example: 192.168.40.30):
  - **URL**: https://192.168.40.30:833
  - **Username**: manager
  - **Password**: (found in) /usr/local/src/manager-vdcmanager-pass

