#!/bin/bash

# initialize an empty array to hold the json objects
JSON_ARRAY=()

# loop through each argument and create a json object
for arg in "$@"; do
    
    ArrArray=$(echo "$arg" | tr ' ' '\n')
    for kvalue in "${ArrArray[@]}"; do

        # split argument into key and value
        IFS='=' read -ra KV <<< "$kvalue"
        key=${KV[0]}
        value=${KV[1]}

        # add json object to array
        JSON_ARRAY+=("{\"ParameterKey\": \"$key\", \"ParameterValue\": \"$value\"}")
        JSON_ARRAY+=(",")
    
    done
done

# remove the last comma
JSON_ARRAY=("${JSON_ARRAY[@]::${#JSON_ARRAY[@]}-1}")
# join the json objects with commas and enclose in brackets to create a json array
JSON_STRING="[${JSON_ARRAY[*]}]"

# print the json array
echo "$JSON_STRING"