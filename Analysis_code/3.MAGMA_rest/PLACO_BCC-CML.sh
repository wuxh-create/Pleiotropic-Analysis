zcat /home/yanyq/share_genetics/result/PLACO/PLACO_BCC-CML.gz | cut -f 1,6  > /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_BCC-CML
sed -i '1d' /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_BCC-CML
magma --bfile ~/share_genetics/data/MAGMA/g1000_eur/g1000_eur --pval /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_BCC-CML N=649006 --gene-annot ~/share_genetics/result/MAGMA/anno/MAGMA_g1000_eur_10_1.5.genes.annot --out ~/share_genetics/result/MAGMA/asso/PLACO_BCC-CML_10_1.5
rm /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_BCC-CML
