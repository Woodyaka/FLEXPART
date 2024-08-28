#!/bin/bash

# Define the base directory
BASE_DIR="/nobackup/py21cb/AREOTRACE_MPHASE"

# Export BASE_DIR for use in find -exec
export BASE_DIR

# Function to rename files
rename_files() {
    # Find all PNG files
    find "$BASE_DIR" -type f -name "*.nc" | while read -r file; do
        # Get the directory name of the file
        dir=$(dirname "$file")

        # Get the parent directory two levels up
        parent_dir_two_levels_up=$(basename "$(dirname "$dir")")

        # Construct the new file name
        new_file="${dir}/${parent_dir_two_levels_up}_grid_time.nc"

        # Rename the file
        mv "$file" "$new_file"

        # Output the renaming action
        echo "Renamed $file to $new_file"
    done
}

# Run the function
rename_files

