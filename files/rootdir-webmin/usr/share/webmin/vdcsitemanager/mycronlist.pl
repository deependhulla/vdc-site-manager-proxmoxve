#!/usr/bin/perl

# 1. Entry: Minute when the process will be started [0-60]
# 2. Entry: Hour when the process will be started [0-23]
# 3. Entry: Day of the month when the process will be started [1-28/29/30/31]
# 4. Entry: Month of the year when the process will be started [1-12]
# 5. Entry: Weekday when the process will be started [0-6] [0 is Sunday]

sub getcronlist 
{
$gett = $_[0]; 
my @cronvalue=();my @crontitle=();my $c=0;
$cronvalue[$c]="*/10 * * * *";$crontitle[$c]="Every 10 minutes";$c++;
$cronvalue[$c]="*/20 * * * *";$crontitle[$c]="Every 20 minutes";$c++;
$cronvalue[$c]="*/30 * * * *";$crontitle[$c]="Every 30 minutes";$c++;
$cronvalue[$c]="*/40 * * * *";$crontitle[$c]="Every 40 minutes";$c++;
$cronvalue[$c]="*/50 * * * *";$crontitle[$c]="Every 50 minutes";$c++;
$cronvalue[$c]="0 * * * *";$crontitle[$c]="Every hour";$c++;
$cronvalue[$c]="0 */2 * * *";$crontitle[$c]="Every 2 hours";$c++;
$cronvalue[$c]="0 */4 * * *";$crontitle[$c]="Every 4 hours";$c++;
$cronvalue[$c]="0 */6 * * *";$crontitle[$c]="Every 6 hours";$c++;
$cronvalue[$c]="0 */12 * * *";$crontitle[$c]="Every 12 hours";$c++;
$cronvalue[$c]="0 */24 * * *";$crontitle[$c]="Every 24 hours";$c++;
$cronvalue[$c]="0 1 * * 5";$crontitle[$c]="Every Fri @ 01:00";$c++;
$cronvalue[$c]="0 1 * * 5";$crontitle[$c]="Every Fri @ 02:00";$c++;
$cronvalue[$c]="0 1 * * 5";$crontitle[$c]="Every Fri @ 03:00";$c++;
$cronvalue[$c]="0 1 * * 5";$crontitle[$c]="Every Fri @ 04:00";$c++;
$cronvalue[$c]="0 1 * * 6";$crontitle[$c]="Every Sat @ 01:00";$c++;
$cronvalue[$c]="0 1 * * 6";$crontitle[$c]="Every Sat @ 02:00";$c++;
$cronvalue[$c]="0 1 * * 6";$crontitle[$c]="Every Sat @ 03:00";$c++;
$cronvalue[$c]="0 1 * * 6";$crontitle[$c]="Every Sat @ 04:00";$c++;
$cronvalue[$c]="0 1 * * 0";$crontitle[$c]="Every Sun @ 01:00";$c++;
$cronvalue[$c]="0 1 * * 0";$crontitle[$c]="Every Sun @ 02:00";$c++;
$cronvalue[$c]="0 1 * * 0";$crontitle[$c]="Every Sun @ 03:00";$c++;
$cronvalue[$c]="0 1 * * 0";$crontitle[$c]="Every Sun @ 04:00";$c++;


if($gett eq "value"){return @cronvalue;}
if($gett eq "title"){return @crontitle;}

}
true;
