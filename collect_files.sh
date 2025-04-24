#!/bin/bash

if [ "$#" -lt 2 ] || [ "$#" -gt 4 ]; then
    echo "Использование: $0 <входная_директория> <выходная_директория> [--max_depth <глубина>]"
    exit 1
fi

input_dir="$1"
output_dir="$2"
max_depth=""
counter=1

if [ "$#" -ge 3 ]; then
    if [ "$3" != "--max_depth" ]; then
        echo "Ошибка: Неизвестный параметр '$3'. Ожидалось --max_depth"
        exit 1
    fi
    if [ "$#" -ne 4 ]; then
        echo "Ошибка: Для --max_depth необходимо указать значение глубины"
        exit 1
    fi
    if ! [[ "$4" =~ ^[0-9]+$ ]]; then
        echo "Ошибка: Глубина должна быть числом"
        exit 1
    fi
    max_depth="$4"
fi

if [ ! -d "$input_dir" ]; then
    echo "Ошибка: Входная директория '$input_dir' не существует"
    exit 1
fi

if [ ! -w "$(dirname "$output_dir")" ]; then
    echo "Ошибка: Нет прав на запись в родительскую директорию выходной директории"
    exit 1
fi

mkdir -p "$output_dir" || {
    echo "Ошибка: Не удалось создать выходную директорию '$output_dir'"
    exit 1
}

copy_file() {
    local src="$1"
    local dest_dir="$2"
    local filename=$(basename "$src")
    local dest_path="$dest_dir/$filename"
    
    if [ ! -f "$src" ]; then
        echo "Предупреждение: '$src' не является файлом, пропускаем"
        return 1
    fi
    
    if [ -e "$dest_path" ]; then
        local name="${filename%.*}"
        local ext="${filename##*.}"
        
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
    
    if ! cp "$src" "$dest_path"; then
        echo "Ошибка: Не удалось скопировать '$src' в '$dest_path'"
        return 1
    fi
}

if [ -z "$max_depth" ]; then
    find_cmd="find \"$input_dir\" -type f"
else
    find_cmd="find \"$input_dir\" -maxdepth $max_depth -type f"
fi

if ! eval "$find_cmd" | while read -r file; do
    copy_file "$file" "$output_dir" || true
done; then
    echo "Ошибка при выполнении поиска файлов"
    exit 1
fi

echo "Файлы успешно скопированы из '$input_dir' в '$output_dir'"
