<?php
error_reporting(E_ERROR);

if($argv[1] =="" || $argv[2] =="" || $argv[3] =="" || $argv[4] =="" || $argv[5] =="" || $argv[6] =="" || $argv[7] =="" )
{
print "NEED INFORMATION <CEPHPOOLNAME> <ERASURECODE0/1> <VMID> <VMDISKNAME> <FROMNODEIP> <TONODEIP> <UIDXFORLOG>";
print "\nExample : \n";
print "php sync-vm-disk-data-to-another-cluster.php starceph 0 706 vm-706-disk-1 192.168.40.146 192.168.30.114 1701687925\n";
exit;
}


$debugnow=1;

$cephpoolname=$argv[1];
$cephpoolec=$argv[2];
$checkvmid=$argv[3];
$keyimg=$argv[4];
$selffromip=$argv[5];
$drserversship=$argv[6];
$drserversshport="22";
$uidx=$argv[7];

$keeplastsnapshot=3;

#######
$keyimg=str_replace("\n","",$keyimg);
$keyimg=str_replace("\r","",$keyimg);
$keyimg=str_replace("\t","",$keyimg);
$keyimg=str_replace("\0","",$keyimg);

if($keyimg=="")
{
print "Please Provide the image name example : vm-100-disk-0 ";
}
if($keyimg!="")
{
$cephpool=$cephpoolname;
$cephdata='';
if($cephpoolec==1)
{

$cephdata=$cephpoolname.'-data';
$cephpool=$cephpoolname.'-metadata';
}
###################################
$hlog='/var/vdcsitemanager/nodes-logs/'.$checkvmid.'-'.$uidx.'-datasync.log';
`touch $hlog`;
print "LOG : $hlog\n";
#$drimg="livedr-".$keyimg;
$drimg=$keyimg;
$cmdx="ssh -p ".$drserversshport." ".$drserversship." rbd ls ".$cephpool." | grep ".$drimg."";
if($debugnow==1){
$logx="".date('Y-m-d H:m:s')." ".$uidx." ".$checkvmid." ".$keyimg." ";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx="CHECK IF IMG THERE ON REMOTE SERVER\n";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx="".date('Y-m-d H:m:s')." ".$uidx." ".$checkvmid." ".$keyimg." ";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx=$cmdx."\n";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);

}
$cmdxout=`$cmdx`;$cmdxout=str_replace("\n","",$cmdxout);$cmdxout=str_replace("\r","",$cmdxout);

if($cmdxout=="")
{
$cmdx="ssh -p ".$drserversshport." ".$drserversship." rbd create ".$cephpool."/".$drimg." -s 1";
if($cephpoolec==1)
{
##rbd create livedr-vm-102-disk-0 -s 1 --data-pool ec21-data --pool ec21-metadata
$cmdx="ssh -p ".$drserversshport." ".$drserversship." rbd create ".$drimg." -s 1 --data-pool ".$cephdata." --pool ".$cephpool."";
}
if($debugnow==1){
$logx="".date('Y-m-d H:m:s')." ".$uidx." ".$checkvmid." ".$keyimg." ";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx="CREATING FIRST TIME IMG ON REMOTE SERVER\n";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx="".date('Y-m-d H:m:s')." ".$uidx." ".$checkvmid." ".$keyimg." ";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx=$cmdx."\n";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);

}

$cmdxout=`$cmdx`;$cmdxout=str_replace("\n","",$cmdxout);$cmdxout=str_replace("\r","",$cmdxout);
}

$curtime=date('Y-m-d_h-i-s')."__".microtime(true);
#create CURRENT's snapshot on SOURCEPOOL

$cmdx="rbd snap ls ".$cephpool."/".$keyimg." | grep ".$curtime."";
if($debugnow==1){
$logx="".date('Y-m-d H:m:s')." ".$uidx." ".$checkvmid." ".$keyimg." ";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx="CHECK IF BY MISTAKE CURTIME SNAPSHOT ON SOURCE IS THERE\n";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx="".date('Y-m-d H:m:s')." ".$uidx." ".$checkvmid." ".$keyimg." ";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx=$cmdx."\n";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);

}
$cmdxout=`$cmdx`;$cmdxout=str_replace("\n","",$cmdxout);$cmdxout=str_replace("\r","",$cmdxout);

