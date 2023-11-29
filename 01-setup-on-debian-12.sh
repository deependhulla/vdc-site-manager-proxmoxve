#!/bin/sh

# for Debian 12
## set to India IST timezone -- You can dissable it if needed
timedatectl set-timezone 'Asia/Kolkata'
dpkg-reconfigure -f noninteractive tzdata


export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i -e 's/en_IN UTF-8/# en_IN UTF-8/' /etc/locale.gen
locale-gen en_US en_US.UTF-8
echo "LANG=en_US.UTF-8" > /etc/environment
echo "LC_ALL=en_US.UTF-8" >> /etc/environment

##disable ipv6 as most time not required
sysctl -w net.ipv6.conf.all.disable_ipv6=1 1>/dev/null
sysctl -w net.ipv6.conf.default.disable_ipv6=1 1>/dev/null

## backup existing repo by copy just for safety
mkdir -p /opt/old-config-backup/ 2>/dev/null
/bin/cp -pR /etc/apt/sources.list /opt/old-config-backup/old-sources.list-`date +%s`
echo "" >  /etc/apt/sources.list

echo "deb http://deb.debian.org/debian/ bookworm main non-free-firmware contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://deb.debian.org/debian/ bookworm main non-free-firmware contrib non-free" >> /etc/apt/sources.list
echo "deb http://security.debian.org/debian-security bookworm-security main non-free-firmware contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://security.debian.org/debian-security bookworm-security main non-free-firmware contrib non-free" >> /etc/apt/sources.list
echo "deb http://deb.debian.org/debian/ bookworm-updates main non-free-firmware contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://deb.debian.org/debian/ bookworm-updates main non-free-firmware contrib non-free" >> /etc/apt/sources.list

apt update
apt -y upgrade

CFG_HOSTNAME_FQDN=`hostname -f`
echo "postfix postfix/main_mailer_type select Internet Site" | debconf-set-selections
echo "postfix postfix/mailname string $CFG_HOSTNAME_FQDN" | debconf-set-selections
echo "iptables-persistent iptables-persistent/autosave_v4 boolean true" | debconf-set-selections
echo "iptables-persistent iptables-persistent/autosave_v6 boolean true" | debconf-set-selections
DEBIAN_FRONTEND=noninteractive

apt -y install vim chrony openssh-server screen net-tools git mc postfix sendemail  \
sudo wget curl ethtool iptraf-ng traceroute telnet rsyslog software-properties-common \
dirmngr parted gdisk apt-transport-https lsb-release ca-certificates iputils-ping \
debconf-utils pwgen xfsprogs iftop htop multitail net-tools elinks pssh apache2 \
iptables-persistent build-essential gnupg2 zip rar unrar ftp php rsync unzip \
libimage-exiftool-perl php-pear poppler-utils tnef whois libauthen-pam-perl php-zip \
libio-pty-perl libnet-ssleay-perl lynx lynx-common perl-openssl-defaults mariadb-server \
libapache2-mod-php php-mysql php-cli php-common php-imap php-ldap php-xml tar \
php-curl php-mbstring php-zip php-apcu php-gd php-imagick imagemagick mcrypt \
memcached php-memcached php-bcmath dbconfig-common libapache2-mod-php php-intl \
php-mysql php-intl libdbd-mysql-perl certbot python3-certbot-apache automysqlbackup \
php-mailparse perl-doc mysqltuner catdoc imagemagick tesseract-ocr tesseract-ocr-eng \
poppler-utils exiv2 libnet-dns-perl libmailtools-perl php-mail-mime \
libjson-perl libjson-pp-perl xapian-tools recoll libdatetime-format-mail-perl  \

systemctl restart chrony
echo > /var/log/mail.log

