#!/bin/bash

IN=$1
OUT=${IN%.md}.html

pandoc "${IN}" --standalone -t html5 --metadata pagetitle="${IN}" -A include.html |\
  sed -e 's/<pre class="mermaid"><code>/<pre class="mermaid">/g' |\
  sed -e 's/<\/code><\/pre>/<\/pre>/g' >\
  "${OUT}"




