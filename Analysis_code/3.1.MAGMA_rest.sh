#!/bin/bash
while read line
do
    array=(${line/\t/,/})
    trait_pairs=${array[0]}
    sampleSize=${array[1]}
    echo 'zcat /home/yanyq/share_genetics/result/PLACO/'$trait_pairs'.gz | cut -f 1,6  > /home/yanyq/share_genetics/result/PLACO/tmp_'$trait_pairs > ~/share_genetics/pipeline/code/3.MAGMA_rest/$trait_pairs.sh
    echo "sed -i '1d' /home/yanyq/share_genetics/result/PLACO/tmp_"$trait_pairs >> ~/share_genetics/pipeline/code/3.MAGMA_rest/$trait_pairs.sh
    echo 'magma --bfile ~/share_genetics/data/MAGMA/g1000_eur/g1000_eur --pval /home/yanyq/share_genetics/result/PLACO/tmp_'$trait_pairs' N='$sampleSize' --gene-annot ~/share_genetics/result/MAGMA/anno/MAGMA_g1000_eur_10_1.5.genes.annot --out ~/share_genetics/result/MAGMA/asso/'$trait_pairs'_10_1.5' >> ~/share_genetics/pipeline/code/3.MAGMA_rest/$trait_pairs.sh
    echo 'rm /home/yanyq/share_genetics/result/PLACO/tmp_'$trait_pairs >> ~/share_genetics/pipeline/code/3.MAGMA_rest/$trait_pairs.sh
    echo 'nohup bash ~/share_genetics/pipeline/code/3.MAGMA_rest/'$trait_pairs'.sh >& ~/share_genetics/pipeline/code/log/3.MAGMA_rest/'$trait_pairs'.log &' >> ~/share_genetics/pipeline/code/MAGMA_run
done < /home/yanyq/share_genetics/data/sampleSize_trait_pairs_rest

i=0
window="10_1.5"

trait=("CRC" "DLBC" "ESCA" "STAD" "THCA" "BGC" "AML" "BAC" "BCC" "BGA" "BM" "CESC" "CML" "CORP" "EYAD" "GSS" "HL" "LIHC" "LL" "MCL" "MESO" "MM" "MS" "MZBL" "SCC" "SI" "TEST" "VULVA")
sampleSize=(185616 315243  21271  315616  316100  315400  314436  314417  334699  314534  314708  416913  314307  185006  314414  314405  456276  314693  411202  314403  314549  314808  314302  314395  317724  314718  131692  183129)
for i in {0..27}
do
        echo ${trait[$i]}
        echo ${sampleSize[$i]}
        zcat /home/yanyq/share_genetics/data/GWAS/processed/${trait[$i]}.gz | cut -f 1,8 | sed '1d' > /home/yanyq/share_genetics/result/PLACO/${trait[$i]}_tmp
        magma --bfile ~/share_genetics/data/MAGMA/g1000_eur/g1000_eur --pval /home/yanyq/share_genetics/result/PLACO/${trait[$i]}_tmp N=${sampleSize[$i]} --gene-annot ~/share_genetics/result/MAGMA/anno/MAGMA_g1000_eur_${window}.genes.annot --out ~/share_genetics/result/MAGMA/asso/${trait[$i]}_$window
        rm /home/yanyq/share_genetics/result/PLACO/${trait[$i]}_tmp
done

