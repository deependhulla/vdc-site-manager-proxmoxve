#!/usr/bin/perl

use strict;
use warnings;
use JSON;
use Data::Dumper;

my $rawdatastore='/opt/generate-proxmox-inventory-data';

if (-d $rawdatastore) {
} else {
    if (mkdir $rawdatastore) {
    } else {
        print "Error creating directory '$rawdatastore': $!\n";
	exit;
    }
}
#################################
sub vm_config_parser {
  my ($config_data) = @_;    my @sections = split(/\n\n/, $config_data);
  my @parsed_data;    foreach my $section (@sections) {
  my %section_data;     my @lines = split(/\n/, $section);
 foreach my $line (@lines) {  my ($key, $value) = split(/:\s*/, $line, 2);
 $section_data{$key} = defined $value ? $value : '';  }
 push @parsed_data, \%section_data; } return \@parsed_data;
}
#################################
my $pvenodesfile="/etc/pve/.members";
my $pvenodejson="";
open(FH, '<', $pvenodesfile);
while(<FH>){
$pvenodejson=$pvenodejson.$_;
}
close(FH);
my $nodelistarray = decode_json($pvenodejson);
my $nodelist = $nodelistarray->{'nodelist'};
#my $ni=0;
#foreach my $nodename (keys %$nodelist) {
#$ni++;
#    my $nodeid    = $nodelist->{$nodename}->{'id'};
#    my $nodeip    = $nodelist->{$nodename}->{'ip'};
#    print "SR: $ni - ";
#    print "ID: $nodeid - ";
#    print "Name: $nodename - ";
#    print "IP: $nodeip\n";
#}
#################################
my $vmlistfile="/etc/pve/.vmlist";
my $vmlistjson="";
open(FH, '<', $vmlistfile);
while(<FH>){
$vmlistjson=$vmlistjson.$_;
}
close(FH);
#"1","solid139","qemu-server","505","1","2","2048","32G",

print '"SR","NODE","VM-CT","VMID","VMNAME","SOCKETS","CORES","MEMORY","DISK0","DISK1","DISK2","DISK3","DISK4","DISK5","DISK6","DISK7","DISK8","DISK9","DISK10"';
print "\n";

print "\n";
my $vmlistarray = decode_json($vmlistjson);
my $vmidlist = $vmlistarray->{'ids'};
my $vmi=0;
my $vmdiskcount=0;
foreach my $vmid (keys %$vmidlist) {
$vmi++;
my $vmtype    = $vmidlist->{$vmid}->{'type'};
my $vmnode    = $vmidlist->{$vmid}->{'node'};
my $vmnodeip  =''; my $vmconfigfile='';
my $vmtypefolder=$vmtype;
if($vmtype eq "qemu"){$vmtypefolder='qemu-server';}
foreach my $nodename (keys %$nodelist) {
if($nodename eq $vmnode){ $vmnodeip    = $nodelist->{$nodename}->{'ip'};}}    
#/etc/pve/nodes/pve113/qemu-server/403.conf
my $vmline="";
$vmconfigfile="/etc/pve/nodes/".$vmnode."/".$vmtypefolder."/".$vmid.".conf";
    # Print the data in a table format
    #print "SR: $vmi - ";
    $vmline=$vmline."\"".$vmi."\",";
    $vmline=$vmline."\"".$vmnode."\",";
    $vmline=$vmline."\"".$vmtypefolder."\",";
    $vmline=$vmline."\"".$vmid."\",";
#    print "ID: $vmid - ";
#    print "Type: $vmtype - ";
#print $vmconfigfile.""; 
#   print "Node: $vmnode - ";
#    print "IP: $vmnodeip\n";

my $vmconfig_data="";
open(FHV, '<', $vmconfigfile);
while(<FHV>){
$vmconfig_data=$vmconfig_data.$_;
}
close(FHV);
# Call the function to parse the config data
my $vmparsed_data = vm_config_parser($vmconfig_data);
my $vmcsockets='';
my $vmccores='';
my $vmcmemory='';
my $vmcname='';
####### VM DISK LIST --- START
my @vm_disk_list; my $vmdiski=0; my $vmdisklast="";
my @vm_disk_listsize;
foreach my $vmsection_data (@$vmparsed_data) {
if($vmtype eq "lxc"){$vmcsockets="\"1\",";}
foreach my $vmkey (sort keys %$vmsection_data) {
my $vmvalue = $vmsection_data->{$vmkey};
if($vmkey eq "hostname"){$vmcname="\"".$vmvalue."\",";}
if($vmkey eq "name"){$vmcname="\"".$vmvalue."\",";}
if($vmkey eq "sockets"){$vmcsockets="\"".$vmvalue."\",";}
if($vmkey eq "cores"){$vmccores="\"".$vmvalue."\",";}
if($vmkey eq "memory"){$vmcmemory="\"".$vmvalue."\",";}
#print "\n $vmvalue - $vmkey";
my @valsplit = split(/,/, $vmvalue);my $vmdiskfind="-disk-";
if (defined($valsplit[0]) && $valsplit[0] =~ /$vmdiskfind/)
{if($vmdisklast ne $valsplit[0]){$vmdisklast=$valsplit[0];
@vm_disk_list[$vmdiski]=$valsplit[0];
@vm_disk_listsize[$vmdiski]=$vmvalue;
$vmdiski++;
}}}}

my $vmcdisk="";
for(my $r=0;$r<@vm_disk_list;$r++)
{
#print "\n";
#print $vm_disk_list[$r];
#$vmcdisk=$vmcdisk."\"".$vm_disk_list[$r]."\",";
my @xvalsplit = split(/,/, $vm_disk_listsize[$r]);
my $esize=@xvalsplit;
##my @esize2= split(/=/,$xvalsplit[$esize -1 ]);

for( my $ci=0;$ci<@xvalsplit;$ci++)
{
#print " --> $ci --> ".$xvalsplit[$ci];
my @esize2= split(/=/,$xvalsplit[$ci]);
if($esize2[0] eq "size")
{
$vmcdisk=$vmcdisk."\"".$esize2[1]."\",";
}
}

#$vmcdisk=$vmcdisk."\"".$vm_disk_listsize[$r]."\",";
#if (defined($esize2[1]))
#{
#$vmcdisk=$vmcdisk."\"".$esize2[1]."\",";
#}
$vmcdisk=$vmcdisk."";
}
####### VM DISK LIST --- END

print $vmline;
print $vmcname;
print $vmcsockets;
print $vmccores;
print $vmcmemory;
print $vmcdisk;

print "\n";
#######################################
### for loop for VMLIST OF IDS OVER
}



##vm-100-state-test123
#$cmdstroageinfo='pvesh get /storage --output-format=json';
#$cmdstoragedetail='pvesh get /storage/cephdata --output-format=json';
#$vminfocmd='qm guest cmd #VMID# get-fsinfo';
#$vmrbdinfo='rbd disk-usage -p cephdata-metadata vm-101-disk-0 --format=json';
#$vmrbdinfo='rbd disk-usage -p cephdata-metadata vm-101-disk-0';
#$vmrbdinfo='rbd info -p cephdata-metadata vm-101-disk-0  --format=json';
#$vmrbdinfo='rbd info -p cephdata-metadata vm-101-disk-0';
#$vmrbdinfo='rbd snap list  -p cephdata-metadata vm-100-disk-0';
#$vmrbdinfo='rbd snap list  -p cephdata-metadata vm-100-disk-0 --format=json';


