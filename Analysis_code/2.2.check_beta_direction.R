# PLACO中SNP的beta方向与GWAS原文件中是否不同，没啥不同
# PLACO中SNP全转为beta为正，保留唯一rsid

library(readr)
PLACO = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer_MAGMA_SMR_GWASCatalog"))
PLACO = PLACO[,1:19]
some_wrong = c()
for(i in unique(c(PLACO$trait1, PLACO$trait2))){
  t1 = PLACO[PLACO$trait1==i,c(1:6)]
  t2 = PLACO[PLACO$trait2==i,c(1:5,11)]
  colnames(t1) = gsub(".trait1", "",colnames(t1))
  colnames(t2) = gsub(".trait2", "",colnames(t2))
  PLACO_cur = rbind(t1,t2)
  beta = log(PLACO_cur$or)
  
  # 把beta全都转为正方向
  # 等位基因位置交换
  a1 = PLACO_cur$a1[beta<0]
  PLACO_cur$a1[beta<0] = PLACO_cur$a2[beta<0]
  PLACO_cur$a2[beta<0] = a1
  PLACO_cur = unique(PLACO_cur[,1:5])
  
  # SNP id重复
  dup_SNP = which(duplicated(PLACO_cur$snpid))
  if(length(dup_SNP)>0){
    # 链转换
    PLACO_cur_dup = PLACO_cur[dup_SNP,]
    A_1 = PLACO_cur_dup$a1=="A"
    C_1 = PLACO_cur_dup$a1=="C"
    G_1 = PLACO_cur_dup$a1=="G"
    T_1 = PLACO_cur_dup$a1=="T"
    A_2 = PLACO_cur_dup$a2=="A"
    C_2 = PLACO_cur_dup$a2=="C"
    G_2 = PLACO_cur_dup$a2=="G"
    T_2 = PLACO_cur_dup$a2=="T"
    
    PLACO_cur_dup$a1[A_1] = "T"
    PLACO_cur_dup$a1[C_1] = "G"
    PLACO_cur_dup$a1[G_1] = "C"
    PLACO_cur_dup$a1[T_1] = "A"
    
    PLACO_cur_dup$a2[A_2] = "T"
    PLACO_cur_dup$a2[C_2] = "G"
    PLACO_cur_dup$a2[G_2] = "C"
    PLACO_cur_dup$a2[T_2] = "A"
    
    PLACO_cur[dup_SNP,] = PLACO_cur_dup
    PLACO_cur = unique(PLACO_cur)
    
    dup_SNP = which(duplicated(PLACO_cur$snpid))
    if(length(dup_SNP)>0){
      some_wrong = c(some_wrong, i)
    }
  }
  write_tsv(PLACO_cur, paste0("/home/yanyq/share_genetics/result/PLACO/check_beta/positive_beta_", i))
}

