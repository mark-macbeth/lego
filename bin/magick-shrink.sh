#!/bin/bash

if [[ "$1" == "" ]] ; then
  echo "Shrink an image to JPG at 85% quality using ImageMagick"
  echo "usage: magick-shrink.sh <input file>"
  echo "output: <dir>/<name>-shrink.jpg"
  exit 1
fi

input="$1"

# Get directory and filename from input file
input_dir=$(dirname "$input")
input_base=$(basename "$input")
input_name="${input_base%.*}"

# Construct output filename
output="${input_dir}/${input_name}-shrink.jpg"

# Flatten transparency to black before JPEG export so transparent edges do not render as a white halo
exec magick "$input" -background black -alpha remove -alpha off -quality 85 "$output"
