#!/bin/bash

# This script combines all Swift files in the Objects and Views directories into one file.
# Save this as combine_files.sh in your project root and run: bash combine_files.sh

OUTPUT_FILE="combined_views_objects.swift"
> "$OUTPUT_FILE"

VIEWS_DIR="Views"
OBJECTS_DIR="Objects"

append_files() {
  local dir=$1
  for file in "$dir"/*.swift; do
    [ -e "$file" ] || continue
    echo "// ===== START FILE: $(basename "$file") =====" >> "$OUTPUT_FILE"
    cat "$file" >> "$OUTPUT_FILE"
    echo -e "\n// ===== END FILE: $(basename "$file") =====\n" >> "$OUTPUT_FILE"
  done
}

append_files "$OBJECTS_DIR"
append_files "$VIEWS_DIR"

echo "All files combined into $OUTPUT_FILE"

# Make script executable: chmod +x combine_files.sh
# Run with: ./combine_files.sh

