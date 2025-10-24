#!/bin/bash
ls /home/yanyq/share_genetics/data/FUSION > /home/yanyq/share_genetics/data/tmp_files
sed -i 's/.tar.gz//g' /home/yanyq/share_genetics/data/tmp_files

mkdir /home/yanyq/share_genetics/data/FUSION/tmp
while read line
do
    echo $line
    tar -xzvf /home/yanyq/share_genetics/data/FUSION/$line.tar.gz -C /home/yanyq/share_genetics/data/FUSION/tmp/
done < /home/yanyq/share_genetics/data/tmp_files

# ln -s /home/yanyq/share_genetics/data/GWAS/SUPERGNOVA /home/yanyq/share_genetics/data/GWAS/FUSION
while read line
do
    mkdir /home/yanyq/share_genetics/result/FUSION/$line
    echo $line
    while read cancer
    do
        array=(${cancer//\t/})
        echo ${array[0]}
        echo ${array[1]}
        for chrom in {1..22}
        do
            Rscript /home/yanyq/software/fusion_twas-master/FUSION.assoc_test.R \
            --sumstats /home/yanyq/share_genetics/data/GWAS/FUSION/${array[0]}.gz \
            --weights /home/yanyq/share_genetics/data/FUSION/tmp/$line.pos \
            --weights_dir /home/yanyq/share_genetics/data/FUSION/tmp/ \
            --ref_ld_chr /home/yanyq/share_genetics/data/MAGMA/g1000_eur/chr/chr \
            --chr $chrom \
            --GWASN ${array[1]}\
            --out /home/yanyq/share_genetics/result/FUSION/$line/${array[0]}_chr${chrom}
        done
    done < /home/yanyq/share_genetics/data/sampleSize
done < /home/yanyq/share_genetics/data/tmp_files
rm /home/yanyq/share_genetics/data/tmp_files