a2enmod actions > /dev/null 2>&1
a2enmod proxy_fcgi > /dev/null 2>&1
a2enmod fcgid > /dev/null 2>&1
a2enmod alias > /dev/null 2>&1
a2enmod suexec > /dev/null 2>&1
a2enmod rewrite > /dev/null 2>&1
a2enmod ssl > /dev/null 2>&1
a2enmod actions > /dev/null 2>&1
a2enmod include > /dev/null 2>&1
a2enmod dav_fs > /dev/null 2>&1
a2enmod dav > /dev/null 2>&1
a2enmod auth_digest > /dev/null 2>&1
a2enmod cgi > /dev/null 2>&1
a2enmod headers > /dev/null 2>&1
a2enmod proxy_http > /dev/null 2>&1
systemctl stop apache2

## centos like bash ..for all inteactive 
echo "" >> /etc/bash.bashrc
echo "alias cp='cp -i'" >> /etc/bash.bashrc
echo "alias l.='ls -d .* --color=auto'" >> /etc/bash.bashrc
echo "alias ll='ls -l --color=auto'" >> /etc/bash.bashrc
echo "alias ls='ls --color=auto'" >> /etc/bash.bashrc
echo "alias mv='mv -i'" >> /etc/bash.bashrc
echo "alias rm='rm -i'" >> /etc/bash.bashrc
echo "export EDITOR=vi" >> /etc/bash.bashrc
echo "export HISTTIMEFORMAT=\"%y-%m-%d %T \" " >> /etc/bash.bashrc

##echo "PS1='\[\033[01;32m\]\u@$(hostname -f) \D{%Y-%m-%d-%H:%M:%S}:\w\$\[\033[00m\] '" >> /etc/bash.bashrc
echo "PS1='\[\e[1;32m\]\u@\h\[\e[m\]:\[\e[1;34m\]\w\[\e[m\]:\[\e[1;31m\]\$\[\e[m\] '" >> /etc/bash.bashrc
export EDITOR=vi
export HISTTIMEFORMAT="%y-%m-%d %T "
#PS1="[\u@\h \D{%Y-%m-%d-%H:%M:%S}]#"
#PS1='\[\033[01;32m\]\u@\H:\w\$\[\033[00m\] '
#PS1='\[\033[01;32m\]\u@$(hostname -f):\w\$\[\033[00m\] '
#PS1='\[\033[01;32m\]\u@$(hostname -f) \D{%Y-%m-%d-%H:%M:%S}:\w\$\[\033[00m\] '


#echo "export LC_CTYPE=en_US.UTF-8" >> /etc/bash.bashrc
#echo "export LC_ALL=en_US.UTF-8" >> /etc/bash.bashrc

#Setting rc.local, perl, bash, vim basic default config and IST time sync NTP

/bin/cp -pR /etc/rc.local /opt/old-config-backup/old-rc.local-`date +%s` 2>/dev/null
## create with default IPV6 disabled
touch /etc/rc.local
printf '%s\n' '#!/bin/bash'  | tee -a /etc/rc.local 1>/dev/null
echo "sysctl -w net.ipv6.conf.all.disable_ipv6=1" >>/etc/rc.local
echo "sysctl -w net.ipv6.conf.default.disable_ipv6=1" >> /etc/rc.local
echo "sysctl vm.swappiness=0" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local
chmod 755 /etc/rc.local
## need like autoexe bat on startup
echo "[Unit]" > /etc/systemd/system/rc-local.service
echo " Description=/etc/rc.local Compatibility" >> /etc/systemd/system/rc-local.service
echo " ConditionPathExists=/etc/rc.local" >> /etc/systemd/system/rc-local.service
echo "" >> /etc/systemd/system/rc-local.service
echo "[Service]" >> /etc/systemd/system/rc-local.service
echo " Type=forking" >> /etc/systemd/system/rc-local.service
echo " ExecStart=/etc/rc.local start" >> /etc/systemd/system/rc-local.service
echo " TimeoutSec=0" >> /etc/systemd/system/rc-local.service
echo " StandardOutput=tty" >> /etc/systemd/system/rc-local.service
echo " RemainAfterExit=yes" >> /etc/systemd/system/rc-local.service
## featured Removed
###echo " SysVStartPriority=99" >> /etc/systemd/system/rc-local.service
echo "" >> /etc/systemd/system/rc-local.service
echo "[Install]" >> /etc/systemd/system/rc-local.service
echo " WantedBy=multi-user.target" >> /etc/systemd/system/rc-local.service

