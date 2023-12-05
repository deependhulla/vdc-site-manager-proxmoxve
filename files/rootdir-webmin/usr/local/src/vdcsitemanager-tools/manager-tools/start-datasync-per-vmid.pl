#!/usr/bin/perl
##Updated : 07-Aug-2023
use strict;
use warnings;
use JSON::PP; 

my $debugnow=0;

my $vdcip=`hostname -i`;
$vdcip=~ s/\n/""/eg;
$vdcip=~ s/\r/""/eg;
$vdcip=~ s/\t/""/eg;
$vdcip=~ s/\0/""/eg;
$vdcip=~ s/ /""/eg;

## means datasync on node 3
my $datasyncnodeid=1;
my $hs="";
my $hsend="";
my $hfire="";
my $hlog="";
my $hlogv="";
my $hlock="";
my $tonodeip='';
my $fromnodeip='';

my $uidx=time();

my $checkvmid="";
$checkvmid=$ARGV[0];
if (defined $checkvmid) {
## working on VMID
}
else
{
print " Please provide VM ID : Example 706\n";
print "OR final Sync then shutdown and activate to another cluster and start VM\nPlease provide VM ID : Example 706 activate start\n";
print "or final Sync then shutdown and activate to another cluster and Do-Not-start(Keep stop) VM\nPlease provide VM ID : Example 706 activate stop\n";
exit;
}

my $folder_path='';
$folder_path='/var/vdcsitemanager/';if (!-d $folder_path) {if (mkdir $folder_path){}}
$folder_path='/var/vdcsitemanager/nodes-scripts/';if (!-d $folder_path) {if (mkdir $folder_path){}}
$folder_path='/var/vdcsitemanager/nodes-lock/';if (!-d $folder_path) {if (mkdir $folder_path){}}
$folder_path='/var/vdcsitemanager/nodes-logs/';if (!-d $folder_path) {if (mkdir $folder_path){}}
my $checkactivate='';
my $checkstartstop='';
$checkactivate=$ARGV[1];
if (defined $checkactivate) { $checkstartstop=$ARGV[2];
## working on VMID

if (defined $checkstartstop && $checkactivate eq "activate") 
{
##work on activate and start-stop value
if($checkstartstop eq "start" || $checkstartstop eq "stop")
{
##work final
}
else
{
print "Need activate + stop or start value\n";
exit;
}

}
else
{
print "Need activate as optoin + stop or start value\n";
exit;
}

}




my $finalscript='/var/vdcsitemanager/nodes-scripts/'.$checkvmid.'-datasyncscript.sh';
$hlog="/var/vdcsitemanager/nodes-logs/".$checkvmid."-".$uidx."-datasync.log";
$hlogv="/var/vdcsitemanager/nodes-logs/".$checkvmid."-datasync.log";
$hlock="/var/vdcsitemanager/nodes-lock/".$checkvmid."-datasync.lock";

