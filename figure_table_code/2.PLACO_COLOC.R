library(data.table)
library(readr)
library(GPA)
library(gpaExample)
data(exampleData) # 各GWASp值和注释数据
fit.GPA.noAnn = GPA( exampleData$pval[ , c(3,5) ]) # 无注释数据拟合，一次分析一对GWAS
estimates( fit.GPA.wAnn ) # 参数估计
# 基于拟合的GPA模型，我们使用命令实现关联映射
assoc.GPA.wAnn <- assoc( fit.GPA.wAnn, FDR=0.20, fdrControl="global" )
fdr.GPA.wAnn <- fdr(fit.GPA.wAnn) # 输出与每一个表型不相关的SNP
# 多效性假设检验
fit.GPA.pleiotropy.H0 <- GPA( exampleData$pval[ , c(3,5) ], NULL, pleiotropyH0=TRUE )

#########################
# PLACO，寻找多效SNP
#########################
source("~/software/R_pac/PLACO/PLACO_v0.1.1.R")
setwd("~/share_genetics/data/GWAS/processed")
# merge AND harmonise
AN = fread("AN")
AN$zscore = log(AN$or)/AN$se
for(i in c("GORD","IBD","IBS","PUD")){
  changbing = fread(i)
  changbing$zscore = log(changbing$or)/changbing$se
  merged = merge(AN,changbing,by = "snpid",suffixes = c(".AN",paste0(".",i)))
  merged = as.data.frame(merged)
  merged = merged[merged$a1.AN%in%c("A","C","G","T")&merged$a2.AN%in%c("A","C","G","T")&merged[,paste0("a1.",i)]%in%c("A","C","G","T")&merged[,paste0("a2.",i)]%in%c("A","C","G","T"),]
  harmonised = merged[merged$a1.AN==merged[,paste0("a1.",i)]&merged$a2.AN==merged[,paste0("a2.",i)],]
  if(nrow(merged)!=nrow(harmonised)){
    unharmonised = merged[merged$a1.AN!=merged[,paste0("a1.",i)]|merged$a2.AN!=merged[,paste0("a2.",i)],]
    tmp = unharmonised$a1.AN
    unharmonised$a1.AN = unharmonised$a2.AN
    unharmonised$a2.AN = tmp
    unharmonised$zscore.AN = -unharmonised$zscore.AN
    harmonised = rbind(harmonised,unharmonised[unharmonised$a1.AN==unharmonised[,paste0("a1.",i)]&unharmonised$a2.AN==unharmonised[,paste0("a2.",i)],])
  }
  if(nrow(merged)!=nrow(harmonised)){
    unharmonised = merged[!(merged$snpid%in%harmonised$snpid),]
    A1_loc = which(unharmonised$a1.AN=="A")
    T1_loc = which(unharmonised$a1.AN=="T")
    C1_loc = which(unharmonised$a1.AN=="C")
    G1_loc = which(unharmonised$a1.AN=="G")
    A2_loc = which(unharmonised$a2.AN=="A")
    T2_loc = which(unharmonised$a2.AN=="T")
    C2_loc = which(unharmonised$a2.AN=="C")
    G2_loc = which(unharmonised$a2.AN=="G")
    table(unharmonised$a1.AN)
    table(unharmonised$a2.AN)
    unharmonised$a1.AN[A1_loc] = "T"
    unharmonised$a1.AN[T1_loc] = "A"
    unharmonised$a1.AN[C1_loc] = "G"
    unharmonised$a1.AN[G1_loc] = "C"
    unharmonised$a2.AN[A2_loc] = "T"
    unharmonised$a2.AN[T2_loc] = "A"
    unharmonised$a2.AN[C2_loc] = "G"
    unharmonised$a2.AN[G2_loc] = "C"
    table(unharmonised$a1.AN)
    table(unharmonised$a2.AN)
    harmonised = rbind(harmonised,unharmonised[unharmonised$a1.AN==unharmonised[,paste0("a1.",i)]&unharmonised$a2.AN==unharmonised[,paste0("a2.",i)],])
  }
  if(nrow(merged)!=nrow(harmonised)){
    unharmonised = unharmonised[!(unharmonised$snpid%in%harmonised$snpid),]
    tmp = unharmonised$a1.AN
    unharmonised$a1.AN = unharmonised$a2.AN
    unharmonised$a2.AN = tmp
    unharmonised$zscore.AN = -unharmonised$zscore.AN
    harmonised = rbind(harmonised,unharmonised[unharmonised$a1.AN==unharmonised[,paste0("a1.",i)]&unharmonised$a2.AN==unharmonised[,paste0("a2.",i)],])
  }
  if(nrow(merged)!=nrow(harmonised)){
    print(paste0("exsit unharmonise: ",i))
  }
  write_tsv(harmonised,paste0("overlap_AN_",i))
}

