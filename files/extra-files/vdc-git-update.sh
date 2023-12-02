#!/bin/bash
cd /opt/vdc-site-manager-proxmoxve
rsync -av /usr/share/webmin/vdcsitemanager  /opt/vdc-site-manager-proxmoxve/files/rootdir-webmin/usr/share/webmin/
rsync -av /usr/local/src/vdcsitemanager-tools  /opt/vdc-site-manager-proxmoxve/files/rootdir-webmin/usr/local/src/

gitdone.sh

cd -
