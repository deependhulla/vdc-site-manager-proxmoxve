#!/usr/bin/perl

use strict;
use warnings;
use JSON;
use Data::Dumper;

my $cephstorage=$ARGV[0];
my $cephpool=$ARGV[1];
my $cepherasureactive=$ARGV[2];
my $qemuipi=0;
my $decoded="";

if($cepherasureactive eq "" || $cephpool eq "" || $cephstorage eq "")
{

print "Please Pass <ceph storage name> <ceph pool name> <erasurecode> <DO WORD>\n";
print "get-fulldetails-of-all-vm.pl starceph starceph 0 DO";
print "\n";
print "OR for Erasurecode\n";
print "get-fulldetails-of-all-vm.pl cephdata cephdata-metadata 1 DO";
print "\n";
exit;
}


# Attempt to decode JSON and check for errors
sub is_valid_json {
    my $str = shift;
    eval {
        decode_json($str);
        1;
    } or do {
        return 0;
    };
}

#print "\n-- $cephstorage -- $cephpool -- $cepherasureactive --\n";

sub convert_to_best_unit {
    my ($bytes) = @_;
    my @units = qw(B KiB MiB GiB TiB);
    my $unit = 0;

    while ($bytes >= 1024 && $unit < $#units) {
        $bytes /= 1024;
        $unit++;
    }

    return sprintf("%.2f %s", $bytes, $units[$unit]);
}


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

print '"SR","NODE","VM-CT","VMID","VMNAME","SOCKETS","CORES","MEMORY","VM-ONLINE","QEMU-AGENT-ACTIVE","QEMU-IP","QEMU-OS-TYPE","QEMU-KERNEL-INFO","DISK 0 NAME","DISK 0 SIZE","DISK 0 USED","DISK 1 NAME","DISK 1 SIZE","DISK 1 USED","DISK 2 NAME","DISK 2 SIZE","DISK 2 USED","DISK 3 NAME","DISK 3 SIZE","DISK 3 USED","DISK 4 NAME","DISK 4 SIZE","DISK 4 USED","DISK 5 NAME","DISK 5 SIZE","DISK 5 USED","DISK 6 NAME","DISK 6 SIZE","DISK 6 USED","DISK 7 NAME","DISK 7 SIZE","DISK 7 USED","DISK 8 NAME","DISK 8 SIZE","DISK 8 USED","DISK 9 NAME","DISK 9 SIZE","DISK 9 USED","DISK 10 NAME","DISK 10 SIZE","DISK 10 USED"';
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
my $vmcmemorya='';
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
if($vmkey eq "memory"){
$vmcmemory="\"".$vmvalue."\",";
$vmcmemorya=$vmvalue;
}
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
$vmcdisk=$vmcdisk."\"".$xvalsplit[0]."\",";