for(i in c("GORD","IBD","IBS","PUD")){
  overlap = as.data.frame(fread(paste0("overlap_AN_",i)))
  overlap = overlap[((overlap$zscore.AN)^2<=80)&((overlap[,paste0("zscore.",i)])^2<=80),] # 由于极大的效应大小可能产生杂散信号，Z得分平方高于80的SNP被去除
  # 去相关Z评分，以解释潜在的样本重叠
  Z.matrix = as.matrix(overlap[,c("zscore.AN",paste0("zscore.",i))])
  P.matrix = as.matrix(overlap[,c("pval.AN",paste0("pval.",i))])
  R = cor.pearson(Z.matrix, P.matrix, p.threshold=1e-4)
  "%^%" <- function(x, pow)
    with(eigen(x), vectors %*% (values^pow * t(vectors)))
  Z.matrix.decor <- Z.matrix %*% (R %^% (-0.5))
  # PLACO
  VarZ = var.placo(Z.matrix.decor, P.matrix, p.threshold=1e-4)
  out <- sapply(1:nrow(Z.matrix.decor), function(i) placo(Z=Z.matrix.decor[i,], VarZ=VarZ))
  write_rds(out,paste0("/home/yanyq/share_genetics/result/PLACO/AN_",i,".rds"))
}

setwd("~/share_genetics/data/GWAS/processed")
for(i in c("GORD","IBD","IBS","PUD")){
  out = readRDS(paste0("/home/yanyq/share_genetics/result/PLACO/AN_",i,".rds"))
  out = t(as.data.frame(out))
  out = as.data.frame(out)
  colnames(out) = c("T.placo","p.placo")
  overlap = as.data.frame(fread(paste0("~/share_genetics/data/GWAS/processed/overlap_AN_",i)))
  overlap = overlap[((overlap$zscore.AN)^2<=80)&((overlap[,paste0("zscore.",i)])^2<=80),]
  overlap = cbind(overlap,out)
  overlap$p.placo = unlist(overlap$p.placo)
  write_tsv(overlap[,c("snpid", "hg19chr.AN", "bp.AN", "a1.AN", "a2.AN", "p.placo")],paste0("~/share_genetics/result/PLACO/PLACO_AN_",i,".gz"))
  overlap = overlap[overlap$p.placo<5e-8,]
  write_tsv(overlap,paste0("~/share_genetics/result/PLACO/sig_AN_",i))
}


