#!/usr/bin/perl
use strict;
use warnings;
use JSON;
use utf8;

#	Hier werden einige globale Parameter festgelegt
#	wie zum Beispiel der absolute Speicherpfad der Freifunk JSON.

our $json_source = "/var/www/meshviewer/nodes.json";
our $export = "index.html";
our $html_ffbsee;
our $ffcommunity = "Freifunk Bodensee";
our $fflink = "https://freifunk-bodensee.net/";
our $fftitle = "Freifunk Node Liste";
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

open(DATEI, $json_source) or die "Datei wurde nicht gefunden\n";
    my $daten;
    while(<DATEI>){
         $daten = $daten.$_;
    }
close (DATEI);
our $json_text = $daten;
our $json = JSON->new->utf8; #force UTF8 Encoding
our $ffbsee_json = $json->decode( $json_text ); #decode nodes.json
#
#	Generiert das HTML:
#
$html_ffbsee .= "<!doctype html>\n<html>\n  <head>\n    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">";
#  $html_ffbsee .= "\n";
$html_ffbsee .= "\n    <meta http-equiv=\"content-type\" content=\"text/html; charset=ISO-8859-1\">";
$html_ffbsee .= "\n    <title>$fftitle</title>\n";
#	CSS
$html_ffbsee .= "\n    <style>\n        table {\n            width: 100%;\n        }\n\n        th {\n            cursor: default;\n        }\n\n        thead th:hover {\n            text-decoration: underline;\n        }\n";
$html_ffbsee .= ".online {\nbackground-color: rgba(128, 255, 128, 0.4);\n}\n.offline {\nbackground-color: rgba(255, 128, 128, 0.07)\n}\n";
$html_ffbsee .= "\n        .amount {\n            text-align: right;\n        }\n\n        .skip-sort {\n            background-color: black;\n            color: white;\n        }\n";
$html_ffbsee .= "\n        .odd {\n            background-color: rgba(180, 180, 255, 0.9);\n        }\n\n    </style>\n";

#
#	Generate FFNodes
#
$html_ffbsee .= "  </head>\n\n  <body>\n";
$html_ffbsee .= "    <h1>$fftitle</h1>\n";
$html_ffbsee .= "\n    <table class=\"sortable\">\n      <thead>\n        <tr>\n";
$html_ffbsee .= "          <th class=\"str-sort\">Name:</th>\n           <th class=\"str-sort\">Status:</th>\n           <th class=\"float-sort\">Clients:</th>\n";
$html_ffbsee .= "<!--          <th class=\"float-sort\">WLAN Links:</th>\n           <th class=\"float-sort\">VPN:</th>-->\n           <th class=\"str-sort\">Geo:</th>\n";
$html_ffbsee .= "          <th class=\"str-sort\">Firmware:</th>\n           <th class=\"str-sort\">Hardware:</th>\n           <th class=\"str-sort\">Community:</th>\n";
$html_ffbsee .= "        </tr>\n      </thead>\n";#      <tfoot>\n        <tr>\n";
  #$html_ffbsee .= "          <th>Name</th>\n          <th>name</th>\n          <th>amount</th>\n";
  #$html_ffbsee .= "        </tr>\n      </tfoot>";
$html_ffbsee .= "\n       <tbody>\n";
my $runXTime = 1;
my $hashref_ffbsee = $ffbsee_json->{"nodes"};
for my $ffkey (keys %{$hashref_ffbsee}) {
    if ($runXTime == 1){
        $runXTime = 0;
        $html_ffbsee .= "<tr class=\"even\">";
    } else { $html_ffbsee .= "<tr class=\"odd\">"; $runXTime = 1; }
    if ($debug) { print "$ffkey\n"; }
    my $ffNodeName = $ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"hostname"};
    $html_ffbsee .= "<td>$ffNodeName</td>";
    my $ffNodeOnline = $ffbsee_json->{"nodes"}->{"$ffkey"}->{"flags"}->{"online"};
    if (($ffNodeOnline eq "true") or ($ffNodeOnline eq 1) or ($ffNodeOnline eq "True")){
        $html_ffbsee .= "<td class=\"online\"><a>online</a></td>";
    }
    else {
        $html_ffbsee .= "<td class=\"offline\"><a>offline</a></td>";
    }
    my $ffClients = $ffbsee_json->{"nodes"}->{"$ffkey"}->{"statistics"}->{"clients"};
    $html_ffbsee .= "<td>$ffClients</td>";
#    $html_ffbsee .= "<td></td>"; #WLAN Links
#    $html_ffbsee .= "<td></td>"; #VPN
    my $ffNodeVPN;
    if (defined($ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"location"})){
        $ffNodeVPN = "ja";
    } else { $ffNodeVPN = "nein";}
    $html_ffbsee .= "<td>$ffNodeVPN</td>";
    my $ffNodeFirmware;
    if (defined($ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"software"}->{"firmware"}->{"release"})){
        $ffNodeFirmware = $ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"software"}->{"firmware"}->{"release"};
    } else {$ffNodeFirmware = "";}
    $html_ffbsee .= "<td>$ffNodeFirmware</td>";

    my $ffHardware;
    if (defined($ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"hardware"}->{"model"})){
        $ffHardware = $ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"hardware"}->{"model"};
    } else {$ffHardware = "";}
    $html_ffbsee .= "<td>$ffHardware</td>";

    my $ffCommunity = $ffbsee_json->{"nodes"}->{"$ffkey"}->{"nodeinfo"}->{"system"}->{"site_code"};
    $html_ffbsee .= "<td>$ffCommunity</td>";
 
    $html_ffbsee .= "</tr>\n";
}

#
#	EOFFNodes
#
$html_ffbsee .= "\n        </tbody>\n    </table>\n\n<script src=\"sortableTables.js\"></script>\n</body>\n</html>\n";
#	Öffne eine Datei und generiere das JSON

open (DATEI, "> $export") or die $!;
    print DATEI $html_ffbsee;
   
close (DATEI);
