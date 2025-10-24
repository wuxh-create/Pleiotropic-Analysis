zcat /home/yanyq/share_genetics/result/PLACO/PLACO_BGA-GSS.gz | cut -f 1,6  > /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_BGA-GSS
sed -i '1d' /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_BGA-GSS
magma --bfile ~/share_genetics/data/MAGMA/g1000_eur/g1000_eur --pval /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_BGA-GSS N=628939 --gene-annot ~/share_genetics/result/MAGMA/anno/MAGMA_g1000_eur_10_1.5.genes.annot --out ~/share_genetics/result/MAGMA/asso/PLACO_BGA-GSS_10_1.5
rm /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_BGA-GSS
