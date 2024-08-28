#!/bin/bash

# Function to parse the config file and extract job details
parse_config() {
    local filename=$1
    local jobs=()

    while IFS= read -r line; do
        line=$(echo "$line" | xargs)  # Trim leading/trailing whitespace
        if [[ -z "$line" || "$line" == \#* ]]; then
            continue
        fi
        jobs+=("$line")
    done < "$filename"

    # Return the parsed jobs as a newline-separated string
    printf "%s\n" "${jobs[@]}"
}

# Function to process jobs and create directories
make_jobs() {
    local jobs
    jobs="$1"
    local templ_dr="/nobackup/py21cb/templates/run_template"  # Adjust path to template directory
    local airtracer_dir="/nobackup/py21cb/AREOTRACE_MPHASE"    

    # Split jobs into an array
    IFS=$'\n' read -r -d '' -a job_array <<< "$jobs"

    for job in "${job_array[@]}"; do
        IFS=' ' read -r -a job_details <<< "$job"
        local name="${job_details[0]}"
        local start_date="${job_details[1]}"
        local start_time="${job_details[2]}"
        local end_date="${job_details[3]}"
        local end_time="${job_details[4]}"
        local release_height="${job_details[5]}"
        local latitude="${job_details[6]}"
        local longitude="${job_details[7]}"

        # Directory into which directories will be copied/models will be run
        local out_dir="${airtracer_dir}/${name}"
        mkdir -p "$out_dir"

        local run_dir="$out_dir/"
        rm -rf "$run_dir"
        mkdir -p "$run_dir"
        mkdir -p "$run_dir/output"        

        cp -r "$templ_dr"/* "$run_dir"

        # Update pathnames file
        sed -i -e "s|XRDX|${run_dir}options|g" \
               -e "s|XRDOX|${run_dir}output|g" \
               "$run_dir/pathnames"

        # Calculate range values
        local release_height_minus_005=$(echo "$release_height - 5" | bc)
        local release_height_plus_005=$(echo "$release_height + 5" | bc)
        local latitude_minus_005=$(echo "$latitude - 0.05" | bc)
        local latitude_plus_005=$(echo "$latitude + 0.05" | bc)
        local longitude_minus_005=$(echo "$longitude - 0.05" | bc)
        local longitude_plus_005=$(echo "$longitude + 0.05" | bc)

        # Update release file
        sed -i -e "s|XSTDX|$start_date|g" \
               -e "s|XSTTX|$start_time|g" \
               -e "s|XETDX|$end_date|g" \
               -e "s|XETTX|$end_time|g" \
               -e "s|XZ1X|$release_height_minus_005|g" \
               -e "s|XZ2X|$release_height_plus_005|g" \
               -e "s|XLAT1X|$latitude_minus_005|g" \
               -e "s|XLAT2X|$latitude_plus_005|g" \
               -e "s|XLON1X|$longitude_minus_005|g" \
               -e "s|XLON2X|$longitude_plus_005|g" \
               "$run_dir/options/RELEASES"

        # Update command file
        sed -i -e "s|XEDX|$start_date|g" \
               -e "s|XETX|$end_time|g" \
               -e "s|XSDX|$(date -d "$start_date - 14 days" +%Y%m%d)|g" \
               "$run_dir/options/COMMAND"

        # Copy and update job script
        cp /nobackup/py21cb/templates/run_template/run_job.sh "$run_dir/run_job.sh"
        sed -i -e "s|0:20:00|2:00:00|g" \
               "$run_dir/run_job.sh"

        chmod 755 "$run_dir/run_job.sh"
    done
}

# Main script
config_file="/nobackup/py21cb/templates/config_MPHASE"  # Adjust path to config file
jobs=$(parse_config "$config_file")
make_jobs "$jobs"

