FFNodeList
==========

## generateList.py
A simple python skript to generate a Freifunk Node List.
The Script get his informations from the [Meshviewer](https://github.com/ffnord/meshviewer) [¹](https://github.com/ffbsee/meshviewer).
The Meshviewer has a JSON File [²](https://mate.ffbsee.de/meshviewer/nodes.json) which is used from the script.

Following setting can be set in the script:
* root:                 The url to the server where to find the nodes.json. e.g. https://mate.ffbsee.net/
* nodes:                File name of the json file. e.g. nodes.json
* html_filename_list:   Name of the output html file for the long list. e.g. list.html
* html_filename_index:  Name of the output html file for the short list. e.g. index.html
* html_pathname:        Sets the output folder. e.g. ./
* local_path:           Where to find the nodes.json when local mode is enabled. e.g. ./
* local_file:           Enable to True when a local file have to be opened
* newest_firmware:      Version of the newest firmware. 19/09 is 2.0.0

The Script generate an index.html and an liste.html. Both Pages display all Freifunk nodes from the meshviewer JSON file.
The index.html file only contains the most important informations. The list.html has a lot more information.
Feel free to fork this github repository for your own Freifunk community.

# SortableTables

A simple Javascript library to make html tables sortable.
It uses Array.from, which may not be available in your Javascript version.
You can find a polyfill at [MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/from#Browser_compatibility).

Basic usage for the JavaScript:

The table element must have class *sortable*.
Sort criteria is defined by using a class on the *th* element for each column.

e.g.
```no-highlight
<thead>
    <tr>
    <th class="str-sort">Strings</th>
    </tr>
</thead>
```

Currently implemented sort criteria are:
* str-sort (locale aware standard javascript sorting)
* date-sort (default date format is: dd/mm/yyyy)
* float-sort (probably works for ints too)

Rows can be skipped using class *skip-sort*.
*thead* and *tfoot* elements are always skipped.

# Installation:

This is now the template for our Ansible setup

---
```
pip install datetime
```
All other used modules are built-in on python3.

# License:

## sortableTables.js

MIT License - Copyright 2016, Gregory Vigo Torres [³](https://github.com/GregoryVigoTorres/sortableTables)

## generateList.py
CC-BY-NC - Joni Arida
