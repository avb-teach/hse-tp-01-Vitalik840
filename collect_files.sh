nput_dir="$1"
output_dir="$2"

files=()
while IFS= read -r -d '' file; do
    files+=("$file")
done < <(find "$input_dir" -type f -print0)

for file in "${files[@]}"; do
    filename=$(basename "$file")
    if [[ -f "$output_dir/$filename" ]]; then
        new_filename="$filename"
        counter=1
        while [[ -f "$output_dir/$new_filename" ]]; do
            new_filename="${filename%.*}_$counter.${filename##*.}"
            ((counter++))
        done
        cp "$file" "$output_dir/$new_filename"
    else
        cp "$file" "$output_dir"
    fi
done