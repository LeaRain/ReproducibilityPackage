#!/bin/bash

if [ "$1" == "false" ]; then
	echo "only generating plots..."
	./generate_all.sh
else
	echo "running trainings..."
	./run_all_generate_all.sh
fi
