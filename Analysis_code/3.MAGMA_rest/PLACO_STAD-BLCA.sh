zcat /home/yanyq/share_genetics/result/PLACO/PLACO_STAD-BLCA.gz | cut -f 1,6  > /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_STAD-BLCA
sed -i '1d' /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_STAD-BLCA
magma --bfile ~/share_genetics/data/MAGMA/g1000_eur/g1000_eur --pval /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_STAD-BLCA N=632002 --gene-annot ~/share_genetics/result/MAGMA/anno/MAGMA_g1000_eur_10_1.5.genes.annot --out ~/share_genetics/result/MAGMA/asso/PLACO_STAD-BLCA_10_1.5
rm /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_STAD-BLCA
