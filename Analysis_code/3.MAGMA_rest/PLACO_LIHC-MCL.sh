zcat /home/yanyq/share_genetics/result/PLACO/PLACO_LIHC-MCL.gz | cut -f 1,6  > /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_LIHC-MCL
sed -i '1d' /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_LIHC-MCL
magma --bfile ~/share_genetics/data/MAGMA/g1000_eur/g1000_eur --pval /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_LIHC-MCL N=629096 --gene-annot ~/share_genetics/result/MAGMA/anno/MAGMA_g1000_eur_10_1.5.genes.annot --out ~/share_genetics/result/MAGMA/asso/PLACO_LIHC-MCL_10_1.5
rm /home/yanyq/share_genetics/result/PLACO/tmp_PLACO_LIHC-MCL
