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


print "<pre>";
STDOUT->autoflush(1); 

open(my $fh, '-|', 'ssh', 'root@192.168.30.114', 'tail', '-f', '/var/vdcsitemanager/nodes-logs/901-datasync.log') or die "Cannot open file: $!";

while (my $line = <$fh>) {
    print $line;
}

close($fh);

print "</pre>";



print "</body></html>";
