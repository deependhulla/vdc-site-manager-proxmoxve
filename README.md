# Virtual Data Center - Site Manager for Proxmox VE 8.x with Ceph Cluster

This tool is designed to synchronize and replicate data between two Proxmox VE clusters using Ceph in an incremental, differential manner.

## Key Features

- **Cluster Setup:**
  - Supports a primary data center (DC) cluster with 6 nodes using Ceph for replication or erasure coding as storage.
  - A similar setup is used for the far Disaster Recovery (DR) site, with 6 nodes using Ceph replication or erasure coding.
  
- **VM Synchronization:**
  - Allows virtual machines (VMs) to be synchronized from the DC cluster to the DR cluster over a secure, dedicated line or VPN.
  - Utilizes Ceph's RBD export with snapshots for backend data handling.
  - Supports synchronization based on resource groups, enabling efficient management of multiple VMs.
  - Syncing can be scheduled to automate the process, ensuring regular updates without manual intervention.
  - VMs remain visible and active on one cluster at a time, though the drive image is maintained on the other cluster for differential snapshot restoration.

- **Disaster Recovery (DR) Readiness:**
  - Uses VxLAN to facilitate seamless DR drills, enabling quick switching between the DC and DR locations.
  - Supports smooth transitions back from the DR site to the DC site after testing.

- **Scalability:**
  - Scale till 1000 VMs in a cluster.
  - Successfully tested with 10+ VMs and a 5TB storage environment.
  
- **Management Interface:**
  - Webmin is used as the frontend for managing the synchronization, with resource group-based controls to handle multiple VMs.
  
- **Additional Features:**
  - Supports export of the VM inventory list for easy tracking and reporting.

## Installation

1. Set up a VM with 100GB of Debian 12 at the DR location.
2. Follow scripts 01 to 04.
3. Refer to the details provided in the 05.txt file for additional instructions.

## Usage

- Log in as the Webmin manager or root user.
- Access the VDC Site Manager, which is designed to be self-explanatory.