systemctl enable rc-local
systemctl start rc-local

# download latest MyslqTunner--useful when perforance tuning needed
#https://github.com/major/MySQLTuner-perl/blob/master/INTERNALS.md

### changing timezone to Asia Kolkata
sed -i "s/;date.timezone =/date\.timezone \= \'Asia\/Kolkata\'/" /etc/php/8.2/apache2/php.ini
sed -i "s/;date.timezone =/date\.timezone \= \'Asia\/Kolkata\'/" /etc/php/8.2/cli/php.ini
#sed -i "s/;date.timezone =/date\.timezone \= \'Asia\/Kolkata\'/" /etc/php/8.2/fpm/php.ini
##disable error
sed -i "s/error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT/error_reporting = E_ERROR/" /etc/php/8.2/cli/php.ini
#sed -i "s/error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT/error_reporting = E_ERROR/" /etc/php/8.2/fpm/php.ini
sed -i "s/error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT/error_reporting = E_ERROR/" /etc/php/8.2/apache2/php.ini

sed -i "s/memory_limit = 128M/memory_limit = 512M/" /etc/php/8.2/apache2/php.ini
sed -i "s/post_max_size = 100M/post_max_size = 800M/" /etc/php/8.2/apache2/php.ini
sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 100M/" /etc/php/8.2/apache2/php.ini

##disable this program as not needed
systemctl stop ModemManager 1>/dev/null 2>/dev/null
systemctl disable ModemManager 1>/dev/null 2>/dev/null
systemctl stop wpa_supplicant 1>/dev/null 2>/dev/null
systemctl disable wpa_supplicant 1>/dev/null 2>/dev/null

sed -i "s/#RateLimitIntervalSec=30s/RateLimitIntervalSec=0/"  /etc/systemd/journald.conf
sed -i "s/#RateLimitBurst=10000/RateLimitBurst=0/"  /etc/systemd/journald.conf
systemctl restart systemd-journald

## make cpan auto yes for pre-requist modules of perl
(echo y;echo o conf prerequisites_policy follow;echo o conf commit)|cpan 1>/dev/null

#Disable vim automatic visual mode using mouse
echo "\"set mouse=a/g" >  ~/.vimrc
echo "syntax on" >> ~/.vimrc
##  for  other new users
echo "\"set mouse=a/g" >  /etc/skel/.vimrc
echo "syntax on" >> /etc/skel/.vimrc

##Comment this if you do not want root login via ssh activated using port 7722
sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config
#sed -i "s/#Port 22/Port 7722/g" /etc/ssh/sshd_config
systemctl restart ssh

##### configure proper timezone
#dpkg-reconfigure tzdata
##### configure locale proper
#dpkg-reconfigure locales
## set India IST time.
#/bin/rm -rf /etc/localtime
#/bin/ln -vs /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
#### for adding firmware realtek driver
#apt-get install firmware-linux-nonfree
#apt-get install firmware-realtek
#update-initramfs -u
## only if VM notfor LXC
## for proxmox/kvm better preformance
#apt-get -y install qemu-guest-agent
## if on Consle need Mouse to use for copy paste use gpm
#apt-get install gpm
#google dns: [2001:4860:4860::8888]
#cloudflare dns: [2606:4700:4700::1111]

/bin/cp -p files/extra-files/etc-config-backup.sh /bin/
/bin/cp -p files/extra-files/pfHandle /bin/
chown -R www-data:www-data /var/www/html
## safe backup
files/extra-files/etc-config-backup.sh

## copy fw default settings
/bin/cp -pR files/rootdir/* /
systemctl restart unbound 1>/dev/null 2>/dev/null
systemctl restart  rsyslog
systemctl restart  apache2
systemctl restart  cron
systemctl restart  mariadb
echo `hostname -f` > /etc/mailname

hostname -f
ping `hostname -f` -c 2


