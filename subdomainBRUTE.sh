#!/bin/bash

# Define color codes
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Define file path to your wordlist i use seclist personally
input_file="/usr/share/seclists/Discovery/DNS/fierce-hostlist.txt"
output_file="RecordsDNS.txt"

# Number of parallel jobs use more if you have strong CPU and great bandwith use more then 10 threads
parallel_jobs=10

display_header() {
  printf "${PURPLE}###########################################################${NC}\n"
  printf "${PURPLE}#${NC} ${CYAN}Created by Aimane / H4d3SPH4NT0M${NC} ${PURPLE}#${NC}\n"
  printf "${PURPLE}###########################################################${NC}\n\n"
}

# update progress bar
update_progress() {
  local current=$1
  local total=$2
  local percent=$(( (current * 100) / total ))
  local bar_width=50
  local progress=$((percent * bar_width / 100))
  local progress_bar=$(printf "%${progress}s" | tr ' ' '#')
  progress_bar=$(printf "%-${bar_width}s" "$progress_bar")

  # Move cursor to the beginning of the progress bar line and clear the line to avopid overlapping 
  printf "\033[2K\033[1;0H${PURPLE}Progress: [${progress_bar}] ${percent}%%${NC}\n"
}

clear
# Display the header
display_header
sleep 3

# Clear the terminal screen again to start the main process
clear

if [ ! -f "$input_file" ]; then
  printf "${RED}Input file not found: $input_file${NC}\n"
  exit 1
fi

touch "$output_file"
total_lines=$(wc -l < "$input_file")

# Function to perform the dig and process the result
dig_subdomain() {
  local sub=$1
  # Trim whitespace from the subdomain
  sub=$(echo "$sub" | xargs)

  # Check if mpty
  if [ -z "$sub" ]; then
    return
  fi

  printf "${CYAN}Processing Records: ${PURPLE}%s${NC}\n" "$sub"
  
  # Please change to your target domain and ns
  dig "$sub.dev.inlanefreight.htb" @10.129.2.133 | grep -v ';\|SOA' | sed -r '/^\s*$/d' | grep "$sub" >> "$output_file"
  printf "${CYAN}Finished processing: ${PURPLE}%s${NC}\n" "$sub"

  # Update progress
  current=$((current + 1))
  update_progress "$current" "$total_lines"
}

export -f dig_subdomain
export output_file
export total_lines
export -f update_progress

# Initialize progress
current=0

printf "${PURPLE}Starting parallel processing with ${CYAN}%d${PURPLE} jobs...${NC}\n" "$parallel_jobs"
cat "$input_file" | parallel -j "$parallel_jobs" dig_subdomain
printf "${GREEN}Processing complete. Results are in ${CYAN}%s${GREEN}.${NC}\n" "$output_file"

# final progress updated
update_progress "$total_lines" "$total_lines"
printf "\n"
