#!/bin/bash
#Author: Di0nj@ck - 12/05/19
#Version: 1.0

# Caplyzer is a tool that automatically extracts interesting info from a PCAP file (using tshark) and creates a plain TXT file with results
#*******************************************************************************************************************

#CONFIG VARIABLES
APP_VERSION=1.0
APP_DIR=$(pwd)
SCRIPT_TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S")

#GLOBAL VARIABLES
capture_file="$1"
commands_file="tshark_comm.txt"
commands_list=()
report_file="report_pcap.txt"

#************************************************************************************

#LOAD FILE INTO ARRAY
function load_commands {
    
    readarray -t commands_list < "$1"
  
    #printf '%s\n' "${commands_list[@]}"
    #printf '%s\n' "${titles_list[@]}"
}

#RUN ALL COMMANDS
function run_commands {

    exec 3<> "$report_file"
    SAVEIFS=$IFS   # Save current IFS
    IFS=$'\n'      # Change IFS to new line

    cnt=${#commands_list[@]}
    i=0

    for a_command in "${commands_list[@]}";do
        
        tshark_comm=$(echo $a_command | cut -d ";" -f1)
        name_comm=$(echo $a_command | cut -d ";" -f2)

        printf '    [%d/%d] %s\n' "$((i + 1))" "$cnt" "$name_comm"
        printf '[%d/%d] %s\n' "$((i + 1))" "$cnt" "$name_comm" >&3

        if [[ "$name_comm" == *"sorted"* ]];then
            eval $tshark_comm -r $capture_file | sort | uniq -c | sort -n >&3
        else
            eval $tshark_comm -r $capture_file >&3
        fi
        i=$i+1
    done

    IFS=$SAVEIFS
}


#************************************************************************************
#**** MAIN CODE ****

#READ TSHARK COMMANDS FILE AND STORE CONTENTS INTO OUR ARRAYS
printf '[*] Loading PCAP extraction filters...\n'
load_commands "$commands_file"

#LAUNCH ALL COMMANDS
printf '[*] Running extraction filters...\n'
run_commands