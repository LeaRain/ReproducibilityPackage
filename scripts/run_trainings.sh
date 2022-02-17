#!/bin/bash

if [ $# -ne 1 ] || [ "$1" != "skolik" ] && [ "$1" != "lockwood" ]; then
    echo "Usage: $0 skolik or $0 lockwood"
    exit 2
fi

# in case the script is started from inside the scripts folder
if [ "${PWD##*/}" = "scripts" ]; then
    cd ..
fi

# This script assumes that all three cloned repositories have the same parent folder,
# i.e. the repository folders named "ReproducibilityPackage", "quantum-rl" and "plot_rl_vqc_data" are present in the same folder.

cd ../quantum-rl

# cleaning up prior skolik or lockwood runs, but not both
rm -r -f logs/tfq.reproduction."$1".*
rm -r -f ../plot_rl_vqc_data/quantum-rl/logs/tfq.reproduction."$1".*


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

printf "\n\n\nfinished the trainings, now converting to .csv files ...\n"

cd ../plot_rl_vqc_data

# convert all freshly generated training results to .csv files
for directory in ../quantum-rl/logs/tfq.reproduction."$1".*; do
    printf "\n\n\ngenerating .csv files for directory "$directory" ...\n\n\n\n"
    python3 get_csv.py "$directory" parent
done

printf "\n\n\nfinished all "$1" trainings.\n\n\n\n"
