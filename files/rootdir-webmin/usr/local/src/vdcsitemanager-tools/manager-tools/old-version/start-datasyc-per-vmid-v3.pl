#!/usr/bin/perl
##Updated : 07-Aug-2023
use strict;
use warnings;
use JSON::PP; 

## means datasync on node 3
my $datasyncnodeid=1;


my $checkvmid="";
$checkvmid=$ARGV[0];
if (defined $checkvmid) {
## working on VMID
}
else
{
print " Please provide VM ID : Example 706\n";
exit;
}
my $cephstorage="";
my $cepherasure="";
my $cepherasuremsg=" Replication mode";
my $cepherasureactive=0;
open(OUTOAZ,"</etc/webmin/vdcsitemanager/ceph-storage-name");
while(<OUTOAZ>)
{
$cephstorage=$cephstorage.$_;
}
close(OUTOAZ);

$cephstorage=~ s/\n/""/eg;
$cephstorage=~ s/\r/""/eg;
$cephstorage=~ s/\t/""/eg;
$cephstorage=~ s/\0/""/eg;
$cephstorage=~ s/ /""/eg;

open(OUTOAZ,"</etc/webmin/vdcsitemanager/ceph-erasure-code");
while(<OUTOAZ>)
{
$cepherasure=$cepherasure.$_;
}
close(OUTOAZ);
$cepherasure=~ s/\n/""/eg;
$cepherasure=~ s/\t/""/eg;
$cepherasure=~ s/\r/""/eg;
$cepherasure=~ s/\0/""/eg;
$cepherasure=~ s/ /""/eg;
##$cepherasure="";
if($cephstorage eq "" || $cepherasure eq "")
{
print "Please Setup cephstorage & cepherasure config file first.";
exit;
}

if($cepherasure eq "0")
{
$cepherasuremsg="(replication)";
$cepherasureactive=0;
}
if($cepherasure eq "1")
{
$cepherasuremsg="(erasure code)";
$cepherasureactive=1;
}

my $maxsiteinfo=5;
my $mainsiteinfofolder='/etc/webmin/vdcsitemanager/siteinfo/';
my @siteinfo=();
my @siteinfoname=();
my @siteinfoalias=();
my @siteinfonodeid=();
my @siteinfonodeip=();
my @siteinfonodename=();
my $si=0;
my $s=0;
#/etc/webmin/vdcsitemanager/siteinfo/site-info-1/host-node-list-members
for($s=0;$s<$maxsiteinfo;$s++)
{

my $folder_path = '/etc/webmin/vdcsitemanager/siteinfo/site-info-'.$s;
if (-d $folder_path) {
$siteinfo[$si]=$s;
my $hostmemfile=$folder_path."/host-node-list-members";
my $json_string="";
open(OUTOAZ,"<$hostmemfile");while(<OUTOAZ>){$json_string=$json_string.$_;}close(OUTOAZ);
#print "\n------".$json_string."---\n";
my $data = decode_json($json_string);

# Access specific elements of the decoded data structure
my $node_name = $data->{'nodename'};
my $cluster_name = $data->{'cluster'}->{'name'};
my $node_list = $data->{'nodelist'};
my $ri=0;
#print "Node Name: $node_name\n";
#print "Cluster Name: $cluster_name\n";
$siteinfoname[$si]=$cluster_name;
$siteinfoalias[$si]=$cluster_name;
if($si==0){

#print "<table border=1>";

}
#print "<tr>";
#print "<td style=\"border: 1px solid;background-color:#FFFAF0 !important\" align=center>Cluster<br>".$siteinfoalias[$si]."</td>";
foreach my $node (keys %$node_list) {
    my $id = $node_list->{$node}->{'id'};
    my $ip = $node_list->{$node}->{'ip'};
$siteinfonodeip[$si][$ri]=$ip;
$siteinfonodeid[$si][$ri]=$id;
$siteinfonodename[$si][$ri]=$node;
#    print "<hr> $si --> $ri --> Node: $node, ID: $id, IP: $ip\n";
$ri++;
#print "<td style=\"padding:1px;border: 1px solid; background-color:#FAF0E6 !important\" align=center>".$node."<br>".$ip."</td>";
}
#print "</tr>";

$si++;
## if siteinfo folder dir found -over
}
###forloop for maxsote over
}
if($si!=0){
#print "</table><br>";
}

