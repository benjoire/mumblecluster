#!/bin/bash

ODS_PATH="/home/celvin__1/Documents/MumbleCluster/github/syncstream/SYNCSTREAM_sheet.ods"
CSV_PATH="/home/celvin__1/Documents/MumbleCluster/github/syncstream/logs/new_log.csv"

# Check dependencies
if ! command -v python3 &> /dev/null || ! command -v soffice &> /dev/null; then
    echo "LibreOffice or Python3 is missing."
    exit 1
fi

# Launch LibreOffice in listening mode (UNO bridge)
soffice --headless --accept="socket,host=localhost,port=2002;urp;" &

# Wait for bridge
sleep 3

# Call injection script
python3 ./scripts/append_log_uno.py "$CSV_PATH" "$ODS_PATH"
