#!/bin/bash

while true; do
  for file in *.sh; do
    echo "Running $file"
    bash "$file"
    echo "Waiting 10 seconds..."
    sleep 10
  done
done
