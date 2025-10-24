# FUMA和MAGMA共定位结果
library(readr)
library(data.table)
library(coloc)

traits = c("AML","BAC","BCC","BGA","BGC","BLCA","BM","BRCA","CESC","CML","CORP",
           "CRC","DLBC","ESCA","EYAD","GSS","HL","HNSC","kidney","LIHC","LL",
           "lung","MCL","MESO","MM","MS","MZBL","OV","PAAD","PRAD","SCC","SI",
           "SKCM","STAD","TEST","THCA","UCEC","VULVA")
FUMA_coloc = list()
MAGMA_coloc = list()
for(trait1 in traits){
  for(trait2 in traits){
    if(file.exists(paste0("~/share_genetics/result/FUMA/merge/",trait1,"-",trait2))){
      FUMA_coloc[[paste0(trait1,"-",trait2)]] = read_tsv(paste0("~/share_genetics/result/coloc/summary/",trait1,"-",trait2))
      FUMA_coloc[[paste0(trait1,"-",trait2)]]$traits = paste0(trait1,"-",trait2)
    }
    if(file.exists(paste0("~/share_genetics/result/coloc_MAGMA/summary/",trait1,"-",trait2))){
      MAGMA_coloc[[paste0(trait1,"-",trait2)]] = read_tsv(paste0("~/share_genetics/result/coloc_MAGMA/summary/",trait1,"-",trait2))
      MAGMA_coloc[[paste0(trait1,"-",trait2)]]$traits = paste0(trait1,"-",trait2)
    }
  }
}
FUMA_coloc = do.call(rbind, FUMA_coloc)
MAGMA_coloc = do.call(rbind, MAGMA_coloc)
write_tsv(FUMA_coloc, "~/share_genetics/result/coloc/summary/all")
write_tsv(MAGMA_coloc, "~/share_genetics/result/coloc_MAGMA/summary/all")
FUMA_coloc_sig = FUMA_coloc[FUMA_coloc$PP.H4.abf>0.7,]
MAGMA_coloc_sig = MAGMA_coloc[MAGMA_coloc$PP.H4.abf>0.7,]

# MAGMA和FUMA交集
MAGMA = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/all"))
MAGMA$flag = paste0(MAGMA$trait,":",MAGMA$locus.MAGMA)
MAGMA_coloc_sig$flag = paste0(MAGMA_coloc_sig$traits, ":",MAGMA_coloc_sig$locus)
MAGMA_coloc_sig = dplyr::left_join(MAGMA_coloc_sig, MAGMA[,c("flag","locus.FUMA")], by = "flag")
MAGMA_coloc_sig$flag = paste0(MAGMA_coloc_sig$traits, ":",MAGMA_coloc_sig$locus.FUMA)
FUMA_coloc_sig$flag = paste0(FUMA_coloc_sig$traits, ":",FUMA_coloc_sig$locus)
MAGMA_coloc_sig$in_FUMA_coloc_sig = MAGMA_coloc_sig$flag%in%FUMA_coloc_sig$flag
FUMA_coloc_sig$in_MAGMA_coloc_sig = FUMA_coloc_sig$flag%in%MAGMA_coloc_sig$flag

