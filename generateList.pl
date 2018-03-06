#!/usr/bin/perl
use strict;
use warnings;
use JSON;
use utf8;
use LWP::Simple;
use HTML::Entities;
our $firmware = "1.0.3"; #aktuelle Firmware Version

#	Hier werden einige globale Parameter festgelegt
#	wie zum Beispiel der absolute Speicherpfad der Freifunk JSON.
our     @author = ("Freifunk Bodensee", "L3D");
our     $lizenz = "CC-BY-NC";

our $root = "/var/www";
our $json_source = "$root/meshviewer/nodes.json";
our $json_graph = "$root/meshviewer/graph.json";
our $export = "$root/FFNodeList/liste.html";
our $html_ffbsee;
our $export_minimal = "$root/FFNodeList/index.html";
our $html_minimal;
our $ffcommunity = "Freifunk Bodensee";
our $ffLink = "https://freifunk-bodensee.net/";
our $fftitle = "Freifunk Node Liste";
our $ffSupernode = `hostname`;
our $ff_statistik = "https://s.ffbsee.de/";
chomp $ffSupernode;
our $debug;
our $community_freifunk_karte = "https://www.freifunk-karte.de/?lat=47.74579&lng=9.43314&z=10";
our $prefix = "fdef:1701:b5ee:42:";

while (my $arg = shift @ARGV) {
    #Komandozeilenargumente: #print "$arg\n";
    if (($arg eq "-h") or ($arg eq "h") or ($arg eq "--help")){
        print "Dieses Script generiert eine sortierbare Liste von allen FFBSee Nodes\nBasierend auf den JSON file vom Meshviewer in der location $json_source\n";
        print "\n\n --debug\t Debuging\n";
		print "\n";
		exit(0);
    }
	if ($arg eq "--debug"){
	    $debug = "True";
	}
	
}
if (not($debug)){sleep 0.42;}
#
#  nodes.json
#
open(DATEI, $json_source) or die "Datei nodes.json wurde nicht gefunden\n";
    my $daten = "";
    while(<DATEI>){
         $daten = $daten.$_;
    }
close (DATEI);
our $json_text = $daten;
our $json = JSON->new->utf8; #force UTF8 Encoding
our $ffbsee_json = $json->decode( $json_text ); #decode nodes.json
#
#  graph.json
#
open(DATEI, $json_graph) or die "Datei graph.json wurde nicht gefunden\n";
    my $graphdaten = "";
    while(<DATEI>){                                                                                                                                 
         $graphdaten = $graphdaten.$_; 
    }
close (DATEI);
our $json_text_graph = $graphdaten;
our $jsongraph = JSON->new->utf8; #force UTF8 Encoding
our $ffbsee_graph = $jsongraph->decode( $json_text_graph ); #decode graph.json
#
# Meshing auswertung (graph.json)
#  -> VPN
#
our %graph;
our %vpn;
our $ffmeshNr = 0;
our @ffmeshGraph = @{ $ffbsee_graph->{"batadv"}->{"links"} };
our $ffVerbindungen = 0;
foreach my $ffmesh ( @ffmeshGraph ) {
    if($debug){print $ffmesh; print "  ".$ffmeshNr."\n";}
    my $ffmeshTarget = $ffmesh->{"target"};
    if (not defined($graph{$ffbsee_graph->{"batadv"}->{"nodes"}->[$ffmeshTarget]->{"node_id"}})){
        $graph{$ffbsee_graph->{"batadv"}->{"nodes"}->[$ffmeshTarget]->{"node_id"}} = 1;
    }
    else {$graph{$ffbsee_graph->{"batadv"}->{"nodes"}->[$ffmeshTarget]->{"node_id"}} ++;}
    if($debug){print $graph{$ffbsee_graph->{"batadv"}->{"nodes"}->[$ffmeshTarget]->{"node_id"}}."\n";}

    my $ffmeshSource = $ffmesh->{"source"};                                                                                                         
    if (not defined($graph{$ffbsee_graph->{"batadv"}->{"nodes"}->[$ffmeshSource]->{"node_id"}})){                                                   
        $graph{$ffbsee_graph->{"batadv"}->{"nodes"}->[$ffmeshSource]->{"node_id"}} = 1;                                                             
    }                                                                                                                                               
    else {$graph{$ffbsee_graph->{"batadv"}->{"nodes"}->[$ffmeshSource]->{"node_id"}} ++;} 
    $ffVerbindungen ++;
    if($debug){$ffmeshNr = $ffmeshNr + 1;}
}
#
#  Firmware
#
our $ffNodesOnline = 0;
our $ffNodesInsg = 0;
our $ffClientInsg = 0;
our $ffNodeGeo = 0;
our $ffNodeFW = 0;


