#!/usr/bin/perl
##Updated : 07-Aug-2023
use DBI;
use WebminCore;
  init_config();
  
$showheadernow=1;


if($showheadernow==1)
{
 ui_print_header(undef, 'VDC Site Manager', '');
}


print "<center>";
  print ui_table_start('Management for '.$in{'vpopmaildomain'}, 'width=100% align=center', 8);
  print ui_table_row('<a href=\'index.cgi?fun=adduser&vpopmaildomain='.$in{'vpopmaildomain'}.'&\'>Add Email User</a>');
  print ui_table_row('<a href=\'index.cgi?fun=listuser&vpopmaildomain='.$in{'vpopmaildomain'}.'&\'>Manage Email Users</a>');
  print ui_table_row('<a href=\'index.cgi?fun=searchuser&vpopmaildomain='.$in{'vpopmaildomain'}.'&\'>Search Users</a>');
  print ui_table_row('<a href=\'index.cgi?fun=exportuser&vpopmaildomain='.$in{'vpopmaildomain'}.'&\'>Export Users</a>');
  print ui_table_row('<a href=\'index.cgi?fun=addalias&vpopmaildomain='.$in{'vpopmaildomain'}.'&\'>Add Email Alias</a>');
  print ui_table_row('<a href=\'index.cgi?fun=listalias&vpopmaildomain='.$in{'vpopmaildomain'}.'&\'>Manage Email Alias</a>');
  print ui_table_row('<a href=\'index.cgi?fun=addlist&vpopmaildomain='.$in{'vpopmaildomain'}.'&\'>Add Group Mailing List</a>');
  print ui_table_row('<a href=\'index.cgi?fun=managelist&vpopmaildomain='.$in{'vpopmaildomain'}.'&\'>Manage Group Mailing List</a>');

  print ui_table_end();
  

