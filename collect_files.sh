#!/bin/bash

if [ "$#" -lt 2 ] || [ "$#" -gt 4 ]; then
    exit 1
fi

input_dir="$1"
output_dir="$2"
max_depth=""
counter=1

if [ "$#" -ge 3 ]; then
    if [ "$3" != "--max_depth" ]  [ "$#" -ne 4 ]  ! [[ "$4" =~ ^[0-9]+$ ]]; then
        exit 1
    fi
    max_depth="$4"
fi

[ -d "$input_dir" ] || exit 1
mkdir -p "$output_dir" || exit 1

copy_file() {
    local src="$1" dest_dir="$2"
    local filename=$(basename "$src")
    local dest_path="$dest_dir/$filename"
    
    [ -f "$src" ] || return 1
    
    if [ -e "$dest_path" ]; then
        local name="${filename%.*}" ext="${filename##*.}"
        if [[ "$name" != "$ext" ]]; then
            while [ -e "$dest_dir/${name}_$counter.$ext" ]; do
                ((counter++))
            done
            dest_path="$dest_dir/${name}_$counter.$ext"
        else
            while [ -e "$dest_dir/${name}_$counter" ]; do
                ((counter++))
            done
            dest_path="$dest_dir/${name}_$counter"
        fi
    fi
    
    cp "$src" "$dest_path" 2>/dev/null || return 1
}

if [ -z "$max_depth" ]; then
    find_cmd="find \"$input_dir\" -type f"
else
    find_cmd="find \"$input_dir\" -maxdepth $max_depth -type f"
fi

eval "$find_cmd" 2>/dev/null | while read -r file; do
    copy_file "$file" "$output_dir"
done

exit 0
