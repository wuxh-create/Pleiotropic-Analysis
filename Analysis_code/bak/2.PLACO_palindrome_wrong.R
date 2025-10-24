# overlap的回文SNP
# # a1、a2对应得上的SNP，其eaf相差大的，两个性状的EA和NEA实际上反了
# a1、a2对应不上的SNP，其eaf相差小的，两个性状的EA和NEA实际上没反
library(data.table)
library(readr)
library(GPA)
library(gpaExample)
source("~/software/R_pac/PLACO/PLACO_v0.1.1.R")

setwd("~/share_genetics/data/GWAS/processed")
all_trait = c("BLCA",  "BRCA", "HNSC",  "kidney",  "lung",  "OV",  "PAAD",  "PRAD",  "SKCM",  "UCEC")
for(i in 1:9){
  print(i)
  for(j in (i+1):10){
    print(j)
    traits = c(all_trait[i],all_trait[j])
    # merge trait1D harmonise
    trait1 = fread(paste0(traits[1],".gz"))
    trait1$zscore = log(trait1$or)/trait1$se
    trait2 = fread(paste0(traits[2],".gz"))
    trait2$zscore = log(trait2$or)/trait2$se
    merged = merge(trait1,trait2,by = "snpid",suffixes = c(paste0(".",traits[1]),paste0(".",traits[2])))
    merged = as.data.frame(merged)
    merged = merged[merged[,paste0("a1.",traits[1])]%in%c("A","C","G","T")&merged[,paste0("a2.",traits[1])]%in%c("A","C","G","T")&merged[,paste0("a1.",traits[2])]%in%c("A","C","G","T")&merged[,paste0("a2.",traits[2])]%in%c("A","C","G","T"),] # 两个trait的两个等位基因均为A/T/G/C
    num_SNP = nrow(merged)
    
    a1_trait1 = merged[,paste0("a1.",traits[1])]
    a2_trait1 = merged[,paste0("a2.",traits[1])]
    
    palindrome_trait1 = merged[paste0(a1_trait1,"/",a2_trait1)%in%c("A/T","T/A","G/C","C/G"),] # 不需要看trait2的，trait1为回文，trait2必为回文，因为这是rsid overlap后的
    if(nrow(palindrome_trait1)>0){
      # kidney没有EAF列，无法判断
      if(i==4|j==4){
        write_tsv(palindrome_trait1,paste0("/home/yanyq/share_genetics/data/GWAS/overlap_palindrome/all_",traits[1],"-",traits[2]))
      }else{
        palindrome_trait1$eaf1_minus_eaf2 = abs(palindrome_trait1[,paste0("EURaf.",traits[1])]-palindrome_trait1[,paste0("EURaf.",traits[2])])
        
        palindrome_duiying = palindrome_trait1[palindrome_trait1[,paste0("a1.",traits[1])]==palindrome_trait1[,paste0("a1.",traits[2])]&palindrome_trait1[,paste0("a2.",traits[1])]==palindrome_trait1[,paste0("a2.",traits[2])],]
        palindrome_noduiying = palindrome_trait1[palindrome_trait1[,paste0("a1.",traits[1])]==palindrome_trait1[,paste0("a2.",traits[2])]&palindrome_trait1[,paste0("a2.",traits[1])]==palindrome_trait1[,paste0("a1.",traits[2])],]
        
        palindrome_duiying = palindrome_duiying[palindrome_duiying$eaf1_minus_eaf2>0.2,]
        palindrome_noduiying = palindrome_noduiying[palindrome_noduiying$eaf1_minus_eaf2<0.2,]
        
        if(nrow(palindrome_duiying)>0&nrow(palindrome_noduiying)>0){
          palindrome_duiying$duiying = "yes"
          palindrome_noduiying$duiying = "no"
          write_tsv(rbind(palindrome_duiying,palindrome_noduiying),paste0("/home/yanyq/share_genetics/data/GWAS/overlap_palindrome/wrong_",traits[1],"-",traits[2]))
        }
        if(nrow(palindrome_duiying)>0&nrow(palindrome_noduiying)==0){
          palindrome_duiying$duiying = "yes"
          write_tsv(palindrome_duiying,paste0("/home/yanyq/share_genetics/data/GWAS/overlap_palindrome/wrong_",traits[1],"-",traits[2]))
        }
        if(nrow(palindrome_duiying)==0&nrow(palindrome_noduiying)>0){
          palindrome_noduiying$duiying = "no"
          write_tsv(palindrome_noduiying,paste0("/home/yanyq/share_genetics/data/GWAS/overlap_palindrome/wrong_",traits[1],"-",traits[2]))
        }
      }
    }
  }
}
