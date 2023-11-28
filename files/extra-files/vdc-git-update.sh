#!/bin/bash
cd /opt/vdc-site-manager-proxmoxve
/bin/cp -pRv /usr/share/webmin/vdcsitemanager  /opt/vdc-site-manager-proxmoxve/files/rootdir-webmin/usr/share/webmin/
/bin/cp -pRv /usr/local/src/vdcsitemanager-tools  /opt/vdc-site-manager-proxmoxve/files/rootdir-webmin/usr/local/src/

gitdone.sh

cd -
