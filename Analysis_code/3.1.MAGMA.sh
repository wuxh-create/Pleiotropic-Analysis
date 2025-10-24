#!/bin/bash
# ~/share_genetics/data/MAGMA/g1000_eur/dbsnp156.sh
# magma --annotate window=10,1.5 --snp-loc ~/share_genetics/data/MAGMA/g1000_eur/g1000_eur.bim --gene-loc ~/share_genetics/data/MAGMA/NCBI37.3/NCBI37.3.gene.loc --out ~/share_genetics/result/MAGMA/anno/MAGMA_g1000_eur_10_1.5
sampleSize=(514141 632860 632951 402102 382836 632205 1043214 633773 438271 514229 514320 283471 264205 513574 924583 515142 319640 633039 402190 382924 632293 1043302 633861 438359 402281 383015 632384 1043393 633952 438450 152166 401535 812544 403103 207601 382269 793278 383837 188335 1042647 633206 437704 1044215 848713 439272)

i=0
window="10_1.5"
while read line
do
   echo ${sampleSize[i]}
   echo $i
   echo $line
   zcat /home/yanyq/share_genetics/result/PLACO/$line.gz | cut -f 1,6  > /home/yanyq/share_genetics/result/PLACO/${line}_tmp
   sed -i '1d' /home/yanyq/share_genetics/result/PLACO/${line}_tmp
   magma --bfile ~/share_genetics/data/MAGMA/g1000_eur/g1000_eur --pval /home/yanyq/share_genetics/result/PLACO/${line}_tmp N=${sampleSize[i]} --gene-annot ~/share_genetics/result/MAGMA/anno/MAGMA_g1000_eur_${window}.genes.annot --out ~/share_genetics/result/MAGMA/asso/${line}_$window
   let i++
   rm /home/yanyq/share_genetics/result/PLACO/${line}_tmp
done < /home/yanyq/share_genetics/result/PLACO_file

trait=("BLCA" "BRCA" "HNSC" "OV" "PAAD" "PRAD" "SKCM" "UCEC" "kidney" "lung")
sampleSize=(316386 197755 316474 316565 85716 66450 315819 726828 317387 121885)
for i in {0..9}
do
        echo ${trait[$i]}
        echo ${sampleSize[$i]}
        zcat /home/yanyq/share_genetics/data/GWAS/processed/${trait[$i]}.gz | cut -f 1,8 | sed '1d' > /home/yanyq/share_genetics/result/PLACO/${trait[$i]}_tmp
        magma --bfile ~/share_genetics/data/MAGMA/g1000_eur/g1000_eur --pval /home/yanyq/share_genetics/result/PLACO/${trait[$i]}_tmp N=${sampleSize[$i]} --gene-annot ~/share_genetics/result/MAGMA/anno/MAGMA_g1000_eur_${window}.genes.annot --out ~/share_genetics/result/MAGMA/asso/${trait[$i]}_$window
        rm /home/yanyq/share_genetics/result/PLACO/${trait[$i]}_tmp
done
