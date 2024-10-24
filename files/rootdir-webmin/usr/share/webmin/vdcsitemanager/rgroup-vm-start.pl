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


my $checkvmid="";
$checkvmid=$ARGV[0];
if (defined $checkvmid) {
## working on VMID
use Scalar::Util qw(looks_like_number);
if (looks_like_number($checkvmid)) {
#        print "Argument is numeric.\n";
    } else {
        print "VMID  is not numeric.\n";
exit;
    }

}
else
{
print " Please provide VM ID : Example 706\n";
exit;
}


print "Started for VM $checkvmid \n";

my $dmessage = "rgroup-vm-start.pl triggered for VM $checkvmid to check if not transfering ...start it.";
system("logger", "-p", "user.info", $dmessage);



my $cmdstart='/usr/local/src/vdcsitemanager-tools/manager-tools/start-datasync-per-vmid.pl '.$checkvmid;

#print "<hr> $cmdstart  <hr>";
my $lockvm=0;
my $hlock="/var/vdcsitemanager/nodes-lock/".$checkvmid."-datasync.lock";
if (-e $hlock) {
$lockvm=1;
print "vm lock";
}
if($lockvm==0)
{
print "start data";
my $cmdxout=`$cmdstart`;
my $dmessage = "rgroup-vm-start.pl triggered for VM $checkvmid Data Transfer Started";
system("logger", "-p", "user.info", $dmessage);

}

print "\n\n";
