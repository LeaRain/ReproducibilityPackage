#!/bin/bash

# in case the script is started from inside the scripts folder
if [ "${PWD##*/}" = "scripts" ]; then
    cd ..
fi

cd scripts

python generate_comparison_plots.py ../data
mv comparison.pgf ../paper/

cd ..