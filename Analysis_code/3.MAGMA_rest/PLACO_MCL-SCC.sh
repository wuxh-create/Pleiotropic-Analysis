zcat /home/yanyq/share_genetics/result/PLACO/PLACO_MCL-SCC.gz | cut -f 1,6  > /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_MCL-SCC
sed -i '1d' /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_MCL-SCC
magma --bfile ~/share_genetics/data/MAGMA/g1000_eur/g1000_eur --pval /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_MCL-SCC N=632127 --gene-annot ~/share_genetics/result/MAGMA/anno/MAGMA_g1000_eur_10_1.5.genes.annot --out ~/share_genetics/result/MAGMA/asso/PLACO_MCL-SCC_10_1.5
rm /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_MCL-SCC
