#!/bin/bash

# Check if input file is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    echo "Input file should be tab-delimited with sequence name and sequence"
    exit 1
fi

input_file=$1
output_file="${input_file%.*}.fasta"

# Process the file
while IFS=$'\t' read -r name sequence || [ -n "$name" ]; do
    # Skip empty lines
    [ -z "$name" ] && continue
    
    # Remove any carriage returns that might be present
    sequence=$(echo "$sequence" | tr -d '\r')
    
    # Write FASTA format
    echo ">$name"
    echo "$sequence"
done < "$input_file" > "$output_file"

echo "Conversion complete. FASTA file saved as: $output_file"

# Make the script executable
chmod +x "$0"
