zcat /home/yanyq/share_genetics/result/PLACO/PLACO_LIHC-THCA.gz | cut -f 1,6  > /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_LIHC-THCA
sed -i '1d' /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_LIHC-THCA
magma --bfile ~/share_genetics/data/MAGMA/g1000_eur/g1000_eur --pval /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_LIHC-THCA N=630793 --gene-annot ~/share_genetics/result/MAGMA/anno/MAGMA_g1000_eur_10_1.5.genes.annot --out ~/share_genetics/result/MAGMA/asso/PLACO_LIHC-THCA_10_1.5
rm /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_LIHC-THCA