#print "<hr>";
##################################
my $fun="vminfo";
##############################
if($fun eq "vminfo")
{
#print "<h4><i>List of VMs in Clusters</i></h4>";
#$siteinfonodeip[$si][$ri]
for($si=0;$si<@siteinfo;$si++)
{
#print "<h4>List of VMs in Cluster-Site : ".$siteinfo[$si]." :  ".$siteinfoname[$si]."</h4>";
my $nodesship=$siteinfonodeip[$si][0];
## get Site VM Info
##my $cmdx="ssh root@".$nodesship." /usr/local/src/vdcsitemanager-tools/nodes-tools/get-list-of-vm-in-cluster.pl";
my $cmdx="ssh root@".$nodesship." /usr/local/src/vdcsitemanager-tools/nodes-tools/get-disk-name-of-all-vm.pl";
#print "$cmdx";
my $csvdata=`$cmdx`;
#print "<table border='1'>\n";
my @rows = split(/\n/, $csvdata);
my $rx=0;my $tcolx=0;
my $tbgcol="#FFFAF0";
my $rowhead="";
foreach my $row (@rows) {
if($rx==0){$rowhead=$row; $rowhead=~ s/\"SR\",//g;}$rx++;
my $showallow=1;
my $colx=0;
    $row =~ s/"//g; # Remove quotes
    my @columns = split(/,/, $row);
 foreach my $column (@columns) {
$colx++;
if($colx==4 && $column eq $checkvmid){
#print "FOUND";
##print $row;
my $rowdata=$row;
my $rowdata1=$cephstorage.":";
$rowdata =~ s/$rowdata1//g;
####print $rowdata;
if ($rowdata =~ /:/) {
$showallow=0;
}
if($showallow==1)
{
my @columnsf = split(/,/, $rowdata);
my $rowinfo="";
$colx=0;
foreach my $columnf (@columnsf) {
$colx++;
if($colx!=1)
{
if($colx!=2){$rowinfo=$rowinfo.",";}
$rowinfo=$rowinfo.$columnf;
}
}
## ONLY ALLOW CEPH STORAGE VM
#print "\"SITE_ID\",\"CLUSTER_NAME\",".$rowhead."\n";
#print $siteinfo[$si].",".$siteinfoname[$si].",".$rowinfo."\n";
my @infox=();
@infox=split/,/,$rowinfo;
###########################################
########## WORK ON SYNC SCRIPT Creation and Pushing to Server -START ######
###########################################
my @totaldiskname=();
my @totaldisksize=();
my $ti=0;
my $jj=0;
for(my $ii=7;$ii<@infox;$ii++)
{
my $diskok=0;my $diskokf=0;
if($jj==0){$diskok=1;}


if($diskok==1)
{
if ($infox[$ii] =~ /-disk-/) {
#    print "Got disk\n";

$diskokf=1;
}
}
if($diskokf==1)
{
$totaldiskname[$ti]=$infox[$ii];
$totaldisksize[$ti]=$infox[$ii+1];
$ti++;
#print "\n FROM  DISK $ii -->".$infox[$ii];
}
$jj++;
if($jj==2){$jj=0;}
}
#### work for Script to Sync Disk from one cluster to another start #####
#totaldiskname
my $fromsiteid=$siteinfo[$si];
my $fromclustername=$siteinfoname[$si];
my $fromnodename=$infox[0];
my $fromnodeip='';
my $fromnodeid=0;
my $fromdatasyncip=$siteinfonodeip[$si][$datasyncnodeid];
my $tsi=0;
if($si==0){$tsi=1;}
if($si==1){$tsi=0;}
my $tositeid=$siteinfo[$tsi];
my $toclustername=$siteinfoname[$tsi];
my $tonodename='';
my $tonodeip='';
my $tonodeid=0;

my $vmtype=$infox[1];
my $tdisk=@totaldiskname;
my $tj=0;

for(my $ni=0;$ni<@{$siteinfonodeip[$si]};$ni++)
{if($siteinfonodename[$si][$ni] eq $fromnodename){
$fromnodeip=$siteinfonodeip[$si][$ni];
$fromnodeid=$siteinfonodeid[$si][$ni];
}}


for(my $ni=0;$ni<@{$siteinfonodeip[$tsi]};$ni++)
{if($siteinfonodeid[$tsi][$ni] eq $fromnodeid){
$tonodename=$siteinfonodename[$tsi][$ni];;
$tonodeip=$siteinfonodeip[$tsi][$ni];
$tonodeid=$siteinfonodeid[$tsi][$ni];
}}

for($ti=0;$ti<@totaldiskname;$ti++)
{
$tj++;

print "FROM SITE ID [".$si."]: ".$fromsiteid."\n";
print "FROM CLUSTER NAME ".$fromclustername."\n";
print "FROM ON NODE : ".$fromnodename."\n";
print "FROM ON NODE ID : ".$fromnodeid."\n";
print "FROM ON NODE IP : ".$fromnodeip."\n";
print "FROM DATA SYNC NODE IP : ".$fromdatasyncip."\n";

print "VM ID ".$checkvmid."\n";
print "VM TYPE ".$vmtype."\n";
print "Disk $tj of $tdisk \n";
print "DISK TO WORK  ".$totaldiskname[$ti]."\n";
print "DISK SIZE ".$totaldisksize[$ti]."\n";


print "TO SITE ID [".$tsi."]: ".$tositeid."\n";
print "TO CLUSTER NAME ".$toclustername."\n";
print "TO ON NODE : ".$tonodename."\n";
print "TO ON NODE ID : ".$tonodeid."\n";
print "TO ON NODE IP : ".$tonodeip."\n";

print "\n---------------------\n";
## for loop of valid Disk over
}
#### work for Script to Sync Disk from one cluster to another end #####
###########################################
########## WORK ON SYNC SCRIPT Creation and Pushing to Server  -END ######
###########################################

}
 }
}

}
#print "</table>";
##for loop for site is over
}

###
}

##########VM INFO over####################
print "\n";




