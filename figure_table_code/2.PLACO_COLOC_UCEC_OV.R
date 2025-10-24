library(data.table)
library(readr)
library(GPA)
library(gpaExample)
data(exampleData) # 各GWASp值和注释数据
fit.GPA.noOVn = GPA( exampleData$pval[ , c(3,5) ]) # 无注释数据拟合，一次分析一对GWAS
estimates( fit.GPA.wOVn ) # 参数估计
# 基于拟合的GPA模型，我们使用命令实现关联映射
assoc.GPA.wOVn <- assoc( fit.GPA.wOVn, FDR=0.20, fdrControl="global" )
fdr.GPA.wOVn <- fdr(fit.GPA.wOVn) # 输出与每一个表型不相关的SNP
# 多效性假设检验
fit.GPA.pleiotropy.H0 <- GPA( exampleData$pval[ , c(3,5) ], NULL, pleiotropyH0=TRUE )

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

# FUMA注释多效基因座
# UCEC_IBD N=188335
# UCEC N=121885
# IBD N=66450
setwd("~/share_genetics/result/FUMA")
# PLACO_sig = fread("~/share_genetics/result/PLACO/sig_OV_UCEC")
FUMA_UCEC_OV = fread("/home/yanyq/share_genetics/result/FUMA/UCEC_OV/GenomicRiskLoci.txt")
FUMA_UCEC_OV$locus = paste0(FUMA_UCEC_OV$chr,":",FUMA_UCEC_OV$start,"-",FUMA_UCEC_OV$end)
FUMA_UCEC = fread("/home/yanyq/share_genetics/result/FUMA/UCEC/GenomicRiskLoci.txt")
FUMA_UCEC$locus = paste0(FUMA_UCEC$chr,":",FUMA_UCEC$start,"-",FUMA_UCEC$end)
FUMA_OV = fread("/home/yanyq/share_genetics/result/FUMA/OV/GenomicRiskLoci.txt")
FUMA_OV$locus = paste0(FUMA_OV$chr,":",FUMA_OV$start,"-",FUMA_OV$end)
FUMA_UCEC_OV$exist_UCEC = ifelse(FUMA_UCEC_OV$locus%in%FUMA_UCEC$locus,1,0) # PLACO注释的基因座，UCEC中同样注释到了
FUMA_UCEC_OV$exist_OV = ifelse(FUMA_UCEC_OV$locus%in%FUMA_OV$locus,1,0)
FUMA_UCEC_OV_anno = fread("/home/yanyq/share_genetics/result/FUMA/UCEC_OV/snps.txt")
FUMA_UCEC_OV = dplyr::left_join(FUMA_UCEC_OV,FUMA_UCEC_OV_anno[,c(1,7:10,12:21)],by = "uniqID")
write_tsv(FUMA_UCEC_OV,"~/share_genetics/result/FUMA/merge/UCEC_OV")

# 共定位分析
setwd("~/share_genetics/data/GWAS/processed")
library(coloc)
result = list()
best_result = list() # SNP.PP.H4最佳的
FUMA_UCEC_OV = fread("~/share_genetics/result/FUMA/merge/UCEC_OV")
{
  overlap = fread(paste0("overlap_OV_",i))
  to_coloc = list()
  if(i=="UCEC"){
    for(j in 1:nrow(FUMA_UCEC_OV)){
      to_coloc[[j]] = overlap[overlap$hg19chr.OV==FUMA_UCEC_OV$chr[j]&overlap$bp.OV>=FUMA_UCEC_OV$start[j]&overlap$bp.OV<=FUMA_UCEC_OV$end[j],]
    }
    N_UCEC = 121885
    N_OV = 66450
  }
 
  for(j in 1:length(to_coloc)){
    to_coloc[[j]] = as.matrix(to_coloc[[j]])
    result[[paste0(i,"_",j)]] = coloc.abf(dataset1=list(pvalues=as.numeric(to_coloc[[j]][,8]), type="cc",snp=to_coloc[[j]][,1],beta=log(as.numeric(to_coloc[[j]][,6])),varbeta=(as.numeric(to_coloc[[j]][,7]))^2,N=N_OV, MAF=as.numeric(to_coloc[[j]][,9])),
                                          dataset2=list(pvalues=as.numeric(to_coloc[[j]][,17]), type="cc",snp=to_coloc[[j]][,1],beta=log(as.numeric(to_coloc[[j]][,15])),varbeta=(as.numeric(to_coloc[[j]][,16]))^2,N=N_UCEC,MAF=as.numeric(to_coloc[[j]][,19])))
    tmp_result = result[[paste0(i,"_",j)]]$result
    best_result[[paste0(i,"_",j)]] = tmp_result[which.max(tmp_result$`SNP.PP.H4`),]
    result[[paste0(i,"_",j)]] = result[[paste0(i,"_",j)]]$summary
  }
  
}

best_result = do.call(rbind,best_result)
result = do.call(rbind,result)
result = as.data.frame(result)
result$locus = FUMA_UCEC_OV$locus
result$no.locus = FUMA_UCEC_OV$GenomicLocus
write_tsv(cbind(result,best_result),"~/share_genetics/result/coloc/UCEC_OV")