# 共定位分析
setwd("~/share_genetics/data/GWAS/processed")
library(coloc)
result = list()
best_result = list() # SNP.PP.H4最佳的
for(i in c("GORD","IBD","IBS","PUD")){
  overlap = fread(paste0("overlap_AN_",i))
  to_coloc = list()
  if(i =="GORD"){
    coloc_1 = (overlap$hg19chr.AN==3&overlap$bp.AN>= 49734229&overlap$bp.AN<=50209053)
    coloc_2 = (overlap$hg19chr.AN==3&overlap$bp.AN>=70795054&overlap$bp.AN<=71018894)
    coloc_3 = (overlap$hg19chr.AN==11&overlap$bp.AN>=112826867&overlap$bp.AN<=112922254)
    coloc_4 = (overlap$hg19chr.AN==12&overlap$bp.AN>=56368708&overlap$bp.AN<=56478658)
    # # coloc_1 = overlap$snpid=="rs199956414"
    # # coloc_2 = overlap$snpid=="rs13097265"
    # # coloc_3 = overlap$snpid=="rs7105462"
    # # coloc_4 = overlap$snpid=="rs1873914"
    to_coloc[[1]] = overlap[coloc_1,]
    to_coloc[[2]] = overlap[coloc_2,]
    to_coloc[[3]] = overlap[coloc_3,]
    to_coloc[[4]] = overlap[coloc_4,]
    N = 456327
  }
  if(i == "IBD"){
    coloc_1 = (overlap$hg19chr.AN==1&overlap$bp.AN>=200864267&overlap$bp.AN<=201024059)
    coloc_2 = (overlap$hg19chr.AN==3&overlap$bp.AN>=48446237&overlap$bp.AN<=50519141)
    # # coloc_1 = overlap$snpid=="rs6427868"
    # # coloc_2 = overlap$snpid=="rs11717978"
    to_coloc[[1]] = overlap[coloc_1,]
    to_coloc[[2]] = overlap[coloc_2,]
    N = 456327
  }
  if(i == "IBS"){
    coloc_1 = (overlap$hg19chr.AN==9&overlap$bp.AN>=96163260&overlap$bp.AN<=96356004)
    coloc_2 = (overlap$hg19chr.AN==11&overlap$bp.AN>=112826311&overlap$bp.AN<=113062983)
    # # coloc_1 = overlap$snpid=="rs7021689"
    # # coloc_2 = overlap$snpid=="rs55694714"
    to_coloc[[1]] = overlap[coloc_1,]
    to_coloc[[2]] = overlap[coloc_2,]
    N = 486601
  }
  if(i ==  "PUD"){
    coloc_1 = (overlap$hg19chr.AN==4&overlap$bp.AN>=147216084&overlap$bp.AN<=147337374)
    coloc_2 = (overlap$hg19chr.AN==8&overlap$bp.AN>=143752994&overlap$bp.AN<=143809193)
    # # coloc_1 = overlap$snpid=="rs9784437"
    # # coloc_2 = overlap$snpid=="rs2978977"
    to_coloc[[1]] = overlap[coloc_1,]
    to_coloc[[2]] = overlap[coloc_2,]
    N = 456327
  }
  for(j in 1:length(to_coloc)){
    to_coloc[[j]] = as.matrix(to_coloc[[j]])
    result[[paste0(i,"_",j)]] = coloc.abf(dataset1=list(pvalues=as.numeric(to_coloc[[j]][,8]), type="cc",snp=to_coloc[[j]][,1],beta=log(as.numeric(to_coloc[[j]][,6])),varbeta=(as.numeric(to_coloc[[j]][,7]))^2,N=72517),
                                          dataset2=list(pvalues=as.numeric(to_coloc[[j]][,19]), type="cc",snp=to_coloc[[j]][,1],beta=log(as.numeric(to_coloc[[j]][,17])),varbeta=(as.numeric(to_coloc[[j]][,18]))^2,N=N), MAF=as.numeric(to_coloc[[j]][,22]))
    tmp_result = result[[paste0(i,"_",j)]]$result
    best_result[[paste0(i,"_",j)]] = tmp_result[which.max(tmp_result$`SNP.PP.H4`),]
    result[[paste0(i,"_",j)]] = result[[paste0(i,"_",j)]]$summary
  }
  
}

best_result = do.call(rbind,best_result)
result = do.call(rbind,result)
