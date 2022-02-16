#!/bin/bash

if [ $# -ne 1 ] || [ "$1" != "skolik" ] && [ "$1" != "lockwood" ]; then
    echo "Usage: $0 skolik or $0 lockwood"
    exit 2
fi

# in case the script is started from inside the scripts folder
if [ "${PWD##*/}" = "scripts" ]; then
    cd ..
fi

# This script assumes that both repositories have the same parent folder,
# i.e. the repository folders named "ReproducibilityPackage" and "quantum-rl" are present in the same folder.

cd ../quantum-rl

# cleaning up prior skolik or lockwood runs, but not both
rm -r -f logs/tfq.reproduction."$1".*
rm -r -f data/logs/tfq.reproduction."$1".*
rm -r -f ../ReproducibilityPackage/data/tfq.reproduction."$1".*

configStringStart=tfq.reproduction."$1".cartpole.skolik_hyper
if [ "$1" = "skolik" ]; then
configStringStart="$configStringStart".baseline
fi # skolik has a slighly different config path

# run 5 trainings each for every combination of extraction and encoding strategies
for extraction in "gs" "gsp" "ls"; do
    for encoding in "c" "sc" "sd"; do
        for ((i=1; i<6; i++)); do
            configString="$configStringStart"."$extraction"."$encoding"_enc
            printf "\n\n\nstarting new training on config "$configString" ("$i" of 5) ...\n\n\n\n"
            python3 train.py "$configString"
        done
    done
done

# convert all freshly generated training results to .csv files
printf "\n\n\nfinished the trainings, now converting to .csv files ...\n"
python3 plot/get_csv.py logs/ parent

# copy the .csv files into our data folder
cd ../ReproducibilityPackage
cp ../quantum-rl/data/logs/tfq.reproduction."$1".* data/

printf "\n\n\nfinished all "$1" trainings.\n\n\n\n"
