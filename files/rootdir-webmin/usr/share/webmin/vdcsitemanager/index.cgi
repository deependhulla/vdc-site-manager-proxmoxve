#!/usr/bin/perl
##Updated : 07-Aug-2023
use strict;
use warnings;
use JSON::PP; 
use Time::Local;

my @cronvalue=();my @crontitle=();my $c=0;
require './mycronlist.pl';
@cronvalue=getcronlist('value');
@crontitle=getcronlist('title');

use DBI;
use WebminCore;
  init_config();
my $tt=-2;
my $csvline="";
my $lockvm=0;
&ReadParse();
my $datasyncvmconfigfolder='/etc/webmin/vdcsitemanager/data-sync-vm-config';
my $showheadernow=1;
my $fun=$in{'fun'};
my $crontab_schedule_active_no="";
my $crontab_schedule_active_yes="";
my $cephmeta='';
my $checkvmid=$in{'vmid'};
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
$cephmeta='';
}
if($cepherasure eq "1")
{
$cepherasuremsg="(erasure code)";
$cepherasureactive=1;
$cephmeta='-metadata';
}
print "<center>";
  print ui_table_start('Cluster\'s Data Sync : Ceph-Storage: '.$cephstorage.' '.$cepherasuremsg, 'width=100% align=center',undef, 3);
  print ui_table_row('<a href=\'index.cgi?fun=clustervmlist\'>List of VMs in Clusters</a>');
  print ui_table_row('<a href=\'index.cgi?fun=datasyncstatus\'>Active VM Data Sync Status</a>');
  print ui_table_row('<a href=\'index.cgi?fun=resourcegroup\'>Resource Group</a>');
##  #print ui_table_row('<a href=\'index.cgi?fun=datavmlist\'>Active VM Data Sync Schedule List</a>');
  print ui_table_row('<a href=\'index.cgi?fun=license\'>License</a>');
  print ui_table_end();