setwd("/home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/")
library(vroom)
library(readr)
library(dplyr)
{
  raw = as.data.frame(vroom::vroom("/home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/icogs_onco_gwas_meta_overall_breast_cancer_summary_level_statistics.txt"))
  raw = raw[,c("chr.iCOGs","Position.iCOGs","Effect.Meta","Baseline.Meta","Beta.meta")]
  
  colnames(raw) = c("hg19chr", "bp", "a1", "a2","beta")
  raw$flag = paste0(raw$hg19chr, ":",raw$bp)
  PLACO = as.data.frame(read_tsv(paste0("/home/yanyq/share_genetics/result/PLACO/check_beta/positive_beta_BRCA")))
  PLACO$flag = paste0(PLACO$hg19chr, ":", PLACO$bp)
  
  raw = raw[raw$flag%in%PLACO$flag,]
  raw = raw[raw$a1%in%c("A","C","G","T")&raw$a2%in%c("A","C","G","T"),]
  raw = beta_pos(raw)
  which(duplicated(paste0(raw$flag,":",raw$a1,":",raw$a2)))
  which(!PLACO$flag%in%raw$flag)
  
  raw = left_join(raw,PLACO[,4:6], by = "flag")
  raw = raw[which(raw$a1.x!=raw$a1.y|raw$a2.x!=raw$a2.y),] # 找到等位基因不对应的
  raw = raw[!((paste(raw$a1.x,raw$a2.x, sep = "/")%in%c("A/T","T/A")&paste(raw$a1.y,raw$a2.y, sep = "/")%in%c("A/T","T/A"))|(paste(raw$a1.x,raw$a2.x, sep = "/")%in%c("C/G","G/C")&paste(raw$a1.y,raw$a2.y, sep = "/")%in%c("C/G","G/C"))),]# 去掉回文
  nrow(raw)
}
{
  raw = as.data.frame(vroom::vroom("/home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/lung"))
  raw = raw[,c("chromosome","base_pair_location","effect_allele","other_allele","beta")]
  
  colnames(raw) = c("hg19chr", "bp", "a1", "a2","beta")
  raw$flag = paste0(raw$hg19chr, ":",raw$bp)
  PLACO = as.data.frame(read_tsv(paste0("/home/yanyq/share_genetics/result/PLACO/check_beta/positive_beta_lung")))
  PLACO$flag = paste0(PLACO$hg19chr, ":", PLACO$bp)
  
  raw = raw[raw$flag%in%PLACO$flag,]
  raw = raw[raw$a1%in%c("A","C","G","T")&raw$a2%in%c("A","C","G","T"),]
  raw = beta_pos(raw)
  which(duplicated(paste0(raw$flag,":",raw$a1,":",raw$a2)))
  which(!PLACO$flag%in%raw$flag)
  
  raw = left_join(raw,PLACO[,4:6], by = "flag")
  raw = raw[which(raw$a1.x!=raw$a1.y|raw$a2.x!=raw$a2.y),] # 找到等位基因不对应的
  nrow(raw)
  raw = raw[!((paste(raw$a1.x,raw$a2.x, sep = "/")%in%c("A/T","T/A")&paste(raw$a1.y,raw$a2.y, sep = "/")%in%c("A/T","T/A"))|(paste(raw$a1.x,raw$a2.x, sep = "/")%in%c("C/G","G/C")&paste(raw$a1.y,raw$a2.y, sep = "/")%in%c("C/G","G/C"))),]# 去掉回文
  nrow(raw)
}
{
  raw = as.data.frame(vroom::vroom("/home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/OV.gz"))
  raw = raw[,c("Chromosome","Position","Effect","Baseline","overall_OR")]
  
  colnames(raw) = c("hg19chr", "bp", "a1", "a2","beta")
  raw$flag = paste0(raw$hg19chr, ":",raw$bp)
  PLACO = as.data.frame(read_tsv(paste0("/home/yanyq/share_genetics/result/PLACO/check_beta/positive_beta_OV")))
  PLACO$flag = paste0(PLACO$hg19chr, ":", PLACO$bp)
  
  raw = raw[raw$flag%in%PLACO$flag,]
  raw = raw[raw$a1%in%c("A","C","G","T")&raw$a2%in%c("A","C","G","T"),]
  raw = beta_pos(raw)
  which(duplicated(paste0(raw$flag,":",raw$a1,":",raw$a2)))
  which(!PLACO$flag%in%raw$flag)
  
  raw = left_join(raw,PLACO[,4:6], by = "flag")
  raw = raw[which(raw$a1.x!=raw$a1.y|raw$a2.x!=raw$a2.y),] # 找到等位基因不对应的
  nrow(raw)
  raw = raw[!((paste(raw$a1.x,raw$a2.x, sep = "/")%in%c("A/T","T/A")&paste(raw$a1.y,raw$a2.y, sep = "/")%in%c("A/T","T/A"))|(paste(raw$a1.x,raw$a2.x, sep = "/")%in%c("C/G","G/C")&paste(raw$a1.y,raw$a2.y, sep = "/")%in%c("C/G","G/C"))),]# 去掉回文
  nrow(raw)
}
{
  raw = as.data.frame(vroom::vroom("/home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/PRAD"))
  raw = raw[,c("chromosome","base_pair_location","effect_allele","other_allele","beta")]
  PLACO = as.data.frame(read_tsv(paste0("/home/yanyq/share_genetics/result/PLACO/check_beta/positive_beta_PRAD")))
  
  colnames(raw) = c("hg19chr", "bp", "a1", "a2","beta")
  raw$flag = paste0(raw$hg19chr, ":",raw$bp)
  PLACO$flag = paste0(PLACO$hg19chr, ":", PLACO$bp)
  
  raw = raw[raw$flag%in%PLACO$flag,]
  raw = raw[raw$a1%in%c("A","C","G","T")&raw$a2%in%c("A","C","G","T"),]
  raw = beta_pos(raw)
  which(duplicated(paste0(raw$flag,":",raw$a1,":",raw$a2)))
  which(!PLACO$flag%in%raw$flag)
  
  raw = left_join(raw,PLACO[,4:6], by = "flag")
  raw = raw[which(raw$a1.x!=raw$a1.y|raw$a2.x!=raw$a2.y),] # 找到等位基因不对应的
  nrow(raw)
  raw = raw[!((paste(raw$a1.x,raw$a2.x, sep = "/")%in%c("A/T","T/A")&paste(raw$a1.y,raw$a2.y, sep = "/")%in%c("A/T","T/A"))|(paste(raw$a1.x,raw$a2.x, sep = "/")%in%c("C/G","G/C")&paste(raw$a1.y,raw$a2.y, sep = "/")%in%c("C/G","G/C"))),]# 去掉回文
  nrow(raw)
  raw = raw[!((raw$a1.x==raw$a1.y&raw$a2.x!=raw$a2.y)|(raw$a1.x==raw$a2.y&raw$a2.x!=raw$a1.y)|(raw$a2.x==raw$a1.y&raw$a1.x!=raw$a2.y)|(raw$a2.x==raw$a2.y&raw$a1.x!=raw$a1.y)),]
  nrow(raw)
}
{
  raw = as.data.frame(vroom::vroom("/home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/UCEC.tsv.gz"))
  raw = raw[,c("chromosome","base_pair_location","effect_allele","other_allele","beta")]
  PLACO = as.data.frame(read_tsv(paste0("/home/yanyq/share_genetics/result/PLACO/check_beta/positive_beta_UCEC")))
  
  colnames(raw) = c("hg19chr", "bp", "a1", "a2","beta")
  raw$flag = paste0(raw$hg19chr, ":",raw$bp)
  PLACO$flag = paste0(PLACO$hg19chr, ":", PLACO$bp)
  
  raw = raw[raw$flag%in%PLACO$flag,]
  raw = raw[raw$a1%in%c("A","C","G","T")&raw$a2%in%c("A","C","G","T"),]
  raw = beta_pos(raw)
  which(duplicated(paste0(raw$flag,":",raw$a1,":",raw$a2)))
  which(!PLACO$flag%in%raw$flag)
  
  raw = left_join(raw,PLACO[,4:6], by = "flag")
  raw = raw[which(raw$a1.x!=raw$a1.y|raw$a2.x!=raw$a2.y),] # 找到等位基因不对应的
  nrow(raw)
  raw = raw[!((paste(raw$a1.x,raw$a2.x, sep = "/")%in%c("A/T","T/A")&paste(raw$a1.y,raw$a2.y, sep = "/")%in%c("A/T","T/A"))|(paste(raw$a1.x,raw$a2.x, sep = "/")%in%c("C/G","G/C")&paste(raw$a1.y,raw$a2.y, sep = "/")%in%c("C/G","G/C"))),]# 去掉回文
  nrow(raw)
  raw = raw[!((raw$a1.x==raw$a1.y&raw$a2.x!=raw$a2.y)|(raw$a1.x==raw$a2.y&raw$a2.x!=raw$a1.y)|(raw$a2.x==raw$a1.y&raw$a1.x!=raw$a2.y)|(raw$a2.x==raw$a2.y&raw$a1.x!=raw$a1.y)),]
  nrow(raw)
}
{
  raw = as.data.frame(vroom::vroom("/home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/CRC.tsv.gz"))
  raw = raw[,c("chromosome","base_pair_location","effect_allele","other_allele","beta")]
  PLACO = as.data.frame(read_tsv(paste0("/home/yanyq/share_genetics/result/PLACO/check_beta/positive_beta_CRC")))
  
  colnames(raw) = c("hg19chr", "bp", "a1", "a2","beta")
  raw$flag = paste0(raw$hg19chr, ":",raw$bp)
  PLACO$flag = paste0(PLACO$hg19chr, ":", PLACO$bp)
  
  raw = raw[raw$flag%in%PLACO$flag,]
  raw = raw[raw$a1%in%c("A","C","G","T")&raw$a2%in%c("A","C","G","T"),]
  raw = beta_pos(raw)
  which(duplicated(paste0(raw$flag,":",raw$a1,":",raw$a2)))
  which(!PLACO$flag%in%raw$flag)
  
  raw = left_join(raw,PLACO[,4:6], by = "flag")
  raw = raw[which(raw$a1.x!=raw$a1.y|raw$a2.x!=raw$a2.y),] # 找到等位基因不对应的
  nrow(raw)
  raw = raw[!((paste(raw$a1.x,raw$a2.x, sep = "/")%in%c("A/T","T/A")&paste(raw$a1.y,raw$a2.y, sep = "/")%in%c("A/T","T/A"))|(paste(raw$a1.x,raw$a2.x, sep = "/")%in%c("C/G","G/C")&paste(raw$a1.y,raw$a2.y, sep = "/")%in%c("C/G","G/C"))),]# 去掉回文
  nrow(raw)
  raw = raw[!((raw$a1.x==raw$a1.y&raw$a2.x!=raw$a2.y)|(raw$a1.x==raw$a2.y&raw$a2.x!=raw$a1.y)|(raw$a2.x==raw$a1.y&raw$a1.x!=raw$a2.y)|(raw$a2.x==raw$a2.y&raw$a1.x!=raw$a1.y)),]
  nrow(raw)
}
{
  raw = as.data.frame(vroom::vroom("/home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/ESCA.gz"))
  raw = raw[,c("chromosome","base_pair_location","effect_allele","other_allele","beta")]
  PLACO = as.data.frame(read_tsv(paste0("/home/yanyq/share_genetics/result/PLACO/check_beta/positive_beta_ESCA")))
  
  colnames(raw) = c("hg19chr", "bp", "a1", "a2","beta")
  raw$flag = paste0(raw$hg19chr, ":",raw$bp)
  PLACO$flag = paste0(PLACO$hg19chr, ":", PLACO$bp)
  
  raw = raw[raw$flag%in%PLACO$flag,]
  raw = raw[raw$a1%in%c("A","C","G","T")&raw$a2%in%c("A","C","G","T"),]
  raw = beta_pos(raw)
  which(duplicated(paste0(raw$flag,":",raw$a1,":",raw$a2)))
  which(!PLACO$flag%in%raw$flag)
  
  raw = left_join(raw,PLACO[,4:6], by = "flag")
  raw = raw[which(raw$a1.x!=raw$a1.y|raw$a2.x!=raw$a2.y),] # 找到等位基因不对应的
  nrow(raw)
  raw = raw[!((paste(raw$a1.x,raw$a2.x, sep = "/")%in%c("A/T","T/A")&paste(raw$a1.y,raw$a2.y, sep = "/")%in%c("A/T","T/A"))|(paste(raw$a1.x,raw$a2.x, sep = "/")%in%c("C/G","G/C")&paste(raw$a1.y,raw$a2.y, sep = "/")%in%c("C/G","G/C"))),]# 去掉回文
  nrow(raw)
  raw = raw[!((raw$a1.x==raw$a1.y&raw$a2.x!=raw$a2.y)|(raw$a1.x==raw$a2.y&raw$a2.x!=raw$a1.y)|(raw$a2.x==raw$a1.y&raw$a1.x!=raw$a2.y)|(raw$a2.x==raw$a2.y&raw$a1.x!=raw$a1.y)),]
  nrow(raw)
}
{
  raw = as.data.frame(vroom::vroom("/home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/CESC.tsv.gz"))
  raw$beta = log(raw$odds_ratio)
  raw = raw[,c("chromosome","base_pair_location","effect_allele","other_allele","beta")]
  PLACO = as.data.frame(read_tsv(paste0("/home/yanyq/share_genetics/result/PLACO/check_beta/positive_beta_CESC")))
  
  colnames(raw) = c("hg19chr", "bp", "a1", "a2","beta")
  raw$flag = paste0(raw$hg19chr, ":",raw$bp)
  PLACO$flag = paste0(PLACO$hg19chr, ":", PLACO$bp)
  
  raw = raw[raw$flag%in%PLACO$flag,]
  raw = raw[raw$a1%in%c("A","C","G","T")&raw$a2%in%c("A","C","G","T"),]
  raw = beta_pos(raw)
  which(duplicated(paste0(raw$flag,":",raw$a1,":",raw$a2)))
  which(!PLACO$flag%in%raw$flag)
  
  raw = left_join(raw,PLACO[,4:6], by = "flag")
  raw = raw[which(raw$a1.x!=raw$a1.y|raw$a2.x!=raw$a2.y),] # 找到等位基因不对应的
  nrow(raw)
  raw = raw[!((paste(raw$a1.x,raw$a2.x, sep = "/")%in%c("A/T","T/A")&paste(raw$a1.y,raw$a2.y, sep = "/")%in%c("A/T","T/A"))|(paste(raw$a1.x,raw$a2.x, sep = "/")%in%c("C/G","G/C")&paste(raw$a1.y,raw$a2.y, sep = "/")%in%c("C/G","G/C"))),]# 去掉回文
  nrow(raw)
  raw = raw[!((raw$a1.x==raw$a1.y&raw$a2.x!=raw$a2.y)|(raw$a1.x==raw$a2.y&raw$a2.x!=raw$a1.y)|(raw$a2.x==raw$a1.y&raw$a1.x!=raw$a2.y)|(raw$a2.x==raw$a2.y&raw$a1.x!=raw$a1.y)),]
  nrow(raw)
}
{
  raw = as.data.frame(vroom::vroom("/home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/HL.gz"))
  raw = raw[,c("chromosome","base_pair_location","effect_allele","other_allele","beta")]
  PLACO = as.data.frame(read_tsv(paste0("/home/yanyq/share_genetics/result/PLACO/check_beta/positive_beta_HL")))
  
  colnames(raw) = c("hg19chr", "bp", "a1", "a2","beta")
  raw$flag = paste0(raw$hg19chr, ":",raw$bp)
  PLACO$flag = paste0(PLACO$hg19chr, ":", PLACO$bp)
  
  raw = raw[raw$flag%in%PLACO$flag,]
  raw = raw[raw$a1%in%c("A","C","G","T")&raw$a2%in%c("A","C","G","T"),]
  raw = beta_pos(raw)
  which(duplicated(paste0(raw$flag,":",raw$a1,":",raw$a2)))
  which(!PLACO$flag%in%raw$flag)
  
  raw = left_join(raw,PLACO[,4:6], by = "flag")
  raw = raw[which(raw$a1.x!=raw$a1.y|raw$a2.x!=raw$a2.y),] # 找到等位基因不对应的
  nrow(raw)
  raw = raw[!((paste(raw$a1.x,raw$a2.x, sep = "/")%in%c("A/T","T/A")&paste(raw$a1.y,raw$a2.y, sep = "/")%in%c("A/T","T/A"))|(paste(raw$a1.x,raw$a2.x, sep = "/")%in%c("C/G","G/C")&paste(raw$a1.y,raw$a2.y, sep = "/")%in%c("C/G","G/C"))),]# 去掉回文
  nrow(raw)
  raw = raw[!((raw$a1.x==raw$a1.y&raw$a2.x!=raw$a2.y)|(raw$a1.x==raw$a2.y&raw$a2.x!=raw$a1.y)|(raw$a2.x==raw$a1.y&raw$a1.x!=raw$a2.y)|(raw$a2.x==raw$a2.y&raw$a1.x!=raw$a1.y)),]
  nrow(raw)
}
{
  raw = as.data.frame(vroom::vroom("/home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/LL.gz"))
  raw$beta = log(raw$odds_ratio)
  raw = raw[,c("chromosome","base_pair_location","effect_allele","other_allele","beta")]
  PLACO = as.data.frame(read_tsv(paste0("/home/yanyq/share_genetics/result/PLACO/check_beta/positive_beta_LL")))
  
  colnames(raw) = c("hg19chr", "bp", "a1", "a2","beta")
  raw$flag = paste0(raw$hg19chr, ":",raw$bp)
  PLACO$flag = paste0(PLACO$hg19chr, ":", PLACO$bp)
  
  raw = raw[raw$flag%in%PLACO$flag,]
  raw = raw[raw$a1%in%c("A","C","G","T")&raw$a2%in%c("A","C","G","T"),]
  raw = beta_pos(raw)
  which(duplicated(paste0(raw$flag,":",raw$a1,":",raw$a2)))
  which(!PLACO$flag%in%raw$flag)
  
  raw = left_join(raw,PLACO[,4:6], by = "flag")
  raw = raw[which(raw$a1.x!=raw$a1.y|raw$a2.x!=raw$a2.y),] # 找到等位基因不对应的
  nrow(raw)
  raw = raw[!((paste(raw$a1.x,raw$a2.x, sep = "/")%in%c("A/T","T/A")&paste(raw$a1.y,raw$a2.y, sep = "/")%in%c("A/T","T/A"))|(paste(raw$a1.x,raw$a2.x, sep = "/")%in%c("C/G","G/C")&paste(raw$a1.y,raw$a2.y, sep = "/")%in%c("C/G","G/C"))),]# 去掉回文
  nrow(raw)
  raw = raw[!((raw$a1.x==raw$a1.y&raw$a2.x!=raw$a2.y)|(raw$a1.x==raw$a2.y&raw$a2.x!=raw$a1.y)|(raw$a2.x==raw$a1.y&raw$a1.x!=raw$a2.y)|(raw$a2.x==raw$a2.y&raw$a1.x!=raw$a1.y)),]
  nrow(raw)
}
record = as.data.frame(matrix(ncol = 5, nrow = 28))
j = 1
for(i in c("BLCA","HNSC","kidney","PAAD","SKCM","DLBC","BGC", "STAD", "THCA",
           "AML","BAC","CML","CORP","EYAD","GSS","BGA","LIHC","MCL","MZBL",
           "BM","MESO","MM","MS","SI","TEST","VULVA","BCC","SCC")){
  
  raw = as.data.frame(vroom::vroom(paste0("/home/yanyq/share_genetics/data/GWAS/processed/",i,".gz")))
  raw$beta = log(raw$or)
  raw = raw[,c("hg19chr", "bp", "a1", "a2","beta")]
  PLACO = as.data.frame(read_tsv(paste0("/home/yanyq/share_genetics/result/PLACO/check_beta/positive_beta_",i)))
  
  colnames(raw) = c("hg19chr", "bp", "a1", "a2","beta")
  raw$flag = paste0(raw$hg19chr, ":",raw$bp)
  PLACO$flag = paste0(PLACO$hg19chr, ":", PLACO$bp)
  
  raw = raw[raw$flag%in%PLACO$flag,]
  raw = raw[raw$a1%in%c("A","C","G","T")&raw$a2%in%c("A","C","G","T"),]
  raw = beta_pos(raw)
  if(length(which(duplicated(paste0(raw$flag,":",raw$a1,":",raw$a2))))>0){
    record[j,1] = 1
  }
  if(length(which(!PLACO$flag%in%raw$flag))>0){
    record[j,2] = 1
  }
  
  raw = left_join(raw,PLACO[,4:6], by = "flag")
  raw = raw[which(raw$a1.x!=raw$a1.y|raw$a2.x!=raw$a2.y),] # 找到等位基因不对应的
  record[j,3] = nrow(raw)
  raw = raw[!((paste(raw$a1.x,raw$a2.x, sep = "/")%in%c("A/T","T/A")&paste(raw$a1.y,raw$a2.y, sep = "/")%in%c("A/T","T/A"))|(paste(raw$a1.x,raw$a2.x, sep = "/")%in%c("C/G","G/C")&paste(raw$a1.y,raw$a2.y, sep = "/")%in%c("C/G","G/C"))),]# 去掉回文
  record[j,4] = nrow(raw)
  raw = raw[!((raw$a1.x==raw$a1.y&raw$a2.x!=raw$a2.y)|(raw$a1.x==raw$a2.y&raw$a2.x!=raw$a1.y)|(raw$a2.x==raw$a1.y&raw$a1.x!=raw$a2.y)|(raw$a2.x==raw$a2.y&raw$a1.x!=raw$a1.y)),]
  record[j,5] = nrow(raw)
  j = j+1
}


