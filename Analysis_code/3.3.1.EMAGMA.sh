#!/bin/bash
while read line
do
    array=(${line/\t/,/})
    trait_pairs=${array[0]}
    sampleSize=${array[1]}
    echo 'zcat /home/yanyq/share_genetics/result/PLACO/'$trait_pairs'.gz | cut -f 1,6  > /home/yanyq/share_genetics/result/PLACO/tmp_'$trait_pairs > ~/share_genetics/pipeline/code/3.EMAGMA_rest/$trait_pairs.sh
    echo "sed -i '1d' /home/yanyq/share_genetics/result/PLACO/tmp_"$trait_pairs >> ~/share_genetics/pipeline/code/3.EMAGMA_rest/$trait_pairs.sh
    echo 'while read tissue' >> ~/share_genetics/pipeline/code/3.EMAGMA_rest/$trait_pairs.sh
    echo 'do'>> ~/share_genetics/pipeline/code/3.EMAGMA_rest/$trait_pairs.sh
        echo 'magma --bfile ~/share_genetics/data/MAGMA/g1000_eur/g1000_eur --gene-annot /home/yanyq/software/eMAGMA-tutorial/$tissue.genes.annot --pval /home/yanyq/share_genetics/result/PLACO/tmp_'$trait_pairs' N='$sampleSize' --out ~/share_genetics/result/EMAGMA/asso/$tissue/'${trait_pairs} >> ~/share_genetics/pipeline/code/3.EMAGMA_rest/$trait_pairs.sh
    echo 'done < /home/yanyq/software/eMAGMA-tutorial/annot_file' >> ~/share_genetics/pipeline/code/3.EMAGMA_rest/$trait_pairs.sh
    echo 'rm /home/yanyq/share_genetics/result/PLACO/tmp_'$trait_pairs >> ~/share_genetics/pipeline/code/3.EMAGMA_rest/$trait_pairs.sh
    echo 'nohup bash ~/share_genetics/pipeline/code/3.EMAGMA_rest/'$trait_pairs'.sh >& ~/share_genetics/pipeline/code/log/3.MAGMA_rest/'$trait_pairs'.log &' >> ~/share_genetics/pipeline/code/EMAGMA_run
done < /home/yanyq/share_genetics/data/sampleSize_trait_pairs_rest