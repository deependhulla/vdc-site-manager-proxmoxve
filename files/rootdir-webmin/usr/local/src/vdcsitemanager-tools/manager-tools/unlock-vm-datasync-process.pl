#!/usr/bin/perl


use strict;
use warnings;


my $checkvmid="";
$checkvmid=$ARGV[0];
if (defined $checkvmid) {
my $hlock="/var/vdcsitemanager/nodes-lock/".$checkvmid."-datasync.lock";

unlink($hlock);
print "VMID $checkvmid UNLOCKED\n";
## working on VMID
}
else
{
print " Please provide VM ID : Example 706\n";
}
