#!/usr/bin/perl
use strict;
use warnings;
use JSON;
use utf8;
use LWP::Simple;

#	Hier werden einige globale Parameter festgelegt
#	wie zum Beispiel der absolute Speicherpfad der Freifunk JSON.


our $json_source = "/var/www/meshviewer/nodes.json";
our $json_graph = "/var/www/meshviewer/graph.json";
our $export = "/var/www/FFNodeList/index.html";
our $html_ffbsee;
our $ffcommunity = "Freifunk Bodensee";
our $ffLink = "https://freifunk-bodensee.net/";
our $fftitle = "Freifunk Node Liste";
our $ffSupernode = `hostname`;
our $debug;

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
    my $daten;
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
    my $graphdaten;
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

my $url = 'http://vpn1.ffbsee.de/freifunk/firmware/autoupdater/manifest';
my $content = get( $url );
my @wort = split /\n/, $content;
$content = $wort[23];
@wort = split / /, $content;
our $firmware = $wort[1];
our $ffC = 0;
#
#	Generiert das HTML:
#
$html_ffbsee .= "<!doctype html>\n<html>\n  <head>\n    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">";
$html_ffbsee .= "\n";
$html_ffbsee .= "\n    <meta http-equiv=\"content-type\" content=\"text/html; charset=ISO-8859-1\">";
$html_ffbsee .= "\n    <title>$fftitle</title>\n";
#	CSS
$html_ffbsee .= "\n    <style>\n        table {\n            width: 100%;\n        }\n\n        th {\n            cursor: default;\n        }\n\n        thead th:hover {\n            text-decoration: underline;\n        }\n";
$html_ffbsee .= ".online {\nbackground-color: rgba(128, 255, 128, 0.4);\n}\n.offline {\nbackground-color: rgba(255, 128, 128, 0.07)\n}\n";
$html_ffbsee .= "\n        .amount {\n            text-align: right;\n        }\n\n        .skip-sort {\n            background-color: black;\n            color: white;\n        }\n";
$html_ffbsee .= "ul {\n    list-style-type: none;\n    margin: -5px;\n    padding: 0;\n    overflow: hidden;\n    background-color: #333;\n}\n\nli {\n    float: left;\n}\n\nli a {\n    display: block;\n    color: white;\n    text-align: center;\n    padding: 14px 16px;\n    text-decoration: none;\n}\n\nli a:hover {\n    background-color: #111;\n}\n";
$html_ffbsee .= ".g2  {\noverflow: hidden;\nmargin: auto\noverflow-x: hidden;\nwidth: 50%;\nmargin-left: 50%;\ntext-align; right;\nmin-height: 16em;\n margin-top: -8em;\nmargin-bottom: -8em;\n\n}\n";
$html_ffbsee .= "\n.generated {\noverflow: hidden;\noverflow-x: hidden;\nbackground-color: rgba(128, 255, 172, 0.4);\n min-width: 15em;\ntext-align: center;\nmargin: auto;\nmargin-right: -20em;\nmargin-top: 6em;\npadding: 0.4em;\npadding-left: 23em;\npadding-right: 23em;\n    -webkit-transform: rotate(20deg);\n    -moz-transform: rotate(20deg);\n    -o-transform: rotate(20deg);\n    writing-mode: lr-tb;\n}\n";
$html_ffbsee .= "thead tr {\nbackground: rgba(0, 255, 255, 0.7);\npadding-top: 1em;\npadding-bottom: 0.5em;\n}\n";
$html_ffbsee .= "tfoot tr {\nbackground: rgba(0, 255, 255, 0.7);\npadding-top: 1em;\npadding-bottom: 0.5em;\ntext-align: center;\n}\n";
$html_ffbsee .= "tfoot {\ntext-align: center;\n}\n";
$html_ffbsee .= "\n        .odd {\n       background-color: rgba(180, 200, 255, 0.7);\n        }\n\n    </style>\n";

#
#	Generate FFNodes
#
$html_ffbsee .= "  </head>\n\n  <body>\n";
$html_ffbsee .= "<ul>";
$html_ffbsee .= "<li><a href=\"$ffLink\">$ffcommunity</a></li><li><a href=\"https://$ffSupernode/\">$ffSupernode</a></li>\n";
$html_ffbsee .= "<li><a href=\"https://$ffSupernode/meshviewer/\">Meshviewer</a></li>";
$html_ffbsee .= "<li><a href=\"https://www.freifunk-karte.de/?lat=47.74579&lng=9.43314&z=10\">freifunk-karte.de</a></li>";
$html_ffbsee .= "<li><a style=\"cursor: pointer;\" onclick=\"hide()\">Erweiterte Ansicht</a></li>";
$html_ffbsee .= "</ul>";
our $ffDate = "<!--";
our $ffHwP = 0;
$ffDate .= $ffbsee_json->{"meta"}->{"timestamp"};
$ffDate .= " <br/> -->";
$ffDate .= `date`;
$html_ffbsee .= "    <h1>$fftitle</h1>\n";
$html_ffbsee .= "\n<div id=\"adv\" class=\"g2\"><div class=\"generated\"><a>Aktualisiert: $ffDate</a></div></div>\n";
$html_ffbsee .= "\n    <table class=\"sortable\">\n      <thead>\n        <tr>\n";
$html_ffbsee .= "     <th class=\"str-sort\">Name:</th>\n           <th class=\"str-sort\">Status:</th>\n           <th class=\"float-sort\" id=\"adv\">Uptime: (Stunden)</th>\n";
$html_ffbsee .= "        <th class=\"float-sort\" style=\"adv\">Verbindungen</th>\n        <th id=\"adv\" class=\"float-sort\">Clients:</th>\n";
$html_ffbsee .= "<!--          <th class=\"float-sort\">WLAN Links:</th>\n           <th class=\"float-sort\">VPN:</th>-->\n           <th class=\"str-sort\">Geo:</th>\n";
$html_ffbsee .= "          <th class=\"str-sort\">Firmware:</th>\n           <th class=\"str-sort\">Hardware:</th>\n           <th class=\"str-sort\">Community:</th>\n";
$html_ffbsee .= "        </tr>\n      </thead>\n";#      <tfoot>\n        <tr>\n";
  #$html_ffbsee .= "          <th>Name</th>\n          <th>name</th>\n          <th>amount</th>\n";
  #$html_ffbsee .= "        </tr>\n      </tfoot>";