if($cmdxout=="")
{
$cmdx="rbd snap create ".$cephpool."/".$keyimg."@".$curtime."";
if($debugnow==1){

$logx="".date('Y-m-d H:m:s')." ".$uidx." ".$checkvmid." ".$keyimg." ";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx="CREATE SNAPSHOT ON SOURCE\n";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx="".date('Y-m-d H:m:s')." ".$uidx." ".$checkvmid." ".$keyimg." ";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx=$cmdx."\n";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);

}
$cmdxout=`$cmdx`;$cmdxout=str_replace("\n","",$cmdxout);$cmdxout=str_replace("\r","",$cmdxout);

}


$cmdx="ssh -p ".$drserversshport." ".$drserversship."  rbd snap ls ".$cephpool."/".$drimg." 2>/dev/null | grep -v \"SNAPID\" | sort -rn | head -n 1 |awk '{print $2}'";
if($debugnow==1){
$logx="".date('Y-m-d H:m:s')." ".$uidx." ".$checkvmid." ".$keyimg." ";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx="CHECK IF SNAPSHOT ON REMOTE IS THERE AND GET LAST SNAPSNOT-IMAGE-NAME\n";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx="".date('Y-m-d H:m:s')." ".$uidx." ".$checkvmid." ".$keyimg." ";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx=$cmdx."\n";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);

}
$cmdxout=`$cmdx`;$cmdxout=str_replace("\n","",$cmdxout);$cmdxout=str_replace("\r","",$cmdxout);
$lastsnapid=$cmdxout;

if($lastsnapid=="")
{
$cmdx="rbd export-diff ".$cephpool."/".$keyimg."@".$curtime." - | ssh -p ".$drserversshport." ".$drserversship." rbd import-diff - ".$cephpool."/".$drimg."  ";
if($debugnow==1){
$logx="".date('Y-m-d H:m:s')." ".$uidx." ".$checkvmid." ".$keyimg." ";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx="TRANSFER THE FIRST SNAPSHOT TO REMOTE\n";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx="".date('Y-m-d H:m:s')." ".$uidx." ".$checkvmid." ".$keyimg." ";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx=$cmdx."\n";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);

}
system($cmdx);

}

if($lastsnapid!="")
{
$lastsnapid=$cmdxout;
$cmdx="rbd export-diff --from-snap ".$lastsnapid." ".$cephpool."/".$keyimg."@".$curtime." - | ssh -p ".$drserversshport." ".$drserversship." rbd import-diff - ".$cephpool."/".$drimg."  ";
if($debugnow==1){
$logx="".date('Y-m-d H:m:s')." ".$uidx." ".$checkvmid." ".$keyimg." ";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx="TRANSFER THE LATEST SNAPSHOT TO REMOTE FROM LASTSNAPSHOT IT HAD ON REMOTE\n";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx="".date('Y-m-d H:m:s')." ".$uidx." ".$checkvmid." ".$keyimg." ";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx=$cmdx."\n";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
}
system($cmdx);
}



$cmdx="ssh -p ".$drserversshport." ".$drserversship."  rbd snap ls ".$cephpool."/".$drimg." 2>/dev/null | grep -v \"SNAPID\" | sort -rn |awk '{print $2}'";
if($debugnow==1){
$logx="".date('Y-m-d H:m:s')." ".$uidx." ".$checkvmid." ".$keyimg." ";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx="CHECK IF SNAPSHOT ON REMOTE IS THERE AND GET LAST SNAPSHOT-IMAGE-NAME FOR VERIFY\n";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx="".date('Y-m-d H:m:s')." ".$uidx." ".$checkvmid." ".$keyimg." ";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx="AND WORK ON CLEAN UP OF OLD SNAPSHOT IF ANY (KEEP $keeplastsnapshot)\n";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx="".date('Y-m-d H:m:s')." ".$uidx." ".$checkvmid." ".$keyimg." ";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx=$cmdx."\n";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);

}
$cmdxout=`$cmdx`;
$snaplist=array();
$snaplist=explode("\n",$cmdxout);
$lastcopy=0;
if($snaplist[sizeof($snaplist)-1] == $curx){$lastcopy=1; }

