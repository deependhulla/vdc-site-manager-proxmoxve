#!/usr/bin/perl
##Updated : 07-Aug-2023
use strict;
use warnings;
use JSON::PP; 


use DBI;
use WebminCore;
  init_config();

&ReadParse();
my $datasyncvmconfigfolder='/etc/webmin/vdcsitemanager/data-sync-vm-config';
my $showheadernow=1;
my $fun=$in{'fun'};
my $crontab_schedule_active_no="";
my $crontab_schedule_active_yes="";
if($showheadernow==1)
{
 ui_print_header(undef, 'VDC Site Manager', '');

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
print "<center>";
  print ui_table_start('Cluster\'s Data Sync : Ceph-Storage: '.$cephstorage.' '.$cepherasuremsg, 'width=100% align=center',undef, 3);
  print ui_table_row('<a href=\'index.cgi?fun=datavmlist\'>Data Sync VMs List</a>');
  print ui_table_row('<a href=\'index.cgi?fun=datasyncstatus\'>Data Sync VM Status</a>');
  print ui_table_row('<a href=\'index.cgi?fun=clustervmlist\'>List of VMs in Clusters</a>');
  print ui_table_row('<a href=\'index.cgi?fun=license\'>License</a>');
  print ui_table_end();
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
if($si==0){print "<table border=1>";

}
print "<tr>";
print "<td style=\"border: 1px solid;background-color:#FFFAF0 !important\" align=center>Cluster<br>".$siteinfoalias[$si]."</td>";
foreach my $node (keys %$node_list) {
    my $id = $node_list->{$node}->{'id'};
    my $ip = $node_list->{$node}->{'ip'};
$siteinfonodeip[$si][$ri]=$ip;$ri++;
$siteinfonodeid[$si][$ri]=$id;$ri++;
$siteinfonodename[$si][$ri]=$node;$ri++;
#    print "<hr>Node: $node, ID: $id, IP: $ip\n";
print "<td style=\"padding:1px;border: 1px solid; background-color:#FAF0E6 !important\" align=center>".$node."<br>".$ip."</td>";
}
print "</tr>";

$si++;
## if siteinfo folder dir found -over
}
###forloop for maxsote over
}
if($si!=0){print "</table><br>";}

print "<hr>";
##################################
##############################
if($fun eq "clustervmlist")
{
#print "<h4><i>List of VMs in Clusters</i></h4>";
#$siteinfonodeip[$si][$ri]
for($si=0;$si<@siteinfo;$si++)
{
print "<h4>List of VMs in Cluster-Site : ".$siteinfo[$si]." :  ".$siteinfoname[$si]."</h4>";
my $nodesship=$siteinfonodeip[$si][0];
## get Site VM Info
##my $cmdx="ssh root@".$nodesship." /usr/local/src/vdcsitemanager-tools/nodes-tools/get-list-of-vm-in-cluster.pl";
my $cmdx="ssh root@".$nodesship." /usr/local/src/vdcsitemanager-tools/nodes-tools/get-disk-name-of-all-vm.pl";
#print "$cmdx";
my $csvdata=`$cmdx`;
print "<table border='1'>\n";
my @rows = split(/\n/, $csvdata);
my $rx=0;my $tcolx=0;
my $tbgcol="#FFFAF0";
foreach my $row (@rows) {
my $showallow=1;

    $row =~ s/"//g; # Remove quotes
    my @columns = split(/,/, $row);
if($rx==0){$tcolx=@columns;}$rx++;
    print "<tr>\n";
my $colx=0;
my $vmid="";
my $nodename="";
my $vmname="";
    foreach my $column (@columns) {
$colx++;
my $columndata=$column;
my $columndata1=$cephstorage.":";
$columndata =~ s/$columndata1//g;
if($colx==4){$vmid=$column;}
if($colx==2){$nodename=$column;}
if($colx==5){$vmname=$column;}
if ($columndata =~ /:/) {
## as there is another storage mapped
$showallow=0;
}
print "<td style=\"border: 1px solid;background-color:".$tbgcol." !important\" align=center>".$columndata."</td>\n";
    }
#print $colx."xx --> $tcolx;\n";
for(my $ci=$colx;$ci<$tcolx;$ci++)
{
print "<td style=\"border: 1px solid;background-color:".$tbgcol." !important\" align=center>-</tD>";
}

my $astart="";my $aend="";
my $tbgcolvid=$tbgcol;
$tbgcolvid='#cccccc';
my $extracss="";
my $columndata3="Action";
if($rx!=1)
{

$tbgcolvid='#cccccc';
#$extracss="text-decoration: underline;";
$columndata3="Disabled";
if($showallow==1)
{
$tbgcolvid='#AFEEEE';
$extracss="text-decoration: underline;";
$columndata3="Manage";
$astart="<a href=\"index.cgi?fun=datasyncnow&vmid=".$vmid."&nodename=".$nodename."&vmname=".$vmname."\">";$aend="</a>";
}
}

print "<td style=\"border: 1px solid;".$extracss."background-color:".$tbgcolvid." !important\" align=center>".$astart.$columndata3.$aend."</td>\n";

$tbgcol="#FAF0E6";



    print "</tr>\n";
}
print "</table>";
##for loop for site is over
}

###
}