#
#	Generiert das HTML:
#
our $html_head;
$html_head .= "<!doctype html>\n<html lang=\"de\">\n  <head>\n    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">";
$html_head .= "\n";
$html_head .= "    <meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\">";
$html_head .= "\n    <title>$fftitle</title>\n    <meta name=\"description\" content=\"Eine Liste der Nodes, die bei Freifunk Bodensee aktiv sind. Dargestellt auf dem Supernode $ffSupernode.\">\n";
#	CSS
$html_head .= "    <style>\n        table {\n            width: 100%;\n        }\n\n        th {\n            cursor: default;\n        }\n\n        thead th:hover {\n            text-decoration: underline;\n        }\n";
$html_head .= "        .online {\n            background-color: rgba(128, 255, 128, 0.4);\n        }\n        .offline {\n            background-color: rgba(255, 128, 128, 0.07)\n        }\n";
$html_head .= "\n        .amount {\n            text-align: right;\n        }\n\n        .skip-sort {\n            background-color: black;\n            color: white;\n        }\n\n";
$html_head .= "        ul {\n            list-style-type: none;\n            margin: -5px;\n            padding: 0;\n            overflow: hidden;\n            background-color: #333;\n        }\n\n        li {\n            float: left;\n        }\n\n        li a {\n            display: block;\n            color: white;\n            text-align: center;\n            padding: 14px 16px;\n            text-decoration: none;\n        }\n\n        li a:hover {\n            background-color: #111;\n         }\n";
$html_head .= "        .g2  {\n            overflow: hidden;\n            margin: auto\n            overflow-x: hidden;\n            width: 50%;\n            margin-left: 50%;\n            text-align; right;\n            min-height: 16em;\n            margin-top: -8em;\n            margin-bottom: -8em;\n        }\n";
$html_head .= "\n        .generated {\n            overflow: hidden;\n             overflow-x: hidden;\n            background-color: rgba(128, 255, 172, 0.4);\n             min-width: 15em;\n            text-align: center;\n            margin: auto;\n            margin-right: -20em;\n            margin-top: 6em;\n            padding: 0.4em;\n              padding-left: 23em;\n            padding-right: 23em;\n            -webkit-transform: rotate(20deg);\n            -moz-transform: rotate(20deg);\n             -o-transform: rotate(20deg);\n            writing-mode: lr-tb;\n        }\n";
$html_head .= "        thead tr {\n            background: rgba(0, 255, 255, 0.7);\n            padding-top: 1em;\n            padding-bottom: 0.5em;\n        }\n";
$html_head .= "        tfoot tr {\n            background: rgba(0, 255, 255, 0.7);\n            padding-top: 1em;\n            padding-bottom: 0.5em;\n            text-align: center;\n        }\n";
$html_head .= "\n        tfoot {\n            text-align: center;\n        }\n";
my $rgba1 = "rgba(255,255,255,1)";
my $rgba2 = "rgba(0,142,255,1)";
my $rgba3 = "rgba(0, 132, 255, 0.12)";
my $rgba4 = "rgba(255,255,255,0.1)";
my $rgba6 = "rgba(0, 255, 255, 0.15)";
my $rgba5 = "rgba(55,255,100,0.2)";
$html_head .= "\n        tfoot, thead {\n            height: 2.3em;\n            background: no-repeat center center,-moz-linear-gradient(top,    $rgba1, $rgba2);\n            background: no-repeat center center,-webkit-linear-gradient(top, $rgba1, $rgba2);\n            background: no-repeat center center,-o-linear-gradient(top,      $rgba1, $rgba2);\n            background: no-repeat center center,-ms-linear-gradient(top,     $rgba1, $rgba2);\n            background: no-repeat center center,linear-gradient(top,         $rgba1, $rgba2);\n        }\n";
$html_head .= "\n         thead td:hover, thead th:hover {\n            background: no-repeat center center,-moz-linear-gradient(top,    $rgba2, $rgba1);\n            background: no-repeat center center,-webkit-linear-gradient(top, $rgba2, $rgba1);\n            background: no-repeat center center,-o-linear-gradient(top,      $rgba2, $rgba1);\n            background: no-repeat center center,-ms-linear-gradient(top,     $rgba2, $rgba1);\n            background: no-repeat center center,linear-gradient(top,         $rgba2, $rgba1);\n        }\n";
$html_head .= "\n        tr{\n            height: 1.8em;\n                 \n            background: no-repeat center center,-moz-linear-gradient(top,    $rgba3, $rgba4);\n            background: no-repeat center center,-webkit-linear-gradient(top, $rgba3, $rgba4);\n            background: no-repeat center center,-o-linear-gradient(top,      $rgba3, $rgba4);\n            background: no-repeat center center,-ms-linear-gradient(top,     $rgba3, $rgba4);\n            background: no-repeat center center,linear-gradient(top,         $rgba3, $rgba4);\n\n            \n        }\n";
$html_head .= "\n        tr:hover {\n            height: 1.8em;\n                 \n            background: no-repeat center center,-moz-linear-gradient(top,    $rgba5, $rgba6);\n            background: no-repeat center center,-webkit-linear-gradient(top, $rgba5, $rgba6);\n            background: no-repeat center center,-o-linear-gradient(top,      $rgba5, $rgba6);\n            background: no-repeat center center,-ms-linear-gradient(top,     $rgba5, $rgba6);\n            background: no-repeat center center,linear-gradient(top,         $rgba5, $rgba6);\n\n            \n        }\n";    
#$html_head .= "\n        .odd {\n            background-color: rgba(180, 200, 255, 0.7);\n        }";
$html_head .= "\n\n    </style>\n";
#
#
$html_ffbsee .= $html_head;
$html_minimal .= $html_head;

