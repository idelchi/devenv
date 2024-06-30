#!/bin/bash

# This script extracts sections marked as FILE from a single input and writes to corresponding files.
# All files are written into a subdirectory ".backup" of the current directory.

# Input file name, either pipe content into this script or modify to read directly from a specific file
input_file="${1:-/dev/stdin}"

# Base directory where files will be created
backup_dir=".backup"

# Create the backup directory if it doesn't already exist
mkdir -p "${backup_dir}"

# Variables to keep track of the current file being written to
current_file=""
inside_section=false

while IFS= read -r line || [[ -n ${line} ]]; do
  # Check if the line indicates the start of a new file section
  if [[ ${line} =~ ^\*\*\*\*\*\ FILE:\ (.*)\ \*\*\*\*\* ]]; then
    # Extract filename from the line, prepend with backup directory path
    current_file="${backup_dir}/${BASH_REMATCH[1]}"
    # Ensure the directory exists for the file
    mkdir -p "$(dirname "${current_file}")"
    # Initialize or clear the file
    : >"${current_file}"
    inside_section=true
  elif [[ ${line} =~ ^\*\*\*\*\*\ FILE:\ .* && ${inside_section} == true ]]; then
    # If another FILE line is found while already writing one, switch files
    current_file="${backup_dir}/${line#***** FILE: }"
    current_file="${current_file% *****}"
    mkdir -p "$(dirname "${current_file}")"
    : >"${current_file}"
  elif [[ ${inside_section} == true ]]; then
    # If inside a section, write to the current file
    echo "${line}" >>"${current_file}"
  fi
done <"${input_file}"
