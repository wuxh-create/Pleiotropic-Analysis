# 共定位
library(locuscomparer)

{ # THCA-PRAD-HAUS6
  rm(list = ls())
  setwd("~/share_genetics/data/GWAS/processed")
  library(readr)
  library(data.table)
  library(coloc)
  trait1 = "THCA"
  trait2 = "PRAD"
  MAGMA_both = fread(paste0("/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/",trait1,"-",trait2))
  MAGMA_both = MAGMA_both[MAGMA_both$SYMBOL=="HAUS6",]
  overlap = fread(paste0("~/share_genetics/data/GWAS/overlap/",trait1,"-",trait2,".gz"))
  colnames(overlap)[2:3] = c("chr","bp")
  overlap_f = overlap[overlap$chr==MAGMA_both$CHR&overlap$bp>=MAGMA_both$START&overlap$bp<=MAGMA_both$STOP,]

  THCA <- overlap_f[,c('snpid','pval.THCA')] %>%
    dplyr::rename(rsid = snpid, pval = pval.THCA)
  PRAD <- overlap_f[,c('snpid','pval.PRAD')] %>%
    dplyr::rename(rsid = snpid, pval = pval.PRAD)
  print(locuscompare(in_fn1 = THCA, 
                     in_fn2 = PRAD, 
                     title1 = 'THCA', 
                     title2 = 'PRAD'))
}