for($i=1;$i<sizeof($snaplist);$i++)
{
if($snaplist[$i]!="" && $lastcopy ==1)
{
## looks like last sync was good we can delete old
$todelnow=0;
if($keeplastsnapshot < $i ){$todelnow=1;}
if($todelnow==1)
{
$cmdx="ssh -p ".$drserversshport." ".$drserversship."  rbd snap remove ".$cephpool."/".$drimg."@".$snaplist[$i]." 2>/dev/null ";
if($debugnow==1){
$logx="".date('Y-m-d H:m:s')." ".$uidx." ".$checkvmid." ".$keyimg." ";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx="REMOVE OLD SNAPSHOT ON REMOTE\n";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx="".date('Y-m-d H:m:s')." ".$uidx." ".$checkvmid." ".$keyimg." ";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx=$cmdx."\n";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);

}
system($cmdx);
}
}
}



$cmdx="rbd snap ls ".$cephpool."/".$keyimg." 2>/dev/null | grep -v \"SNAPID\" | sort -rn |awk '{print $2}'";
if($debugnow==1){
$logx="".date('Y-m-d H:m:s')." ".$uidx." ".$checkvmid." ".$keyimg." ";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx="WORK ON CLEAN UP OF OLD SNAPSHOT IF ANY ON LOCAL (KEEP $keeplastsnapshot)\n";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx="".date('Y-m-d H:m:s')." ".$uidx." ".$checkvmid." ".$keyimg." ";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx=$cmdx."\n";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
}
$cmdxout=`$cmdx`;
$snaplist=array();
$snaplist=explode("\n",$cmdxout);

for($i=1;$i<sizeof($snaplist);$i++)
{
if($snaplist[$i]!="" && $lastcopy ==1)
{
## looks like last sync was good we can delete old
$todelnow=0;
if($keeplastsnapshot < $i ){$todelnow=1;}
if($todelnow==1)
{
$cmdx=" rbd snap remove ".$cephpool."/".$keyimg."@".$snaplist[$i]." 2>/dev/null ";
if($debugnow==1){
$logx="".date('Y-m-d H:m:s')." ".$uidx." ".$checkvmid." ".$keyimg." ";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx="REMOVE OLD SNAPSHOT ON REMOTE\n";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx="".date('Y-m-d H:m:s')." ".$uidx." ".$checkvmid." ".$keyimg." ";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx=$cmdx."\n";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
}
system($cmdx);
}
}
}

$cmdx="rbd du '".$cephpool."/".$keyimg."' ";
if($debugnow==1){
$logx="".date('Y-m-d H:m:s')." ".$uidx." ".$checkvmid." ".$keyimg." ";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx="RDB DU INFO LOCAL\n";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx="".date('Y-m-d H:m:s')." ".$uidx." ".$checkvmid." ".$keyimg." ";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx=$cmdx."\n";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
}
$cmdxout=`$cmdx`;
print $cmdxout;


$cmdx="ssh -p ".$drserversshport." ".$drserversship."  rbd du '".$cephpool."/".$keyimg."' ";
if($debugnow==1){
$logx="".date('Y-m-d H:m:s')." ".$uidx." ".$checkvmid." ".$keyimg." ";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx="RDB DU INFO REMOTE\n";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx="".date('Y-m-d H:m:s')." ".$uidx." ".$checkvmid." ".$keyimg." ";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
$logx=$cmdx."\n";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);
}
$cmdxout=`$cmdx`;
print $cmdxout;
$logx="".date('Y-m-d H:m:s')." ".$uidx." ".$checkvmid." ".$keyimg." ";
$logx="DATA-SYNC-TASK of  ".$keyimg." DONE : OK\n";
print $logx;file_put_contents($hlog,$logx,FILE_APPEND);

//// if key there
}

?>


