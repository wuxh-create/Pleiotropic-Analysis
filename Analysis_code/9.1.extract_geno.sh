for chr in 1 3 4 5 6 7 8 9 10 11 12 14 15 17 19 22
do
        echo $chr
        echo "BRCA"
        plink2 --bgen /home/luohh/UKB50wData/01.Download/02.ImputationData/ukb_imp_chr${chr}_v3.bgen 'ref-first' --sample /home/luohh/UKB50wData/01.Download/02.ImputationData/ukb_imp_chr${chr}_v3.sample --extract "/home/yanyq/share_genetics/result/PLACO/sigUnique_SNP/BRCA-OV" --keep "/home/yanyq/share_genetics/data/UKB_multi_cancer/01.mpcSampleExtract/singleCancer.breast.sample" --make-bed --out /home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/BRCA_chr$chr
        echo "OV"
        plink2 --bgen /home/luohh/UKB50wData/01.Download/02.ImputationData/ukb_imp_chr${chr}_v3.bgen 'ref-first' --sample /home/luohh/UKB50wData/01.Download/02.ImputationData/ukb_imp_chr${chr}_v3.sample --extract "/home/yanyq/share_genetics/result/PLACO/sigUnique_SNP/BRCA-OV" --keep "/home/yanyq/share_genetics/data/UKB_multi_cancer/01.mpcSampleExtract/singleCancer.ovary.sample" --make-bed --out /home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/OV_chr$chr
        echo "BRAC_OV"
        plink2 --bgen /home/luohh/UKB50wData/01.Download/02.ImputationData/ukb_imp_chr${chr}_v3.bgen 'ref-first' --sample /home/luohh/UKB50wData/01.Download/02.ImputationData/ukb_imp_chr${chr}_v3.sample --extract "/home/yanyq/share_genetics/result/PLACO/sigUnique_SNP/BRCA-OV" --keep "/home/yanyq/share_genetics/data/UKB_multi_cancer/01.mpcSampleExtract/breastThenOvary.sample" --make-bed --out /home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/BRCA_OV_chr$chr
        echo "OV_BRCA"
        plink2 --bgen /home/luohh/UKB50wData/01.Download/02.ImputationData/ukb_imp_chr${chr}_v3.bgen 'ref-first' --sample /home/luohh/UKB50wData/01.Download/02.ImputationData/ukb_imp_chr${chr}_v3.sample --extract "/home/yanyq/share_genetics/result/PLACO/sigUnique_SNP/BRCA-OV" --keep "/home/yanyq/share_genetics/data/UKB_multi_cancer/01.mpcSampleExtract/ovaryThenBreast.sample"  --make-bed --out /home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/OV_BRCA_chr$chr

        echo '/home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/BRCA_chr'"$chr"'' >> /home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/BRCA_concat_list
        echo '/home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/OV_chr'"$chr"'' >> /home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/OV_concat_list
        echo '/home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/BRCA_OV_chr'"$chr"'' >> /home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/BRCA_OV_concat_list
        echo '/home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/OV_BRCA_chr'"$chr"'' >> /home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/OV_BRCA_concat_list
done

# 存在三个等位基因的SNP
for(chr in c(1,3:9, 10, 11, 12, 14, 15, 17, 19, 22)){
  f = read_tsv(paste0("/home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/BRCA_chr",chr,".bim"), col_names = F)
  f$X2 = paste0(f$X2,":",f$X5,":",f$X6)
  write_tsv(f,paste0("/home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/BRCA_chr",chr,".bim"), col_names = F)

  f = read_tsv(paste0("/home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/OV_chr",chr,".bim"), col_names = F)
  f$X2 = paste0(f$X2,":",f$X5,":",f$X6)
  write_tsv(f,paste0("/home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/OV_chr",chr,".bim"), col_names = F)

  f = read_tsv(paste0("/home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/BRCA_OV_chr",chr,".bim"), col_names = F)
  f$X2 = paste0(f$X2,":",f$X5,":",f$X6)
  write_tsv(f,paste0("/home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/BRCA_OV_chr",chr,".bim"), col_names = F)

  f = read_tsv(paste0("/home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/OV_BRCA_chr",chr,".bim"), col_names = F)
  f$X2 = paste0(f$X2,":",f$X5,":",f$X6)
  write_tsv(f,paste0("/home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/OV_BRCA_chr",chr,".bim"), col_names = F)
}


plink --merge-list /home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/BRCA_concat_list --out /home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/BRCA_all
plink --merge-list /home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/OV_concat_list --out /home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/OV_all
plink --merge-list /home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/BRCA_OV_concat_list --out /home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/BRCA_OV_all
plink --merge-list /home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/OV_BRCA_concat_list --out /home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/OV_BRCA_all

cd ~/share_genetics/data/UKB_multi_cancer/genotype

plink --bfile BRCA_all --freq --out BRCA_all
plink --bfile OV_all --freq --out OV_all
plink --bfile BRCA_OV_all --freq --out BRCA_OV_all
plink --bfile OV_BRCA_all --freq --out OV_BRCA_all

# 分两组
plink --bfile BRCA_all --bmerge OV_all.bed OV_all.bim OV_all.fam --make-bed --out all_single
plink --bfile BRCA_OV_all --bmerge OV_BRCA_all.bed OV_BRCA_all.bim OV_BRCA_all.fam --make-bed --out all_multi
plink --bfile all_single --freq --out all_single
plink --bfile all_multi --freq --out all_multi

# f = read_tsv("/home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/BRCA_all.bim",col_names = F)
# f[!grepl("rs",f$X2),]
# f = tidyr::separate(f, col = "X2", into = "SNP", sep = ":")
# write_tsv(f, "/home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/BRCA_all.bim",col_names = F)
# f = read_tsv("/home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/OV_all.bim",col_names = F)
# f[!grepl("rs",f$X2),]
# f = tidyr::separate(f, col = "X2", into = "SNP", sep = ":")
# write_tsv(f, "/home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/OV_all.bim",col_names = F)
# f = read_tsv("/home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/BRCA_OV_all.bim",col_names = F)
# f[!grepl("rs",f$X2),]
# f = tidyr::separate(f, col = "X2", into = "SNP", sep = ":")
# write_tsv(f, "/home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/BRCA_OV_all.bim",col_names = F)
# f = read_tsv("/home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/OV_BRCA_all.bim",col_names = F)
# f[!grepl("rs",f$X2),]
# f = tidyr::separate(f, col = "X2", into = "SNP", sep = ":")
# write_tsv(f, "/home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/OV_BRCA_all.bim",col_names = F)

plink --bfile /home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/BRCA_all --export vcf --out /home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/BRCA_all
plink --bfile /home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/BRCA_OV_all --export vcf --out /home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/BRCA_OV_all
plink --bfile /home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/OV_all --export vcf --out /home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/OV_all
plink --bfile /home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/OV_BRCA_all --export vcf --out /home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/OV_BRCA_all
plink --bfile /home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/all_single --export vcf --out /home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/all_single
plink --bfile /home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/all_multi --export vcf --out /home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/all_multi
