#!/bin/bash

# Check if a file is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <file_path>"
    exit 1
fi

# Assign the file path to a variable
file_path="$1"

# Create a temporary file to store the modified content
temp_file=$(mktemp)

# Copy the content of the original file to the temporary file, removing ":" and "/", and replacing tabs with a single space
sed 's/[:\-]//g;s/\t/ /g' "$file_path" > "$temp_file"

# Overwrite the original file with the modified content
mv "$temp_file" "$file_path"

echo "File $file_path has been modified."
