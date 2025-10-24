library(vroom)
library(GenomicRanges)
library(readr)
MAGMA_fdr = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/all"))
MAGMA_fdr = MAGMA_fdr[!grepl("CORP", MAGMA_fdr$trait),] # 4274
MAGMA_fdr$SNP_same_dire = NA # SNP效应方向相同
MAGMA_fdr$SNP_diff_dire = NA # 效应方向相反
MAGMA_fdr$SNP_corr = NA # Z值相关性
MAGMA_fdr$SNP_corr_P = NA # Z值相关性

flag = 1
for(i in unique(MAGMA_fdr$trait)[1:50]){
  print(flag)
  flag = flag+1
  trait1 = strsplit(i,"-")[[1]][1]
  trait2 = strsplit(i,"-")[[1]][2]
  
  SNP = as.data.frame(vroom(paste0("/home/yanyq/share_genetics/data/GWAS/overlap/", i, ".gz")))
  SNP_GR = as(paste0(SNP[,paste0("hg19chr.",trait1)], ":",SNP[,paste0("bp.",trait1)]), "GRanges")
  
  MAGMA_fdr_tmp = MAGMA_fdr[MAGMA_fdr$trait==i,]
  MAGMA_fdr_tmp_GR = as(paste0(MAGMA_fdr_tmp$CHR, ":", MAGMA_fdr_tmp$START, "-", MAGMA_fdr_tmp$STOP), "GRanges")
  
  ov = findOverlaps(MAGMA_fdr_tmp_GR,SNP_GR)
  
  for(j in 1:nrow(MAGMA_fdr_tmp)){
    SNP_tmp = SNP[ov@to[ov@from==j],]
    z1 = SNP_tmp[,paste0("zscore.",trait1)]
    z2 = SNP_tmp[,paste0("zscore.",trait2)]
    cor_pearson <- cor.test(x = z1,y = z2, method = 'pearson')
    MAGMA_fdr_tmp$SNP_same_dire[j] = length(which(z1*z2>0))
    MAGMA_fdr_tmp$SNP_diff_dire[j] = length(which(z1*z2<0))
    MAGMA_fdr_tmp$SNP_corr[j] = as.numeric(cor_pearson$estimate)
    MAGMA_fdr_tmp$SNP_corr_P[j] = cor_pearson$p.value
  }
  
  MAGMA_fdr[MAGMA_fdr$trait==i,] = MAGMA_fdr_tmp
}
write_tsv(MAGMA_fdr, "/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/all_corr_1")
