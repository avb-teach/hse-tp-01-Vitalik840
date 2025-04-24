#!/bin/bash

input_dir="$1"
output_dir="$2"
max_depth=""

for arg in "$@"; do
    if [[ "$arg" == "--max_depth" ]]; then
        max_depth="1"
    fi
done

mkdir -p "$output_dir"

python3 - <<END
import os
import shutil
import sys

input_dir = sys.argv[1]
output_dir = sys.argv[2]
max_depth = int(sys.argv[3]) if len(sys.argv) > 3 else None

def collect_files(input_dir, output_dir, current_depth=0):
    for entry in os.listdir(input_dir):
        path = os.path.join(input_dir, entry)

        if os.path.isdir(path):
            if max_depth is None or current_depth < max_depth:
                collect_files(path, output_dir, current_depth + 1)
        else:
            base_name = os.path.basename(path)
            new_name = base_name
            count = 1

            while os.path.exists(os.path.join(output_dir, new_name)):
                name, ext = os.path.splitext(base_name)
                new_name = f"{name}_{count}{ext}"
                count += 1

            shutil.copy2(path, os.path.join(output_dir, new_name))

collect_files(input_dir, output_dir, 0)
END

[[ ! -z $max_depth ]] && echo "Используется max_depth: $max_depth"