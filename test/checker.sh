#!/bin/bash

Green='\033[0;42m'
Red='\033[0;41m'
Blue='\033[0;34m'
End='\033[0;0m'

if [ $# -ne 3 ]; then
    echo "Usage: '${Blue}$0 <program> <file> <checker>${End}', with <checker> = 1 if the test should pass, 0 otherwise."
    exit 1
fi

program="$1"
file="$2"
# 1 if the test should pass when the program parses, 0 otherwise
checker="$3"
result=$("${program}" < "${file}" 2>&1 | egrep "ERROR")
if ([ "${result}" = "" ] && [ "${checker}" = "1" ]) || ([ "${result}" != "" ] && [ "${checker}" = "0" ]); then
		printf "%-50s ${Green}PASSES${End}\n" "${file}"
else
    printf "%-50s ${Red}FAILS ${End}\n" "${file}"
fi