print '<script>function suredown(url,tt)
{
if(confirm(\'Are you sure download can take quite sometime as it fetch nearly \'+tt+\' VMs live information. ?\'))
{
window.open(url, \'_blank\');
}
}</script>';


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
print "<h4>List of VMs in Cluster-Site : ".$siteinfo[$si]." :  ".$siteinfoname[$si]."</h4>\n";
my $nodesship=$siteinfonodeip[$si][0];
## get Site VM Info
##my $cmdx="ssh root@".$nodesship." /usr/local/src/vdcsitemanager-tools/nodes-tools/get-list-of-vm-in-cluster.pl";
my $cmdx="ssh root@".$nodesship." /usr/local/src/vdcsitemanager-tools/nodes-tools/get-disk-name-of-all-vm.pl";
#print "$cmdx";
my $csvdata=`$cmdx`;
if($si!=0){$csvline=$csvline."\n\n";}
print "<table border='1'>\n";
my @rows = split(/\n/, $csvdata);
my $rx=0;my $tcolx=0;
my $tbgcol="#FFFAF0";
foreach my $row (@rows) {
my $showallow=1;

if($rx==0){
$csvline=$csvline."\"SITE\",";
}
else
{

$csvline=$csvline."\"".$siteinfoname[$si]."\",";
}
    $row =~ s/"//g; # Remove quotes
    my @columns = split(/,/, $row);
if($rx==0){$tcolx=@columns;}$rx++;
    print "<tr>\n";
my $colx=0;
my $vmid="";
my $nodename="";
my $vmname="";
$tt++;
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
if($colx==8){
if($rx!=1)
{
my $columndata2=$columndata/1024;
$columndata=$columndata2."GB";
}
}
if($colx>8){
if($rx==1)
{
my $columndata3=$columndata;
$columndata3 =~ s/ /<br>/g;
$columndata=$columndata3."";
}
}
print "<td style=\"border: 1px solid;background-color:".$tbgcol." !important\" align=center>".$columndata."</td>\n";
my $columndata2=$columndata;


if($rx!=1 && ( $colx==10 || $colx==12 || $colx==14 || $colx==16 || $colx==18 || $colx==20 || $colx==22 || $colx==24 || $colx==26 || $colx==28) ){
my $xdisksize=$columndata2;
if ($xdisksize =~ /^(\d+)([GMT])$/) {
    my $xsize = $1;
    my $xunit = $2;

    if ($xunit eq 'T') {
        $xsize *= 1024; # Convert TB to GB
    }
elsif ($xunit eq 'M') {
        $xsize /= 1024; # Convert MB to GB
    }
	$columndata2=$xsize;
}
##$columndata2="XXX";
}

$csvline=$csvline.'"'.$columndata2.'",';
    }
#print $colx."xx --> $tcolx;\n";
for(my $ci=$colx;$ci<$tcolx;$ci++)
{
$csvline=$csvline.'"-",';
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


$csvline=$csvline."\n";

    print "</tr>\n";
}
print "</table>";


##for loop for site is over
}

my $downloadcsvinfo=time();
my $csvfile="";

my ($sec, $min, $hour, $mday, $mon, $year) = localtime();$year += 1900;$mon += 1;
my $curdatetime = sprintf("%04d-%02d-%02d_%02d-%02d-%02d", $year, $mon, $mday, $hour, $min, $sec);
my $downloadcsvinfo=$curdatetime."---".time();
my $csvfile="/tmp/read-".$downloadcsvinfo;
open(OUTOAZ,">$csvfile");
print OUTOAZ $csvline;
close(OUTOAZ);

print "<br><br><a href=\"downloadcsvinfo.cgi?tmpfile=".$downloadcsvinfo."&\" target=\"_blank\" style=\"display: inline-block; padding: 10px 20px; background-color: #007bff; color: #fff; text-decoration: none; border-radius: 5px; border: 1px solid #007bff;\">Download Basic VM Inventory CSV List</a>  ";
print "&nbsp;&nbsp;&nbsp;";
print "| ";
print "&nbsp;&nbsp;&nbsp;";
#######print " <a href=\"downloaddetailinfo.cgi?tmpfile=".$downloadcsvinfo."&\" target=\"_blank\" style=\"display: inline-block; padding: 10px 20px; background-color: #007bff; color: #fff; text-decoration: none; border-radius: 5px; border: 1px solid #007bff;\" onClick='suredown('downloaddetailinfo.cgi?tmpfile=".$downloadcsvinfo."&\');return false;'>Download VM Detailed Live Inventory CSV List (Takes time to generate)</a><hr><br><br>";
print " <a href=\"#\" target=\"_blank\" style=\"display: inline-block; padding: 10px 20px; background-color: #007bff; color: #fff; text-decoration: none; border-radius: 5px; border: 1px solid #007bff;\" onClick=\"suredown('downloaddetailinfo.cgi?tmpfile=".$downloadcsvinfo."&','".$tt."');return false;\">Download VM Detailed Live Inventory CSV List (Takes time to generate)</a><hr><br><br>";
#<pre>".$csvline;
###
}

##########clustervmlist over####################


##############################
if($fun eq "datavmlist")
{
print "Active VM Data Sync Schedule List.: Comming soon";
#####
}
#############################3
#############################3
##############################
if($fun eq "resourcegroup")
{
if($in{'subfun'} eq "")
{
print "<h4>Resource Group List </h4><br>";
print "<a href=\"index.cgi?fun=resourcegroup&subfun=create\" style=\"display: inline-block; padding: 10px 20px; background-color: #007bff; color: #fff; text-decoration: none; border-radius: 5px; border: 1px solid #007bff;\">Create Resource-Group</a>";  
}


if($in{'subfun'} eq "create" || $in{'subfun'} eq "createsave")
{
my $lastgroupid=0;
my $lastgroupidx="";
if ( -e '/etc/webmin/vdcsitemanager/resource-group/lastgroupid.txt' ) {
## file is there 
}
else
{
open(OUTOAZ,">/etc/webmin/vdcsitemanager/resource-group/lastgroupid.txt");
print OUTOAZ "1";
close(OUTOAZ);
}

open(OUTOAZ,"</etc/webmin/vdcsitemanager/resource-group/lastgroupid.txt");
while(<OUTOAZ>)
{
$lastgroupidx=$lastgroupidx.$_;
}
close(OUTOAZ);

#print "aa -> $lastgroupidx";
$lastgroupidx=~ s/\n/""/eg;
$lastgroupidx=~ s/\r/""/eg;
$lastgroupidx=~ s/\0/""/eg;
$lastgroupidx=~ s/ /""/eg;
$lastgroupid=int($lastgroupidx);
my $newgroupid=$lastgroupid + 1;
if($in{'subfun'} eq "createsave")
{
my $gn=$in{'groupname'};
$gn=~ s/\n/""/eg;
$gn=~ s/\r/""/eg;
$gn=~ s/\0/""/eg;
$gn=~ s/\t/""/eg;
my $newgroupidx=$newgroupid;
if($newgroupid<1000){$newgroupidx="0".$newgroupid;}
if($newgroupid<100){$newgroupidx="00".$newgroupid;}
if($newgroupid<10){$newgroupidx="000".$newgroupid;}
my $filex="/etc/webmin/vdcsitemanager/resource-group/activelist/".$newgroupidx."-rg-info.conf";
my ($sec, $min, $hour, $mday, $mon, $year) = localtime();$year += 1900;$mon += 1;
my $curdatetime = sprintf("%04d-%02d-%02d %02d:%02d:%02d", $year, $mon, $mday, $hour, $min, $sec);
open(OUTOAZ,">$filex");
print OUTOAZ "CREATEDON=".$curdatetime;
print OUTOAZ "\n";
print OUTOAZ "GROUPNAME=".$gn;
print OUTOAZ "\n";
close(OUTOAZ);

open(OUTOAZ,">/etc/webmin/vdcsitemanager/resource-group/lastgroupid.txt");
print OUTOAZ $newgroupid;
close(OUTOAZ);

print "Group [GID:$newgroupid] Created : <b>".$gn."</b>";

}
if($in{'subfun'} eq "create")
{
my $groupnamex='Group '.$newgroupid;
print "<h4>Create a Resource Group </h4><br>";
print "<form name=\"myform\" id=\"myform\" action =\"index.cgi\">";
print "<input type=\"hidden\" name=\"fun\" id=\"fun\" value=\"resourcegroup\">";
print "<input type=\"hidden\" name=\"subfun\" id=\"subfun\" value=\"createsave\">";
print "Create First: New Groupname:<input type=\"text\" name=\"groupname\" id=\"groupname\" value=\"".$groupnamex."\"> &nbsp; ";

print "<input type=\"submit\" value=\"Create ResourceGroup\" style=\"background-color:skyblue\">";


}


##Create group --forum
}

###i RESCOURCE GROUP SECTION OVER##
}
#############################3
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
if($colx==16){$diskimage[3]=$columndata;}
if($colx==18){$diskimage[4]=$columndata;}
if($colx==20){$diskimage[5]=$columndata;}
if($colx==22){$diskimage[6]=$columndata;}
if($colx==24){$diskimage[7]=$columndata;}
if($colx==26){$diskimage[8]=$columndata;}
if($colx==28){$diskimage[9]=$columndata;}
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
      <option value="DISABLED" '.$crontab_schedule_active_no.'>INDIVIDUAL VM DISABLED (ResourceGroup Schedule may apply)</option>
      <option value="ACTIVE" '.$crontab_schedule_active_yes.'>INDIVIDUAL VM ENABLED (Plus ResourceGroup Schedule may apply)</option>
</select><br>
 for  <select id="crontab_schedule_value" name="crontab_schedule_value">'.$cronbox.'
    </select>
<!-- Email updates (optional) <input type="email" name="email_update" id="email_update" value="'.$vmemailconfig.'">     -->
    <input type="submit" value="Update Data Sync Settings" style="background-color:skyblue">
';
print $formdata;
print "</form><hr>";

#################
########################################################
if($in{'funupdate'} eq "do-sync-activate")
{
my ($sec, $min, $hour, $mday, $mon, $year) = localtime();$year += 1900;$mon += 1;
my $curdatetime = sprintf("%04d-%02d-%02d %02d:%02d:%02d", $year, $mon, $mday, $hour, $min, $sec);

my $cmdstart='/usr/local/src/vdcsitemanager-tools/manager-tools/start-datasync-per-vmid.pl '.$checkvmid;
if($in{'mactive'} eq "SYNC-STOP"){$cmdstart=$cmdstart." activate stop";}
if($in{'mactive'} eq "SYNC-START"){$cmdstart=$cmdstart." activate start";}

#print "<hr> $cmdstart  <hr>";

my $hlock="/var/vdcsitemanager/nodes-lock/".$checkvmid."-datasync.lock";
if (-e $hlock) {
$lockvm=1;
}
if($lockvm==0)
{
my $cmdxout=`$cmdstart`;
print "<strong><font color=green> Manual Activity started as on ".$curdatetime."</font></strong><br>";
}
my $pop='<script>
function popupboxfull(x,h1,w1)
{
var w=screen.width;var h=screen.height;
var livephonewin=window.open(x, "_blank", "toolbar=no, scrollbars=yes, resizable=yes, top="+h+", left="+w+", width="+w1+", height="+h1+"");
}

</script>
';

print $pop;


my $uidx="";
my $fromnodeip="";
my $tonodeip="";
my $starttime="";
open(OUTOAZ,"<$hlock");
while(<OUTOAZ>)
{
#    print "".$curdatetime." ".$uidx." ";
#$print $_;
my $linex=$_;
$linex=~ s/\n/""/eg;
$linex=~ s/\r/""/eg;
$linex=~ s/\t/""/eg;
$linex=~ s/\0/""/eg;
my @lx = split(/=/, $linex);
if($lx[0] eq "UIDX"){$uidx=$lx[1];}
if($lx[0] eq "FROMNODEIP"){$fromnodeip=$lx[1];}
if($lx[0] eq "TONODEIP"){$tonodeip=$lx[1];}
if($lx[0] eq "STARTTIME"){$starttime=$lx[1];}
}
close(OUTOAZ);

print "<table border=1>";
print "<tr>";
print "<td style=\"border: 1px solid;background-color:#bbbbbb !important\" align=center>PROCESS ID</td>";
print "<td style=\"border: 1px solid;background-color:#bbbbbb !important\" align=center>VMID</td>";
print "<td style=\"border: 1px solid;background-color:#bbbbbb !important\" align=center>FROM NODE IP</td>";
print "<td style=\"border: 1px solid;background-color:#bbbbbb !important\" align=center>TO NODE IP</td>";
print "<td style=\"border: 1px solid;background-color:#bbbbbb !important\" align=center>START TIME</td>";
print "</tr>";
print "<tr>";
print "<td style=\"border: 1px solid;background-color:#cceecc !important\" align=center><a href=\"#\" onClick=\"popupboxfull('livelog.cgi?uidx=".$uidx."&vmid=".$checkvmid."&fromnodeip=".$fromnodeip."&tonodeip=".$tonodeip."&starttime=".$starttime."&showlivelog=1',800,800);return false;\">".$uidx."</a></td>";
print "<td style=\"border: 1px solid;background-color:#cceecc !important\" align=center>".$checkvmid."</td>";
print "<td style=\"border: 1px solid;background-color:#cceecc !important\" align=center>".$fromnodeip."</td>";
print "<td style=\"border: 1px solid;background-color:#cceecc !important\" align=center>".$tonodeip."</td>";
print "<td style=\"border: 1px solid;background-color:#cceecc !important\" align=center>".$starttime."</td>";
print "</tr>";
print "</table>";


exit;
### update of config done and also cron updated code
}

my $hlock="/var/vdcsitemanager/nodes-lock/".$checkvmid."-datasync.lock";
 $lockvm=0;
if (-e $hlock) {
$lockvm=1;
my ($sec, $min, $hour, $mday, $mon, $year) = localtime();$year += 1900;$mon += 1;
my $curdatetime = sprintf("%04d-%02d-%02d %02d:%02d:%02d", $year, $mon, $mday, $hour, $min, $sec);
 #   print "".$curdatetime."  LOCK ON VM ID ".$checkvmid." for Data-Sync.\n";
 #   print "".$curdatetime."  LOCK INFO OF PROCESS\n";
open(OUTOAZ,"<$hlock");
while(<OUTOAZ>)
{
#    print "".$curdatetime." ".$uidx." ";
#print $_;
}
close(OUTOAZ);
print "\n";
}
#################
my $scriptx='<script>
function fxnow()
{
if(confirm(\'Are you sure you want to trigger Manual\'))
{
document.myform2.submit();
}
}
</script>
';
if($lockvm==1)
{
print "<b><font color=green>DATA SYNC PROCESS IS GOING ON/LOCKED : MANUAL ACTIVATION DISABLED.</font></b>";
}
if($lockvm==0)
{
print $scriptx;
print  "<form name=\"myform2\" id=\"myform2\" action =\"index.cgi\">";
print "<input type=\"hidden\" name=\"vmid\" id=\"vmid\" value=\"".$in{'vmid'}."\">";
print "<input type=\"hidden\" name=\"funupdate\" id=\"funupdate\" value=\"do-sync-activate\">";
print "<input type=\"hidden\" name=\"fun\" id=\"fun\" value=\"datasyncnow\">";
my $formdata="";
$formdata='
 <label for="crontab_schedule">MANUAL SYNC VM DATA:</label>
  <select id="mactive" name="mactive">
      <option value="ONLYSYNC" >Only Sync Live (NO MOVE and VM STATUS REMAIN UNCHANGE )</option>
      <option value="SYNC-STOP" >Sync Live then SHUTDOWN with final-sync and MOVE to another Cluster and keep it SHUTDOWN)</option>
      <option value="SYNC-START" >Sync Live then SHUTDOWN with final-sync and MOVE to another Cluster and START VM on another Cluster)</option>
</select>

    <input type="button" value="Manual Activate" style="background-color:pink" onClick="fxnow();return false;">
';

print $formdata;

print "</form>";
}


#################
#################
#################




########################################################
print "<hr>";for($si=0;$si<@siteinfo;$si++){
print "<h5>VMs Disk Usage in Cluster-Site : ".$siteinfo[$si]." :  ".$siteinfoname[$si]."</h5>";
my $nodesship=$siteinfonodeip[$si][0];print "<pre>";for(my $di=0; $di <@diskimage; $di++){
$cmdx="ssh root@".$siteinfonodeip[$si][0]."  \"rbd du '".$cephstorage.$cephmeta."/".$diskimage[$di]."'\" ";
#print "\n$cmdx\n";
my $cmdxout=`$cmdx`;$cmdxout=~ s/</""/eg;$cmdxout=~ s/>/""/eg;print $cmdxout;}print "</pre>";} print "<hr>";
########################################################


##### OVER if loop
}
#####DATA SYNC VM ID SECITON OVER#########################
##############################
##############################
##############################
if($fun eq "datasyncdonestatus")
{
print "<h4>Completed VM Data Sync Status.</h4>";
my $cmdxx='/usr/local/src/vdcsitemanager-tools/manager-tools/get-logs-from-all-clusters-nodes.pl';
my $cmdxxout='';
$cmdxxout=`$cmdxx`;

my @cmvm=();
my $ai=0;
my $hlock = '/var/vdcsitemanager/nodes-logs/';  # Replace this with your folder path
opendir(my $dh, $hlock) or die "Cannot open directory: $!";

while (my $file = readdir($dh)) {
    next unless (-f "$hlock/$file");  # Check if it's a file
    if ($file =~ /\.log$/) {  # Check for files with the .local extension
#$file=~ s/-datasync.log/""/eg;
#        print "$file <br>\n";
my @vx=split("-",$file);
$cmvm[$ai]{'filename'}=>$file;
$cmvm[$ai]{'vmid'}=$vx[0];
$cmvm[$ai]{'processid'}=$vx[1];
#$cmvm[$ai]['starttime']='';
#$cmvm[$ai]['endtime']='';
#print "<hr>AAAA $ai -->  ".$cmvm[$ai]['vmid']."<hr>";

my $filelog=$hlock."".$file;
#$ai++;
my $ij=0;
open(OUTOAZ,"<$filelog");
while(<OUTOAZ>)
{
my @l1=split(" ",$_);
my @l2=split("from",$_);
my @l3=split(" ",@l2[1]);
my @l4=split(" ",@l3[0]);
if($ij==0)
{
#print $_;
$cmvm[$ai]{'starttime'} = "".$l1[0]." ".$l1[1];
$cmvm[$ai]{'fromnodeip'} = "".$l4[0];
$cmvm[$ai]{'tonodeip'} = "".$l3[2];
## for first line only
}
$cmvm[$ai]{'endtime'}=$l1[0]." ".$l1[1];
##########################
##########################


my $starttimex = $cmvm[$ai]{'starttime'};
my $endtimex   = $cmvm[$ai]{'endtime'};

# Parse the timestamps
my ($start_date, $start_time) = split(' ', $starttimex);
my ($end_date, $end_time)     = split(' ', $endtimex);

my ($start_year, $start_month, $start_day) = split('-', $start_date);
my ($start_hour, $start_min, $start_sec)   = split(':', $start_time);

my ($end_year, $end_month, $end_day)     = split('-', $end_date);
my ($end_hour, $end_min, $end_sec)       = split(':', $end_time);

# Calculate the difference
my $seconds_diff =
    ($end_sec - $start_sec) +
    ($end_min - $start_min) * 60 +
    ($end_hour - $start_hour) * 3600 +
    ($end_day - $start_day) * 86400 +
    ($end_month - $start_month) * 2629743 +    # Average number of seconds in a month
    ($end_year - $start_year) * 31556926;     # Average number of seconds in a year

# Calculate days and remaining seconds
my $days = int($seconds_diff / 86400);
$seconds_diff %= 86400;

# Calculate hours, minutes, and seconds
my $hours   = int($seconds_diff / 3600);
my $minutes = int(($seconds_diff % 3600) / 60);
my $seconds = $seconds_diff % 60;

# Format the duration
my $durationtocomplete = "";
if ($days > 0) {
    $durationtocomplete .= "$days day" . ($days > 1 ? "s " : " ");
}
$durationtocomplete .= sprintf("%02d:%02d:%02d", $hours, $minutes, $seconds);
$cmvm[$ai]{'duration'}=$durationtocomplete;
#print "<hr>Duration to complete: $durationtocomplete\n";


##########################
##########################

$ij++;
}
close(OUTOAZ);
$ai++;
## close check
    }
## close folder
}
closedir($dh);
my $getsortby="endtime";

if($in{'getsortby'} ne ""){$getsortby=$in{'getsortby'};}

if($getsortby ne "")
{
@cmvm = sort {
    my $cmp = $b->{$getsortby} cmp $a->{$getsortby};
    if ($cmp == 0) {
        $a->{'vmid'} <=> $b->{'vmid'};
    } else {
        $cmp;
    }
} @cmvm;
}


my $pop='<script>
function popupboxfull(x,h1,w1)
{
var w=screen.width;var h=screen.height;
var livephonewin=window.open(x, "_blank", "toolbar=no, scrollbars=yes, resizable=yes, top="+h+", left="+w+", width="+w1+", height="+h1+"");
}

</script>
';

print $pop;

print "<table border=1>";
print "<tr>";
print "<td style=\"border: 1px solid;background-color:#bbbbbb !important\" align=center><a href=\"index.cgi?fun=datasyncdonestatus&getsortby=processid\">PROCESS ID</a></td>";
print "<td style=\"border: 1px solid;background-color:#bbbbbb !important\" align=center><a href=\"index.cgi?fun=datasyncdonestatus&getsortby=vmid\">VMID</a></td>";
print "<td style=\"border: 1px solid;background-color:#bbbbbb !important\" align=center><a href=\"index.cgi?fun=datasyncdonestatus&getsortby=fromnodeip\">FROM NODE IP</a></td>";
print "<td style=\"border: 1px solid;background-color:#bbbbbb !important\" align=center><a href=\"index.cgi?fun=datasyncdonestatus&getsortby=tonodeip\">TO NODE IP</a></td>";
print "<td style=\"border: 1px solid;background-color:#bbbbbb !important\" align=center><a href><a href=\"index.cgi?fun=datasyncdonestatus&getsortby=starttime\">START TIME</a></td>";
print "<td style=\"border: 1px solid;background-color:#bbbbbb !important\" align=center><a href=\"index.cgi?fun=datasyncdonestatus&getsortby=endtime\">END TIME</a></td>";
print "<td style=\"border: 1px solid;background-color:#bbbbbb !important\" align=center><a href=\"index.cgi?fun=datasyncdonestatus&getsortby=duration\">DURATION</a></td>";
print "</tr>";

for($ai=0;$ai<@cmvm;$ai++)
{

my $checkvmid=$cmvm[$ai]{'vmid'};
my $fromnodeip=$cmvm[$ai]{'fromnodeip'};
my $tonodeip=$cmvm[$ai]{'tonodeip'};
my $starttime=$cmvm[$ai]{'starttime'};
my $endtime=$cmvm[$ai]{'endtime'};
my $uidx=$cmvm[$ai]{'processid'};
my $duration=$cmvm[$ai]{'duration'};

print "<tr>";
print "<td style=\"border: 1px solid;background-color:#cceecc !important\" align=center><a href=\"#\" onClick=\"popupboxfull('completelog.cgi?uidx=".$uidx."&vmid=".$checkvmid."&fromnodeip=".$fromnodeip."&tonodeip=".$tonodeip."&starttime=".$starttime."&endtime=".$endtime."&duration=".$duration."&showlivelog=1',800,800);return false;\">".$uidx."</a></td>";
print "<td style=\"border: 1px solid;background-color:#cceecc !important\" align=center>".$checkvmid."</td>";
print "<td style=\"border: 1px solid;background-color:#cceecc !important\" align=center>".$fromnodeip."</td>";
print "<td style=\"border: 1px solid;background-color:#cceecc !important\" align=center>".$tonodeip."</td>";
print "<td style=\"border: 1px solid;background-color:#cceecc !important\" align=center>".$starttime."</td>";
print "<td style=\"border: 1px solid;background-color:#cceecc !important\" align=center>".$endtime."</td>";
print "<td style=\"border: 1px solid;background-color:#cceecc !important\" align=center>".$duration."</td>";
print "</tr>";
}
print "</table>";


### COMPLETE LIST IF OVER
}
##############################
##############################
##############################
##############################

