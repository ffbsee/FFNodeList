# HTML head
html_head = '''<!doctype html>
<html lang="de">
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title>Freifunk Node Liste</title>
    <meta name="description" content="Eine Liste der Nodes, die bei Freifunk Bodensee aktiv sind. Dargestellt auf dem Supernode mate.ffbsee.net.">
    <style>
        table {
            width: 100%;
        }

        th {
            cursor: default;
        }

        thead th:hover {
            text-decoration: underline;
        }
        .online {
            background-color: rgba(128, 255, 128, 0.4);
        }
        .offline {
            background-color: rgba(255, 128, 128, 0.07)
        }

        .amount {
            text-align: right;
        }

        .skip-sort {
            background-color: black;
            color: white;
        }

        ul {
            list-style-type: none;
            margin: -5px;
            padding: 0;
            overflow: hidden;
            background-color: #333;
        }

        li {
            float: left;
        }

        li a {
            display: block;
            color: white;
            text-align: center;
            padding: 14px 16px;
            text-decoration: none;
        }

        li a:hover {
            background-color: #111;
         }
        .g2  {
            overflow: hidden;
            margin: auto
            overflow-x: hidden;
            width: 30%;
            margin-left: 70%;
            text-align; right;
            min-height: 16em;
            margin-top: -8em;
            margin-bottom: -8em;
        }

        .generated {
            overflow: hidden;
            overflow-x: hidden;
            background-color: rgba(128, 255, 172, 0.4);
            min-width: 15em;
            text-align: left;
            margin: auto;
            margin-right: -20em;
            margin-top: 4em;
            padding: 0.4em;
            padding-left: 5em;
            padding-right: 10em;
            -webkit-transform: rotate(0deg);
            -moz-transform: rotate(0deg);
            -o-transform: rotate(0deg);
            writing-mode: lr-tb;
        }
        thead tr {
            background: rgba(0, 255, 255, 0.7);
            padding-top: 1em;
            padding-bottom: 0.5em;
        }
        tfoot tr {
            background: rgba(0, 255, 255, 0.7);
            padding-top: 1em;
            padding-bottom: 0.5em;
            text-align: center;
        }

        tfoot {
            text-align: center;
        }

        tfoot, thead {
            height: 2.3em;
            background: no-repeat center center,-moz-linear-gradient(top,    rgba(255,255,255,1), rgba(0,142,255,1));
            background: no-repeat center center,-webkit-linear-gradient(top, rgba(255,255,255,1), rgba(0,142,255,1));
            background: no-repeat center center,-o-linear-gradient(top,      rgba(255,255,255,1), rgba(0,142,255,1));
            background: no-repeat center center,-ms-linear-gradient(top,     rgba(255,255,255,1), rgba(0,142,255,1));
            background: no-repeat center center,linear-gradient(top,         rgba(255,255,255,1), rgba(0,142,255,1));
        }

         thead td:hover, thead th:hover {
            background: no-repeat center center,-moz-linear-gradient(top,    rgba(0,142,255,1), rgba(255,255,255,1));
            background: no-repeat center center,-webkit-linear-gradient(top, rgba(0,142,255,1), rgba(255,255,255,1));
            background: no-repeat center center,-o-linear-gradient(top,      rgba(0,142,255,1), rgba(255,255,255,1));
            background: no-repeat center center,-ms-linear-gradient(top,     rgba(0,142,255,1), rgba(255,255,255,1));
            background: no-repeat center center,linear-gradient(top,         rgba(0,142,255,1), rgba(255,255,255,1));
        }

        tr{
            height: 1.8em;

            background: no-repeat center center,-moz-linear-gradient(top,    rgba(0, 132, 255, 0.12), rgba(255,255,255,0.1));
            background: no-repeat center center,-webkit-linear-gradient(top, rgba(0, 132, 255, 0.12), rgba(255,255,255,0.1));
            background: no-repeat center center,-o-linear-gradient(top,      rgba(0, 132, 255, 0.12), rgba(255,255,255,0.1));
            background: no-repeat center center,-ms-linear-gradient(top,     rgba(0, 132, 255, 0.12), rgba(255,255,255,0.1));
            background: no-repeat center center,linear-gradient(top,         rgba(0, 132, 255, 0.12), rgba(255,255,255,0.1));


        }

        tr:hover {
            height: 1.8em;

            background: no-repeat center center,-moz-linear-gradient(top,    rgba(55,255,100,0.2), rgba(0, 255, 255, 0.15));
            background: no-repeat center center,-webkit-linear-gradient(top, rgba(55,255,100,0.2), rgba(0, 255, 255, 0.15));
            background: no-repeat center center,-o-linear-gradient(top,      rgba(55,255,100,0.2), rgba(0, 255, 255, 0.15));
            background: no-repeat center center,-ms-linear-gradient(top,     rgba(55,255,100,0.2), rgba(0, 255, 255, 0.15));
            background: no-repeat center center,linear-gradient(top,         rgba(55,255,100,0.2), rgba(0, 255, 255, 0.15));


        }


    </style>
  </head>
<body>
<ul><li><a href="https://freifunk-bodensee.net/">Freifunk Bodensee</a></li>
<li><a href="https://mate.ffbsee.net/">mate.ffbsee.net</a></li>
<li><a href="https://mate.ffbsee.net/meshviewer/">Meshviewer</a></li>
<li><a href="https://www.freifunk-karte.de/?lat=47.74579&lng=9.43314&z=10">freifunk-karte.de</a></li>
<!--<li><a href="https://s.ffbsee.de/">Statistik</a></li>-->
<li><a href="https://mate.ffbsee.net/FFNodeList/index.html">Minimale Ansicht</a></li></ul>    <h1>Freifunk Node Liste</h1>

<div class="g2"><div class="generated"><a>Aktualisiert: --TIMESTAMP-- </a></div></div>'''

