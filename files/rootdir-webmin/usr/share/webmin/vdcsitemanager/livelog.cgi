#!/usr/bin/perl
##Updated : 07-Aug-2023
use strict;
use warnings;
use JSON::PP;


use DBI;
use WebminCore;
  init_config();

&ReadParse();

#print "Content-type: text/csv\n";
#print "Content-Disposition: attachment; filename=exportuser-".$in{'vpopmaildomain'}.".csv\n\n";
#print "Content-type: text/plain\n\n";
print "Content-type: text/html\n\n";
my $pop='
function popupboxfull(x,h1,w1)
{
var w=screen.width;var h=screen.height;
var livephonewin=window.open(x, "_blank", "toolbar=no, scrollbars=yes, resizable=yes, top="+h+", left="+w+", width="+w1+", height="+h1+"");
}

';
print "aaa ";

