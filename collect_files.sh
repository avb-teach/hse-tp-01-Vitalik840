#!/bin/bash

input_dir="$1"
output_dir="$2"

mkdir -p "$output_dir"

find "$input_dir" -type f -print0 | while IFS= read -r -d '' file; do
    filename=$(basename "$file")
    dest="$output_dir/$filename"
    
    if [[ -e "$dest" ]]; then
        base="${filename%.*}"
        ext="${filename##*.}"
        counter=1
        
        while [[ -e "$output_dir/${base}_${counter}.${ext}" ]]; do
            ((counter++))
        done
        
        dest="$output_dir/${base}_${counter}.${ext}"
    fi
    
    cp "$file" "$dest"
done