library(vroom)
library(readr)
library(dplyr)

# 定义一个将beta值全转为正的函数
beta_pos = function(PLACO_cur){
  beta = PLACO_cur$beta
  # 把beta全都转为正方向
  # 等位基因位置交换
  a1 = PLACO_cur$a1[beta<0]
  PLACO_cur$a1[beta<0] = PLACO_cur$a2[beta<0]
  PLACO_cur$a2[beta<0] = a1
  PLACO_cur = unique(PLACO_cur[,c(1:4,6)])
  
  # SNP id重复
  dup_SNP = which(duplicated(paste0(PLACO_cur$flag,":",PLACO_cur$a1,":",PLACO_cur$a2)))
  if(length(dup_SNP)>0){
    print("first dup")
    # 链转换
    PLACO_cur_dup = PLACO_cur[dup_SNP,]
    A_1 = PLACO_cur_dup$a1=="A"
    C_1 = PLACO_cur_dup$a1=="C"
    G_1 = PLACO_cur_dup$a1=="G"
    T_1 = PLACO_cur_dup$a1=="T"
    A_2 = PLACO_cur_dup$a2=="A"
    C_2 = PLACO_cur_dup$a2=="C"
    G_2 = PLACO_cur_dup$a2=="G"
    T_2 = PLACO_cur_dup$a2=="T"
    
    PLACO_cur_dup$a1[A_1] = "T"
    PLACO_cur_dup$a1[C_1] = "G"
    PLACO_cur_dup$a1[G_1] = "C"
    PLACO_cur_dup$a1[T_1] = "A"
    
    PLACO_cur_dup$a2[A_2] = "T"
    PLACO_cur_dup$a2[C_2] = "G"
    PLACO_cur_dup$a2[G_2] = "C"
    PLACO_cur_dup$a2[T_2] = "A"
    
    PLACO_cur[dup_SNP,] = PLACO_cur_dup
    PLACO_cur = unique(PLACO_cur)
    
    dup_SNP = which(duplicated(paste0(PLACO_cur$flag,":",PLACO_cur$a1,":",PLACO_cur$a2)))
    if(length(dup_SNP)>0){
      print("second wrong")
    }
  }
  return(PLACO_cur)
}