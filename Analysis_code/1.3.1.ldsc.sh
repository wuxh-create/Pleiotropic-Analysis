#!/bin/bash

# trait_path="/home/yanyq/share_genetics/result/ldsc/munge_filter"

# trait1=("BLCA" "BRCA" "HNSC" "kidney" "lung" "OV" "PAAD" "PRAD" "SKCM" "UCEC")
# trait2=("BGC" "CRC" "DLBC" "ESCA" "STAD" "THCA")
# trait3=("AML" "BAC" "BCC" "BGA" "BM" "CESC" "CML" "CORP" "EYAD" "GSS" "HL" "LIHC" "LL" "MCL" "MESO" "MM" "MS" "MZBL" "SCC" "SI" "TEST" "VULVA")

# for i in {0..8}
# do
#         j=$(($i+1))
#         while [ $j -lt 10 ]
#         do
#                 ldsc.py \
#                         --rg $trait_path/${trait1[i]}.sumstats.gz,$trait_path/${trait1[j]}.sumstats.gz \
#                         --ref-ld-chr /home/yanyq/share_genetics/data/reference/eur_w_ld_chr/ \
#                         --w-ld-chr /home/yanyq/share_genetics/data/reference/eur_w_ld_chr/ \
#                         --out /home/yanyq/share_genetics/result/ldsc/ldsc/${trait1[i]}_${trait1[j]}
#                 let j++
#         done
# done

# for i in {0..4}
# do
#         j=$(($i+1))
#         while [ $j -lt 6 ]
#         do
#                 ldsc.py \
#                         --rg $trait_path/${trait2[i]}.sumstats.gz,$trait_path/${trait2[j]}.sumstats.gz \
#                         --ref-ld-chr /home/yanyq/share_genetics/data/reference/eur_w_ld_chr/ \
#                         --w-ld-chr /home/yanyq/share_genetics/data/reference/eur_w_ld_chr/ \
#                         --out /home/yanyq/share_genetics/result/ldsc/ldsc/${trait2[i]}_${trait2[j]}
#                 let j++
#         done
# done

# for i in {0..20}
# do
#         j=$(($i+1))
#         while [ $j -lt 22 ]
#         do
#                 ldsc.py \
#                         --rg $trait_path/${trait3[i]}.sumstats.gz,$trait_path/${trait3[j]}.sumstats.gz \
#                         --ref-ld-chr /home/yanyq/share_genetics/data/reference/eur_w_ld_chr/ \
#                         --w-ld-chr /home/yanyq/share_genetics/data/reference/eur_w_ld_chr/ \
#                         --out /home/yanyq/share_genetics/result/ldsc/ldsc/${trait3[i]}_${trait3[j]}
#                 let j++
#         done
# done

# for i in {0..5}
# do
#         for j in {0..9}
#         do
#                 ldsc.py \
#                         --rg $trait_path/${trait2[i]}.sumstats.gz,$trait_path/${trait1[j]}.sumstats.gz \
#                         --ref-ld-chr /home/yanyq/share_genetics/data/reference/eur_w_ld_chr/ \
#                         --w-ld-chr /home/yanyq/share_genetics/data/reference/eur_w_ld_chr/ \
#                         --out /home/yanyq/share_genetics/result/ldsc/ldsc/${trait2[i]}_${trait1[j]}
#         done
# done

# for i in {0..21}
# do
#         for j in {0..9}
#         do
#                 ldsc.py \
#                         --rg $trait_path/${trait3[i]}.sumstats.gz,$trait_path/${trait1[j]}.sumstats.gz \
#                         --ref-ld-chr /home/yanyq/share_genetics/data/reference/eur_w_ld_chr/ \
#                         --w-ld-chr /home/yanyq/share_genetics/data/reference/eur_w_ld_chr/ \
#                         --out /home/yanyq/share_genetics/result/ldsc/ldsc/${trait3[i]}_${trait1[j]}
#         done
# done

# for i in {0..21}
# do
#         for j in {0..5}
#         do
#                 ldsc.py \
#                         --rg $trait_path/${trait3[i]}.sumstats.gz,$trait_path/${trait2[j]}.sumstats.gz \
#                         --ref-ld-chr /home/yanyq/share_genetics/data/reference/eur_w_ld_chr/ \
#                         --w-ld-chr /home/yanyq/share_genetics/data/reference/eur_w_ld_chr/ \
#                         --out /home/yanyq/share_genetics/result/ldsc/ldsc/${trait3[i]}_${trait2[j]}
#         done
# done

ldsc_analysis() {
    local folder=$1
    local trait1=$2
    local trait2=$3
    
    trait_path=/home/yanyq/share_genetics/result/ldsc/munge${folder}_filter
    ldsc.py \
        --rg $trait_path/$trait1.sumstats.gz,$trait_path/$trait2.sumstats.gz \
        --ref-ld-chr /home/yanyq/share_genetics/data/reference/eur_w_ld_chr/ \
        --w-ld-chr /home/yanyq/share_genetics/data/reference/eur_w_ld_chr/ \
        --out /home/yanyq/share_genetics/result/ldsc/ldsc${folder}/${trait1}_${trait2}
}

# Function to perform LDSC analysis for a given set of traits
perform_ldsc_analysis() {
    local folder=$1
    local -n traits=$2

    for ((i = 0; i < ${#traits[@]}; i++)); do
        for ((j = i + 1; j < ${#traits[@]}; j++)); do
            ldsc_analysis "$folder" ${traits[$i]} ${traits[$j]}
        done
    done
}

# Function to perform cross-group LDSC analysis
perform_cross_ldsc_analysis() {
    local folder=$1
    local -n traits1=$2
    local -n traits2=$3

    for ((i = 0; i < ${#traits1[@]}; i++)); do
        for ((j = 0; j < ${#traits2[@]}; j++)); do
            ldsc_analysis "$folder" ${traits1[$i]} ${traits2[$j]}
        done
    done
}

trait1=("BLCA" "BRCA" "HNSC" "kidney" "lung" "OV" "PAAD" "PRAD" "SKCM" "UCEC")
trait2=("BGC" "CRC" "DLBC" "ESCA" "STAD" "THCA")
trait3=("AML" "BAC" "BCC" "BGA" "BM" "CESC" "CML" "CORP" "EYAD" "GSS" "HL" "LIHC" "LL" "MCL" "MESO" "MM" "MS" "MZBL" "SCC" "SI" "TEST" "VULVA")

folder=""
perform_ldsc_analysis "$folder" trait1
perform_ldsc_analysis "$folder" trait2
perform_ldsc_analysis "$folder" trait3
perform_cross_ldsc_analysis "$folder" trait2 trait1
perform_cross_ldsc_analysis "$folder" trait3 trait1
perform_cross_ldsc_analysis "$folder" trait3 trait2

folder="_sampleSize_effect"
perform_ldsc_analysis "$folder" trait1
perform_ldsc_analysis "$folder" trait2
perform_ldsc_analysis "$folder" trait3
perform_cross_ldsc_analysis "$folder" trait2 trait1
perform_cross_ldsc_analysis "$folder" trait3 trait1
perform_cross_ldsc_analysis "$folder" trait3 trait2

folder="_sampleSize_effect_4"
perform_ldsc_analysis "$folder" trait1
perform_ldsc_analysis "$folder" trait2
perform_ldsc_analysis "$folder" trait3
perform_cross_ldsc_analysis "$folder" trait2 trait1
perform_cross_ldsc_analysis "$folder" trait3 trait1
perform_cross_ldsc_analysis "$folder" trait3 trait2