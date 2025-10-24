library(data.table)
library(readr)
library(GPA)
library(gpaExample)
source("~/software/R_pac/PLACO/PLACO_v0.1.1.R")

traits = commandArgs()
traits = traits[6:7]
print(traits[1])
print(traits[2])
setwd("~/share_genetics/data/GWAS/processed")
# merge trait1D harmonise
trait1 = fread(paste0(traits[1],".gz"))
trait1$zscore = log(trait1$or)/trait1$se
trait2 = fread(paste0(traits[2],".gz"))
trait2$zscore = log(trait2$or)/trait2$se
merged = merge(trait1,trait2,by = "snpid",suffixes = c(paste0(".",traits[1]),paste0(".",traits[2])))
merged = as.data.frame(merged)
merged = merged[merged[,paste0("a1.",traits[1])]%in%c("A","C","G","T")&merged[,paste0("a2.",traits[1])]%in%c("A","C","G","T")&merged[,paste0("a1.",traits[2])]%in%c("A","C","G","T")&merged[,paste0("a2.",traits[2])]%in%c("A","C","G","T"),] # 两个trait的两个等位基因均为A/T/G/C
num_SNP = nrow(merged)

# 回文SNP
a1 = merged[,paste0("a1.",traits[1])]
a2 = merged[,paste0("a2.",traits[1])]
palindrome = merged[paste0(a1,"/",a2)%in%c("A/T","T/A","G/C","C/G"),] # 不需要看trait2的，trait1为回文，trait2必为回文，因为这是rsid overlap后的
merged = merged[!paste0(a1,"/",a2)%in%c("A/T","T/A","G/C","C/G"),]