#
#	Generate FFNodes
#
our $html_body;
$html_body .= "  </head>\n\n<body>\n";
$html_body .= "<ul>";
$html_body .= "<li><a href=\"$ffLink\">$ffcommunity</a></li>\n<li><a href=\"https://$ffSupernode/\">$ffSupernode</a></li>\n";
$html_body .= "<li><a href=\"https://$ffSupernode/meshviewer/\">Meshviewer</a></li>\n";
$html_body .= "<li><a href=\"$community_freifunk_karte\">freifunk-karte.de</a></li>\n<li><a href=\"$ff_statistik\">Statistik</a></li>\n";
$html_ffbsee .= $html_body;
$html_minimal .= $html_body;
$html_ffbsee .= "<li><a href=\"https://$ffSupernode/FFNodeList/index.html\">Minimale Ansicht</a></li>";
$html_minimal .= "<li><a href=\"https://$ffSupernode/FFNodeList/liste.html\">Erweiterte Ansicht</a></li>";
$html_ffbsee .= "</ul>";
$html_minimal .= "</ul>";
our $ffDate = "<!--";
our $ffHwP = 0;
$ffDate .= $ffbsee_json->{"meta"}->{"timestamp"};
$ffDate .= " <br/> -->";
$ffDate .= `date`;
$html_ffbsee .= "    <h1>$fftitle</h1>\n";
$html_minimal .= "    <h1>$fftitle</h1>\n";
$html_ffbsee .= "\n<div class=\"g2\"><div class=\"generated\"><a>Aktualisiert: $ffDate</a></div></div>\n";
$html_ffbsee .= "\n    <table class=\"sortable\">\n      <thead>\n        <tr>\n     <th class=\"str-sort\">Name:</th>\n           <th class=\"str-sort\">Status:</th>\n";
$html_minimal .= "\n    <table class=\"sortable\">\n      <thead>\n        <tr>\n     <th class=\"str-sort\">Name:</th>\n           <th class=\"str-sort\">Status:</th>\n";
$html_ffbsee .= "        <th class=\"float-sort\">Uptime: (Stunden)</th>\n        <th class=\"float-sort\" >Verbindungen</th>\n";
$html_ffbsee .= "        <th class=\"float-sort\">Clients:</th>\n";
$html_minimal .= "        <th class=\"float-sort\">Clients:</th>\n";
$html_ffbsee .= "         <th class=\"float-sort\">VPN:</th>\n           <th class=\"str-sort\">Geo:</th>\n";
$html_minimal .= "          <th class=\"str-sort\">Firmware:</th>\n";
$html_ffbsee .= "          <th class=\"str-sort\">Firmware:</th>\n           <th class=\"str-sort\">Hardware:</th>\n           <th class=\"str-sort\">Community:</th>\n";
$html_ffbsee .= "        </tr>\n      </thead>\n\n       <tbody>\n";
$html_minimal .= "        </tr>\n      </thead>\n\n       <tbody>\n";
my $runXTime = 1;
my $hashref_ffbsee = $ffbsee_json->{"nodes"};
our $ffCB = 0;
our $ffCFn = 0;
our $ffCU = 0;
our $ffUptime;
our $ffUptimeTage;
our $ffCT = 0;
for my $ffkey (keys %{$hashref_ffbsee}) {
    if ($runXTime == 1){
        $runXTime = 0;
        $html_minimal .= "<tr class=\"even\">";
        $html_ffbsee .= "<tr class=\"even\">";
    } else { $html_ffbsee .= "<tr class=\"odd\">"; $html_minimal .= "<tr class=\"odd\">"; $runXTime = 1; }
    if ($debug) { print "$ffkey\n"; }
    my $ffNodeName = $ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"hostname"};
    my $ffNodeLnk = $ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"node_id"};
    $html_ffbsee .= "<td><a href=\"https://$ffSupernode/meshviewer/#!v:m;n:$ffNodeLnk\" target=\"_blank\">".encode_entities($ffNodeName)."</a></td>";
    $html_minimal .= "<td><a href=\"https://$ffSupernode/meshviewer/#!v:m;n:$ffNodeLnk\" target=\"_blank\">".encode_entities($ffNodeName)."</a></td>";

    # Anzeige der IPv6 Adresse des FF Nodes:
    # Im minnimal:
    my $ffNodeOnline = $ffbsee_json->{"nodes"}->{"$ffkey"}->{"flags"}->{"online"};
    my $ffNodeURL;
    if (defined($ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"network"}->{"addresses"}->[0])){
        $ffNodeURL .= " href=\"http://[";
        my $ff_url = $ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"network"}->{"addresses"}->[0];
        if ($ff_url =~ "fdef:1701:b5ee:42::"){
            $ff_url = $ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"network"}->{"addresses"}->[1];
            if ($debug){print "(I) choose other IPv6 address\n";}
        }
        $ffNodeURL .= "$ff_url]/\"";
    }
    else { $ffNodeURL = "";}
    # Anzeige bei Erweitert:
    our $ff_URL;
    if ($debug){print "(I) EUI64: ";}
    $ff_URL = mac2ipv6($ffkey);
    if (($ffNodeOnline eq "true") or ($ffNodeOnline eq 1) or ($ffNodeOnline eq "True")){
        $html_ffbsee .= "<td class=\"online\"><a href=\"http://[$ff_URL]/\">online</a></etd>";
        $html_minimal .= "<td class=\"online\"><a $ffNodeURL>online</a></td>";
        $ffNodesOnline = int($ffNodesOnline) + 1;
    }
    else {
        $html_ffbsee .= "<td class=\"offline\"><a>offline</a></td>";
        $html_minimal .= "<td class=\"offline\"><a>offline</a></td>";
    }
    if (($ffNodeOnline eq "true") or ($ffNodeOnline eq 1) or ($ffNodeOnline eq "True")){
        if (defined($ffbsee_json->{"nodes"}->{"$ffkey"}->{"statistics"}->{"uptime"})){
            $ffUptime = $ffbsee_json->{"nodes"}->{"$ffkey"}->{"statistics"}->{"uptime"};
            $ffUptime = $ffUptime / 3600 * 10;
            $ffUptime = int($ffUptime)/10;
        } else {$ffUptime = " ";}
    } else {$ffUptime = " ";}
    $html_ffbsee .= "<td>$ffUptime</td>"; 
    
    if (not defined($graph{$ffkey})){
        $graph{$ffkey} = 0;
    }
    $html_ffbsee .= "<td>$graph{$ffkey}</td>";

    # Clients pro FF Node:
    $ffNodesInsg = $ffNodesInsg + 1;
    my $ffClients = $ffbsee_json->{"nodes"}->{"$ffkey"}->{"statistics"}->{"clients"};
    if (($ffNodeOnline eq "true") or ($ffNodeOnline eq 1) or ($ffNodeOnline eq "True")){
        $html_ffbsee .= "<td>$ffClients</td>";
        $html_minimal .= "<td>$ffClients</td>";
        $ffClientInsg = $ffClientInsg + $ffClients;
    } else {
        $html_ffbsee .= "<td>-</td>";
        $html_minimal .= "<td>-</td>";
    }

    $html_ffbsee .= "<td></td>"; #VPN



    my $ffNodeVPN;
    if (defined($ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"location"})){
        $ffNodeVPN = "ja";
        $ffNodeGeo = $ffNodeGeo + 1;
    } else { $ffNodeVPN = "nein";}
    $html_ffbsee .= "<td>$ffNodeVPN</td>";
    my $ffNodeFirmware;
    if (defined($ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"software"}->{"firmware"}->{"release"})){
        $ffNodeFirmware = $ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"software"}->{"firmware"}->{"release"};
        if ($ffNodeFirmware eq "ffbsee-$firmware"){
            $ffNodeFW = $ffNodeFW + 1;
        }
    } else {$ffNodeFirmware = "";}
    $html_ffbsee .= "<td>$ffNodeFirmware</td>";
    $html_minimal .= "<td>$ffNodeFirmware</td>";

    my $ffHardware;
    if (defined($ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"hardware"}->{"model"})){
        $ffHardware = $ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"hardware"}->{"model"};
        $ffHwP = $ffHwP + 1;
    } else {$ffHardware = "";}
    $html_ffbsee .= "<td>$ffHardware</td>";
    my $ffCommunity;
    $ffCommunity = $ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"system"}->{"site_code"};
    if (not defined($ffCommunity)){ $ffCommunity = "bodensee";}
    $html_ffbsee .= "<td>$ffCommunity</td>";
    if ($ffCommunity eq "bodensee"){
        $ffCB = $ffCB + 1;
    }
    if ($ffCommunity eq "friedrichshafen"){
        $ffCFn = $ffCFn + 1;
    }
    if ($ffCommunity eq "ueberlingen"){
        $ffCU = $ffCU + 1;
    }
    if ($ffCommunity eq "tettnang"){
        $ffCT = $ffCT + 1;
    }
    $html_ffbsee .= "</tr>\n";
    $html_minimal .= "</tr>\n";
}

