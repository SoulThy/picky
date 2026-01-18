#!/bin/bash

# picky - A photo organizer tool that lets you review and sort 
# pictures interactively.
# 
# Usage: ./picky.sh <directory>
# 
# For each image in the specified directory, the script will:
#   1. Display the photo in an image viewer
#   2. Prompt you to keep or delete it
#   3. Delete the file if you choose to discard it
#
# Dependencies: zenity (for dialog prompts), and an image viewer
# Author: thanel

detect_viewer() {
        local viewers=(
        "eog"
        "gwenview"
        "ristretto"
        "gpicview"
        "lximage-qt"
        "nomacs"
        "feh"
        "sxiv"
        "imv"
        "xviewer"
        "gthumb"
        "geeqie"
        "viewnior"
        "xdg-open"
    )

    for viewer in "${viewers[@]}"; do
        if command -v "$viewer" &> /dev/null; then
            echo "$viewer"
            return 0
        fi
    done

    return 1
}

FILE_VIEWER=$(detect_viewer)

if [[ -z "$FILE_VIEWER" ]]; then
    echo "Error: No image viewer found. Please install one."
    exit 1
fi

echo "Using image viewer: $FILE_VIEWER"

if [[ $# -ne 1 ]]; then
    echo "Usage: ./picky.sh <path_directory>"
    exit 1
fi

DIR=$1

if [[ ! -d "$DIR" ]]; then
    echo "Error: Directory '$DIR' not found"
    exit 1
fi

shopt -s nullglob

for filepath in "$DIR"/*; do
    if [[ ! -f "$filepath" ]]; then continue; fi

    mimetype=$(file --mime-type -b "$filepath")
    if [[ ! "$mimetype" =~ image/* ]]; then continue; fi

    filename=$(basename "$filepath")

    echo "Processing: $filename"

    $FILE_VIEWER "$filepath" >/dev/null 2>&1 &
    VIEWER_PID=$!

    zenity --question \
           --title="Picky: $filename" \
           --text="What you want to do with the photo?" \
           --ok-label="Keep" \
           --cancel-label="Delete" \
           --width=300 2>/dev/null

    # Zenity response
    RESPONSE=$?

    kill $VIEWER_PID 2>/dev/null

    if [[ $RESPONSE -eq 0 ]]; then
        echo "--> Kept."
    else
        rm "$filepath"
        echo "--> DELETED."
    fi
    echo ""
done