$html_ffbsee .= "\n       <tbody>\n";
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
        $html_ffbsee .= "<tr class=\"even\">";
    } else { $html_ffbsee .= "<tr class=\"odd\">"; $runXTime = 1; }
    if ($debug) { print "$ffkey\n"; }
    my $ffNodeName = $ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"hostname"};
    my $ffNodeLnk = $ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"node_id"};
    $html_ffbsee .= "<td><a href=\"https://$ffSupernode/meshviewer/#!v:m;n:$ffNodeLnk\" target=\"_blank\">$ffNodeName</a></td>";
    my $ffNodeOnline = $ffbsee_json->{"nodes"}->{"$ffkey"}->{"flags"}->{"online"};
    my $ffNodeURL;
    if (defined($ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"network"}->{"addresses"}->[1])){
        $ffNodeURL .= " href=\"http://[";
        $ffNodeURL .= $ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"network"}->{"addresses"}->[1];
        $ffNodeURL .= "]/\"";
    }
    else { $ffNodeURL = "";}
    if (($ffNodeOnline eq "true") or ($ffNodeOnline eq 1) or ($ffNodeOnline eq "True")){
        $html_ffbsee .= "<td class=\"online\"><a $ffNodeURL>online</a></td>";
        $ffNodesOnline = int($ffNodesOnline) + 1;
    }
    else {
        $html_ffbsee .= "<td class=\"offline\"><a>offline</a></td>";
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

    $ffNodesInsg = $ffNodesInsg + 1;
    my $ffClients = $ffbsee_json->{"nodes"}->{"$ffkey"}->{"statistics"}->{"clients"};
    $html_ffbsee .= "<td>$ffClients</td>";
    
    $ffClientInsg = $ffClientInsg + $ffClients;
#    $html_ffbsee .= "<td></td>"; #WLAN Links
#    $html_ffbsee .= "<td></td>"; #VPN
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

    my $ffHardware;
    if (defined($ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"hardware"}->{"model"})){
        $ffHardware = $ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"hardware"}->{"model"};
        $ffHwP = $ffHwP + 1;
    } else {$ffHardware = "";}
    $html_ffbsee .= "<td>$ffHardware</td>";

    my $ffCommunity = $ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"system"}->{"site_code"};
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
}

$html_ffbsee .= "<tfoot>\n<tr>\n<td>$ffNodesOnline von $ffNodesInsg Freifunk Nodes sind derzeit online</td>\n<td></td>\n";
$html_ffbsee .= "<td id=\"adv\"></td>"; #uptime
$html_ffbsee .= "<td id=\"adv\">$ffVerbindungen<br/>Verbindungen</td>"; #verbindungen
$html_ffbsee .= "<td>$ffClientInsg<br/>Clients online</td>\n";
my $ffNodeGeoP = 100 / int($ffNodesInsg) * int($ffNodeGeo);
my $ffNodeGeoPS = int(100 * $ffNodeGeoP + 0.5 ) / 100;
$html_ffbsee .= "<td id=\"adv\">$ffNodeGeoPS%<br/>mit Koordinaten</td>\n";
my $ffNodeFWP = int(100 * 100 / int($ffNodesInsg) * int($ffNodeFW) + 0.5) / 100;
$html_ffbsee .= "<td>$ffNodeFWP%<br/>mit $firmware</td>\n";
my $ffHw = int(100 * 100 / int($ffNodesInsg) * int($ffHwP) + 0.5) / 100;
$html_ffbsee .= "<td id=\"adv\">$ffHw% der Nodes<br/>geben Ihre Hardware bekannt</td>";
$html_ffbsee .= "<td>";
if ($ffCB > 0){
    $html_ffbsee .= "$ffCB bodensee<br/>";
}
if ($ffCFn > 0){
    $html_ffbsee .= "$ffCFn friedrichshafen<br/>";
}
if ($ffCU > 0){
    $html_ffbsee .= "$ffCU ueberlingen";
}
if ($ffCT > 0){
    $html_ffbsee .= "$ffCT tettnang";
}
$html_ffbsee .= "\n</tr>\n</tfoot>\n";
#
#	EOFFNodes
#
$html_ffbsee .= "\n        </tbody>\n    </table>\n\n<script src=\"sortableTables.js\"></script>\n\n\n";
$html_ffbsee .="<script>\nfunction hide() {\n    var x = document.getElementById('advt');\n    if (x.style.display === 'none') {\n        x.style.display = 'block';\n    } else {\n        x.style.display = 'none';\n    }\n}\n</script>\n\n";
$html_ffbsee .= "\n</body>\n</html>\n";
#	Öffne eine Datei und generiere das JSON

open (DATEI, "> $export") or die $!;
    print DATEI $html_ffbsee;
   
close (DATEI);
print"FFListe wurde erzeugt!\n";
