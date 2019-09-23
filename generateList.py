#!/usr/bin/python

#* ----------------------------------------------------------------------------
#* This work is licensed under the Creative Commons Attribution-NonCommercial
#* 3.0 Germany License.
#* To view a copy of this license, visit
#* http://creativecommons.org/licenses/by-nc/3.0/de/
#* or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042,
#* USA.
#* ----------------------------------------------------------------------------/

import json
import urllib.request, urllib.parse, urllib.error
import sys
from datetime import datetime
from html_strings import *

#Settings
root = 'https://mate.ffbsee.net/'
nodes = 'nodes.json'
html_filename_list = 'liste.html'
html_filename_index = 'index.html'
html_pathname = './'
local_path  = './'
local_file = False
newest_firmware = '2.0.0'

#declaration
nodes_count = 0
location_count = 0
online_count = 0
clients_count = 0
community_count = 0
newest_firmware_count = 0
with_hardware_count = 0
html_body_long = ''
html_body_short = ''
debug = False
license = 'CC-BY-NC'
author = 'Joni Arida'
post = 'joni.arida@posteo.de'


def even_odd(i):
    if i % 2:
        return 'odd'
    else:
        return 'even'

def isonline(is_online, addresses):
    if is_online == True:
        if (addresses != '') and (len(addresses) > 0):
                return 'online"><a href="http://['+str(addresses[0])+']/">Online'
        else:
            return 'online">Online'
    else:
        return 'offline">Offline'

def have_geo(location):
    if ('latitude' in location) and ('longitude' in location):
        return 'Ja'
    else:
        return 'Nein'

