#!/bin/bash

## old format
##echo "#deb https://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list 
##wget -c https://download.webmin.com/jcameron-key.asc -O /etc/apt/trusted.gpg.d/webmin-jcameron-key.asc
## New Format
echo "deb https://download.webmin.com/download/newkey/repository stable contrib" > /etc/apt/sources.list.d/webmin.list 
wget -c https://download.webmin.com/developers-key.asc -O /etc/apt/trusted.gpg.d/developers-key.asc
apt-get update
apt-get -y install webmin
#apt-get -y install webmin --install-recommends

## copies all program of VDC
/bin/cp -pR files/rootdir-webmin/* /
mkdir -p /etc/webmin/vdcsitemanager/siteinfo
mkdir /etc/webmin/vdcsitemanager/data-sync-vm-config
mkdir -p /var/log/vdcsitemanager-logs
## ssh key-gen
ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -N ""

## change port from 10000 to 8383
sed -i "s/10000/8383/g" /etc/webmin/miniserv.conf
/etc/init.d/webmin restart 2>/dev/null

echo "manager:xxxxxjpihs:0" >> /etc/webmin/miniserv.users
echo "manager:vdcsitemanager custom" >>  /etc/webmin/webmin.acl

cd /usr/share/webmin
WEPASSVPOP=`pwgen -c -1 8`
echo $WEPASSVPOP > /usr/local/src/manager-vdcmanager-pass
/usr/share/webmin/changepass.pl  /etc/webmin manager `cat /usr/local/src/manager-vdcmanager-pass`
cd -

echo "Webmin run https on port 8383 use Firefox Browser to Access not Google Chrome as SSL Certifcate is not applied yet"; 
