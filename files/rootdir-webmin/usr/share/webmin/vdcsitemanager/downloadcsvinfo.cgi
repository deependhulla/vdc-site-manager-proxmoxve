#!/usr/bin/perl
##Updated : 07-Aug-2023
use strict;
use warnings;
use JSON::PP;

use DBI;
use WebminCore;
  init_config();

my $csvline="";
my $lockvm=0;
&ReadParse();
my $downloadcsvinfo=$in{'tmpfile'};
my @rows = split(/---/, $downloadcsvinfo);
print "Content-type: text/csv\n";
print "Content-Disposition: attachment; filename=cluster-vm-info-".$rows[0].".csv\n\n";
#print "Content-type: text/plain\n\n";
my $csvfile="/tmp/read-".$downloadcsvinfo;
open(OUTOAZ,"<$csvfile");
while(<OUTOAZ>)
{
print $_;
}
close(OUTOAZ);

