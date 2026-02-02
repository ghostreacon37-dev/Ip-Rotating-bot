#!/bin/bash

# Path to your script
SCRIPT_PATH="./Ip-taker.sh"

echo "Loop started. Triggering $SCRIPT_PATH every 20 minutes."

while true
do
    # Check if the file exists and is executable
    if [ -x "$SCRIPT_PATH" ]; then
        bash "$SCRIPT_PATH"
        echo "Executed at $(date)"
    else
        echo "Error: $SCRIPT_PATH not found or not executable."
    fi

    # Wait for 20 minutes (1200 seconds)
    sleep 1200
done
