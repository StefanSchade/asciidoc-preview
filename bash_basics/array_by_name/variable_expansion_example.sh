#!/bin/bash

# indirect expansion, the content of var_name is
# treated as the name of another variable
#
access_variable_by_name() {
    local var_name=$1
    echo "Variable name is: $var_name"
    echo "Variable content: ${!var_name}"
}

# here $var_name is the value in the functions
# argument - it does not refer to the underlying
# variable
#
access_variable_by_value() {
    local var_name=$1
    echo "Variable content: $var_name"
}

access_array_by_name() {
   local array_name=$1
   # ${!VAR} notation not possible for arrays
   declare -n array_ref="$array_name" 

   echo "Array name is: $array_name"
   echo "Array content: ${array_ref[@]}"
   echo "First element: ${array_ref[0]}"
   echo "Array length:  ${#array_ref[@]}"
   echo "Array indices: ${!array_ref[@]}"
   echo "First two elements: ${array_ref[@]:0:2}"
   echo "Looping over array contents:"
   for item in "${array_ref[@]}"; do
       echo "Item: $item"
   done
}

access_array_by_value() {
    local -n array_ref=$1  # Reference the array directly
    echo "Array content: ${array_ref[@]}"
    echo "First element: ${array_ref[0]}"
    echo "Array length:  ${#array_ref[@]}"  # Length of the array
    echo "All indices:   ${!array_ref[@]}"   # Indices of the array
}

helloworld="Hello World"
echo -e "\nAcess simple variable by name:"
access_variable_by_name "helloworld"

echo -e "\nAcess simple variable by directly:"
access_variable_by_value helloworld
# part after space is treated as second arguement
access_variable_by_value $helloworld
access_variable_by_value "$helloworld"

fruits=("apple" "banana" "cherry")
echo -e "\nAcess array by name:"
access_array_by_name "fruits"
echo -e "\nAcess array directly:"
access_array_by_value fruits
