#!/bin/bash

# in case the script is started from inside the scripts folder
if [ "${PWD##*/}" = "scripts" ]; then
    cd ..
fi

cd paper/

lualatex -interaction nonstopmode main.tex
bibtex main
lualatex -interaction nonstopmode main.tex
lualatex -interaction nonstopmode main.tex

mv main.pdf ../report.pdf

cd ..
