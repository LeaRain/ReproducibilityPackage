#!/bin/bash

# run the trainings and convert the results to .csv
./scripts/run_trainings.sh skolik
./scripts/run_trainings.sh lockwood

# generate the plot and report
./generate_all.sh