zcat /home/yanyq/share_genetics/result/PLACO/PLACO_lung-PAAD.gz | cut -f 1,6  > /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_lung-PAAD
sed -i '1d' /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_lung-PAAD
magma --bfile ~/share_genetics/data/MAGMA/g1000_eur/g1000_eur --pval /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_lung-PAAD N=355309 --gene-annot ~/share_genetics/result/MAGMA/anno/MAGMA_g1000_eur_500kb.genes.annot --out ~/share_genetics/result/MAGMA/asso/PLACO_lung-PAAD
