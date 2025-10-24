for i in {1..22}
do
smr --beqtl-summary ~/cogenetics/data/meQTL/LBC_BSGS_meta_tmp/bl_mqtl_chr$i --genes /home/yanyq/cogenetics/result/smr_multiSNP_0.01/meQTL/all_cancer_fdr_0.05.msmr.methylist --query 1 --out /home/yanyq/cogenetics/data/meQTL/SMR/chr$i
done
