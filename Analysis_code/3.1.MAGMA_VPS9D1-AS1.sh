magma --annotate window=10,1.5 --snp-loc ~/share_genetics/data/MAGMA/g1000_eur/g1000_eur.bim --gene-loc ~/share_genetics/data/MAGMA/NCBI37.3/VPS9D1-AS1 --out ~/share_genetics/result/MAGMA/anno/VPS9D1-AS1_g1000_eur_10_1.5


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
   magma --bfile ~/share_genetics/data/MAGMA/g1000_eur/g1000_eur --pval /home/yanyq/share_genetics/result/PLACO/${line}_tmp N=${sampleSize[i]} --gene-annot ~/share_genetics/result/MAGMA/anno/VPS9D1-AS1_g1000_eur_${window}.genes.annot --out ~/share_genetics/result/MAGMA_VPS9D1-AS1/asso/${line}_$window
   let i++
   rm /home/yanyq/share_genetics/result/PLACO/${line}_tmp
done < /home/yanyq/share_genetics/result/PLACO_file

while read line
do
    array=(${line/\t/,/})
    trait_pairs=${array[0]}
    sampleSize=${array[1]}
    zcat /home/yanyq/share_genetics/result/PLACO/$trait_pairs.gz | cut -f 1,6  > /home/yanyq/share_genetics/result/PLACO/tmp_$trait_pairs
    sed -i '1d' /home/yanyq/share_genetics/result/PLACO/tmp_$trait_pairs
    magma --bfile ~/share_genetics/data/MAGMA/g1000_eur/g1000_eur --pval /home/yanyq/share_genetics/result/PLACO/tmp_$trait_pairs N=$sampleSize --gene-annot ~/share_genetics/result/MAGMA/anno/VPS9D1-AS1_g1000_eur_10_1.5.genes.annot --out ~/share_genetics/result/MAGMA_VPS9D1-AS1/asso/$trait_pairs_10_1.5
    rm /home/yanyq/share_genetics/result/PLACO/tmp_$trait_pairs
done < /home/yanyq/share_genetics/data/sampleSize_trait_pairs_rest

