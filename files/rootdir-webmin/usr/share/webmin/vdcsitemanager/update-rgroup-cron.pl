#!/usr/bin/perl
##Updated : 24-Oct-2024
use strict;
use warnings;
use JSON::PP;

my $debugnow=0;
my $waitsec=10;
my $vdcip=`hostname -i`;
$vdcip=~ s/\n/""/eg;
$vdcip=~ s/\r/""/eg;
$vdcip=~ s/\t/""/eg;
$vdcip=~ s/\0/""/eg;
$vdcip=~ s/ /""/eg;

## means datasync on node 3
my $datasyncnodeid=1;
my $hs="";
my $hs1="";
my $hsend="";
my $hfire="";
my $hlog="";
my $hlogv="";
my $hlock="";
my $tonodeip='';
my $tonodename='';
my $fromnodeip='';
my $fromnodename='';
my $vmtype='';
my $uidx=time();



my $checkrgid="";
$checkrgid=$ARGV[0];
if (defined $checkrgid) {
## working on RGID
use Scalar::Util qw(looks_like_number);
if (looks_like_number($checkrgid)) {
#        print "Argument is numeric.\n";
    } else {
        print "RGID  is not numeric.\n";
exit;
    }

}
else
{
print " Please provide RG ID : Example 5\n";
exit;
}

my $folder_path='';
$folder_path='/var/vdcsitemanager/';if (!-d $folder_path) {if (mkdir $folder_path){}}
$folder_path='/var/vdcsitemanager/nodes-scripts/';if (!-d $folder_path) {if (mkdir $folder_path){}}
$folder_path='/var/vdcsitemanager/nodes-lock/';if (!-d $folder_path) {if (mkdir $folder_path){}}
$folder_path='/var/vdcsitemanager/nodes-logs/';if (!-d $folder_path) {if (mkdir $folder_path){}}
$folder_path='/var/vdcsitemanager/nodes-config-backup/';if (!-d $folder_path) {if (mkdir $folder_path){}}



my $newgroupidx=$checkrgid;
   
my @recgroup=();
my $ai=0;
my @vrows;
my $filelog = "/etc/webmin/vdcsitemanager/resource-group/activelist/".$newgroupidx."-rg-info.conf";

if(-e $filelog)
{
print "\n $filelog \n";
$recgroup[$ai]{'cronactive'}='';

open(OUTOAZ,"<$filelog");
while(<OUTOAZ>)
{
my $fline=$_;
$fline=~ s/\n/""/eg;
$fline=~ s/\r/""/eg;
$fline=~ s/\t/""/eg;
$fline=~ s/\0/""/eg;

my @l1=split("=",$fline);

if($l1[0] eq "CREATEDON"){ $recgroup[$ai]{'createdon'}=$l1[1];}
if($l1[0] eq "VMLIST"){ $recgroup[$ai]{'vmlist'}=$l1[1];
if(defined($l1[1]) && $l1[1] ne ""){@vrows = split(/,/, $l1[1]);}
}
if($l1[0] eq "GROUPNAME"){ $recgroup[$ai]{'groupname'}=$l1[1];}
if($l1[0] eq "SYNCACTIVE"){ $recgroup[$ai]{'cronactive'}=$l1[1];}
if($l1[0] eq "CRONTABCONFIG"){ $recgroup[$ai]{'crontime'}=$l1[1];}
if($l1[0] eq "EMAILUPDATES"){ $recgroup[$ai]{'emailupdates'}=$l1[1];}
print $_;
}
close(OUTOAZ);


my $filergcron = "/etc/cron.d/vdcsite-manager-rgcron-".$newgroupidx."-rg-cron";

print "\n $filergcron \n ";

if($recgroup[$ai]{'cronactive'} eq "ACTIVE")
{
print "\nMake file for cron \n";
open(OUTOAZS,">$filergcron");
print OUTOAZS "SHELL=/bin/sh\n";
print OUTOAZS "PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin\n";
print OUTOAZS "MAILTO=\"\"\n";
for(my $ri=0;$ri<@vrows;$ri++)
{
print OUTOAZS $recgroup[$ai]{'crontime'}." root /usr/share/webmin/vdcsitemanager/rgroup-vm-start.pl ".$vrows[$ri]."\n";
}
close(OUTOAZS);
}
else
{
open(OUTOAZS,">$filergcron");
print OUTOAZS "SHELL=/bin/sh\n";
print OUTOAZS "PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin\n";
print OUTOAZS "MAILTO=\"\"\n";
print OUTOAZS "#DISABLED";
close(OUTOAZS);
print "\nRemove from cron file the VM there\n";
}


### if file exist over
}
else
{
print "No RGID : $checkrgid \n";
}
## ocode over
