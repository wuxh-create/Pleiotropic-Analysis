zcat /home/yanyq/share_genetics/result/PLACO/PLACO_OV-PRAD.gz | cut -f 1,6  > /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_OV-PRAD
sed -i '1d' /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_OV-PRAD
magma --bfile ~/share_genetics/data/MAGMA/g1000_eur/g1000_eur --pval /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_OV-PRAD N=141299 --gene-annot ~/share_genetics/result/MAGMA/anno/MAGMA_g1000_eur_500kb.genes.annot --out ~/share_genetics/result/MAGMA/asso/PLACO_OV-PRAD
