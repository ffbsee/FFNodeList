SortableTables.js 

A simple pure Javascript library to make an html table sortable.


Basic usage:

The table must have class sortable.
Sortable th elements must have sort criteria for the column as a class.
 currently implemented criteria are:
 str-sort (uses locale aware built-in javascript sorting)
 date-sort (default date format is a string like: dd/mm/yyyy)
 float-sort (probably works for ints too)

 Rows can be skipped using class skip-sort.
 thead and tfoot elements are always skipped.


MIT License
copyright 2016, Gregory Vigo Torres
