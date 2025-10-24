zcat /home/yanyq/share_genetics/result/PLACO/PLACO_BRCA-kidney.gz | cut -f 1,6  > /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_BRCA-kidney
sed -i '1d' /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_BRCA-kidney
magma --bfile ~/share_genetics/data/MAGMA/g1000_eur/g1000_eur --pval /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_BRCA-kidney N=609443 --gene-annot ~/share_genetics/result/MAGMA/anno/MAGMA_g1000_eur_500kb.genes.annot --out ~/share_genetics/result/MAGMA/asso/PLACO_BRCA-kidney