#HTML Table Long Version
html_table_long ='''<table class="sortable">
      <thead>
        <tr>
          <th class="str-sort">Name:</th>
          <th class="str-sort">Status:</th>
          <th class="float-sort">Uptime: (Stunden)</th>
          <th class="float-sort" >Verbindungen</th>
          <th class="float-sort">Clients:</th>
          <th class="str-sort">Geo:</th>
          <th class="str-sort">Firmware:</th>
          <th class="str-sort">Hardware:</th>
          <th class="str-sort">Community:</th>
        </tr>
      </thead>

       <tbody>'''

#HTML Table short Version
html_table_short ='''<table class="sortable">
     <thead>
       <tr>
         <th class="str-sort">Name:</th>
         <th class="str-sort">Status:</th>
         <th class="float-sort">Clients:</th>
         <th class="str-sort">Firmware:</th>
       </tr>
     </thead>

      <tbody>'''


# HTML footer long version
html_footer_long='''</tbody>
<tfoot>
<tr>
<td>--ONLINE_NODES-- von --NODES_COUNT-- Freifunk Nodes sind derzeit online</td>
<td></td>
<td></td><td>--CONNECTIONS--<br/>Verbindungen</td><td>--CLIENTS--<br/>Clients online</td>
<td>--PERCENT_WITH_LOCATION--%<br/>mit Koordinaten</td>
<td>--PERCENT_WITH_NEWEST_FIRMWARE--%<br/>mit --NEWEST_FIRMWARE--</td>
<td>--PERCENT_WITH_HARDWARE--% der Nodes<br/>geben Ihre Hardware bekannt</td><td>--PERCENT_WITH_COMMUNITY--%<br/>der Nodes haben Ihre<br/>Community eingestellt
</tr>
</tfoot>
    </table>

<script src="sortableTables.js"></script>

<br/>
<div style="opacity: 0.42; margin-left: auto; margin-right: auto; text-align: center; color: #5eba5e;">
<a>Entwickelt von Freifunk Bodensee auf </a><a color="#5eba5e" href="https://github.com/ffbsee/FFNodeList">GitHub</a>
<br/>
<a>Lizenz: CC-BY-NC</a>
</div>

</body>
</html>
'''

# HTML footer short version
html_footer_short='''</tbody>
<tfoot>
<tr>
<td>--ONLINE_NODES-- von --NODES_COUNT-- Freifunk Nodes sind derzeit online</td>
<td></td>
<td>--CLIENTS--<br/>Clients online</td>
<td>--PERCENT_WITH_NEWEST_FIRMWARE--%<br/>mit --NEWEST_FIRMWARE--</td>
</tr>
</tfoot>
    </table>

<script src="sortableTables.js"></script>

<br/>
<div style="opacity: 0.42; margin-left: auto; margin-right: auto; text-align: center; color: #5eba5e;">
<a>Entwickelt von Freifunk Bodensee auf </a><a color="#5eba5e" href="https://github.com/ffbsee/FFNodeList">GitHub</a>
<br/>
<a>Lizenz: CC-BY-NC</a>
</div>

</body>
</html>
'''