def  calc_uptime(uptime):
    if uptime != '':
        uptime_datetime_obj = datetime.strptime(uptime, '%Y-%m-%d %H:%M:%S')
        uptime_diff = datetime.now() - uptime_datetime_obj
        return str(abs(uptime_diff.days * 24 ) + abs(uptime_diff.seconds // 3600)) + ':' + str(uptime_diff.seconds % 60)
    else:
        return ''

def count_connections(node_id, links):
    connections = 0
    for route in links:
        if (route['source'] == node_id) or (route['target'] == node_id):
            connections = connections + 1
    return str(connections)


if len(sys.argv) -1 > 0:
    if (sys.argv[1] == '--help')  or (sys.argv[1] == '-h'):
        print('''This script generates a sortable list of all nodes in the FFBSee network
To enable debug mode use the argument ""--debug".
The argument "--help" show this help.

Following setting can be set in the script:
* root:                 The url to the server where to find the nodes.json. e.g. https://mate.ffbsee.net/
* nodes:                File name of the jason file. e.g. nodes.json
* html_filename_list:   Name of the output html file for the long list. e.g. list.html
* html_filename_index:  Name of the output html file for the short list. e.g. index.html
* html_pathname:        Sets the outpu folder. e.g. ./
* local_path:           Where to find the nodes.json when local mode is enabled. e.g. ./
* local_file:           enable to True when a local file have to be opend
* newest_firmware:      Version of the newest firmware. 19/09 is 2.0.0

    Author: %s (%s)
    License: %s''' % ( author, post, license ))
        sys.exit(0)

    if (sys.argv[1] == '--debug') or (sys.argv[1] == '-d'):
        debug = True

if local_file == True:
    json_file = open(local_path+nodes, 'r')
    json_data = json.loads(json_file.read())
    json_file.close()
else:
    json_url = urllib.request.urlopen(root+nodes)
    json_data = json.loads(json_url.read().decode('utf-8'))

for nodes in json_data['nodes']:
    hostname = nodes['hostname']
    node_id = nodes['node_id']
    is_online = nodes['is_online']
    uptime = nodes['uptime']
    clients = nodes['clients']
    location = nodes['location']
    firmware_release = nodes['firmware']['release']
    model = nodes['model']
    site_code = nodes['site_code']
    clients = nodes['clients']
    addresses = nodes['addresses']

    if debug == True:
        print('Hostname: '+hostname)
        print('Node ID: ' +node_id)
        print('Online: ' +str(is_online))
        print('Uptime: '+str(uptime))
        print('Clients: ' +str(clients))
        print('Location: ' + str(location))
        print('firmware: ' +firmware_release)
        print('Model: ' +model)
        print('Community: ' +str(site_code))
        print('Clients: ' +str(clients))
        print('Adresses: ' +str(len(addresses)))
        print('+-----------------------------------+')

    nodes_count = nodes_count + 1

    var_odd = even_odd(nodes_count)
    var_is_online = isonline(is_online, addresses)
    var_uptime = calc_uptime(str(uptime))
    var_connections_cnt = count_connections(node_id, json_data['links'])
    var_clients = str(clients)
    var_have_geo = have_geo(location)
    var_site_code = str(site_code)


    html_body_long = html_body_long +'<tr class="'
    html_body_long = html_body_long + var_odd
    html_body_long = html_body_long + '"><td><a href="https://mate.ffbsee.net/meshviewer/#!/de/map/'
    html_body_long = html_body_long + node_id
    html_body_long = html_body_long + '" target="_blank">'
    html_body_long = html_body_long + hostname
    html_body_long = html_body_long + '</a></td><td class="'
    html_body_long = html_body_long + var_is_online
    html_body_long = html_body_long + '</etd><td>'
    html_body_long = html_body_long + var_uptime
    html_body_long = html_body_long + '</td><td>'
    html_body_long = html_body_long + var_connections_cnt
    html_body_long = html_body_long + '</td><td>'
    html_body_long = html_body_long + var_clients
    html_body_long = html_body_long + '</td><td>'
    html_body_long = html_body_long + var_have_geo
    html_body_long = html_body_long + '</td><td>'
    html_body_long = html_body_long + firmware_release
    html_body_long = html_body_long + '</td><td>'
    html_body_long = html_body_long + model
    html_body_long = html_body_long + '</td><td>'
    html_body_long = html_body_long + var_site_code
    html_body_long = html_body_long + '</td><td>\n'

    html_body_short = html_body_short +'<tr class="'
    html_body_short = html_body_short + var_odd
    html_body_short = html_body_short + '"><td><a href="https://mate.ffbsee.net/meshviewer/#!/de/map/'
    html_body_short = html_body_short + node_id
    html_body_short = html_body_short + '" target="_blank">'
    html_body_short = html_body_short + hostname
    html_body_short = html_body_short + '</a></td><td class="'
    html_body_short = html_body_short + var_is_online
    html_body_short = html_body_short + '</etd><td>'
    html_body_short = html_body_short + var_clients
    html_body_short = html_body_short + '</td><td>'
    html_body_short = html_body_short + firmware_release
    html_body_short = html_body_short + '</td>\n'


    if var_have_geo == 'Ja':
        location_count = location_count + 1

    if is_online == True:
        online_count = online_count + 1

    if site_code != '':
        community_count = community_count + 1

    if firmware_release == newest_firmware:
        newest_firmware_count = newest_firmware_count + 1

    if model !='':
        with_hardware_count = with_hardware_count + 1

    clients_count = clients_count + clients


if nodes_count != 0:
    percent_with_location = round((location_count/nodes_count) * 100, 2)
    percent_with_community = round((community_count/nodes_count) * 100, 2)
    percent_with_newest_firmware = round((newest_firmware_count/nodes_count) * 100, 2)
    percent_with_hardware = round((with_hardware_count/nodes_count) * 100, 2)

timestamp = json_data['meta']['timestamp']
timestamp = timestamp.replace('T', ' ')

connections = len(json_data['links'])

if debug == True:
    print('+-----------------------------------+')
    print('Statistics:')
    print('Timestamp: ' +timestamp)
    print('Nodes: ' +str(nodes_count))
    print('Online Nodes: ' +str(online_count))
    print('With coordinates: ' +str(percent_with_location) + '%')
    print('Verbindungen: ' +str(connections))
    print('Clients: ' + str(clients_count))
    print('With community: ' +str(percent_with_community))
    print('With newest firmware: ' +str(percent_with_newest_firmware) + '%')
    print('Share Hardware: ' +str(percent_with_hardware) + '%')
    print('+-----------------------------------+')


html_head = html_head.replace('--TIMESTAMP--', timestamp)
html_footer_long = html_footer_long.replace('--NODES_COUNT--', str(nodes_count))
html_footer_long = html_footer_long.replace('--ONLINE_NODES--', str(online_count))
html_footer_long = html_footer_long.replace('--PERCENT_WITH_LOCATION--', str(percent_with_location))
html_footer_long = html_footer_long.replace('--CONNECTIONS--', str(connections))
html_footer_long = html_footer_long.replace('--CLIENTS--', str(clients_count))
html_footer_long = html_footer_long.replace('--PERCENT_WITH_COMMUNITY--', str(percent_with_community))
html_footer_long = html_footer_long.replace('--NEWEST_FIRMWARE--', newest_firmware)
html_footer_long = html_footer_long.replace('--PERCENT_WITH_NEWEST_FIRMWARE--', str(percent_with_newest_firmware))
html_footer_long = html_footer_long.replace('--PERCENT_WITH_HARDWARE--', str(percent_with_hardware))

#Write long HTML File
html_file = open(html_pathname + html_filename_list, 'wb')
html_content = html_head + html_table_long + html_body_long + html_footer_long
html_file.write(html_content.encode('utf-8'))
html_file.close()


html_footer_short = html_footer_short.replace('--NODES_COUNT--', str(nodes_count))
html_footer_short = html_footer_short.replace('--ONLINE_NODES--', str(online_count))
html_footer_short = html_footer_short.replace('--CLIENTS--', str(clients_count))
html_footer_short = html_footer_short.replace('--NEWEST_FIRMWARE--', newest_firmware)
html_footer_short = html_footer_short.replace('--PERCENT_WITH_NEWEST_FIRMWARE--', str(percent_with_newest_firmware))

#Write short HTML File
html_file = open(html_pathname + html_filename_index, 'wb')
html_content = html_head + html_table_short + html_body_short + html_footer_short
html_file.write(html_content.encode('utf8'))
html_file.close()