if((nrow(palindrome)+nrow(merged))==num_SNP){
  # 非回文SNP
  {
    harmonised = merged[merged[,paste0("a1.",traits[1])]==merged[,paste0("a1.",traits[2])]&merged[,paste0("a2.",traits[1])]==merged[,paste0("a2.",traits[2])],] # trait1和trait2的a1和a2对应
    if(nrow(merged)!=nrow(harmonised)){
      unharmonised = merged[(merged[,paste0("a1.",traits[1])]!=merged[,paste0("a1.",traits[2])])|(merged[,paste0("a2.",traits[1])]!=merged[,paste0("a2.",traits[2])]),]
      tmp = unharmonised[,paste0("a1.",traits[1])]
      unharmonised[,paste0("a1.",traits[1])] = unharmonised[,paste0("a2.",traits[1])]
      unharmonised[,paste0("a2.",traits[1])] = tmp # a1和a2交换位置
      unharmonised[,paste0("zscore.",traits[1])] = -unharmonised[,paste0("zscore.",traits[1])] # zscore取反
      unharmonised[,paste0("or.",traits[1])] = exp(-log(unharmonised[,paste0("or.",traits[1])])) # OR取反
      unharmonised[,paste0("EURaf.",traits[1])] = 1-unharmonised[,paste0("EURaf.",traits[1])] # eaf
      harmonised = rbind(harmonised,unharmonised[unharmonised[,paste0("a1.",traits[1])]==unharmonised[,paste0("a1.",traits[2])]&unharmonised[,paste0("a2.",traits[1])]==unharmonised[,paste0("a2.",traits[2])],])
    }
    if(nrow(merged)!=nrow(harmonised)){
      unharmonised = merged[!(merged$snpid%in%harmonised$snpid),]
      # 链翻转
      A1_loc = which(unharmonised[,paste0("a1.",traits[1])]=="A")
      T1_loc = which(unharmonised[,paste0("a1.",traits[1])]=="T")
      C1_loc = which(unharmonised[,paste0("a1.",traits[1])]=="C")
      G1_loc = which(unharmonised[,paste0("a1.",traits[1])]=="G")
      A2_loc = which(unharmonised[,paste0("a2.",traits[1])]=="A")
      T2_loc = which(unharmonised[,paste0("a2.",traits[1])]=="T")
      C2_loc = which(unharmonised[,paste0("a2.",traits[1])]=="C")
      G2_loc = which(unharmonised[,paste0("a2.",traits[1])]=="G")
      table(unharmonised[,paste0("a1.",traits[1])])
      table(unharmonised[,paste0("a2.",traits[1])])
      unharmonised[,paste0("a1.",traits[1])][A1_loc] = "T"
      unharmonised[,paste0("a1.",traits[1])][T1_loc] = "A"
      unharmonised[,paste0("a1.",traits[1])][C1_loc] = "G"
      unharmonised[,paste0("a1.",traits[1])][G1_loc] = "C"
      unharmonised[,paste0("a2.",traits[1])][A2_loc] = "T"
      unharmonised[,paste0("a2.",traits[1])][T2_loc] = "A"
      unharmonised[,paste0("a2.",traits[1])][C2_loc] = "G"
      unharmonised[,paste0("a2.",traits[1])][G2_loc] = "C"
      table(unharmonised[,paste0("a1.",traits[1])])
      table(unharmonised[,paste0("a2.",traits[1])])
      harmonised = rbind(harmonised,unharmonised[unharmonised[,paste0("a1.",traits[1])]==unharmonised[,paste0("a1.",traits[2])]&unharmonised[,paste0("a2.",traits[1])]==unharmonised[,paste0("a2.",traits[2])],])
    }
    if(nrow(merged)!=nrow(harmonised)){
      unharmonised = unharmonised[!(unharmonised$snpid%in%harmonised$snpid),]
      tmp = unharmonised[,paste0("a1.",traits[1])]
      unharmonised[,paste0("a1.",traits[1])] = unharmonised[,paste0("a2.",traits[1])]
      unharmonised[,paste0("a2.",traits[1])] = tmp
      unharmonised[,paste0("zscore.",traits[1])] = -unharmonised[,paste0("zscore.",traits[1])]
      unharmonised[,paste0("or.",traits[1])] = exp(-log(unharmonised[,paste0("or.",traits[1])])) # OR取反
      unharmonised[,paste0("EURaf.",traits[1])] = 1-unharmonised[,paste0("EURaf.",traits[1])] # eaf
      harmonised = rbind(harmonised,unharmonised[unharmonised[,paste0("a1.",traits[1])]==unharmonised[,paste0("a1.",traits[2])]&unharmonised[,paste0("a2.",traits[1])]==unharmonised[,paste0("a2.",traits[2])],])
    }
    if(nrow(merged)!=nrow(harmonised)){
      print(paste0("exsit merge unharmonise: ",paste0(traits[1],"-",traits[2],"; ",(nrow(merged)-nrow(harmonised)))))
    }
  }
  
  if(nrow(palindrome)>0){
    
    palindrome$eaf1_minus_eaf2 = abs(palindrome[,paste0("EURaf.",traits[1])]-palindrome[,paste0("EURaf.",traits[2])])
    
    palindrome_duiying = palindrome[,paste0("a1.",traits[1])]==palindrome[,paste0("a1.",traits[2])]&palindrome[,paste0("a2.",traits[1])]==palindrome[,paste0("a2.",traits[2])]
    palindrome_noduiying = palindrome[,paste0("a1.",traits[1])]==palindrome[,paste0("a2.",traits[2])]&palindrome[,paste0("a2.",traits[1])]==palindrome[,paste0("a1.",traits[2])]
    palindrome = palindrome[palindrome_duiying|palindrome_noduiying,] # 去除了trait1为A/T，trait2为A/G的情况
    
    palindrome[palindrome$eaf1_minus_eaf2>0.2,paste0("zscore.",traits[1])] = -palindrome[palindrome$eaf1_minus_eaf2>0.2,paste0("zscore.",traits[1])]
    palindrome[palindrome$eaf1_minus_eaf2>0.2,paste0("or.",traits[1])] = exp(-log(palindrome[palindrome$eaf1_minus_eaf2>0.2,paste0("or.",traits[1])]))
    
    palindrome[,paste0("a1.",traits[1])]=palindrome[,paste0("a1.",traits[2])]
    palindrome[,paste0("a2.",traits[1])]=palindrome[,paste0("a2.",traits[2])]
    palindrome = palindrome[,-which(colnames(palindrome)=="eaf1_minus_eaf2")]
    harmonised = rbind(harmonised,palindrome)
  }
  print(paste0("exsit palindrome and merge unharmonise: ",paste0(traits[1],"-",traits[2],"; ",(num_SNP-nrow(harmonised)))))
  write_tsv(harmonised,paste0("~/share_genetics/data/GWAS/overlap/",traits[1],"-",traits[2],".gz"))
}else{
  print(paste0("wrong palindrome and merged rows: ",traits[1],"-",traits[2]))
}

