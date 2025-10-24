# 下载ldetect计算的EUR 1703个染色体分区 https://bitbucket.org/nygcresearch/ldetect-data.git

# 局部遗传相关性
LOGODetect_analysis() {
    local trait1=$1
    local trait2=$2
    local N1=$3
    local N2=$4
    
    trait_path=/home/yanyq/share_genetics/data/GWAS/processed
    echo 'Rscript ~/software/LOGODetect/LOGODetect.R --sumstats '$trait_path'/'$trait1'.gz,'$trait_path'/'$trait2'.gz --n_gwas '$N1','$N2' --ref_dir /home/yanyq/software/LOGODetect/LOGODetect_data/LOGODetect_1kg_ref --pop EUR --ldsc_dir /home/yanyq/software/LOGODetect/ldsc --block_partition /home/yanyq/software/ldetect-data/EUR/fourier_ls-all.bed --out_dir ~/share_genetics/result/LOGODetect --n_cores 20' >> ~/share_genetics/pipeline/code/1.7.2.run_LOGODetect.sh
    echo 'mv ~/share_genetics/result/LOGODetect/LOGODetect_regions.txt ~/share_genetics/result/LOGODetect/'${trait1}'_'${trait2}'' >> ~/share_genetics/pipeline/code/1.7.2.run_LOGODetect.sh
    # Rscript ~/software/LOGODetect/LOGODetect.R \
    #     --sumstats $trait_path/$trait1.gz,$trait_path/$trait2.gz \
    #     --n_gwas $N1,$N2 \
    #     --ref_dir /home/yanyq/software/LOGODetect/LOGODetect_data/LOGODetect_1kg_ref \
    #     --pop EUR \
    #     --ldsc_dir /home/yanyq/software/LOGODetect/ldsc \
    #     --block_partition /home/yanyq/software/ldetect-data/EUR/fourier_ls-all.bed \
    #     --out_dir ~/share_genetics/result/LOGODetect \
    #     --n_cores 20
    
    # mv ~/share_genetics/result/LOGODetect/LOGODetect_regions.txt ~/share_genetics/result/LOGODetect/${trait1}_${trait2}
}

# Function to perform LDSC analysis for a given set of traits
perform_analysis() {
    local -n traits=$1
    local -n sampleSize=$2

    for ((i = 0; i < ${#traits[@]}; i++)); do
        for ((j = i + 1; j < ${#traits[@]}; j++)); do
            LOGODetect_analysis ${traits[$i]} ${traits[$j]} ${sampleSize[$i]} ${sampleSize[$j]}
        done
    done
}

# Function to perform cross-group LDSC analysis
perform_cross_analysis() {
    local -n traits1=$1
    local -n traits2=$2
    local -n sampleSize1=$3
    local -n sampleSize2=$4

    for ((i = 0; i < ${#traits1[@]}; i++)); do
        for ((j = 0; j < ${#traits2[@]}; j++)); do
            LOGODetect_analysis ${traits1[$i]} ${traits2[$j]} ${sampleSize1[$i]} ${sampleSize2[$j]}
        done
    done
}

trait1=("BLCA" "BRCA" "HNSC" "kidney" "lung" "OV" "PAAD" "PRAD" "SKCM" "UCEC")
sampleSize_trait1=(8711 196647 9058 9417 77095 62866 6471 406587 12647 46158)
trait2=("BGC" "CRC" "DLBC" "ESCA" "STAD" "THCA")
sampleSize_trait2=(4810 181188 4186 13268 5666 7582)
trait3=("AML" "BAC" "BCC" "BGA" "BM" "CESC" "CML" "CORP" "EYAD" "GSS" "HL" "LIHC" "LL" "MCL" "MESO" "MM" "MS" "MZBL" "SCC" "SI" "TEST" "VULVA")
sampleSize_trait3=(975 895 76999 1363 5242 25839 460 8223 883 1035 1714 1997 3401 839 1422 2487 823 807 13967 2096 1698 807)

perform_analysis  trait1 sampleSize_trait1
perform_analysis  trait2 sampleSize_trait2
perform_analysis trait3 sampleSize_trait3
perform_cross_analysis trait2 trait1 sampleSize_trait2 sampleSize_trait1
perform_cross_analysis trait3 trait1 sampleSize_trait3 sampleSize_trait1
perform_cross_analysis trait3 trait2 sampleSize_trait3 sampleSize_trait2