################################################################################
# 共享基因座上的top SNP同时也是最佳共享因果变异
library(vroom)
all_FUMA_coloc_top_best = list()
all_MAGMA_coloc_top_best = list()
for(trait1 in traits){
  for(trait2 in traits){
    print(paste0(trait1, "-", trait2))
    if(file.exists(paste0("~/share_genetics/result/FUMA/merge/",trait1,"-",trait2))){
      PLACO = as.data.frame(vroom(paste0("/home/yanyq/share_genetics/result/PLACO/PLACO_",trait1,"-",trait2,".gz")))
      FUMA_raw = readRDS(paste0("~/share_genetics/result/coloc/raw/",trait1,"-",trait2))
      if(length(FUMA_raw)>0){
        FUMA_coloc_top_best = as.data.frame(matrix(nrow = length(FUMA_raw), ncol = 7))
        # top SNP的P值、共定位结果最好的SNP P值
        colnames(FUMA_coloc_top_best) = c("traits", "PLACO_topSNP","top_P","COLOC_P", "COLOC_bestSNP","top_H4","best_H4")
        FUMA_coloc_top_best$traits = paste0(trait1,"-",trait2)
        
        for(i in 1:length(FUMA_raw)){
          if(!is.null(FUMA_raw[[i]])){
            coloc_SNP = PLACO[PLACO$snpid%in%FUMA_raw[[i]]$results$snp,]
            top_SNP = coloc_SNP$snpid[which.min(coloc_SNP$p.placo)]
            best_SNP = FUMA_raw[[i]]$results$snp[which.max(FUMA_raw[[i]]$results$SNP.PP.H4)]
            
            FUMA_coloc_top_best$PLACO_topSNP[i] = top_SNP
            FUMA_coloc_top_best$COLOC_bestSNP[i] = best_SNP
            
            FUMA_coloc_top_best$top_P[i] = min(coloc_SNP$p.placo)
            if(any(PLACO$snpid==best_SNP)){
              FUMA_coloc_top_best$COLOC_P[i] = PLACO$p.placo[PLACO$snpid==best_SNP]
            }
            
            FUMA_coloc_top_best$best_H4[i] = max(FUMA_raw[[i]]$results$SNP.PP.H4)
            if(any(FUMA_raw[[i]]$results$snp==top_SNP)){
              FUMA_coloc_top_best$top_H4[i] = FUMA_raw[[i]]$results$SNP.PP.H4[FUMA_raw[[i]]$results$snp==top_SNP]
            }
          }
        }
        all_FUMA_coloc_top_best[[paste0(trait1,"-",trait2)]] = FUMA_coloc_top_best
      }
    }
    if(file.exists(paste0("~/share_genetics/result/coloc_MAGMA/summary/",trait1,"-",trait2))){
      MAGMA_raw = readRDS(paste0("/home/yanyq/share_genetics/result/coloc_MAGMA/raw/",trait1,"-",trait2))
      if(length(MAGMA_raw)>0){
        MAGMA_coloc_top_best = as.data.frame(matrix(nrow = length(MAGMA_raw), ncol = 7))
        # top SNP的P值、共定位结果最好的SNP P值
        colnames(MAGMA_coloc_top_best) = c("traits", "PLACO_topSNP","top_P","COLOC_P", "COLOC_bestSNP","top_H4","best_H4")
        MAGMA_coloc_top_best$traits = paste0(trait1,"-",trait2)
        
        for(i in 1:length(MAGMA_raw)){
          if(!is.null(MAGMA_raw[[i]])){
            coloc_SNP = PLACO[PLACO$snpid%in%MAGMA_raw[[i]]$results$snp,]
            top_SNP = coloc_SNP$snpid[which.min(coloc_SNP$p.placo)]
            best_SNP = MAGMA_raw[[i]]$results$snp[which.max(MAGMA_raw[[i]]$results$SNP.PP.H4)]
            
            MAGMA_coloc_top_best$PLACO_topSNP[i] = top_SNP
            MAGMA_coloc_top_best$COLOC_bestSNP[i] = best_SNP
            
            MAGMA_coloc_top_best$top_P[i] = min(coloc_SNP$p.placo)
            if(any(PLACO$snpid==best_SNP)){
              MAGMA_coloc_top_best$COLOC_P[i] = PLACO$p.placo[PLACO$snpid==best_SNP]
            }
            
            MAGMA_coloc_top_best$best_H4[i] = max(MAGMA_raw[[i]]$results$SNP.PP.H4)
            if(any(MAGMA_raw[[i]]$results$snp==top_SNP)){
              MAGMA_coloc_top_best$top_H4[i] = MAGMA_raw[[i]]$results$SNP.PP.H4[MAGMA_raw[[i]]$results$snp==top_SNP]
            }
          }
        }
        all_MAGMA_coloc_top_best[[paste0(trait1,"-",trait2)]] = MAGMA_coloc_top_best
      }
    }
  }
}
write_rds(all_FUMA_coloc_top_best, "/home/yanyq/share_genetics/result/coloc/all_FUMA_coloc_top_best")
write_rds(all_MAGMA_coloc_top_best, "/home/yanyq/share_genetics/result/coloc_MAGMA/all_MAGMA_coloc_top_best")

all_FUMA_coloc_top_best = read_rds("/home/yanyq/share_genetics/result/coloc/all_FUMA_coloc_top_best")
all_FUMA_coloc_top_best = do.call(rbind, all_FUMA_coloc_top_best)
FUMA_coloc = as.data.frame(read_tsv("~/share_genetics/result/coloc/summary/all"))
length(which(all_FUMA_coloc_top_best$PLACO_topSNP==all_FUMA_coloc_top_best$COLOC_bestSNP&FUMA_coloc$PP.H4.abf>0.7))

