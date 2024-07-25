#!/bin/bash

bar_width=50

for percent in $(seq 0 5 100); do
  progress=$((percent * bar_width / 100))
  progress_bar=$(printf "%${progress}s" | tr ' ' '#')
  progress_bar=$(printf "%-${bar_width}s" "$progress_bar")
  printf "\rProgress: [${progress_bar}] ${percent}%%"
  sleep 0.1
done
printf "\nDone\n"