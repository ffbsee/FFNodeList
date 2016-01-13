##SortableTables.js 

A simple Javascript library to make html tables sortable.
It uses Array.from, which may not be available in your Javascript version. 
You can find a polyfill at [MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/from#Browser_compatibility).


Basic usage:

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


MIT License

Copyright 2016, Gregory Vigo Torres