all_MAGMA_coloc_top_best = read_rds("/home/yanyq/share_genetics/result/coloc_MAGMA/all_MAGMA_coloc_top_best")
all_MAGMA_coloc_top_best = do.call(rbind, all_MAGMA_coloc_top_best)
MAGMA_coloc = as.data.frame(read_tsv("~/share_genetics/result/coloc_MAGMA/summary/all"))
length(which(all_MAGMA_coloc_top_best$PLACO_topSNP==all_MAGMA_coloc_top_best$COLOC_bestSNP&MAGMA_coloc$PP.H4.abf>0.7))

########################### 把由于beta=0的error给补上
# FUMA
{
  rm(list = ls())
  setwd("/home/yanyq/share_genetics/result/coloc/error/")
  files = list.files()
  files = c("BCC-CESC_locus_11",
            "CESC-BRCA_locus_5",  "CESC-BRCA_locus_6", "CESC-BRCA_locus_7","CESC-BRCA_locus_11", 
            "CESC-ESCA_locus_1",  "CESC-ESCA_locus_2" , 
            "CESC-OV_locus_3",  "CESC-OV_locus_4","CESC-OV_locus_5",
            "CESC-PRAD_locus_4","CESC-PRAD_locus_8" ,"CESC-PRAD_locus_10", "CESC-PRAD_locus_11","CESC-PRAD_locus_13", "CESC-PRAD_locus_17",
            "CESC-SKCM_locus_3",
            "GSS-LL_locus_1",
            "HL-LL_locus_1",
            "LL-kidney_locus_1", 
            "LL-MESO_locus_1",
            "LL-MZBL_locus_2",
            "LL-PRAD_locus_17","LL-PRAD_locus_20",  
            "LL-SKCM_locus_3",
            "LL-THCA_locus_4" )
  files_1 = files[c(2:5,8:16,23)]
  files_2 = files[-c(2:5,8:16,23)]
  sampleSize = read.table("/home/yanyq/share_genetics/data/sampleSize",header = F)
  # mv "/home/yanyq/share_genetics/result/coloc/summary/all" "/home/yanyq/share_genetics/result/coloc/summary/all.bak"
  coloc = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/coloc/summary/all.bak"))
  coloc_NA = coloc[is.na(coloc$PP.H0.abf),]
  
  for(i in 1:nrow(coloc_NA)){
    traits = coloc_NA$traits[i]
    trait1 = str_split(traits, "-")[[1]][1]
    trait2 = str_split(traits, "-")[[1]][2]
    to_coloc = readRDS(files_1[i])
    
    if((as.data.frame(to_coloc)[1,"chr"]==str_split(coloc_NA$locus[i],":")[[1]][1])&((str_split(files_1[i],"_")[[1]][1]==coloc_NA$traits[i]))){
      MAF_trait1 = to_coloc[,paste0("EURaf.",trait1)]
      MAF_trait2 = to_coloc[,paste0("EURaf.",trait2)]
      
      N_trait1 = sampleSize$V2[sampleSize$V1==trait1]
      N_trait2 = sampleSize$V2[sampleSize$V1==trait2]
      
      # 检查是否有beta为0的
      tmp_or1 = as.numeric(to_coloc[,paste0("or.",trait1)])
      tmp_or2 = as.numeric(to_coloc[,paste0("or.",trait2)])
      dataset1 = list(pvalues=as.numeric(to_coloc[,paste0("pval.",trait1)])[tmp_or1!=1], type="cc",snp=to_coloc[,"snpid"][tmp_or1!=1],beta=log(as.numeric(to_coloc[,paste0("or.",trait1)]))[tmp_or1!=1],varbeta=((as.numeric(to_coloc[,paste0("se.",trait1)]))^2)[tmp_or1!=1],N=N_trait1, MAF=as.numeric(MAF_trait1)[tmp_or1!=1])
      dataset2 = list(pvalues=as.numeric(to_coloc[,paste0("pval.",trait2)])[tmp_or2!=1], type="cc",snp=to_coloc[,"snpid"][tmp_or2!=1],beta=log(as.numeric(to_coloc[,paste0("or.",trait2)]))[tmp_or2!=1],varbeta=((as.numeric(to_coloc[,paste0("se.",trait2)]))^2)[tmp_or2!=1],N=N_trait2, MAF=as.numeric(MAF_trait2)[tmp_or2!=1])
      
      result = coloc.abf(dataset1 = dataset1,
                         dataset2 = dataset2)
      coloc_NA[i,1:6] = result$summary
      tmp_result = result$result
      best_result = tmp_result[which.max(tmp_result$`SNP.PP.H4`),]
      coloc_NA[i,9:19] = best_result
    }else{
      print(i)
    }
  }
  coloc[is.na(coloc$PP.H0.abf),] = coloc_NA
  
  coloc_NA = coloc_NA[1:12,]
  coloc_NA[1:12,] = NA
  flag = 1
  for(i in files_2){
    to_coloc = readRDS(i)
    print(to_coloc[1,"chr"])
    traits = str_split(i, "_")[[1]][1]
    trait1 = str_split(traits, "-")[[1]][1]
    trait2 = str_split(traits, "-")[[1]][2]
    MAF_trait1 = to_coloc[,paste0("EURaf.",trait1)]
    MAF_trait2 = to_coloc[,paste0("EURaf.",trait2)]
    
    N_trait1 = sampleSize$V2[sampleSize$V1==trait1]
    N_trait2 = sampleSize$V2[sampleSize$V1==trait2]
    
    # 检查是否有beta为0的
    tmp_or1 = as.numeric(to_coloc[,paste0("or.",trait1)])
    tmp_or2 = as.numeric(to_coloc[,paste0("or.",trait2)])
    dataset1 = list(pvalues=as.numeric(to_coloc[,paste0("pval.",trait1)])[tmp_or1!=1], type="cc",snp=to_coloc[,"snpid"][tmp_or1!=1],beta=log(as.numeric(to_coloc[,paste0("or.",trait1)]))[tmp_or1!=1],varbeta=((as.numeric(to_coloc[,paste0("se.",trait1)]))^2)[tmp_or1!=1],N=N_trait1, MAF=as.numeric(MAF_trait1)[tmp_or1!=1])
    dataset2 = list(pvalues=as.numeric(to_coloc[,paste0("pval.",trait2)])[tmp_or2!=1], type="cc",snp=to_coloc[,"snpid"][tmp_or2!=1],beta=log(as.numeric(to_coloc[,paste0("or.",trait2)]))[tmp_or2!=1],varbeta=((as.numeric(to_coloc[,paste0("se.",trait2)]))^2)[tmp_or2!=1],N=N_trait2, MAF=as.numeric(MAF_trait2)[tmp_or2!=1])
    
    result = coloc.abf(dataset1 = dataset1,
                       dataset2 = dataset2)
    coloc_NA[flag,1:6] = result$summary
    tmp_result = result$result
    best_result = tmp_result[which.max(tmp_result$`SNP.PP.H4`),]
    coloc_NA[flag,9:19] = best_result
    
    FUMA_both = as.data.frame(read_tsv(paste0("~/share_genetics/result/FUMA/merge/",trait1,"-",trait2)))
    coloc_NA$locus[flag] = FUMA_both$locus[as.numeric(str_split(i, "_")[[1]][3])]
    coloc_NA$`no.locus`[flag] = FUMA_both$GenomicLocus[as.numeric(str_split(i, "_")[[1]][3])]
    coloc_NA$traits[flag] = traits
    flag = flag+1
  }
  coloc = rbind(coloc, coloc_NA)
  write_tsv(coloc,"/home/yanyq/share_genetics/result/coloc/summary/all")
}

