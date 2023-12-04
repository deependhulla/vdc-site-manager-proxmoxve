<?php
$siteid=$argv[1];
$siteip=$argv[2];

$siteinfo="/etc/webmin/vdcsitemanager/siteinfo";
## max 9 siteid allowed
if($siteid>0 && $siteip!="")
{
$cmdx="/bin/cp /etc/webmin/vdcsitemanager/ceph-storage-name /usr/local/src/vdcsitemanager-tools/nodes-tools/";
`$cmdx`;
$cmdx="/bin/cp /etc/webmin/vdcsitemanager/ceph-erasure-code /usr/local/src/vdcsitemanager-tools/nodes-tools/";
`$cmdx`;

$siteidfolder=$siteinfo."/site-info-".$siteid."/";
$cmdx="mkdir -p ".$siteidfolder." 1>/dev/null 2>/dev/null";
`$cmdx`;
$cmdx="ssh root@".$siteip." \"cat /etc/pve/.members\" > ".$siteidfolder."/host-node-list-members";
#print $cmdx;
`$cmdx`;
$jsondataout=file_get_contents($siteidfolder."/host-node-list-members");
print "\n $jsondataout\n";
$node_data=json_decode($jsondataout,true);
#var_dump($node_data);
if (isset($node_data['nodelist'])) {
    foreach ($node_data['nodelist'] as $nodeName => $nodeDetails) {
        echo "Node Name: $nodeName, IP: {$nodeDetails['ip']}\n";
$cmdx="scp -r /usr/local/src/vdcsitemanager-tools root@".$nodeDetails['ip'].":/usr/local/src/";
print "\n $cmdx \n";
`$cmdx`;
$cmdx="ssh root@".$nodeDetails['ip']." 'mkdir -p /var/vdcsitemanager/';";
print "\n $cmdx \n";
`$cmdx`;
$cmdx="ssh root@".$nodeDetails['ip']." 'mkdir -p /var/vdcsitemanager/nodes-scripts/';";
print "\n $cmdx \n";
`$cmdx`;
$cmdx="ssh root@".$nodeDetails['ip']." 'mkdir -p /var/vdcsitemanager/nodes-lock/';";
print "\n $cmdx \n";
`$cmdx`;
$cmdx="ssh root@".$nodeDetails['ip']." 'mkdir -p /var/vdcsitemanager/nodes-logs/';";
print "\n $cmdx \n";
`$cmdx`;


///per node copy done
    }
}


#/usr/local/src/vdcsitemanager-tools

print "\n";
////all info over
}
else
{
print "Please Provide SITE-ID and IP address\n of one of PVE of each site/location \n";
print "Example Site 1 for DC and Site 2 for DR: \n";
print "php first-time-only-for-site-build.php 1 192.168.40.144\n";
print "php first-time-only-for-site-build.php 2 192.168.30.112\n";
print "\n";
}

?>
