#!/bin/bash

if [[ "$1" == "" || "$2" == "" ]] ; then
  echo "Convert a background color to transparent using ImageMagick"
  echo "usage: magick-convert-to-transparent <input file> <background color>"
  echo "output: <dir>/<name>-transparent-<color>.<ext>"
  echo "  color format: color name (white, black, red, etc.), hex (#ffffff), or rgb(r,g,b)"
  exit 1
fi

input="$1"
color="$2"

# Get directory and filename from input file
input_dir=$(dirname "$input")
input_base=$(basename "$input")
input_name="${input_base%.*}"  # Remove extension
input_ext="${input_base##*.}"  # Get extension

# Construct output filename
output="${input_dir}/${input_name}-transparent-${color}.${input_ext}"

exec magick convert "$input" -transparent "$color" "$output"
