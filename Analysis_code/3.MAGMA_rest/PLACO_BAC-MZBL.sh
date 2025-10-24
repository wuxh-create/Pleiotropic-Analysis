zcat /home/yanyq/share_genetics/result/PLACO/PLACO_BAC-MZBL.gz | cut -f 1,6  > /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_BAC-MZBL
sed -i '1d' /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_BAC-MZBL
magma --bfile ~/share_genetics/data/MAGMA/g1000_eur/g1000_eur --pval /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_BAC-MZBL N=628812 --gene-annot ~/share_genetics/result/MAGMA/anno/MAGMA_g1000_eur_10_1.5.genes.annot --out ~/share_genetics/result/MAGMA/asso/PLACO_BAC-MZBL_10_1.5
rm /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_BAC-MZBL
