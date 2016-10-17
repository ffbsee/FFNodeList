##SortableTables.js 

A simple Javascript library to make html tables sortable.
It uses Array.from, which may not be available in your Javascript version. 
You can find a polyfill at [MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/from#Browser_compatibility).

A Perl Script generate the FF Node List for ffbsee:

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

##Freifunk Node List
The Perl Script generate an index.html and an liste.html. Both Pages display all freifunk nodes from the meshviewer JSON file.
The index.html file only contains the most important informations. The list.html has a lot more information.
Please have a look at [index.html](https://vpn3.ffbsee.de/FFNodeList/liste.html) and [list.html](https://vpn3.ffbsee.de/FFNodeList/index.html).
More Questions?
Have a look at the Source code [Source Code](https://raw.githubusercontent.com/ffbsee/FFNodeList/master/generateList.pl) or come to the next [Freifunk Bodensee](https://ffbsee.de) meeting.

#License:

sortableTables.js

MIT License - Copyright 2016, Gregory Vigo Torres

generateList.pl

CC-BY-NC - Freifunk Bodensee, L3D.
