zcat /home/yanyq/share_genetics/result/PLACO/PLACO_GSS-MM.gz | cut -f 1,6  > /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_GSS-MM
sed -i '1d' /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_GSS-MM
magma --bfile ~/share_genetics/data/MAGMA/g1000_eur/g1000_eur --pval /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_GSS-MM N=629213 --gene-annot ~/share_genetics/result/MAGMA/anno/MAGMA_g1000_eur_10_1.5.genes.annot --out ~/share_genetics/result/MAGMA/asso/PLACO_GSS-MM_10_1.5
rm /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_GSS-MM