# MAGMA
{
  rm(list = ls())
  setwd("/home/yanyq/share_genetics/result/coloc_MAGMA/error/")
  files = list.files()
  files = c("BCC-CESC_locus_3","BCC-CESC_locus_7",
            "CESC-BRCA_locus_5","CESC-BRCA_locus_15","CESC-BRCA_locus_16",
            "CESC-CRC_locus_3",
            "CESC-OV_locus_3",
            "CESC-PRAD_locus_6" ,
            "CESC-SCC_locus_1","CESC-SCC_locus_2","CESC-SKCM_locus_5","CESC-SKCM_locus_6" ,
            "LL-PRAD_locus_34")
  # CESC-SCC，就两个MAGMA位点，都error了，所以不在MAGMA_NA中
  # "CESC-SKCM_locus_5","CESC-SKCM_locus_6"，共有6个MAGMA位点，最后两个共定位的结果为error，所以length(result)=4
  sampleSize = read.table("/home/yanyq/share_genetics/data/sampleSize",header = F)
  # mv ~/share_genetics/result/coloc_MAGMA/summary/all ~/share_genetics/result/coloc_MAGMA/summary/all.bak
  MAGMA_coloc = as.data.frame(read_tsv("~/share_genetics/result/coloc_MAGMA/summary/all.bak"))
  MAGMA_coloc_NA = MAGMA_coloc[is.na(MAGMA_coloc$PP.H0.abf),]
  
  for(i in 1:nrow(MAGMA_coloc_NA)){
    traits = MAGMA_coloc_NA$traits[i]
    trait1 = str_split(traits, "-")[[1]][1]
    trait2 = str_split(traits, "-")[[1]][2]
    if(i==9){
      to_coloc = readRDS("LL-PRAD_locus_34")
    }else{
      to_coloc = readRDS(files[i])
    }
    if((as.data.frame(to_coloc)[1,"chr"]==str_split(MAGMA_coloc_NA$locus[i],":")[[1]][1])&((str_split(files[i],"_")[[1]][1]==MAGMA_coloc_NA$traits[i])|(MAGMA_coloc_NA$traits[i]=="LL-PRAD"))){
      MAF_trait1 = to_coloc[,paste0("EURaf.",trait1)]
      MAF_trait2 = to_coloc[,paste0("EURaf.",trait2)]
      
      N_trait1 = sampleSize$V2[sampleSize$V1==trait1]
      N_trait2 = sampleSize$V2[sampleSize$V1==trait2]
      
      # 检查是否有beta为0的
      tmp_or1 = as.numeric(to_coloc[,paste0("or.",trait1)])
      tmp_or2 = as.numeric(to_coloc[,paste0("or.",trait2)])
      dataset1 = list(pvalues=as.numeric(to_coloc[,paste0("pval.",trait1)])[tmp_or1!=1], type="cc",snp=to_coloc[,"snpid"][tmp_or1!=1],beta=log(as.numeric(to_coloc[,paste0("or.",trait1)]))[tmp_or1!=1],varbeta=((as.numeric(to_coloc[,paste0("se.",trait1)]))^2)[tmp_or1!=1],N=N_trait1, MAF=as.numeric(MAF_trait1)[tmp_or1!=1])
      dataset2 = list(pvalues=as.numeric(to_coloc[,paste0("pval.",trait2)])[tmp_or2!=1], type="cc",snp=to_coloc[,"snpid"][tmp_or2!=1],beta=log(as.numeric(to_coloc[,paste0("or.",trait2)]))[tmp_or2!=1],varbeta=((as.numeric(to_coloc[,paste0("se.",trait2)]))^2)[tmp_or2!=1],N=N_trait2, MAF=as.numeric(MAF_trait2)[tmp_or2!=1])
      
      result = coloc.abf(dataset1 = dataset1,
                         dataset2 = dataset2)
      MAGMA_coloc_NA[i,1:6] = result$summary
      tmp_result = result$result
      best_result = tmp_result[which.max(tmp_result$`SNP.PP.H4`),]
      MAGMA_coloc_NA[i,8:18] = best_result
    }else{
      print(i)
    }
  }
  MAGMA_coloc[is.na(MAGMA_coloc$PP.H0.abf),] = MAGMA_coloc_NA
  
  MAGMA_coloc_NA = MAGMA_coloc_NA[1:4,]
  MAGMA_coloc_NA[1:4,] = NA
  flag = 1
  for(i in c("CESC-SCC_locus_1","CESC-SCC_locus_2","CESC-SKCM_locus_5","CESC-SKCM_locus_6")){
    to_coloc = readRDS(i)
    print(to_coloc[1,"chr"])
    traits = str_split(i, "_")[[1]][1]
    trait1 = str_split(traits, "-")[[1]][1]
    trait2 = str_split(traits, "-")[[1]][2]
    MAF_trait1 = to_coloc[,paste0("EURaf.",trait1)]
    MAF_trait2 = to_coloc[,paste0("EURaf.",trait2)]
    
    N_trait1 = sampleSize$V2[sampleSize$V1==trait1]
    N_trait2 = sampleSize$V2[sampleSize$V1==trait2]
    
    # 检查是否有beta为0的
    tmp_or1 = as.numeric(to_coloc[,paste0("or.",trait1)])
    tmp_or2 = as.numeric(to_coloc[,paste0("or.",trait2)])
    dataset1 = list(pvalues=as.numeric(to_coloc[,paste0("pval.",trait1)])[tmp_or1!=1], type="cc",snp=to_coloc[,"snpid"][tmp_or1!=1],beta=log(as.numeric(to_coloc[,paste0("or.",trait1)]))[tmp_or1!=1],varbeta=((as.numeric(to_coloc[,paste0("se.",trait1)]))^2)[tmp_or1!=1],N=N_trait1, MAF=as.numeric(MAF_trait1)[tmp_or1!=1])
    dataset2 = list(pvalues=as.numeric(to_coloc[,paste0("pval.",trait2)])[tmp_or2!=1], type="cc",snp=to_coloc[,"snpid"][tmp_or2!=1],beta=log(as.numeric(to_coloc[,paste0("or.",trait2)]))[tmp_or2!=1],varbeta=((as.numeric(to_coloc[,paste0("se.",trait2)]))^2)[tmp_or2!=1],N=N_trait2, MAF=as.numeric(MAF_trait2)[tmp_or2!=1])
    
    result = coloc.abf(dataset1 = dataset1,
                       dataset2 = dataset2)
    MAGMA_coloc_NA[flag,1:6] = result$summary
    tmp_result = result$result
    best_result = tmp_result[which.max(tmp_result$`SNP.PP.H4`),]
    MAGMA_coloc_NA[flag,8:18] = best_result
    
    MAGMA_both = fread(paste0("/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/",trait1,"-",trait2))
    MAGMA_coloc_NA$locus[flag] = MAGMA_both$locus.MAGMA[as.numeric(str_split(i, "_")[[1]][3])]
    MAGMA_coloc_NA$traits[flag] = traits
    flag = flag+1
  }
  MAGMA_coloc = rbind(MAGMA_coloc, MAGMA_coloc_NA)
  write_tsv(MAGMA_coloc,"~/share_genetics/result/coloc_MAGMA/summary/all")
}


