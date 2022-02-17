#!/bin/bash

# in case the script is started from inside the scripts folder
if [ "${PWD##*/}" = "scripts" ]; then
    cd ..
fi

cd paper/

lualatex main.tex
bibtex main
lualatex main.tex
lualatex main.tex

mv main.pdf ../

cd ..

mv main.pdf report.pdf
