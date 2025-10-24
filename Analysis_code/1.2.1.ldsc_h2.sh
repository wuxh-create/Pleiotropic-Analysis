#!/bin/bash

ldsc_analysis() {
    local trait_path="$1"
    local out_path="$2"

    for i in {0..37}; do
        ldsc.py \
            --h2 "$trait_path/${trait[$i]}.sumstats.gz" \
            --ref-ld-chr /home/yanyq/share_genetics/data/reference/eur_w_ld_chr/ \
            --w-ld-chr /home/yanyq/share_genetics/data/reference/eur_w_ld_chr/ \
            --out "$out_path/${trait[$i]}"
    done
}

trait_path="/home/yanyq/share_genetics/result/ldsc/munge_filter"
out_path="/home/yanyq/share_genetics/result/ldsc/h2"
trait=("BLCA" "BRCA" "HNSC" "kidney" "lung" "OV" "PAAD" "PRAD" "SKCM" "UCEC" "BGC" "CRC" "DLBC" "ESCA" "STAD" "THCA" "AML" "BAC" "BCC" "BGA" "BM" "CESC" "CML" "CORP" "EYAD" "GSS" "HL" "LIHC" "LL" "MCL" "MESO" "MM" "MS" "MZBL" "SCC" "SI" "TEST" "VULVA")

ldsc_analysis "$trait_path" "$out_path"

trait_path="/home/yanyq/share_genetics/result/ldsc/munge_sampleSize_effect_filter"
out_path="/home/yanyq/share_genetics/result/ldsc/h2_sampleSize_effect"

ldsc_analysis "$trait_path" "$out_path"

trait_path="/home/yanyq/share_genetics/result/ldsc/munge_sampleSize_effect_4_filter"
out_path="/home/yanyq/share_genetics/result/ldsc/h2_sampleSize_effect_4"

ldsc_analysis "$trait_path" "$out_path"