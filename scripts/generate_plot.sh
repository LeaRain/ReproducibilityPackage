#!/bin/bash

# in case the script is started from inside the scripts folder
if [ "${PWD##*/}" = "scripts" ]; then
    cd ..
fi

# delete this when merging with the paper branch, it's only needed if the paper folder isn't there already
mkdir -p paper

cd scripts

python generate_comparison_plots.py ../data
mv comparison.pgf ../paper/

cd ..