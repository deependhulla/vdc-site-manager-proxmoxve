#!/usr/bin/perl
##Updated : 07-Aug-2023
use strict;
use warnings;
use JSON::PP; 

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
$siteinfonodeip[$si][$ri]=$ip;$ri++;
$siteinfonodeid[$si][$ri]=$id;$ri++;
$siteinfonodename[$si][$ri]=$node;$ri++;
#    print "<hr>Node: $node, ID: $id, IP: $ip\n";
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
print "\"SITE_ID\",\"CLUSTER_NAME\",".$rowhead."\n";
print $siteinfo[$si].",".$siteinfoname[$si].",".$rowinfo;
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





