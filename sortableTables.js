/* MIT license
 * copyright 2016, Gregory Vigo Torres
*/


function SortableTable() { 
    this.name = "SortableTable";
    this.allRows = [];
    this.skipRows = {};
    this.sortableRows = [];
    this.alreadySorted = {};
};

SortableTable.prototype.initSortableRows = function() {
    /* This function must be called in order for the Table to be sortable */
    this.allRows = Array.from(this.sortableTable.querySelectorAll('tbody > tr'));

    for (i=0; i<this.allRows.length; i++) {
        var row = this.allRows[i];
        var skipRow = row.classList.contains('skip-sort');
        if (skipRow) { 
            this.skipRows[i] = row;   
        } else {
            this.sortableRows.push(row) 
        };
    };

    this.sortableHeaders = Array.from(this.sortableTable.querySelectorAll('.sortable tr th'));

    for (var i=0; i<this.sortableHeaders.length; i++) {
        /* eventListener callback first arg is the event */
        this.sortableHeaders[i].addEventListener('click', this.getCol.bind(this));
    };
};

SortableTable.prototype.getCol = function(eve) {
    /* get index of this (row header w/sort criteria) */
    elem = eve.target;
    var index = this.sortableHeaders.indexOf(elem);
    /* Additional sorting functions can be registered here */
    if (elem.classList.contains('str-sort')) { this.sortByStr(index); };
    if (elem.classList.contains('float-sort')) { this.sortByFloat(index); };
    if (elem.classList.contains('date-sort')) { this.sortByDate(index); };
};

SortableTable.prototype.replaceTableRows = function(rows, index) {
    if (this.alreadySorted[index]) {
        rows = rows.reverse();
        this.alreadySorted[index] = undefined;
    } else {
        this.alreadySorted[index] = true;
    };

    this.allRows.forEach(function(val, ind, arr) {
        val.remove();
    });
    
    var body = this.sortableTable.getElementsByTagName('tbody')[0];
    if (!body) { body = this.sortableTable; };

    for (i=0; i<rows.length; i++) {
        elem = rows[i];
        skip = this.skipRows[i];

        if (skip) {
            body.appendChild(skip);
        } else {
            body.appendChild(elem);
        };

        if (elem.classList.contains('even') || elem.classList.contains('odd')) {
            if ((i % 2) ===  0) { 
                elem.classList.remove('odd');
                elem.classList.add('even');
            } else {
                elem.classList.add('odd');
                elem.classList.remove('even');
            };
        };
    };

    /* Skipped rows not found while appending sorted rows, 
     * so just add them at the end, in order */
    var extraRows = [];
    for (var Key in this.skipRows) {
        if (Key > rows.length) { extraRows.push(parseInt(Key)) };
    };

    for (i=0; i<extraRows.length; i++) {
        var ind = extraRows[i];
        this.sortableTable.appendChild(this.skipRows[ind]);
    };
};

/* Sort functions */

SortableTable.prototype.sortByDate = function(index) {
    if (index === undefined) { return null; };

    function parseDateStr(str) {
        /* Must return Array [yyyy, mm, dd] to be passed into new Date(Arr)
         * Default format is dd/mm/yyyy
         * This is here to make implementing custom date formats easier 
        */
        var strArr = str.split('/').reverse();
        var Arr = strArr.map(function(val) { return parseInt(val, 10); });
        return Arr;
    };

    function toDate(row) {
        var Str = row.children[index].textContent.trim(); 
        var DateArr = parseDateStr(Str);
        var dateObj = new Date(DateArr);
        return dateObj
    };

    rows = this.sortableRows;
    rows.sort(function(a, b) {
        var aDate = toDate(a);
        var bDate = toDate(b);

        if (Number.isNaN(aDate)) { return 1; }; 
        if (Number.isNaN(bDate)) { return -1; }; 
        if (aDate < bDate) { return -1; };
        if (aDate > bDate) { return 1; };
        if (aDate === bDate) { return 0; };
    });

    this.replaceTableRows(rows, index);
};

SortableTable.prototype.sortByFloat = function(index) {
    if (index === undefined) { return null; };
    rows = this.sortableRows;

    rows.sort(function(a, b) {
        var aval = Number.parseFloat(a.children[index].textContent.trim());
        var bval = Number.parseFloat(b.children[index].textContent.trim());
        
        if (Number.isNaN(aval)) { return -1; }; 
        if (Number.isNaN(bval)) { return 1; }; 
        if (aval < bval) { return -1; };
        if (aval > bval) { return 1; };
        if (aval === bval) { return 0; };
    });

    this.replaceTableRows(rows, index);
};

SortableTable.prototype.sortByStr = function(index) {
    if (index === undefined) { return null; };

    rows = this.sortableRows

    rows.sort(function(a, b) {
        var aval = String(a.children[index].textContent.trim());
        var bval = String(b.children[index].textContent.trim());
        return aval.localeCompare(bval);
    });

    this.replaceTableRows(rows, index);
};

/* Initialize sortable tables */
(function() {
    "use strict";
    var sortableTables = document.getElementsByClassName('sortable');

    function instance(table) {
        var S = new SortableTable;
        S.sortableTable = table;
        return S; 
    };

    for (var i=0; i<sortableTables.length; i++) {
        var s = instance(sortableTables[i]);
        s.initSortableRows();
    };
})();