################################
{
  library(tidyverse)
  library(coloc)
  rm(list = ls())
  sampleSize = read.table("/home/yanyq/share_genetics/data/sampleSize",header = F)
  
  all_FUMA_coloc_top_best = read_rds("/home/yanyq/share_genetics/result/coloc/all_FUMA_coloc_top_best")
  all_FUMA_coloc_top_best = do.call(rbind, all_FUMA_coloc_top_best)
  all_FUMA_coloc_top_best = all_FUMA_coloc_top_best[!is.na(all_FUMA_coloc_top_best$COLOC_bestSNP),]
  
  FUMA_coloc = as.data.frame(read_tsv("~/share_genetics/result/coloc/summary/all"))
  # FUMA_coloc_error = FUMA_coloc[(nrow(all_FUMA_coloc_top_best)+1):nrow(FUMA_coloc),]
  FUMA_coloc_error = FUMA_coloc[!paste0(FUMA_coloc$traits,":",FUMA_coloc$snp)%in%paste0(all_FUMA_coloc_top_best$traits,":",all_FUMA_coloc_top_best$COLOC_bestSNP),]
  
  FUMA_coloc_top_best_error = as.data.frame(matrix(nrow = nrow(FUMA_coloc_error), ncol = 7))
  colnames(FUMA_coloc_top_best_error) = c("traits", "PLACO_topSNP","top_P","COLOC_P", "COLOC_bestSNP","top_H4","best_H4")
  FUMA_coloc_top_best_error$traits = FUMA_coloc_error$traits
  for(i in 1:nrow(FUMA_coloc_error)){
    to_coloc = readRDS(paste0("/home/yanyq/share_genetics/result/coloc/error/",FUMA_coloc_error$traits[i],"_locus_",FUMA_coloc_error$no.locus[i]))
    traits = FUMA_coloc_error$traits[i]
    trait1 = str_split(traits, "-")[[1]][1]
    trait2 = str_split(traits, "-")[[1]][2]
    
    MAF_trait1 = to_coloc[,paste0("EURaf.",trait1)]
    MAF_trait2 = to_coloc[,paste0("EURaf.",trait2)]
    
    N_trait1 = sampleSize$V2[sampleSize$V1==trait1]
    N_trait2 = sampleSize$V2[sampleSize$V1==trait2]
    
    # 检查是否有beta为0的
    tmp_or1 = as.numeric(to_coloc[,paste0("or.",trait1)])
    tmp_or2 = as.numeric(to_coloc[,paste0("or.",trait2)])
    dataset1 = list(pvalues=as.numeric(to_coloc[,paste0("pval.",trait1)])[tmp_or1!=1], type="cc",snp=to_coloc[,"snpid"][tmp_or1!=1],beta=log(as.numeric(to_coloc[,paste0("or.",trait1)]))[tmp_or1!=1],varbeta=((as.numeric(to_coloc[,paste0("se.",trait1)]))^2)[tmp_or1!=1],N=N_trait1, MAF=as.numeric(MAF_trait1)[tmp_or1!=1])
    dataset2 = list(pvalues=as.numeric(to_coloc[,paste0("pval.",trait2)])[tmp_or2!=1], type="cc",snp=to_coloc[,"snpid"][tmp_or2!=1],beta=log(as.numeric(to_coloc[,paste0("or.",trait2)]))[tmp_or2!=1],varbeta=((as.numeric(to_coloc[,paste0("se.",trait2)]))^2)[tmp_or2!=1],N=N_trait2, MAF=as.numeric(MAF_trait2)[tmp_or2!=1])
    
    FUMA_raw = coloc.abf(dataset1 = dataset1,
                         dataset2 = dataset2)
    PLACO = as.data.frame(vroom(paste0("/home/yanyq/share_genetics/result/PLACO/PLACO_",trait1,"-",trait2,".gz")))
    
    coloc_SNP = PLACO[PLACO$snpid%in%FUMA_raw$results$snp,]
    top_SNP = coloc_SNP$snpid[which.min(coloc_SNP$p.placo)]
    best_SNP = FUMA_raw$results$snp[which.max(FUMA_raw$results$SNP.PP.H4)]
    
    FUMA_coloc_top_best_error$PLACO_topSNP[i] = top_SNP
    FUMA_coloc_top_best_error$COLOC_bestSNP[i] = best_SNP
    
    FUMA_coloc_top_best_error$top_P[i] = min(coloc_SNP$p.placo)
    if(any(PLACO$snpid==best_SNP)){
      FUMA_coloc_top_best_error$COLOC_P[i] = PLACO$p.placo[PLACO$snpid==best_SNP]
    }
    
    FUMA_coloc_top_best_error$best_H4[i] = max(FUMA_raw$results$SNP.PP.H4)
    if(any(FUMA_raw$results$snp==top_SNP)){
      FUMA_coloc_top_best_error$top_H4[i] = FUMA_raw$results$SNP.PP.H4[FUMA_raw$results$snp==top_SNP]
    }
  }
  which(FUMA_coloc_top_best_error$COLOC_bestSNP!=FUMA_coloc_error$snp)
  all_FUMA_coloc_top_best = rbind(all_FUMA_coloc_top_best, FUMA_coloc_top_best_error)
  nrow(all_FUMA_coloc_top_best)==nrow(FUMA_coloc)
  length(which(all_FUMA_coloc_top_best$PLACO_topSNP==all_FUMA_coloc_top_best$COLOC_bestSNP&FUMA_coloc$PP.H4.abf>0.7))
  write_tsv(all_FUMA_coloc_top_best, "/home/yanyq/share_genetics/result/coloc/all_FUMA_coloc_top_best_new")
}
{
  rm(list = ls())
  sampleSize = read.table("/home/yanyq/share_genetics/data/sampleSize",header = F)
  
  all_MAGMA_coloc_top_best = read_rds("/home/yanyq/share_genetics/result/coloc_MAGMA/all_MAGMA_coloc_top_best")
  all_MAGMA_coloc_top_best = do.call(rbind, all_MAGMA_coloc_top_best)
  all_MAGMA_coloc_top_best = all_MAGMA_coloc_top_best[!is.na(all_MAGMA_coloc_top_best$COLOC_bestSNP),]
  
  MAGMA_coloc = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/coloc_MAGMA/summary/all"))
  # MAGMA_coloc_error = MAGMA_coloc[(nrow(all_MAGMA_coloc_top_best)+1):nrow(MAGMA_coloc),]
  MAGMA_coloc_error = MAGMA_coloc[!paste0(MAGMA_coloc$traits,":",MAGMA_coloc$snp)%in%paste0(all_MAGMA_coloc_top_best$traits,":",all_MAGMA_coloc_top_best$COLOC_bestSNP),]
  
  MAGMA_coloc_top_best_error = as.data.frame(matrix(nrow = nrow(MAGMA_coloc_error), ncol = 7))
  colnames(MAGMA_coloc_top_best_error) = c("traits", "PLACO_topSNP","top_P","COLOC_P", "COLOC_bestSNP","top_H4","best_H4")
  MAGMA_coloc_top_best_error$traits = MAGMA_coloc_error$traits
  
  files = c("BCC-CESC_locus_3","BCC-CESC_locus_7",
            "CESC-BRCA_locus_5","CESC-BRCA_locus_15","CESC-BRCA_locus_16",
            "CESC-CRC_locus_3",
            "CESC-OV_locus_3",
            "CESC-PRAD_locus_6" ,
            "LL-PRAD_locus_34",
            "CESC-SCC_locus_1","CESC-SCC_locus_2","CESC-SKCM_locus_5","CESC-SKCM_locus_6" )
  # files = c("CESC-SCC_locus_1","CESC-SCC_locus_2","CESC-SKCM_locus_5","CESC-SKCM_locus_6")
  for(i in 1:nrow(MAGMA_coloc_error)){
    to_coloc = readRDS(paste0("/home/yanyq/share_genetics/result/coloc_MAGMA/error/",files[i]))
    traits = MAGMA_coloc_error$traits[i]
    trait1 = str_split(traits, "-")[[1]][1]
    trait2 = str_split(traits, "-")[[1]][2]
    
    MAF_trait1 = to_coloc[,paste0("EURaf.",trait1)]
    MAF_trait2 = to_coloc[,paste0("EURaf.",trait2)]
    
    N_trait1 = sampleSize$V2[sampleSize$V1==trait1]
    N_trait2 = sampleSize$V2[sampleSize$V1==trait2]
    
    # 检查是否有beta为0的
    tmp_or1 = as.numeric(to_coloc[,paste0("or.",trait1)])
    tmp_or2 = as.numeric(to_coloc[,paste0("or.",trait2)])
    dataset1 = list(pvalues=as.numeric(to_coloc[,paste0("pval.",trait1)])[tmp_or1!=1], type="cc",snp=to_coloc[,"snpid"][tmp_or1!=1],beta=log(as.numeric(to_coloc[,paste0("or.",trait1)]))[tmp_or1!=1],varbeta=((as.numeric(to_coloc[,paste0("se.",trait1)]))^2)[tmp_or1!=1],N=N_trait1, MAF=as.numeric(MAF_trait1)[tmp_or1!=1])
    dataset2 = list(pvalues=as.numeric(to_coloc[,paste0("pval.",trait2)])[tmp_or2!=1], type="cc",snp=to_coloc[,"snpid"][tmp_or2!=1],beta=log(as.numeric(to_coloc[,paste0("or.",trait2)]))[tmp_or2!=1],varbeta=((as.numeric(to_coloc[,paste0("se.",trait2)]))^2)[tmp_or2!=1],N=N_trait2, MAF=as.numeric(MAF_trait2)[tmp_or2!=1])
    
    MAGMA_raw = coloc.abf(dataset1 = dataset1,
                         dataset2 = dataset2)
    PLACO = as.data.frame(vroom(paste0("/home/yanyq/share_genetics/result/PLACO/PLACO_",trait1,"-",trait2,".gz")))
    
    coloc_SNP = PLACO[PLACO$snpid%in%MAGMA_raw$results$snp,]
    top_SNP = coloc_SNP$snpid[which.min(coloc_SNP$p.placo)]
    best_SNP = MAGMA_raw$results$snp[which.max(MAGMA_raw$results$SNP.PP.H4)]
    
    MAGMA_coloc_top_best_error$PLACO_topSNP[i] = top_SNP
    MAGMA_coloc_top_best_error$COLOC_bestSNP[i] = best_SNP
    
    MAGMA_coloc_top_best_error$top_P[i] = min(coloc_SNP$p.placo)
    if(any(PLACO$snpid==best_SNP)){
      MAGMA_coloc_top_best_error$COLOC_P[i] = PLACO$p.placo[PLACO$snpid==best_SNP]
    }
    
    MAGMA_coloc_top_best_error$best_H4[i] = max(MAGMA_raw$results$SNP.PP.H4)
    if(any(MAGMA_raw$results$snp==top_SNP)){
      MAGMA_coloc_top_best_error$top_H4[i] = MAGMA_raw$results$SNP.PP.H4[MAGMA_raw$results$snp==top_SNP]
    }
  }
  which(MAGMA_coloc_top_best_error$COLOC_bestSNP!=MAGMA_coloc_error$snp)
  all_MAGMA_coloc_top_best = rbind(all_MAGMA_coloc_top_best, MAGMA_coloc_top_best_error)
  nrow(all_MAGMA_coloc_top_best)==nrow(MAGMA_coloc)
  length(which(all_MAGMA_coloc_top_best$PLACO_topSNP==all_MAGMA_coloc_top_best$COLOC_bestSNP&MAGMA_coloc$PP.H4.abf>0.7))
  write_tsv(all_MAGMA_coloc_top_best, "/home/yanyq/share_genetics/result/coloc_MAGMA/all_MAGMA_coloc_top_best_new")
}