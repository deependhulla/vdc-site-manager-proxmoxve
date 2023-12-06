#!/usr/bin/perl
##Updated : 07-Aug-2023
use strict;
use warnings;
use CGI qw(:standard);
use JSON::PP;


use DBI;
use WebminCore;
  init_config();

&ReadParse();

#print "Content-type: text/csv\n";
#print "Content-Disposition: attachment; filename=exportuser-".$in{'vpopmaildomain'}.".csv\n\n";
#print "Content-type: text/plain\n\n";
print "Content-type: text/html\n\n";
print "<html><head><title>Live Log VM-ID: ".$in{'vmid'}."</title></head><body>";

print "<table border=1>";
print "<tr>";
print "<td style=\"border: 1px solid;background-color:#bbbbbb !important\" align=center>PROCESS ID</td>";
print "<td style=\"border: 1px solid;background-color:#bbbbbb !important\" align=center>VMID</td>";
print "<td style=\"border: 1px solid;background-color:#bbbbbb !important\" align=center>FROM NODE IP</td>";
print "<td style=\"border: 1px solid;background-color:#bbbbbb !important\" align=center>TO NODE IP</td>";
print "<td style=\"border: 1px solid;background-color:#bbbbbb !important\" align=center>START TIME</td>";
print "</tr>";

print "<tr>";
print "<td style=\"border: 1px solid;background-color:#cceecc !important\" align=center>".$in{'uidx'}."</td>";
print "<td style=\"border: 1px solid;background-color:#cceecc !important\" align=center>".$in{'vmid'}."</td>";
print "<td style=\"border: 1px solid;background-color:#cceecc !important\" align=center>".$in{'fromnodeip'}."</td>";
print "<td style=\"border: 1px solid;background-color:#cceecc !important\" align=center>".$in{'tonodeip'}."</td>";
print "<td style=\"border: 1px solid;background-color:#cceecc !important\" align=center>".$in{'starttime'}."</td>";
print "</tr>";
print "</table>";
my $cmdx="ps auwx | grep \"ssh root\@".$in{'fromnodeip'}." tail -f /var/vdcsitemanager/nodes-logs/".$in{'vmid'}."-datasync.log\" |grep -v grep | sed 's/  / /g' | sed 's/  / /g' | sed 's/  / /g' | sed 's/  / /g' | sed 's/  / /g' | sed 's/ /|/g' | cut -d '|' -f 2";

#print "<hr>$cmdx<hr>";
my $cmdout=`$cmdx`;
my @cmdline=split('\n',$cmdout);
my $e=0;
for($e=0;$e<@cmdline;$e++)
{
$cmdx='kill -9 '.$cmdline[$e].';';
#print "<hr> $cmdx";
my $cmdout=`$cmdx`;
}



print "<pre>";
STDOUT->autoflush(1); 

open(my $fh, '-|', 'ssh', 'root@'.$in{'fromnodeip'}.'', 'tail', '-f', '/var/vdcsitemanager/nodes-logs/'.$in{'vmid'}.'-datasync.log') or die "Cannot open file: $!";

while (my $line = <$fh>) {
    print $line;
}

close($fh);

print "</pre>";



print "</body></html>";
