SortableTables.js 
=============================

A simple Javascript library to make html tables sortable.
It uses Array.from, which may not be available in your Javascript version. 
You can find a polyfill at [MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/from#Browser_compatibility).


## generateList.pl

A simple Perl Script to generate a Freifunk Node List.
The Script get his informations from the [Meshviewer](https://github.com/ffnord/meshviewer) [1](https://github.com/ffbsee/meshviewer). 
The Meshviewer has a few JSON Files [²](https://vpn3.ffbsee.de/meshviewer/nodes.json) [³](https://vpn3.ffbsee.de/meshviewer/graph.json) and this script use them. Please have a look at the global variables from the script.


# SortableTables

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

#Freifunk Node List
The Perl Script generate an index.html and an liste.html. Both Pages display all freifunk nodes from the meshviewer JSON file.
The index.html file only contains the most important informations. The list.html has a lot more information.
Feel free to fork this github repository for your own freifunk community.

# Installation:

This is now the template for our ansible setup

 Old infos:
---
```
cpan install JSON
cpan install LWP::Simple
```


# License:

## sortableTables.js

MIT License - Copyright 2016, Gregory Vigo Torres

## generateList.pl

CC-BY-NC - Freifunk Bodensee, L3D.
