#!/bin/bash

echo $1

if [ "$1" == "true" ]; then
	echo "generate plots"
	./generate_all.sh
else
	echo "run training"
	./run_all_generate_all.sh
fi
