#!/bin/bash

# font: (N)ORMAL, (X)BOLD, (R)ED, (G)REEN, (B)LUE
declare -A C # -A option declares associative array.
C[N]="\e[0m" 
C[X]="\e[1;38m" 
C[r]="\e[0;31m"
C[R]="\e[1;31m"
C[g]="\e[0;32m"
C[G]="\e[1;32m"
C[b]="\e[0;34m"
C[B]="\e[1;34m"