{
  # harmonised = as.data.frame(fread(paste0("~/share_genetics/data/GWAS/harmonised/",traits[1],"-",traits[2],".gz")))
  harmonised = harmonised[!is.na(harmonised[,paste0("zscore.",traits[1])]),]
  harmonised = harmonised[!is.na(harmonised[,paste0("zscore.",traits[2])]),]
  harmonised = harmonised[((harmonised[,paste0("zscore.",traits[1])])^2<=80)&((harmonised[,paste0("zscore.",traits[2])])^2<=80),] # 由于极大的效应大小可能产生杂散信号，Z得分平方高于80的SNP被去除
  # 去相关Z评分，以解释潜在的样本重叠
  Z.matrix = as.matrix(harmonised[,c(paste0("zscore.",traits[1]),paste0("zscore.",traits[2]))])
  P.matrix = as.matrix(harmonised[,c(paste0("pval.",traits[1]),paste0("pval.",traits[2]))])
  R = cor.pearson(Z.matrix, P.matrix, p.threshold=1e-4)
  "%^%" <- function(x, pow)
    with(eigen(x), vectors %*% (values^pow * t(vectors)))
  Z.matrix.decor <- Z.matrix %*% (R %^% (-0.5))
  # PLACO
  VarZ = var.placo(Z.matrix.decor, P.matrix, p.threshold=1e-4)
  out <- sapply(1:nrow(Z.matrix.decor), function(i) placo(Z=Z.matrix.decor[i,], VarZ=VarZ))
  write_rds(out,paste0("/home/yanyq/share_genetics/result/PLACO/",traits[1],"-",traits[2],".rds"))
}

setwd("~/share_genetics/data/GWAS/processed")
{
  out = t(as.data.frame(out))
  out = as.data.frame(out)
  colnames(out) = c("T.placo","p.placo")
  # harmonised = as.data.frame(fread(paste0(paste0("~/share_genetics/data/GWAS/harmonised/",traits[1],"-",traits[2],".gz"))))
  # harmonised = harmonised[!is.na(harmonised[,paste0("zscore.",traits[1])]),]
  # harmonised = harmonised[!is.na(harmonised[,paste0("zscore.",traits[2])]),]
  # harmonised = harmonised[((harmonised[,paste0("zscore.",traits[1])])^2<=80)&((harmonised[,paste0("zscore.",traits[2])])^2<=80),]
  harmonised = cbind(harmonised,out)
  harmonised$p.placo = unlist(harmonised$p.placo)
  harmonised$T.placo = unlist(harmonised$T.placo)
  write_tsv(harmonised[,c("snpid", paste0("hg19chr.",traits[1]), paste0("bp.",traits[1]), paste0("a1.",traits[1]), paste0("a2.",traits[1]), "p.placo")],paste0("~/share_genetics/result/PLACO/PLACO_",traits[1],"-",traits[2],".gz"))
  harmonised = harmonised[harmonised$p.placo<5e-8,]
  write_tsv(harmonised,paste0("~/share_genetics/result/PLACO/sig_",traits[1],"-",traits[2]))
}