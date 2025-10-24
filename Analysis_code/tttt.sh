#!/bin/bash
perform_ldsc_analysis() {
    local ttt=$3
    local -n traits=$2
    local tmp=$1
    echo $tmp
    echo $ttt
    for ((i = 0; i < ${#traits[@]}; i++)); do
        for ((j = i + 1; j < ${#traits[@]}; j++)); do
            echo ${traits[$i]}
            echo ${traits[$j]}
            echo '1'
        done
    done

}
trait1=("BLCA" "BRCA" "HNSC" "kidney")
perform_ldsc_analysis 'tmptmp' trait1 ''

