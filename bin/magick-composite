#!/bin/bash

if [[ "$1" == "" || "$2" == "" ]] ; then
  echo "Composite two images using ImageMagick"
  echo "usage: magick-composite <front file> <rear file>"
  echo "output: <front_dir>/<front_name>-composite-<rear_name>.<ext>"
  exit 1
fi

front="$1"
rear="$2"

# Get directory and filename from front file
front_dir=$(dirname "$front")
front_base=$(basename "$front")
front_name="${front_base%.*}"  # Remove extension
front_ext="${front_base##*.}"  # Get extension

# Get filename from rear file
rear_base=$(basename "$rear")
rear_name="${rear_base%.*}"  # Remove extension

# Construct output filename
output="${front_dir}/${front_name}-composite-${rear_name}.${front_ext}"

exec magick composite "$front" "$rear" "$output"
