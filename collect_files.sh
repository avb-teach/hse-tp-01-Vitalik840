#!/bin/bash

input_dir="$1"
output_dir="$2"
max_depth=""

if [[ "$#" -lt 2 ]]; then
    echo "Usage: $0 /path/to/input_dir /path/to/output_dir [--max_depth N]"
    exit 1
fi

for arg in "$@"; do
    if [[ "$arg" == "--max_depth" && $3 =~ ^[0-9]+$ ]]; then
        max_depth="$3"
    fi
done

if [[ ! -d "$input_dir" ]]; then
    echo "Ошибка: Входная директория '$input_dir' не существует."
    exit 1
fi

mkdir -p "$output_dir"

find_command="find \"$input_dir\" -type f"

if [[ -n $max_depth ]]; then
    find_command+=" -maxdepth $max_depth"
fi

echo "Выполняется команда: $find_command"

files=()
while IFS= read -r -d '' file; do
    files+=("$file")
done < <(eval "$find_command" -print0)

for file in "${files[@]}"; do
    filename=$(basename "$file")
    new_filename="$filename"
    counter=1

    while [[ -f "$output_dir/$new_filename" ]]; do
        new_filename="${filename%.*}_$counter.${filename##*.}"
        ((counter++))
    done
    cp "$file" "$output_dir/$new_filename" || {
        echo "Ошибка при копировании $file в $output_dir"
        exit 1
    }
done