$html_ffbsee .= "</tbody>\n<tfoot>\n<tr>\n<td>$ffNodesOnline von $ffNodesInsg Freifunk Nodes sind derzeit online</td>\n<td></td>\n";
$html_minimal .= "<tfoot>\n<tr>\n<td>$ffNodesOnline von $ffNodesInsg Freifunk Nodes sind derzeit online</td>\n<td></td>\n";
$html_ffbsee .= "<td></td>"; #uptime
$html_ffbsee .= "<td>$ffVerbindungen<br/>Verbindungen</td>"; #verbindungen
$html_ffbsee .= "<td>$ffClientInsg<br/>Clients online</td>\n";
$html_minimal .= "<td>$ffClientInsg<br/>Clients online</td>\n";
$html_ffbsee .= "<td></td>\n";
my $ffNodeGeoP = 100 / int($ffNodesInsg) * int($ffNodeGeo);
my $ffNodeGeoPS = int(100 * $ffNodeGeoP + 0.5 ) / 100;
$html_ffbsee .= "<td>$ffNodeGeoPS%<br/>mit Koordinaten</td>\n";
my $ffNodeFWP = int(100 * 100 / int($ffNodesInsg) * int($ffNodeFW) + 0.5) / 100;
$html_ffbsee .= "<td>$ffNodeFWP%<br/>mit $firmware</td>\n";
$html_minimal .= "<td>$ffNodeFWP%<br/>mit $firmware<br/>Firmware</td>\n";
my $ffHw = int(100 * 100 / int($ffNodesInsg) * int($ffHwP) + 0.5) / 100;
$html_ffbsee .= "<td>$ffHw% der Nodes<br/>geben Ihre Hardware bekannt</td>";
$html_ffbsee .= "<td>";
if ($ffCB > 0){
    my $t = int(100*(100*$ffCB/$ffNodesInsg))/100;
    $t = (100 - $t);
    $html_ffbsee .= $t."%<br/>der Nodes haben Ihre<br/>Community eingestellt";
}
our $html_footer;
$html_footer .= "\n</tr>\n</tfoot>";
#
#	EOFFNodes
#
$html_footer .= "\n    </table>\n\n<script src=\"sortableTables.js\"></script>\n\n\n";
$html_footer .= "<br/>\n<div style=\"opacity: 0.42; margin-left: auto; margin-right: auto; text-align: center; color: #5eba5e;\">\n<a>Entwickelt von $author[0] auf </a><a color=\"#5eba5e\" href=\"https://github.com/ffbsee/FFNodeList\">GitHub</a>\n<br/>\n<a>Lizenz: $lizenz</a>\n</div>\n";
$html_footer .= "\n</body>\n</html>\n\n";
$html_ffbsee .= $html_footer;
$html_minimal .= $html_footer;
#	Öffne eine Datei und generiere das JSON