if (-e $hlock) {
my ($sec, $min, $hour, $mday, $mon, $year) = localtime();$year += 1900;$mon += 1;
my $curdatetime = sprintf("%04d-%02d-%02d %02d:%02d:%02d", $year, $mon, $mday, $hour, $min, $sec);
    print "".$curdatetime." ".$uidx." LOCK ON VM ID ".$checkvmid." for Data-Sync.\n";
    print "".$curdatetime." ".$uidx." LOCK INFO OF PROCESS\n";
open(OUTOAZ,"<$hlock");
while(<OUTOAZ>)
{
    print "".$curdatetime." ".$uidx." ";
print $_;
}
close(OUTOAZ);
print "\n";
exit;
##### LOCK --OVER
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
#my $fromnodeip='';
my $fromnodeid=0;
my $fromdatasyncip=$siteinfonodeip[$si][$datasyncnodeid];
my $tsi=0;
if($si==0){$tsi=1;}
if($si==1){$tsi=0;}
my $tositeid=$siteinfo[$tsi];
my $toclustername=$siteinfoname[$tsi];
my $tonodename='';
#my $tonodeip='';
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
if($debugnow==1)
{
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

}
if($tj==1)
{
$hs=$hs."#/bin/bash\n";
$hs=$hs."\n";
$hs=$hs."BASEDIR=\$(dirname \$0)
cd \$BASEDIR

if [ -f '".$hlock."' ];
then
   echo 'File ".$hlock." exists'
else

touch ".$hlock." ";

$hs=$hs."echo \"`date +'%Y-%m-%d %H:%M:%S'` ".$uidx." ".$checkvmid." Disk-Sync Started from ".$fromnodeip." to ".$tonodeip."  \" >> ".$hlog." \n";

$folder_path='/var/vdcsitemanager/';if (!-d $folder_path) {if (mkdir $folder_path){}}
$folder_path='/var/vdcsitemanager/nodes-scripts/';if (!-d $folder_path) {if (mkdir $folder_path){}}
$folder_path='/var/vdcsitemanager/nodes-lock/';if (!-d $folder_path) {if (mkdir $folder_path){}}
$folder_path='/var/vdcsitemanager/nodes-logs/';if (!-d $folder_path) {if (mkdir $folder_path){}}
##$hsend=$hsend."ssh root@".$tonodeip." 'mkdir -p /var/vdcsitemanager/';";  
##$hsend=$hsend."ssh root@".$tonodeip." 'mkdir -p /var/vdcsitemanager/nodes-scripts/';";  
##$hsend=$hsend."ssh root@".$tonodeip." 'mkdir -p /var/vdcsitemanager/nodes-lock/';";  
##$hsend=$hsend."ssh root@".$tonodeip." 'mkdir -p /var/vdcsitemanager/nodes-logs/';";  
$hsend=$hsend."scp \"".$finalscript."\" root@".$fromnodeip.":/var/vdcsitemanager/nodes-scripts/ ";
#####$hfire=$hfire."ssh root@".$fromnodeip." 'nohup ".$finalscript." > /dev/null 2>&1 &' ";
$hfire=$hfire."ssh root@".$fromnodeip." 'nohup ".$finalscript." > ".$hlogv." 2>&1 &' ";
## for First disk  and header--work
}
$hs=$hs."echo \"`date +'%Y-%m-%d %H:%M:%S'` ".$uidx." ".$checkvmid." Disk-Sync ".$tj." of ".$tdisk." : ".$totaldiskname[$ti]." SIZE: ".$totaldisksize[$ti]." of VM ID ".$checkvmid." from ".$fromnodeip." to ".$tonodeip."  \" >> ".$hlog." ";
$hs=$hs."\n";
$hs=$hs."php /usr/local/src/vdcsitemanager-tools/nodes-tools/sync-vm-disk-data-to-another-cluster.php ".$cephstorage." ".$cepherasureactive." ".$checkvmid." ".$totaldiskname[$ti]." ".$fromnodeip." ".$tonodeip." ".$uidx." ";
$hs=$hs."\n";
$hs=$hs."";
$hs=$hs."";

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

#####$hfire=$hfire."ssh root@".$fromnodeip." 'nohup ".$finalscript." > /dev/null 2>&1 &' ";

$hs=$hs."\n";
$hs=$hs."ssh root@".$vdcip." 'nohup /usr/local/src/vdcsitemanager-tools/manager-tools/unlock-vm-datasync-process.pl ".$checkvmid." > /dev/null 2>&1 &'\n";
$hs=$hs."\n";
$hs=$hs."/bin/rm -v ".$hlock."";
$hs=$hs."\n";
$hs=$hs."fi";
$hs=$hs."\n";
##########VM INFO over####################
open(OUTOAZ,">$finalscript");
print OUTOAZ $hs;
close(OUTOAZ);

chmod(0755, $finalscript);
##create lock file
open(OUTOAZU,">$hlock");
print OUTOAZU "UIDX=".$uidx."\n";
print OUTOAZU "FROMNODEIP=".$fromnodeip."\n";
print OUTOAZU "TONODEIP=".$tonodeip."\n";
my ($sec, $min, $hour, $mday, $mon, $year) = localtime();$year += 1900;$mon += 1;
my $curdatetime = sprintf("%04d-%02d-%02d %02d:%02d:%02d", $year, $mon, $mday, $hour, $min, $sec);
print OUTOAZU "STARTTIME=".$curdatetime."\n";
print OUTOAZU $finalscript;
close(OUTOAZU);


 ($sec, $min, $hour, $mday, $mon, $year) = localtime();$year += 1900;$mon += 1;
 $curdatetime = sprintf("%04d-%02d-%02d %02d:%02d:%02d", $year, $mon, $mday, $hour, $min, $sec);
#print "\n$hsend \n";
my $cmdxoutx=`$hsend`;

#print "\n$hfire \n";
$cmdxoutx=`$hfire`;

print "".$curdatetime." ".$uidx." ".$checkvmid." Data-Sync Command given to Server ".$fromnodeip." ".$cmdxoutx."\n";
#print "".$curdatetime." ".$uidx." ".$hfire."\n";





print "\n";

