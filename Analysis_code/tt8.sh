while read line
do
    array=(${line/\t/,/})
    trait_pairs=${array[0]}
    sampleSize=${array[1]}
    zcat /home/yanyq/share_genetics/result/PLACO/${trait_pairs}.gz | cut -f 1,6  > /home/yanyq/share_genetics/result/PLACO/tmp_${trait_pairs}
    sed -i '1d' /home/yanyq/share_genetics/result/PLACO/tmp_${trait_pairs}
    magma --bfile ~/share_genetics/data/MAGMA/g1000_eur/g1000_eur --pval /home/yanyq/share_genetics/result/PLACO/tmp_${trait_pairs} N=$sampleSize --gene-annot ~/share_genetics/result/MAGMA/anno/VPS9D1-AS1_g1000_eur_10_1.5.genes.annot --out ~/share_genetics/result/MAGMA_VPS9D1-AS1/asso/${trait_pairs}_10_1.5
    rm /home/yanyq/share_genetics/result/PLACO/tmp_${trait_pairs}
done < 8