open (DATEI, "> $export") or die $!;
    print DATEI $html_ffbsee;
   
close (DATEI);
open (DATEI, "> $export_minimal") or die $!;
    print DATEI $html_minimal;

close DATEI;
print"FFListe wurde erzeugt!\n";

#Subrotinen:

sub mac2ipv6{
    my $ipv6addr;
    my $mac = shift;
    if (length($mac) eq 12){
    my @mac = split(//, $mac); #Teilt die Mac in 12 Zeichen auf
    my $mac1 = $mac[0];
    $mac1 .= $mac[1];
    my $mac2 = $mac[2];
    $mac2 .= $mac[3];
    my $mac3 = $mac[4];
    my $mac4 = "FF";
    my $mac5 = "FE";
    $mac3 .= $mac[5];
    my $mac6 = $mac[6];
    $mac6 .= $mac[7];
    my $mac7 = $mac[8];
    $mac7 .= $mac[9];
    my $mac8 = $mac[10];
    $mac8 .= $mac[11];
    # Nun beim ersten oktet noch das richtige bit flippen!
        
    if ($debug){ print "binaerer HEX von der Mac: ".$mac1." -> "; }
    $mac1 = sprintf( "%#b", hex( "F".$mac1 ) );
    if ($debug){ 
        print $mac1; 
        print " --> ";
    }
    my @macx = split(//, $mac1);
    my $xmac = 1;
    if ($macx[12] eq "1"){
        $xmac = 0;
    }
    my $mac01;
    my $ii = 0;
    for my $i (@macx){
        $ii++;
        if ($ii eq 13){
            $mac01 .= $xmac;
        } elsif ($ii > 6) { 
            $mac01 .= $i;
        }
    }
    $mac1 = sprintf("%X", oct( "0b$mac01" ));
    if (length($mac1) eq 1){
        $mac1 = "0$mac1";
    }
    if ($debug){print $mac01." ---> $mac1"; print "\n";}
#    $ipv6addr = $mac01.$mac2.$mac3.$mac4.$mac5.$mac6.$mac7.$mac8;
    $ipv6addr = $prefix;
    $ipv6addr .= $mac1.$mac2.":".$mac3.$mac4.":".$mac5.$mac6.":".$mac7.$mac8;
    return $ipv6addr;
} else { print "Fehler!";}}
