#!/usr/bin/perl
##Updated : 07-Aug-2023
use strict;
use warnings;
use JSON::PP; 


use DBI;
use WebminCore;
  init_config();

&ReadParse();
  
my $showheadernow=1;
my $fun=$in{'fun'};

if($showheadernow==1)
{
 ui_print_header(undef, 'VDC Site Manager', '');
}

## get Site VM Info
## ssh root@192.168.30.112 /usr/local/src/vdcsitemanager-tools/nodes-tools/get-list-of-vm-in-cluster.pl

print "<center>";
  print ui_table_start('Cluster Data Sync Management', 'width=100% align=center',undef, 3);
  print ui_table_row('<a href=\'index.cgi?fun=datavmlist\'>Data Sync VMs List</a>');
  print ui_table_row('<a href=\'index.cgi?fun=datasyncstatus\'>Data Sync VM Status</a>');
  print ui_table_row('<a href=\'index.cgi?fun=clustervmlist\'>List of VMs in Cluster</a>');
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
print "<td style=\"border: 1px solid;background-color:lightgreen !important\" align=center>Cluster<br>".$siteinfoalias[$si]."</td>";
foreach my $node (keys %$node_list) {
    my $id = $node_list->{$node}->{'id'};
    my $ip = $node_list->{$node}->{'ip'};
$siteinfonodeip[$si][$ri]=$ip;$ri++;
$siteinfonodeid[$si][$ri]=$id;$ri++;
$siteinfonodename[$si][$ri]=$node;$ri++;
#    print "<hr>Node: $node, ID: $id, IP: $ip\n";
print "<td style=\"padding:1px;border: 1px solid; background-color:#98FB98 !important\" align=center>".$node."<br>".$ip."</td>";
}
print "</tr>";

$si++;
## if siteinfo folder dir found -over
}
###forloop for maxsote over
}
if($si==0){print "<table border=1>";}


##################################
##############################
if($fun eq "clustervmlist")
{

print "Cluster";
###
}

##############################

##############################
if($fun eq "datavmlist")
{
print "DATA Sync VM List";
#####
}
#############################3
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