##########clustervmlist over####################


##############################
if($fun eq "datavmlist")
{
print "DATA Sync VM List";
#####
}
#############################3


##############################
if($fun eq "datasyncnow")
{
print "<h3>Data Sync for VM ID : ".$in{'vmid'}."</h3>";
my $vmfolder=$datasyncvmconfigfolder."/".$in{'vmid'}."/";
my $vmfolderc=$datasyncvmconfigfolder."/".$in{'vmid'}."/vmconfig/";
my $cmdmk="mkdir -p ".$vmfolder."";
my $cmdoutmk=`$cmdmk`;
my $cmdmk="mkdir -p ".$vmfolderc."";
my $cmdoutmk=`$cmdmk`;
#print "--> $cmdmk ";
my $vmfile=$vmfolder."/".$in{'vmid'}."-datasync.conf";
my @diskimage=();


my $cmdx="/usr/local/src/vdcsitemanager-tools/manager-tools/get-per-vmid-info.pl ".$in{'vmid'}."";
my $csvdata=`$cmdx`;
print "<table border='1'>\n";
#my $tbgcol="#FFFAF0";
my $tbgcol="#D0F0C0";
# Splitting CSV data into rows and processing each row
my @rows = split(/\n/, $csvdata);
my $rx=0;
my $tcolx=0;
foreach my $row (@rows) {
    $row =~ s/"//g; # Remove quotes
my $colx=0;
    my @columns = split(/,/, $row);
if($rx==0){$tcolx=@columns;}$rx++;
    print "<tr>\n";
    foreach my $column (@columns) {
$colx++;
my $columndata=$column;
if($columndata eq "SITE_ID"){$columndata="ACTIVE ON SITE";}
if($columndata eq "CLUSTER_NAME"){$columndata="ACTIVE ON CLUSTER";}
if($columndata eq "NODE"){$columndata="ACTIVE ON NODE";}
if($rx==2)
{
if($colx==10){$diskimage[0]=$columndata;}
if($colx==12){$diskimage[1]=$columndata;}
if($colx==14){$diskimage[2]=$columndata;}
if($colx==15){$diskimage[3]=$columndata;}
}
    #    print "<td>$column</td>\n";
print "<td style=\"border: 1px solid;background-color:".$tbgcol." !important\" align=center>".$columndata."</td>\n";

    }
if($rx!=1)
{
#print "--> $tcolx --> $colx";
for(my $ci=$colx;$ci<$tcolx;$ci++)
{
print "<td style=\"border: 1px solid;background-color:".$tbgcol." !important\" align=center>-</tD>";
}
}
    print "</tr>\n";
}

print "</table>\n";
########################################################
########################################################
########################################################


########################################################
#for($si=0;$si<@siteinfo;$si++){
#print "<h5>VMs Disk Usage in Cluster-Site : ".$siteinfo[$si]." :  ".$siteinfoname[$si]."</h5>";
#my $nodesship=$siteinfonodeip[$si][0];print "<pre>";for(my $di=0; $di <@diskimage; $di++){
#$cmdx="ssh root@".$siteinfonodeip[$si][0]."  rbd du '".$cephstorage."/".$diskimage[$di]."' ";
#my $cmdxout=`$cmdx`;$cmdxout=~ s/</""/eg;$cmdxout=~ s/>/""/eg;print $cmdxout;}print "</pre>";}
########################################################


########################################################
########################################################
if($in{'funupdate'} eq "update-vm-data-sync-setting")
{
my ($sec, $min, $hour, $mday, $mon, $year) = localtime();$year += 1900;$mon += 1;
my $curdatetime = sprintf("%04d-%02d-%02d %02d:%02d:%02d", $year, $mon, $mday, $hour, $min, $sec);
open(OUTOAZ,">$vmfile");
print OUTOAZ "SYNCACTIVE===".$in{'crontab_schedule_active'}."\n";
print OUTOAZ "CRONTABCONFIG===".$in{'crontab_schedule_value'}."\n";
print OUTOAZ "EMAILUPDATES===".$in{'email_update'}."\n";
close(OUTOAZ);

print "<strong><font color=green> Config Updated as on ".$curdatetime."</font></strong>";
### update of config done and also cron updated code
}

#####################################################
my $vmactiveconfig="DISABLED";my $vmcrontabconfig="0 */2 * * *";my $vmemailconfig="";my $vmnameconfig="";
open(OUTOAZ,"<$vmfile");
while(<OUTOAZ>)
{
my $fileline=$_;
$fileline=~ s/\n/""/eg;
$fileline=~ s/\r/""/eg;
$fileline=~ s/\t/""/eg;
$fileline=~ s/\0/""/eg;
my @lineb1 = split(/===/, $fileline);
if($lineb1[0] eq "SYNCACTIVE" && $lineb1[1] ne ""){$vmactiveconfig=$lineb1[1];}
if($lineb1[0] eq "CRONTABCONFIG" && $lineb1[1] ne ""){$vmcrontabconfig=$lineb1[1];}
if($lineb1[0] eq "EMAILUPDATES" && $lineb1[1] ne ""){$vmemailconfig=$lineb1[1];}
}
close(OUTOAZ);

if($vmactiveconfig eq "ACTIVE"){$crontab_schedule_active_no='';$crontab_schedule_active_yes='selected';}
if($vmactiveconfig eq "DISABLED"){$crontab_schedule_active_no='selected';$crontab_schedule_active_yes='';}

my @cronvalue=();my @crontitle=();my $c=0;
$cronvalue[$c]="*/10 * * * *";$crontitle[$c]="Every 10 minutes";$c++;
$cronvalue[$c]="*/20 * * * *";$crontitle[$c]="Every 20 minutes";$c++;
$cronvalue[$c]="*/30 * * * *";$crontitle[$c]="Every 30 minutes";$c++;
$cronvalue[$c]="*/40 * * * *";$crontitle[$c]="Every 40 minutes";$c++;
$cronvalue[$c]="*/50 * * * *";$crontitle[$c]="Every 50 minutes";$c++;
$cronvalue[$c]="0 * * * *";$crontitle[$c]="Every hour";$c++;
$cronvalue[$c]="0 */2 * * *";$crontitle[$c]="Every 2 hours";$c++;
$cronvalue[$c]="0 */3 * * *";$crontitle[$c]="Every 3 hours";$c++;
$cronvalue[$c]="0 */4 * * *";$crontitle[$c]="Every 4 hours";$c++;
$cronvalue[$c]="0 */5 * * *";$crontitle[$c]="Every 5 hours";$c++;
$cronvalue[$c]="0 */6 * * *";$crontitle[$c]="Every 6 hours";$c++;

my $cronbox="";
for($c=0;$c<@cronvalue;$c++)
{
my $cronboxsel='';
$cronbox=$cronbox."\n";
if($vmcrontabconfig eq $cronvalue[$c]){$cronboxsel='selected';}
$cronbox=$cronbox."<option value=\"".$cronvalue[$c]."\" ".$cronboxsel.">".$crontitle[$c]."</option>";
}
print  "<form name=\"myform\" id=\"myform\" action =\"index.cgi\">";
print "<input type=\"hidden\" name=\"vmid\" id=\"vmid\" value=\"".$in{'vmid'}."\">";
print "<input type=\"hidden\" name=\"funupdate\" id=\"funupdate\" value=\"update-vm-data-sync-setting\">";
print "<input type=\"hidden\" name=\"fun\" id=\"fun\" value=\"datasyncnow\">";
my $formdata="";
$formdata='
 <label for="crontab_schedule">VM Data Sync:</label>
  Schedule:  <select id="crontab_schedule_active" name="crontab_schedule_active">
      <option value="DISABLED" '.$crontab_schedule_active_no.'>DISABLED</option>
      <option value="ACTIVE" '.$crontab_schedule_active_yes.'>ACTIVE</option>
</select>
 for  
    <select id="crontab_schedule_value" name="crontab_schedule_value">'.$cronbox.'
    </select>
 Email updates (optional) <input type="email" name="email_update" id="email_update" value="'.$vmemailconfig.'">    

    <input type="submit" value="Update Data Sync Settings" style="background-color:skyblue">
';

print $formdata;

print "</form>";




########################################################
print "<hr>";for($si=0;$si<@siteinfo;$si++){
print "<h5>VMs Disk Usage in Cluster-Site : ".$siteinfo[$si]." :  ".$siteinfoname[$si]."</h5>";
my $nodesship=$siteinfonodeip[$si][0];print "<pre>";for(my $di=0; $di <@diskimage; $di++){
$cmdx="ssh root@".$siteinfonodeip[$si][0]."  \"rbd du '".$cephstorage."/".$diskimage[$di]."'\" ";
#print "\n$cmdx\n";
my $cmdxout=`$cmdx`;$cmdxout=~ s/</""/eg;$cmdxout=~ s/>/""/eg;print $cmdxout;}print "</pre>";} print "<hr>";
########################################################


##### OVER if loop
}
#####DATA SYNC VM ID SECITON OVER#########################

##############################
if($fun eq "datasyncstatus")
{
print "DATA Sync VM Logs";

#####
}
########################


##############################  
if($fun eq "license")
{
print "<center>";
print "<pre>";
open(OUTOAZ,"<gpl-3.0.txt");
while(<OUTOAZ>)
{
print $_;
}
close(OUTOAZ);
print "<pre>";
}
##############################  




