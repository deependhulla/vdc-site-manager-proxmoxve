#!/bin/bash


mkdir -p /etc/webmin/vdcsitemanager/siteinfo


ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -N ""

### Now login one time to all site1 PVE & sitePVE2 for autologin.

#ssh-copy-id root@site1
#ssh-copy-id root@site2

