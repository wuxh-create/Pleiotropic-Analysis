zcat /home/yanyq/share_genetics/result/PLACO/PLACO_lung-SKCM.gz | cut -f 1,6  > /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_lung-SKCM
sed -i '1d' /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_lung-SKCM
magma --bfile ~/share_genetics/data/MAGMA/g1000_eur/g1000_eur --pval /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_lung-SKCM N=442523 --gene-annot ~/share_genetics/result/MAGMA/anno/MAGMA_g1000_eur_500kb.genes.annot --out ~/share_genetics/result/MAGMA/asso/PLACO_lung-SKCM