for( my $ci=0;$ci<@xvalsplit;$ci++)
{
#print " --> $ci --> ".$xvalsplit[$ci];
#print " --> $ci --> ".$xvalsplit[$ci];
##$vmcdisk=$vmcdisk."\"".$xvalsplit[$ci]."\",";
my @esize2= split(/=/,$xvalsplit[$ci]);
if($esize2[0] eq "size")
{
my $gotsizenow='-';
$vmcdisk=$vmcdisk."\"".$esize2[1]."\",";
my $columndata=$xvalsplit[0];
my $columndata1=$cephstorage.":";
$columndata =~ s/$columndata1//g;
if ($columndata =~ /:/) {
##print "XX .$columndata";
##Skip Ceph Check..
}
else
{
#print "XX $columndata";
my $gcmdx="rbd du '".$cephpool."/".$columndata."' --format=json";
#print "\n $gcmdx \n";
my $gcmdout=`$gcmdx`;
$gcmdout=~ s/\n//g;
$gcmdout=~ s/\t//g;
$gcmdout=~ s/\0//g;
#print "\n $gcmdout \n";
my $json_parsed = decode_json($gcmdout);
my $images = $json_parsed->{'images'};

# Get the last used_size
if (@$images) {
    my $last_used_size = 0;
for(my $fg=0;$fg<@$images;$fg++)
{    
my $last_image = $images->[$fg];
 $last_used_size = $last_used_size + $last_image->{'used_size'};
}
my $converted_size = convert_to_best_unit($last_used_size);
$gotsizenow=$converted_size;  
 # print "Last used_size: $last_used_size\n";

} else {
   # print "No images found in the JSON data.\n";
}

## Check Ceph match for used storage
}
$vmcdisk=$vmcdisk."\"".$gotsizenow."\",";
#$vmcdisk=$vmcdisk."\"".$esize2[1]."\",";
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
my $vmcmemory1=int($vmcmemorya) / 1024;
print "\"".$vmcmemory1."GB\",";
my $vmonline='';
my $qemuos='';
my $qemukernel='';
my $qemuonline='';
my $qemuip='';
$qemuonline='Agent-In-Active';
$vmonline="Offline";
if($vmtype eq "lxc"){$qemuonline='Container';}
my $cmdz="pvesh get /nodes/".$vmnode."/".$vmtype."/".$vmid."/agent/get-osinfo --output-format=json 2>/tmp/log-".$vmid."-getosinfo";
#print "\n$cmdz\n";
my $gcmdout=`$cmdz`;
$gcmdout=~ s/\n//g;
$gcmdout=~ s/\t//g;
$gcmdout=~ s/\0//g;
#print "\n $gcmdout \n";
if (is_valid_json($gcmdout)) {
my $decoded = decode_json($gcmdout);
if (exists $decoded->{"result"}{"pretty-name"}) {
$qemuos = $decoded->{"result"}{"pretty-name"};
$qemukernel = $decoded->{"result"}{"kernel-version"};
}
$qemuonline='Agent-Active';
}
########################################
########################################
$cmdz="pvesh get /nodes/".$vmnode."/".$vmtype."/".$vmid."/agent/network-get-interfaces --output-format=json 2>/tmp/log-".$vmid."-getinterfaces";
if($vmtype eq "lxc")
{
$cmdz="pvesh get /nodes/".$vmnode."/".$vmtype."/".$vmid."/interfaces --output-format=json 2>/tmp/log-".$vmid."-getinterfaces";
}
#print "\n$cmdz\n";
 $gcmdout=`$cmdz`;$gcmdout=~ s/\n//g;$gcmdout=~ s/\t//g;$gcmdout=~ s/\0//g;$qemuip="";
 $qemuipi=0;
#print "\n $gcmdout \n";
if (is_valid_json($gcmdout)) {
 $decoded = decode_json($gcmdout);
foreach my $entry (@{ $decoded->{'result'} }) {
    foreach my $ip_entry (@{ $entry->{'ip-addresses'} }) {
        if ($ip_entry->{'ip-address-type'} eq 'ipv4' && $ip_entry->{'ip-address'} ne "127.0.0.1") {
#            print "IPv4 Address: " . $ip_entry->{'ip-address'} . "\n";
if($qemuipi!=0){$qemuip=$qemuip.",";}
$qemuip=$qemuip.$ip_entry->{'ip-address'};
$qemuipi++;
}}
$qemuonline='Agent-Active';
}}
########################################
########################################


########################################
########################################
$cmdz="pvesh get /nodes/".$vmnode."/".$vmtype."/".$vmid."/status/current --output-format=json 2>/tmp/log-".$vmid."-getcurrent";
#print "\n$cmdz\n";
 $gcmdout=`$cmdz`;$gcmdout=~ s/\n//g;$gcmdout=~ s/\t//g;$gcmdout=~ s/\0//g;
#print "\n $gcmdout \n";
if (is_valid_json($gcmdout)) {
 $decoded = decode_json($gcmdout);
 $vmonline = $decoded->{'status'};
#print "GOT STATUS --> $vmonline \n";
}
########################################
########################################



print "\"".$vmonline."\",";
print "\"".$qemuonline."\",";
print "\"".$qemuip."\",";
print "\"".$qemuos."\",";
print "\"".$qemukernel."\",";


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