##############################
if($fun eq "datasyncstatus")
{
print "<h4>Active VM Data Sync Status.</h4>";
my $hlock = '/var/vdcsitemanager/nodes-lock/';  # Replace this with your folder path
my @activevm=();
my $ai=0;
opendir(my $dh, $hlock) or die "Cannot open directory: $!";

while (my $file = readdir($dh)) {
    next unless (-f "$hlock/$file");  # Check if it's a file
    if ($file =~ /\.lock$/) {  # Check for files with the .local extension

$file=~ s/-datasync.lock/""/eg;
#        print "$file\n";

$activevm[$ai]=$file;
$ai++;
    }
}

closedir($dh);

if($ai==0)
{
print "No Active Session.";
}
## got information.
if($ai>0)
{
my $pop='<script>
function popupboxfull(x,h1,w1)
{
var w=screen.width;var h=screen.height;
var livephonewin=window.open(x, "_blank", "toolbar=no, scrollbars=yes, resizable=yes, top="+h+", left="+w+", width="+w1+", height="+h1+"");
}
</script>
';

print $pop;

for($ai=0;$ai<@activevm;$ai++)
{
my $hlock="/var/vdcsitemanager/nodes-lock/".$activevm[$ai]."-datasync.lock";
my $uidx="";
my $fromnodeip="";
my $tonodeip="";
my $starttime="";
open(OUTOAZ,"<$hlock");
while(<OUTOAZ>)
{
#    print "".$curdatetime." ".$uidx." ";
#$print $_;
my $linex=$_;
$linex=~ s/\n/""/eg;
$linex=~ s/\r/""/eg;
$linex=~ s/\t/""/eg;
$linex=~ s/\0/""/eg;
my @lx = split(/=/, $linex);
if($lx[0] eq "UIDX"){$uidx=$lx[1];}
if($lx[0] eq "FROMNODEIP"){$fromnodeip=$lx[1];}
if($lx[0] eq "TONODEIP"){$tonodeip=$lx[1];}
if($lx[0] eq "STARTTIME"){$starttime=$lx[1];}
}
close(OUTOAZ);
if($ai==0){
print "<table border=1>";
print "<tr>";
print "<td style=\"border: 1px solid;background-color:#bbbbbb !important\" align=center>Sr.</td>";
print "<td style=\"border: 1px solid;background-color:#bbbbbb !important\" align=center>PROCESS ID</td>";
print "<td style=\"border: 1px solid;background-color:#bbbbbb !important\" align=center>VMID</td>";
print "<td style=\"border: 1px solid;background-color:#bbbbbb !important\" align=center>FROM NODE IP</td>";
print "<td style=\"border: 1px solid;background-color:#bbbbbb !important\" align=center>TO NODE IP</td>";
print "<td style=\"border: 1px solid;background-color:#bbbbbb !important\" align=center>START TIME</td>";
print "</tr>";
}
my $aj=$ai+1;
print "<tr>";
print "<td style=\"border: 1px solid;background-color:#cceecc !important\" align=center>".$aj."</td>";
print "<td style=\"border: 1px solid;background-color:#cceecc !important\" align=center><a href=\"#\" onClick=\"popupboxfull('livelog.cgi?uidx=".$uidx."&vmid=".$activevm[$ai]."&fromnodeip=".$fromnodeip."&tonodeip=".$tonodeip."&starttime=".$starttime."&showlivelog=1',800,800);return false;\">".$uidx."</a></td>";
print "<td style=\"border: 1px solid;background-color:#cceecc !important\" align=center>".$activevm[$ai]."</td>";
print "<td style=\"border: 1px solid;background-color:#cceecc !important\" align=center>".$fromnodeip."</td>";
print "<td style=\"border: 1px solid;background-color:#cceecc !important\" align=center>".$tonodeip."</td>";
print "<td style=\"border: 1px solid;background-color:#cceecc !important\" align=center>".$starttime."</td>";
print "</tr>";


### for loop for activevm --over
}
print "</table>";
### got info for some vm --over
}

#####################
#####################
#####################
print "<hr>";
print "<a href=\"index.cgi?fun=datasyncdonestatus\" style=\"display: inline-block; padding: 10px 15px; color: white; background-color: #007bff; text-align: center; text-decoration: none; border-radius: 5px; font-weight: bold;\">View Completed Process List</a>";

#####################
#####################

#####################
#/var/vdcsitemanager/nodes-lock/

#####
}
######Live Data Sync Info -end##################


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




