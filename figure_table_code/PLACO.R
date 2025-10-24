library(data.table)
library(readr)
library(GPA)
library(gpaExample)
data(exampleData) # 各GWASp值和注释数据
# fit.GPA.noOVn = GPA( exampleData$pval[ , c(3,5) ]) # 无注释数据拟合，一次分析一对GWAS
# estimates( fit.GPA.wOVn ) # 参数估计
# # 基于拟合的GPA模型，我们使用命令实现关联映射
# assoc.GPA.wOVn <- assoc( fit.GPA.wOVn, FDR=0.20, fdrControl="global" )
# fdr.GPA.wOVn <- fdr(fit.GPA.wOVn) # 输出与每一个表型不相关的SNP
# # 多效性假设检验
# fit.GPA.pleiotropy.H0 <- GPA( exampleData$pval[ , c(3,5) ], NULL, pleiotropyH0=TRUE )

#########################
# PLACO，寻找多效SNP
#########################
source("~/software/R_pac/PLACO/PLACO_v0.1.1.R")
setwd("~/share_genetics/data/GWAS/processed")
# merge OVD harmonise
OV = fread("OV.gz")
OV$zscore = log(OV$or)/OV$se
i = "UCEC"
{
  UCEC = fread(paste0(i,".gz"))
  UCEC$zscore = log(UCEC$or)/UCEC$se
  merged = merge(OV,UCEC,by = "snpid",suffixes = c(".OV",paste0(".",i)))
  merged = as.data.frame(merged)
  merged = merged[merged$a1.OV%in%c("A","C","G","T")&merged$a2.OV%in%c("A","C","G","T")&merged[,paste0("a1.",i)]%in%c("A","C","G","T")&merged[,paste0("a2.",i)]%in%c("A","C","G","T"),]
  harmonised = merged[merged$a1.OV==merged[,paste0("a1.",i)]&merged$a2.OV==merged[,paste0("a2.",i)],]
  if(nrow(merged)!=nrow(harmonised)){
    unharmonised = merged[merged$a1.OV!=merged[,paste0("a1.",i)]|merged$a2.OV!=merged[,paste0("a2.",i)],]
    tmp = unharmonised$a1.OV
    unharmonised$a1.OV = unharmonised$a2.OV
    unharmonised$a2.OV = tmp
    unharmonised$zscore.OV = -unharmonised$zscore.OV
    harmonised = rbind(harmonised,unharmonised[unharmonised$a1.OV==unharmonised[,paste0("a1.",i)]&unharmonised$a2.OV==unharmonised[,paste0("a2.",i)],])
  }
  if(nrow(merged)!=nrow(harmonised)){
    unharmonised = merged[!(merged$snpid%in%harmonised$snpid),]
    A1_loc = which(unharmonised$a1.OV=="A")
    T1_loc = which(unharmonised$a1.OV=="T")
    C1_loc = which(unharmonised$a1.OV=="C")
    G1_loc = which(unharmonised$a1.OV=="G")
    A2_loc = which(unharmonised$a2.OV=="A")
    T2_loc = which(unharmonised$a2.OV=="T")
    C2_loc = which(unharmonised$a2.OV=="C")
    G2_loc = which(unharmonised$a2.OV=="G")
    table(unharmonised$a1.OV)
    table(unharmonised$a2.OV)
    unharmonised$a1.OV[A1_loc] = "T"
    unharmonised$a1.OV[T1_loc] = "A"
    unharmonised$a1.OV[C1_loc] = "G"
    unharmonised$a1.OV[G1_loc] = "C"
    unharmonised$a2.OV[A2_loc] = "T"
    unharmonised$a2.OV[T2_loc] = "A"
    unharmonised$a2.OV[C2_loc] = "G"
    unharmonised$a2.OV[G2_loc] = "C"
    table(unharmonised$a1.OV)
    table(unharmonised$a2.OV)
    harmonised = rbind(harmonised,unharmonised[unharmonised$a1.OV==unharmonised[,paste0("a1.",i)]&unharmonised$a2.OV==unharmonised[,paste0("a2.",i)],])
  }
  if(nrow(merged)!=nrow(harmonised)){
    unharmonised = unharmonised[!(unharmonised$snpid%in%harmonised$snpid),]
    tmp = unharmonised$a1.OV
    unharmonised$a1.OV = unharmonised$a2.OV
    unharmonised$a2.OV = tmp
    unharmonised$zscore.OV = -unharmonised$zscore.OV
    harmonised = rbind(harmonised,unharmonised[unharmonised$a1.OV==unharmonised[,paste0("a1.",i)]&unharmonised$a2.OV==unharmonised[,paste0("a2.",i)],])
  }
  if(nrow(merged)!=nrow(harmonised)){
    print(paste0("exsit unharmonise: ",i))
  }
  write_tsv(harmonised,paste0("overlap_OV_",i))
}

{
  overlap = as.data.frame(fread(paste0("overlap_OV_",i)))
  overlap = overlap[((overlap$zscore.OV)^2<=80)&((overlap[,paste0("zscore.",i)])^2<=80),] # 由于极大的效应大小可能产生杂散信号，Z得分平方高于80的SNP被去除
  # 去相关Z评分，以解释潜在的样本重叠
  Z.matrix = as.matrix(overlap[,c("zscore.OV",paste0("zscore.",i))])
  P.matrix = as.matrix(overlap[,c("pval.OV",paste0("pval.",i))])
  R = cor.pearson(Z.matrix, P.matrix, p.threshold=1e-4)
  "%^%" <- function(x, pow)
    with(eigen(x), vectors %*% (values^pow * t(vectors)))
  Z.matrix.decor <- Z.matrix %*% (R %^% (-0.5))
  # PLACO
  VarZ = var.placo(Z.matrix.decor, P.matrix, p.threshold=1e-4)
  out <- sapply(1:nrow(Z.matrix.decor), function(i) placo(Z=Z.matrix.decor[i,], VarZ=VarZ))
  write_rds(out,paste0("/home/yanyq/share_genetics/result/PLACO/OV_",i,".rds"))
}

setwd("~/share_genetics/data/GWAS/processed")

{
  out = readRDS(paste0("/home/yanyq/share_genetics/result/PLACO/OV_",i,".rds"))
  out = t(as.data.frame(out))
  out = as.data.frame(out)
  colnames(out) = c("T.placo","p.placo")
  overlap = as.data.frame(fread(paste0("~/share_genetics/data/GWAS/processed/overlap_OV_",i)))
  overlap = overlap[((overlap$zscore.OV)^2<=80)&((overlap[,paste0("zscore.",i)])^2<=80),]
  overlap = cbind(overlap,out)
  overlap$p.placo = unlist(overlap$p.placo)
  write_tsv(overlap[,c("snpid", "hg19chr.OV", "bp.OV", "a1.OV", "a2.OV", "p.placo")],paste0("~/share_genetics/result/PLACO/PLACO_OV_",i,".gz"))
  overlap = overlap[overlap$p.placo<5e-8,]
  write_tsv(overlap,paste0("~/share_genetics/result/PLACO/sig_OV_",i))
}

