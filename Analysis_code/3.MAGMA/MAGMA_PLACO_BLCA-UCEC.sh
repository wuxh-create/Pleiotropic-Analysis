zcat /home/yanyq/share_genetics/result/PLACO/PLACO_BLCA-UCEC.gz | cut -f 1,6  > /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_BLCA-UCEC
sed -i '1d' /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_BLCA-UCEC
magma --bfile ~/share_genetics/data/MAGMA/g1000_eur/g1000_eur --pval /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_BLCA-UCEC N=411075 --gene-annot ~/share_genetics/result/MAGMA/anno/MAGMA_g1000_eur_500kb.genes.annot --out ~/share_genetics/result/MAGMA/asso/PLACO_BLCA-UCEC
