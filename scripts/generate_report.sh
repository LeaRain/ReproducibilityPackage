#!/bin/bash

# in case the script is started from inside the scripts folder
if [ "${PWD##*/}" = "scripts" ]; then
    cd ..
fi

echo "TODO: generate report via LaTeX"