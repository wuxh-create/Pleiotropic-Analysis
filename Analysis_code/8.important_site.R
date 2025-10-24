library(data.table)
library(bigreadr)
library(readr)
setwd("/home/yanyq/share_genetics/result/PLACO/")
files = list.files("/home/yanyq/share_genetics/result/PLACO/")
files = files[grep("sig_",files)]
# files = files[-c(1:4,50,6,15,24:31)]

# gwas P值在一个性状中显著，在另一个不显著的多效SNP-----------------------------
all = list()
for(i in files){
  tmp = fread(i)
  if(nrow(tmp)>0){
    tmp = tmp[,-c(11:14)]
    colnames(tmp) = c("snpid", "hg19chr", "bp", "a1", "a2", "or.trait1",  "se.trait1", "pval.trait1", "EURaf.trait1", "zscore.trait1","or.trait2",  "se.trait2", "pval.trait2", "EURaf.trait2", "zscore.trait2","T.placo", "p.placo")
    traits = gsub("sig_","",i)
    tmp$trait1 = strsplit(traits,"-")[[1]][1]
    tmp$trait2 = strsplit(traits,"-")[[1]][2]
  }
  # if(grepl("UCEC",i)&(!grepl("kidney",i))){
  #   tmp = fread(i)
  #   if(nrow(tmp)>0){
  #     tmp = tmp[,c(1:10,15:17,19:22)]
  #     colnames(tmp) = c("snpid", "hg19chr", "bp", "a1", "a2", "or.trait1",  "se.trait1", "pval.trait1", "EURaf.trait1", "zscore.trait1","or.trait2",  "se.trait2", "pval.trait2", "EURaf.trait2", "zscore.trait2","T.placo", "p.placo")
  #     traits = gsub("sig_","",i)
  #     tmp$trait1 = strsplit(traits,"-")[[1]][1]
  #     tmp$trait2 = strsplit(traits,"-")[[1]][2]
  #   }
  #   
  # }else if((!grepl("UCEC",i))&grepl("kidney-",i)){
  #   tmp = fread(i)
  #   if(nrow(tmp)>0){
  #     tmp$EURaf.kidney = NA
  #     tmp = tmp[,c(1:8,21,9,14:20)]
  #     colnames(tmp) = c("snpid", "hg19chr", "bp", "a1", "a2", "or.trait1",  "se.trait1", "pval.trait1", "EURaf.trait1", "zscore.trait1","or.trait2",  "se.trait2", "pval.trait2", "EURaf.trait2", "zscore.trait2","T.placo", "p.placo")
  #     traits = gsub("sig_","",i)
  #     tmp$trait1 = strsplit(traits,"-")[[1]][1]
  #     tmp$trait2 = strsplit(traits,"-")[[1]][2]
  #   }
  # }else if((!grepl("UCEC",i))&grepl("-kidney",i)){
  #   tmp = fread(i)
  #   if(nrow(tmp)>0){
  #     tmp$EURaf.kidney = NA
  #     tmp = tmp[,c(1:10,15:17,21,18:20)]
  #     colnames(tmp) = c("snpid", "hg19chr", "bp", "a1", "a2", "or.trait1",  "se.trait1", "pval.trait1", "EURaf.trait1", "zscore.trait1","or.trait2",  "se.trait2", "pval.trait2", "EURaf.trait2", "zscore.trait2","T.placo", "p.placo")
  #     traits = gsub("sig_","",i)
  #     tmp$trait1 = strsplit(traits,"-")[[1]][1]
  #     tmp$trait2 = strsplit(traits,"-")[[1]][2]
  #   }
  # }else if(grepl("UCEC",i)&(grepl("kidney",i))){
  #   tmp = fread(i)
  #   if(nrow(tmp)>0){
  #     tmp$EURaf.kidney = NA
  #     tmp = tmp[,c(1:8,22,9,14:16,18:21)]
  #     colnames(tmp) = c("snpid", "hg19chr", "bp", "a1", "a2", "or.trait1",  "se.trait1", "pval.trait1", "EURaf.trait1", "zscore.trait1","or.trait2",  "se.trait2", "pval.trait2", "EURaf.trait2", "zscore.trait2","T.placo", "p.placo")
  #     traits = gsub("sig_","",i)
  #     tmp$trait1 = strsplit(traits,"-")[[1]][1]
  #     tmp$trait2 = strsplit(traits,"-")[[1]][2]
  #   }
  # }else{
  #   tmp = fread(i)
  #   if(nrow(tmp)>0){
  #     tmp = tmp[,-c(11:14)]
  #     colnames(tmp) = c("snpid", "hg19chr", "bp", "a1", "a2", "or.trait1",  "se.trait1", "pval.trait1", "EURaf.trait1", "zscore.trait1","or.trait2",  "se.trait2", "pval.trait2", "EURaf.trait2", "zscore.trait2","T.placo", "p.placo")
  #     traits = gsub("sig_","",i)
  #     tmp$trait1 = strsplit(traits,"-")[[1]][1]
  #     tmp$trait2 = strsplit(traits,"-")[[1]][2]
  #   }
  # }
  if(nrow(tmp)>0){
    nsnps = fread(paste0("/home/yanyq/share_genetics/result/FUMA/",traits,"/snps.txt"))
    colnames(nsnps)[2] = "snpid"
    tmp = dplyr::left_join(tmp,nsnps,by = "snpid")
    all[[i]] = tmp
  }
}
all = do.call(rbind,all)
all$sig_GWAS = 0 # SNP在GWAS中显著的数目0,1,2
all$sig_GWAS[all$pval.trait1<5e-8|all$pval.trait2<5e-8] = 1
all$sig_GWAS[all$pval.trait1<5e-8&all$pval.trait2<5e-8] = 2
all = all[,-c("gwasP","chr","pos", "non_effect_allele", "effect_allele")]
all_func = all[all$func%in%c("exonic","ncRNA_exonic","UTR3","UTR5"),]
write_tsv(all,"/home/yanyq/share_genetics/result/PLACO/all")

# 注释差异表达基因，源于GEPIA数据库---------------------------------------------
all = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/PLACO/all"))
traits = c("AML","BLCA","BRCA","CESC","CRC","DLBC", "ESCA","HNSC", "kidney","LIHC",
           "lung","OV","PAAD","PRAD","SKCM", "STAD", "TEST", "THCA", "UCEC")
# traits = unique(c(all$trait1,all$trait2))
all[,c("trait1.ENSG",	"trait1.Median_Tumor","trait1.Median_Normal","trait1.Log2FC","trait1.adjP",
       "trait2.ENSG",	"trait2.Median_Tumor","trait2.Median_Normal","trait2.Log2FC","trait2.adjP")] = NA
all = as.data.frame(all)
setwd("/home/yanyq/share_genetics/data/GEPIA_DEG/")
for(i in traits){
  if(file.exists(paste0(i,".txt"))){
    DEG = fread(paste0(i,".txt"))
    DEG = DEG[!duplicated(DEG$V1),]
    colnames(DEG) = c("nearestGene","trait1.ENSG",	"trait1.Median_Tumor","trait1.Median_Normal","trait1.Log2FC","trait1.adjP")
    tmp = all[all$trait1==i,1:35]
    if(nrow(tmp)>0){
      tmp = dplyr::left_join(tmp,DEG,by = "nearestGene")
      if(nrow(all[all$trait1==i,])==nrow(tmp)){
        all[all$trait1==i,36:40]=tmp[,36:40]
      }else{
        print(paste0("error:",i))
      }
    }
    colnames(DEG) = c("nearestGene","trait2.ENSG",	"trait2.Median_Tumor","trait2.Median_Normal","trait2.Log2FC","trait2.adjP")
    tmp = all[all$trait2==i,1:35]
    if(nrow(tmp)>0){
      tmp = dplyr::left_join(tmp,DEG,by = "nearestGene")
      if(nrow(all[all$trait2==i,])==nrow(tmp)){
        all[all$trait2==i,41:45]=tmp[,36:40]
      }else{
        print(paste0("error:",i))
      }
    }
  }
  if(i=="kidney"){
    DEG_KICH = fread(paste0("KICH",".txt"))
    DEG_KICH = DEG_KICH[!duplicated(DEG_KICH$V1),]
    colnames(DEG_KICH) = c("nearestGene","KICH.ENSG",	"KICH.Median_Tumor","KICH.Median_Normal","KICH.Log2FC","KICH.adjP")
    DEG_KIRC = fread(paste0("KIRC",".txt"))
    DEG_KIRC = DEG_KIRC[!duplicated(DEG_KIRC$V1),]
    colnames(DEG_KIRC) = c("nearestGene","KIRC.ENSG",	"KIRC.Median_Tumor","KIRC.Median_Normal","KIRC.Log2FC","KIRC.adjP")
    DEG_KIRP = fread(paste0("KIRP",".txt"))
    DEG_KIRP = DEG_KIRP[!duplicated(DEG_KIRP$V1),]
    colnames(DEG_KIRP) = c("nearestGene","KIRP.ENSG",	"KIRP.Median_Tumor","KIRP.Median_Normal","KIRP.Log2FC","KIRP.adjP")
    DEG = merge(DEG_KICH,DEG_KIRC,by = "nearestGene",all=TRUE)
    DEG = merge(DEG,DEG_KIRP,by = "nearestGene",all=TRUE)
    DEG$KICH.ENSG[is.na(DEG$KICH.ENSG)] = DEG$KIRC.ENSG[is.na(DEG$KICH.ENSG)]
    DEG$KICH.ENSG[is.na(DEG$KICH.ENSG)] = DEG$KIRP.ENSG[is.na(DEG$KICH.ENSG)]
    DEG = DEG[,-c(7,12)]
    DEG$KICH.Median_Tumor = paste0(DEG$KICH.Median_Tumor,"/",DEG$KIRC.Median_Tumor,"/",DEG$KIRP.Median_Tumor)
    DEG$KICH.Median_Normal = paste0(DEG$KICH.Median_Normal,"/",DEG$KIRC.Median_Normal,"/",DEG$KIRP.Median_Normal)
    DEG$KICH.Log2FC = paste0(DEG$KICH.Log2FC,"/",DEG$KIRC.Log2FC,"/",DEG$KIRP.Log2FC)
    DEG$KICH.adjP = paste0(DEG$KICH.adjP,"/",DEG$KIRC.adjP,"/",DEG$KIRP.adjP)
    DEG = DEG[,1:6]
    colnames(DEG) = c("nearestGene","trait1.ENSG",	"trait1.Median_Tumor","trait1.Median_Normal","trait1.Log2FC","trait1.adjP")
    tmp = all[all$trait1==i,1:35]
    if(nrow(tmp)>0){
      tmp = dplyr::left_join(tmp,DEG,by = "nearestGene")
      if(nrow(all[all$trait1==i,])==nrow(tmp)){
        all[all$trait1==i,36:40]=tmp[,36:40]
      }else{
        print(paste0("error:",i))
      }
    }
    colnames(DEG) = c("nearestGene","trait2.ENSG",	"trait2.Median_Tumor","trait2.Median_Normal","trait2.Log2FC","trait2.adjP")
    tmp = all[all$trait2==i,1:35]
    if(nrow(tmp)>0){
      tmp = dplyr::left_join(tmp,DEG,by = "nearestGene")
      if(nrow(all[all$trait2==i,])==nrow(tmp)){
        all[all$trait2==i,41:45]=tmp[,36:40]
      }else{
        print(paste0("error:",i))
      }
    }
  }
  if(i=="lung"){
    DEG_LUAD = fread(paste0("LUAD",".txt"))
    DEG_LUAD = DEG_LUAD[!duplicated(DEG_LUAD$V1),]
    colnames(DEG_LUAD) = c("nearestGene","LUAD.ENSG",	"LUAD.Median_Tumor","LUAD.Median_Normal","LUAD.Log2FC","LUAD.adjP")
    DEG_LUSC = fread(paste0("LUSC",".txt"))
    DEG_LUSC = DEG_LUSC[!duplicated(DEG_LUSC$V1),]
    colnames(DEG_LUSC) = c("nearestGene","LUSC.ENSG",	"LUSC.Median_Tumor","LUSC.Median_Normal","LUSC.Log2FC","LUSC.adjP")
    DEG = merge(DEG_LUAD,DEG_LUSC,by = "nearestGene",all=TRUE)
    DEG$LUAD.ENSG[is.na(DEG$LUAD.ENSG)] = DEG$LUSC.ENSG[is.na(DEG$LUAD.ENSG)]
    DEG = DEG[,-7]
    DEG$LUAD.Median_Tumor = paste0(DEG$LUAD.Median_Tumor,"/",DEG$LUSC.Median_Tumor)
    DEG$LUAD.Median_Normal = paste0(DEG$LUAD.Median_Normal,"/",DEG$LUSC.Median_Normal)
    DEG$LUAD.Log2FC = paste0(DEG$LUAD.Log2FC,"/",DEG$LUSC.Log2FC)
    DEG$LUAD.adjP = paste0(DEG$LUAD.adjP,"/",DEG$LUSC.adjP)
    DEG = DEG[,1:6]
    colnames(DEG) = c("nearestGene","trait1.ENSG",	"trait1.Median_Tumor","trait1.Median_Normal","trait1.Log2FC","trait1.adjP")
    tmp = all[all$trait1==i,1:35]
    if(nrow(tmp)>0){
      tmp = dplyr::left_join(tmp,DEG,by = "nearestGene")
      if(nrow(all[all$trait1==i,])==nrow(tmp)){
        all[all$trait1==i,36:40]=tmp[,36:40]
      }else{
        print(paste0("error:",i))
      }
    }
    colnames(DEG) = c("nearestGene","trait2.ENSG",	"trait2.Median_Tumor","trait2.Median_Normal","trait2.Log2FC","trait2.adjP")
    tmp = all[all$trait2==i,1:35]
    if(nrow(tmp)>0){
      tmp = dplyr::left_join(tmp,DEG,by = "nearestGene")
      if(nrow(all[all$trait2==i,])==nrow(tmp)){
        all[all$trait2==i,41:45]=tmp[,36:40]
      }else{
        print(paste0("error:",i))
      }
    }
  }
  if(i=="CRC"){
    DEG_COAD = fread(paste0("COAD",".txt"))
    DEG_COAD = DEG_COAD[!duplicated(DEG_COAD$V1),]
    colnames(DEG_COAD) = c("nearestGene","COAD.ENSG",	"COAD.Median_Tumor","COAD.Median_Normal","COAD.Log2FC","COAD.adjP")
    DEG_READ = fread(paste0("READ",".txt"))
    DEG_READ = DEG_READ[!duplicated(DEG_READ$V1),]
    colnames(DEG_READ) = c("nearestGene","READ.ENSG",	"READ.Median_Tumor","READ.Median_Normal","READ.Log2FC","READ.adjP")
    DEG = merge(DEG_COAD,DEG_READ,by = "nearestGene",all=TRUE)
    DEG$COAD.ENSG[is.na(DEG$COAD.ENSG)] = DEG$READ.ENSG[is.na(DEG$COAD.ENSG)]
    DEG = DEG[,-7]
    DEG$COAD.Median_Tumor = paste0(DEG$COAD.Median_Tumor,"/",DEG$READ.Median_Tumor)
    DEG$COAD.Median_Normal = paste0(DEG$COAD.Median_Normal,"/",DEG$READ.Median_Normal)
    DEG$COAD.Log2FC = paste0(DEG$COAD.Log2FC,"/",DEG$READ.Log2FC)
    DEG$COAD.adjP = paste0(DEG$COAD.adjP,"/",DEG$READ.adjP)
    DEG = DEG[,1:6]
    colnames(DEG) = c("nearestGene","trait1.ENSG",	"trait1.Median_Tumor","trait1.Median_Normal","trait1.Log2FC","trait1.adjP")
    tmp = all[all$trait1==i,1:35]
    if(nrow(tmp)>0){
      tmp = dplyr::left_join(tmp,DEG,by = "nearestGene")
      if(nrow(all[all$trait1==i,])==nrow(tmp)){
        all[all$trait1==i,36:40]=tmp[,36:40]
      }else{
        print(paste0("error:",i))
      }
    }
    colnames(DEG) = c("nearestGene","trait2.ENSG",	"trait2.Median_Tumor","trait2.Median_Normal","trait2.Log2FC","trait2.adjP")
    tmp = all[all$trait2==i,1:35]
    if(nrow(tmp)>0){
      tmp = dplyr::left_join(tmp,DEG,by = "nearestGene")
      if(nrow(all[all$trait2==i,])==nrow(tmp)){
        all[all$trait2==i,41:45]=tmp[,36:40]
      }else{
        print(paste0("error:",i))
      }
    }
  }
}
write_tsv(all,"/home/yanyq/share_genetics/result/PLACO/all_DEG")

# 生存相关SNP，源于SUMMER-------------------------------------------------------
all = as.data.frame(fread2("/home/yanyq/share_genetics/result/PLACO/all_DEG"))
write_tsv(as.data.frame(unique(all$snpid[all$trait1=="BLCA"|all$trait2=="BLCA"])), "~/snps.txt", col_names = F)
surv = as.data.frame(fread2("/home/yanyq/share_genetics/data/SUMMER/UKB-Bladder_cancer.txt"))
surv_OS = surv[surv$P_value_OS<0.05,]
surv_CSS = surv[surv$P_value_CSS<0.05,]
surv = rbind(surv_OS,surv_CSS)
surv = unique(surv)
all$traits = paste0(all$trait1,"-",all$trait2)
all$SNP = all$snpid
all = dplyr::left_join(all,surv,by = "SNP")
all[!grepl("BLCA",all$traits),48:59]=NA
{
  write_tsv(as.data.frame(unique(all$snpid[all$trait1=="BRCA"|all$trait2=="BRCA"])), "~/snps.txt", col_names = F)
  surv = as.data.frame(fread2("/home/yanyq/share_genetics/data/SUMMER/UKB-Breast_cancer.txt"))
  surv_OS = surv[surv$P_value_OS<0.05,]
  surv_CSS = surv[surv$P_value_CSS<0.05,]
  surv = rbind(surv_OS,surv_CSS)
  surv = unique(surv)
  colnames(surv) = paste0("another",colnames(surv))
  colnames(surv)[3] = "SNP"
  all = dplyr::left_join(all,surv,by = "SNP")
  all[!grepl("BRCA",all$traits),60:71]=NA
  tmp = which((is.na(all$P_value_CSS))&(!is.na(all$anotherP_value_CSS)))
  all[tmp,48:59] = all[tmp,60:71]
  all[tmp,60:71] = NA
  length(unique(all$SNP[(grepl("Breast_cancer",all$Cancer)|grepl("Breast_cancer",all$anotherCancer))&(!is.na(all$P_value_CSS|!is.na(all$anotherP_value_CSS)))]))
}
{
  write_tsv(as.data.frame(unique(all$snpid[all$trait1=="CRC"|all$trait2=="CRC"])), "~/snps.txt", col_names = F)
  surv = fread2("/home/yanyq/share_genetics/data/SUMMER/UKB-Colorectal_cancer.txt")
  surv_OS = surv[surv$P_value_OS<0.05,]
  surv_CSS = surv[surv$P_value_CSS<0.05,]
  surv = rbind(surv_OS,surv_CSS)
  surv = unique(surv)
  colnames(surv) = paste0("another",colnames(surv))
  colnames(surv)[3] = "SNP"
  all_tmp = all[grep("CRC",all$traits),]
  all_tmp[!is.na(all_tmp$anotherP_value_CSS),]
  all_tmp = dplyr::left_join(all_tmp[,1:59],surv,by = "SNP")
  tmp = which((is.na(all_tmp$P_value_CSS))&(!is.na(all_tmp$anotherP_value_CSS)))
  all_tmp[tmp,48:59] = all_tmp[tmp,60:71]
  all_tmp[tmp,60:71] = NA
  all[grep("CRC",all$traits),] = all_tmp
  length(unique(all$SNP[(grepl("Colorectal_cancer",all$Cancer)|grepl("Colorectal_cancer",all$anotherCancer))&(!is.na(all$P_value_CSS|!is.na(all$anotherP_value_CSS)))]))
}
{
  write_tsv(as.data.frame(unique(all$snpid[all$trait1=="ESCA"|all$trait2=="ESCA"])), "~/snps.txt", col_names = F)
  surv = fread2("/home/yanyq/share_genetics/data/SUMMER/UKB-Esophagus_cancer.txt")
  surv_OS = surv[surv$P_value_OS<0.05,]
  surv_CSS = surv[surv$P_value_CSS<0.05,]
  surv = rbind(surv_OS,surv_CSS)
  surv = unique(surv)
  colnames(surv) = paste0("another",colnames(surv))
  colnames(surv)[3] = "SNP"
  all_tmp = all[grep("ESCA",all$traits),]
  all_tmp[!is.na(all_tmp$anotherP_value_CSS),]
  all_tmp = dplyr::left_join(all_tmp[,1:59],surv,by = "SNP")
  tmp = which((is.na(all_tmp$P_value_CSS))&(!is.na(all_tmp$anotherP_value_CSS)))
  all_tmp[tmp,48:59] = all_tmp[tmp,60:71]
  all_tmp[tmp,60:71] = NA
  all[grep("ESCA",all$traits),] = all_tmp
  length(unique(all$SNP[(grepl("Esophagus_cancer",all$Cancer)|grepl("Esophagus_cancer",all$anotherCancer))&(!is.na(all$P_value_CSS|!is.na(all$anotherP_value_CSS)))]))
}

{
  write_tsv(as.data.frame(unique(all$snpid[all$trait1=="HNSC"|all$trait2=="HNSC"])), "~/snps.txt", col_names = F)
  surv = fread2("/home/yanyq/share_genetics/data/SUMMER/UKB-Oral_and_pharynx_cancer.txt")
  surv_OS = surv[surv$P_value_OS<0.05,]
  surv_CSS = surv[surv$P_value_CSS<0.05,]
  surv = rbind(surv_OS,surv_CSS)
  surv = unique(surv)
  colnames(surv) = paste0("another",colnames(surv))
  colnames(surv)[3] = "SNP"
  all_tmp = all[grep("HNSC",all$traits),]
  all_tmp[!is.na(all_tmp$anotherP_value_CSS),]
  all_tmp = dplyr::left_join(all_tmp[,1:59],surv,by = "SNP")
  tmp = which((is.na(all_tmp$P_value_CSS))&(!is.na(all_tmp$anotherP_value_CSS)))
  all_tmp[tmp,48:59] = all_tmp[tmp,60:71]
  all_tmp[tmp,60:71] = NA
  all[grep("HNSC",all$traits),] = all_tmp
  length(unique(all$SNP[(grepl("Oral_and_pharynx_cancer",all$Cancer)|grepl("Oral_and_pharynx_cancer",all$anotherCancer))&(!is.na(all$P_value_CSS|!is.na(all$anotherP_value_CSS)))]))
}

{
  write_tsv(as.data.frame(unique(all$snpid[all$trait1=="OV"|all$trait2=="OV"])), "~/snps.txt", col_names = F)
  surv = fread2("/home/yanyq/share_genetics/data/SUMMER/UKB-Ovarian_cancer.txt")
  surv_OS = surv[surv$P_value_OS<0.05,]
  surv_CSS = surv[surv$P_value_CSS<0.05,]
  surv = rbind(surv_OS,surv_CSS)
  surv = unique(surv)
  colnames(surv) = paste0("another",colnames(surv))
  colnames(surv)[3] = "SNP"
  all_tmp = all[grep("OV",all$traits),]
  all_tmp[!is.na(all_tmp$anotherP_value_CSS),]
  all_tmp = dplyr::left_join(all_tmp[,1:59],surv,by = "SNP")
  tmp = which((is.na(all_tmp$P_value_CSS))&(!is.na(all_tmp$anotherP_value_CSS)))
  all_tmp[tmp,48:59] = all_tmp[tmp,60:71]
  all_tmp[tmp,60:71] = NA
  all[grep("OV",all$traits),] = all_tmp
  length(unique(all$SNP[(grepl("Ovarian_cancer",all$Cancer)|grepl("Ovarian_cancer",all$anotherCancer))&(!is.na(all$P_value_CSS|!is.na(all$anotherP_value_CSS)))]))
}
{
  write_tsv(as.data.frame(unique(all$snpid[all$trait1=="PAAD"|all$trait2=="PAAD"])), "~/snps.txt", col_names = F)
  surv = fread2("/home/yanyq/share_genetics/data/SUMMER/UKB-Pancreatic_cancer.txt")
  surv_OS = surv[surv$P_value_OS<0.05,]
  surv_CSS = surv[surv$P_value_CSS<0.05,]
  surv = rbind(surv_OS,surv_CSS)
  surv = unique(surv)
  colnames(surv) = paste0("another",colnames(surv))
  colnames(surv)[3] = "SNP"
  all_tmp = all[grep("PAAD",all$traits),]
  all_tmp[!is.na(all_tmp$anotherP_value_CSS),]
  all_tmp = dplyr::left_join(all_tmp[,1:59],surv,by = "SNP")
  tmp = which((is.na(all_tmp$P_value_CSS))&(!is.na(all_tmp$anotherP_value_CSS)))
  all_tmp[tmp,48:59] = all_tmp[tmp,60:71]
  all_tmp[tmp,60:71] = NA
  all[grep("PAAD",all$traits),] = all_tmp
  length(unique(all$SNP[(grepl("Pancreatic_cancer",all$Cancer)|grepl("Pancreatic_cancer",all$anotherCancer))&(!is.na(all$P_value_CSS|!is.na(all$anotherP_value_CSS)))]))
}
{
  write_tsv(as.data.frame(unique(all$snpid[all$trait1=="PRAD"|all$trait2=="PRAD"])), "~/snps.txt", col_names = F)
  surv = fread2("/home/yanyq/share_genetics/data/SUMMER/UKB-Prostate_cancer.txt")
  surv_OS = surv[surv$P_value_OS<0.05,]
  surv_CSS = surv[surv$P_value_CSS<0.05,]
  surv = rbind(surv_OS,surv_CSS)
  surv = unique(surv)
  colnames(surv) = paste0("another",colnames(surv))
  colnames(surv)[3] = "SNP"
  all_tmp = all[grep("PRAD",all$traits),]
  all_tmp[!is.na(all_tmp$anotherP_value_CSS),]
  all_tmp = dplyr::left_join(all_tmp[,1:59],surv,by = "SNP")
  tmp = which((is.na(all_tmp$P_value_CSS))&(!is.na(all_tmp$anotherP_value_CSS)))
  all_tmp[tmp,48:59] = all_tmp[tmp,60:71]
  all_tmp[tmp,60:71] = NA
  all[grep("PRAD",all$traits),] = all_tmp
  length(unique(all$SNP[(grepl("Prostate_cancer",all$Cancer)|grepl("Prostate_cancer",all$anotherCancer))&(!is.na(all$P_value_CSS|!is.na(all$anotherP_value_CSS)))]))
}
{
  write_tsv(as.data.frame(unique(all$snpid[all$trait1=="kidney"|all$trait2=="kidney"])), "~/snps.txt", col_names = F)
  surv = fread2("/home/yanyq/share_genetics/data/SUMMER/UKB-Renal_cancer.txt")
  surv_OS = surv[surv$P_value_OS<0.05,]
  surv_CSS = surv[surv$P_value_CSS<0.05,]
  surv = rbind(surv_OS,surv_CSS)
  surv = unique(surv)
  colnames(surv) = paste0("another",colnames(surv))
  colnames(surv)[3] = "SNP"
  all_tmp = all[grep("kidney",all$traits),]
  all_tmp[!is.na(all_tmp$anotherP_value_CSS),]
  all_tmp = dplyr::left_join(all_tmp[,1:59],surv,by = "SNP")
  tmp = which((is.na(all_tmp$P_value_CSS))&(!is.na(all_tmp$anotherP_value_CSS)))
  all_tmp[tmp,48:59] = all_tmp[tmp,60:71]
  all_tmp[tmp,60:71] = NA
  all[grep("kidney",all$traits),] = all_tmp
  length(unique(all$SNP[(grepl("Renal_cancer",all$Cancer)|grepl("Renal_cancer",all$anotherCancer))&(!is.na(all$P_value_CSS|!is.na(all$anotherP_value_CSS)))]))
}
{
  write_tsv(as.data.frame(unique(all$snpid[all$trait1=="lung"|all$trait2=="lung"])), "~/snps.txt", col_names = F)
  surv = fread2("/home/yanyq/share_genetics/data/SUMMER/UKB-Lung_cancer.txt")
  surv_OS = surv[surv$P_value_OS<0.05,]
  surv_CSS = surv[surv$P_value_CSS<0.05,]
  surv = rbind(surv_OS,surv_CSS)
  surv = unique(surv)
  colnames(surv) = paste0("another",colnames(surv))
  colnames(surv)[3] = "SNP"
  all_tmp = all[grep("lung",all$traits),]
  all_tmp[!is.na(all_tmp$anotherP_value_CSS),]
  all_tmp = dplyr::left_join(all_tmp[,1:59],surv,by = "SNP")
  tmp = which((is.na(all_tmp$P_value_CSS))&(!is.na(all_tmp$anotherP_value_CSS)))
  all_tmp[tmp,48:59] = all_tmp[tmp,60:71]
  all_tmp[tmp,60:71] = NA
  all[grep("lung",all$traits),] = all_tmp
  length(unique(all$SNP[(grepl("lung_cancer",all$Cancer)|grepl("lung_cancer",all$anotherCancer))&(!is.na(all$P_value_CSS|!is.na(all$anotherP_value_CSS)))]))
}
{
  write_tsv(as.data.frame(unique(all$snpid[all$trait1=="STAD"|all$trait2=="STAD"])), "~/snps.txt", col_names = F)
  all_tmp[all_tmp$SNP%in%surv$SNP,]
  surv = fread2("/home/yanyq/share_genetics/data/SUMMER/UKB-Gastric_cancer.txt")
  surv_OS = surv[surv$P_value_OS<0.05,]
  surv_CSS = surv[surv$P_value_CSS<0.05,]
  surv = rbind(surv_OS,surv_CSS)
  surv = unique(surv)
  colnames(surv) = paste0("another",colnames(surv))
  colnames(surv)[3] = "SNP"
  all_tmp = all[grep("STAD",all$traits),]
  all_tmp[!is.na(all_tmp$anotherP_value_CSS),]
  all_tmp = dplyr::left_join(all_tmp[,1:59],surv,by = "SNP")
  tmp = which((is.na(all_tmp$P_value_CSS))&(!is.na(all_tmp$anotherP_value_CSS)))
  all_tmp[tmp,48:59] = all_tmp[tmp,60:71]
  all_tmp[tmp,60:71] = NA
  all[grep("STAD",all$traits),] = all_tmp
  length(unique(all$SNP[(grepl("Gastric_cancer",all$Cancer)|grepl("Gastric_cancer",all$anotherCancer))&(!is.na(all$P_value_CSS|!is.na(all$anotherP_value_CSS)))]))
}

{
  write_tsv(as.data.frame(unique(all$snpid[all$trait1=="SKCM"|all$trait2=="SKCM"])), "~/snps.txt", col_names = F)
  surv = fread2("/home/yanyq/share_genetics/data/SUMMER/UKB-Skin_Melanoma.txt")
  surv_OS = surv[surv$P_value_OS<0.05,]
  surv_CSS = surv[surv$P_value_CSS<0.05,]
  surv = rbind(surv_OS,surv_CSS)
  surv = unique(surv)
  colnames(surv) = paste0("another",colnames(surv))
  colnames(surv)[3] = "SNP"
  all_tmp = all[grep("SKCM",all$traits),]
  all_tmp[!is.na(all_tmp$anotherP_value_CSS),]
  all_tmp = dplyr::left_join(all_tmp[,1:59],surv,by = "SNP")
  tmp = which((is.na(all_tmp$P_value_CSS))&(!is.na(all_tmp$anotherP_value_CSS)))
  all_tmp[tmp,48:59] = all_tmp[tmp,60:71]
  all_tmp[tmp,60:71] = NA
  all[grep("SKCM",all$traits),] = all_tmp
  length(unique(all$SNP[(grepl("Skin_Melanoma",all$Cancer)|grepl("Skin_Melanoma",all$anotherCancer))&(!is.na(all$P_value_CSS|!is.na(all$anotherP_value_CSS)))]))
}
{
  write_tsv(as.data.frame(unique(all$snpid[all$trait1=="THCA"|all$trait2=="THCA"])), "~/snps.txt", col_names = F)
  surv = fread2("/home/yanyq/share_genetics/data/SUMMER/UKB-Thyroid_cancer.txt")
  surv_OS = surv[surv$P_value_OS<0.05,]
  surv_CSS = surv[surv$P_value_CSS<0.05,]
  surv = rbind(surv_OS,surv_CSS)
  surv = unique(surv)
  colnames(surv) = paste0("another",colnames(surv))
  colnames(surv)[3] = "SNP"
  all_tmp = all[grep("THCA",all$traits),]
  all_tmp[!is.na(all_tmp$anotherP_value_CSS),]
  all_tmp = dplyr::left_join(all_tmp[,1:59],surv,by = "SNP")
  tmp = which((is.na(all_tmp$P_value_CSS))&(!is.na(all_tmp$anotherP_value_CSS)))
  all_tmp[tmp,48:59] = all_tmp[tmp,60:71]
  all_tmp[tmp,60:71] = NA
  all[grep("THCA",all$traits),] = all_tmp
  length(unique(all$SNP[(grepl("Thyroid_cancer",all$Cancer)|grepl("Thyroid_cancer",all$anotherCancer))&(!is.na(all$P_value_CSS|!is.na(all$anotherP_value_CSS)))]))
}
{
  write_tsv(as.data.frame(unique(all$snpid[all$trait1=="MM"|all$trait2=="MM"])), "~/snps.txt", col_names = F)
  surv = fread2("/home/yanyq/share_genetics/data/SUMMER/UKB-Multiple_Myeloma.txt")
  surv_OS = surv[surv$P_value_OS<0.05,]
  surv_CSS = surv[surv$P_value_CSS<0.05,]
  surv = rbind(surv_OS,surv_CSS)
  surv = unique(surv)
  colnames(surv) = paste0("another",colnames(surv))
  colnames(surv)[3] = "SNP"
  all_tmp = all[grep("MM",all$traits),]
  all_tmp[!is.na(all_tmp$anotherP_value_CSS),]
  all_tmp = dplyr::left_join(all_tmp[,1:59],surv,by = "SNP")
  tmp = which((is.na(all_tmp$P_value_CSS))&(!is.na(all_tmp$anotherP_value_CSS)))
  all_tmp[tmp,48:59] = all_tmp[tmp,60:71]
  all_tmp[tmp,60:71] = NA
  all[grep("MM",all$traits),] = all_tmp
  length(unique(all$SNP[(grepl("Multiple_Myeloma",all$Cancer)|grepl("Multiple_Myeloma",all$anotherCancer))&(!is.na(all$P_value_CSS|!is.na(all$anotherP_value_CSS)))]))
}
{
  write_tsv(as.data.frame(unique(all$snpid[all$trait1=="LL"|all$trait2=="LL"])), "~/snps.txt", col_names = F)
  surv = fread2("/home/yanyq/share_genetics/data/SUMMER/UKB-Lymphoid_Leukaemia.txt")
  surv_OS = surv[surv$P_value_OS<0.05,]
  surv_CSS = surv[surv$P_value_CSS<0.05,]
  surv = rbind(surv_OS,surv_CSS)
  surv = unique(surv)
  colnames(surv) = paste0("another",colnames(surv))
  colnames(surv)[3] = "SNP"
  all_tmp = all[grep("LL",all$traits),]
  all_tmp[!is.na(all_tmp$anotherP_value_CSS),]
  all_tmp = dplyr::left_join(all_tmp[,1:59],surv,by = "SNP")
  tmp = which((is.na(all_tmp$P_value_CSS))&(!is.na(all_tmp$anotherP_value_CSS)))
  all_tmp[tmp,48:59] = all_tmp[tmp,60:71]
  all_tmp[tmp,60:71] = NA
  all[grep("LL",all$traits),] = all_tmp
  length(unique(all$SNP[(grepl("Lymphoid_Leukaemia",all$Cancer)|grepl("Lymphoid_Leukaemia",all$anotherCancer))&(!is.na(all$P_value_CSS|!is.na(all$anotherP_value_CSS)))]))
}
{
  write_tsv(as.data.frame(unique(all$snpid[all$trait1=="CORP"|all$trait2=="CORP"])), "~/snps.txt", col_names = F)
  surv = fread2("/home/yanyq/share_genetics/data/SUMMER/UKB-Corpus_Uteri.txt")
  surv_OS = surv[surv$P_value_OS<0.05,]
  surv_CSS = surv[surv$P_value_CSS<0.05,]
  surv = rbind(surv_OS,surv_CSS)
  surv = unique(surv)
  colnames(surv) = paste0("another",colnames(surv))
  colnames(surv)[3] = "SNP"
  all_tmp = all[grep("CORP",all$traits),]
  all_tmp[!is.na(all_tmp$anotherP_value_CSS),]
  all_tmp = dplyr::left_join(all_tmp[,1:59],surv,by = "SNP")
  tmp = which((is.na(all_tmp$P_value_CSS))&(!is.na(all_tmp$anotherP_value_CSS)))
  all_tmp[tmp,48:59] = all_tmp[tmp,60:71]
  all_tmp[tmp,60:71] = NA
  all[grep("CORP",all$traits),] = all_tmp
  length(unique(all$SNP[(grepl("Corpus_Uteri",all$Cancer)|grepl("Corpus_Uteri",all$anotherCancer))&(!is.na(all$P_value_CSS|!is.na(all$anotherP_value_CSS)))]))
}
# SNP harmonize
{
  # cancer1
  { 
    # 非回文
    {
      non_palindrome = all[(!(paste0(all$a1,"/",all$a2)%in%c("A/T","T/A","G/C","C/G")))&(!(is.na(all$Cancer))),]
      # OA和EA反了的
      loci = (non_palindrome$a1==non_palindrome$A2&non_palindrome$a2==non_palindrome$A1)
      non_palindrome$A1[loci] = non_palindrome$a1[loci]
      non_palindrome$A2[loci] = non_palindrome$a2[loci]
      non_palindrome$HR_OS[loci] = exp(-log(non_palindrome$HR_OS[loci]))
      non_palindrome$HR_CSS[loci] = exp(-log(non_palindrome$HR_CSS[loci]))
      # 链翻转
      A1_loc = which(non_palindrome$A1=="A")
      T1_loc = which(non_palindrome$A1=="T")
      C1_loc = which(non_palindrome$A1=="C")
      G1_loc = which(non_palindrome$A1=="G")
      A2_loc = which(non_palindrome$A2=="A")
      T2_loc = which(non_palindrome$A2=="T")
      C2_loc = which(non_palindrome$A2=="C")
      G2_loc = which(non_palindrome$A2=="G")
      trans_A1 = non_palindrome$A1
      trans_A2 = non_palindrome$A2
      trans_A1[A1_loc] = "T"
      trans_A1[T1_loc] = "A"
      trans_A1[C1_loc] = "G"
      trans_A1[G1_loc] = "C"
      trans_A2[A2_loc] = "T"
      trans_A2[T2_loc] = "A"
      trans_A2[C2_loc] = "G"
      trans_A2[G2_loc] = "C"
      # 正负链反了，OA和EA没反
      loci = (trans_A1==non_palindrome$A1&trans_A2==non_palindrome$A2)
      non_palindrome$A1[loci] = non_palindrome$a1[loci]
      non_palindrome$A2[loci] = non_palindrome$a2[loci]
      # 正负链反了，且OA和EA反了
      loci = (trans_A1==non_palindrome$A2&trans_A2==non_palindrome$A1)
      non_palindrome$A1[loci] = non_palindrome$a1[loci]
      non_palindrome$A2[loci] = non_palindrome$a2[loci]
      non_palindrome$HR_OS[loci] = exp(-log(non_palindrome$HR_OS[loci]))
      non_palindrome$HR_CSS[loci] = exp(-log(non_palindrome$HR_CSS[loci]))
    }
  }
  all[(!(paste0(all$a1,"/",all$a2)%in%c("A/T","T/A","G/C","C/G")))&(!(is.na(all$Cancer))),] = non_palindrome
  # cancer2
  { 
    # 非回文
    {
      non_palindrome = all[(!(paste0(all$a1,"/",all$a2)%in%c("A/T","T/A","G/C","C/G")))&(!(is.na(all$anotherCancer))),]
      # OA和EA反了的
      loci = (non_palindrome$a1==non_palindrome$anotherA2&non_palindrome$a2==non_palindrome$anotherA1)
      non_palindrome$anotherA1[loci] = non_palindrome$a1[loci]
      non_palindrome$anotherA2[loci] = non_palindrome$a2[loci]
      non_palindrome$anotherHR_OS[loci] = exp(-log(non_palindrome$anotherHR_OS[loci]))
      non_palindrome$anotherHR_CSS[loci] = exp(-log(non_palindrome$anotherHR_CSS[loci]))
      # 链翻转
      A1_loc = which(non_palindrome$anotherA1=="A")
      T1_loc = which(non_palindrome$anotherA1=="T")
      C1_loc = which(non_palindrome$anotherA1=="C")
      G1_loc = which(non_palindrome$anotherA1=="G")
      A2_loc = which(non_palindrome$anotherA2=="A")
      T2_loc = which(non_palindrome$anotherA2=="T")
      C2_loc = which(non_palindrome$anotherA2=="C")
      G2_loc = which(non_palindrome$anotherA2=="G")
      trans_A1 = non_palindrome$anotherA1
      trans_A2 = non_palindrome$anotherA2
      trans_A1[A1_loc] = "T"
      trans_A1[T1_loc] = "A"
      trans_A1[C1_loc] = "G"
      trans_A1[G1_loc] = "C"
      trans_A2[A2_loc] = "T"
      trans_A2[T2_loc] = "A"
      trans_A2[C2_loc] = "G"
      trans_A2[G2_loc] = "C"
      # 正负链反了，OA和EA没反
      loci = (trans_A1==non_palindrome$anotherA1&trans_A2==non_palindrome$anotherA2)
      non_palindrome$anotherA1[loci] = non_palindrome$a1[loci]
      non_palindrome$anotherA2[loci] = non_palindrome$a2[loci]
      # 正负链反了，且OA和EA反了
      loci = (trans_A1==non_palindrome$anotherA2&trans_A2==non_palindrome$anotherA1)
      non_palindrome$anotherA1[loci] = non_palindrome$a1[loci]
      non_palindrome$anotherA2[loci] = non_palindrome$a2[loci]
      non_palindrome$anotherHR_OS[loci] = exp(-log(non_palindrome$anotherHR_OS[loci]))
      non_palindrome$anotherHR_CSS[loci] = exp(-log(non_palindrome$anotherHR_CSS[loci]))
    }
  }
  all[(!(paste0(all$a1,"/",all$a2)%in%c("A/T","T/A","G/C","C/G")))&(!(is.na(all$anotherCancer))),] = non_palindrome
  # {
  #   # 回文，没有eaf，无法确定正负链
  #   # 默认在同一条链上矫正后，仍然存在半数以上SNP在GWAS和生存分析中的beta值相反，且存在同一个SNP的HR_OS和HR_CSS方向相反
  #   # 因此这里不考虑回文的生存SNP
  #   all[((paste0(all$a1,"/",all$a2)%in%c("A/T","T/A","G/C","C/G"))),48:71] = NA
  # }
  all[all$a1!=all$A1&!is.na(all$A1),]
  all[all$a2!=all$A2&!is.na(all$A2),]
  all[all$a1!=all$anotherA1&!is.na(all$anotherA1),]
  all[all$a2!=all$anotherA2&!is.na(all$anotherA2),]
}
write_tsv(all,"/home/yanyq/share_genetics/result/PLACO/all_DEG_surv")

# 药物反应基因------------------------------------------------------------------
setwd("/home/yanyq/share_genetics/data/GDSC/")
drugs = fread2("/home/yanyq/share_genetics/data/GDSC/GDSC_drug_syno.tab")
colnames(drugs)[2] = "Drug Name"
drugs = drugs[!duplicated(drugs$`Drug Name`),]
# TTD靶标数据库ID匹配，先匹配pubchemID再匹配药名，匹配率177/288
TTD_drugs = fread2("/home/yanyq/share_genetics/data/TTD/P1-03-TTD_crossmatching.txt",header = F)
TTD_drugs = TTD_drugs[TTD_drugs$V2=="PUBCHCID",]
colnames(TTD_drugs) = c("TTD_ID","Type","pubchem")
drugs = dplyr::left_join(drugs,TTD_drugs,by = "pubchem")# pubchem匹配
drugs = drugs[!drugs$TTD_ID%in%c("D0MX5B","D0B6KC"),] # 两个pubchemID重复
notMatched = drugs[is.na(drugs$TTD_ID),]
TTD_syno = fread2("/home/yanyq/share_genetics/data/TTD/P1-04-Drug_synonyms.txt",header = F)
TTD_syno = TTD_syno[,c(1,3)]
colnames(TTD_syno) = c("TTD_ID_syno","Drug Name")
notMatched = dplyr::left_join(notMatched,TTD_syno,by = "Drug Name") # 药名匹配
notMatched$TTD_ID = notMatched$TTD_ID_syno
drugs[is.na(drugs$TTD_ID),] = notMatched[,1:8]
# TTD药物靶标信息
drug_target = fread2("/home/yanyq/share_genetics/data/TTD/P1-07-Drug-TargetMapping.txt")
colnames(drug_target)[2] = "TTD_ID"
drug_target = drug_target[drug_target$TTD_ID%in%drugs$TTD_ID,]
target_info = fread2("/home/yanyq/share_genetics/data/TTD/P1-01-TTD_target_download.txt",header = F)
target_info = target_info[target_info$V2=="GENENAME",c(1,3)]
colnames(target_info) = c("TargetID","TargetGeneName")
drug_target = dplyr::left_join(drug_target,target_info,by = "TargetID")
notMatched = drug_target[is.na(drug_target$TargetGeneName),]
target_info = fread2("/home/yanyq/share_genetics/data/TTD/P1-01-TTD_target_download.txt",header = F)
target_info = target_info[target_info$V2=="TARGNAME",c(1,3)]
colnames(target_info) = c("TargetID","TargetGeneName")
notMatched = dplyr::left_join(notMatched[,1:4],target_info,by = "TargetID")
notMatched$TargetGeneName = stringr::str_extract(notMatched$TargetGeneName,"(?<=\\().+?(?=\\))")
drug_target[is.na(drug_target$TargetGeneName),] = notMatched
drug_target_new = data.frame(TTD_ID=unique(drug_target$TTD_ID),TargetGeneName = NA)
for(i in 1:nrow(drug_target_new)){
  tmp_target = drug_target$TargetGeneName[drug_target$TTD_ID==drug_target_new$TTD_ID[i]]
  drug_target_new$TargetGeneName[i] = paste(tmp_target,collapse = ",")
}
drugs = dplyr::left_join(drugs,drug_target_new,by = "TTD_ID")
drug_target_match = as.data.frame(matrix(ncol=2)) # 药物靶标多对多匹配，拆分
colnames(drug_target_match) = c("DrugName","TargetName")
for(i in 1:nrow(drugs)){
  tmp_Gene = unlist(strsplit(c(drugs$targets[i],drugs$TargetGeneName[i]),split = ","))
  tmp_Gene = unlist(strsplit(tmp_Gene,split = ";"))
  tmp_drug_target_match = data.frame(DrugName=drugs$`Drug Name`[i],TargetName=tmp_Gene)
  drug_target_match = rbind(drug_target_match,tmp_drug_target_match)
}
drug_target_match = na.omit(drug_target_match)
drug_target_match$TargetName = trimws(drug_target_match$TargetName,which = "both")
drug_target_match = drug_target_match[drug_target_match$TargetName!="-",]
write_tsv(drug_target_match,"/home/yanyq/share_genetics/data/GDSC/drug_target_match_TDD")

rm(list = ls())
drug_target = fread2("/home/yanyq/share_genetics/data/GDSC/drug_target_match_TDD_revised") # 在GeneCard检索后，同义词转换为标准的symbol并去重
drug_target_unique = data.frame(TargetName = unique(drug_target$TargetName),DrugName = NA)
for(i in 1:nrow(drug_target_unique)){
  tmp = drug_target[drug_target$TargetName==drug_target_unique$TargetName[i],]
  drug_target_unique$DrugName[i] = paste(tmp$DrugName,collapse = ",")
}
colnames(drug_target_unique)[1] = "nearestGene"
all = fread2("/home/yanyq/share_genetics/result/PLACO/all_DEG_surv",header = T)
all = dplyr::left_join(all,drug_target_unique,by = "nearestGene")
write_tsv(all,"/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug")
setwd("/home/yanyq/share_genetics/data/GDSC/")
response_pancan = list()
for(i in c('AML','BLCA','BRCA','CESC','CLL','CRC','DLBC','ESCA','HNSC','kidney',
           'LIHC','lung','MESO','MM','OV','PAAD','PRAD','SKCM','STAD','THCA','UCEC')){
  if(i=="kidney"){
    response_all = fread2("KIRC")
  }else if(i=="lung"){
    response1 = fread2("LUAD")
    response2 = fread2("LUSC")
    response_all = rbind(response1,response2)
  }else{
    response_all = fread2(i)
  }
  response = list()
  for(j in unique(response_all$`Drug Name`)){
    tmp_response = response_all[response_all$`Drug Name`==j,]
    response[[j]] = tmp_response[which.min(tmp_response$IC50),] # 选择IC50最小的细胞系实验
  }
  response = do.call(rbind,response)
  response$trait = i
  response_pancan[[i]] = response
}
write_tsv(do.call(rbind,response_pancan),"/home/yanyq/share_genetics/data/GDSC/Pancan_response_unique")

# eQTLGen-----------------------------------------------------------------------
all = fread2("/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug")
eQTL = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/eQTL/eQTLGen/2019-12-11-cis-eQTLsFDR0.05-ProbeLevel-CohortInfoRemoved-BonferroniAdded.txt"))
all$is.eQTLGen = NA # FUMA注释的基因是否为eQTL gene
all$eQTLGen = NA # SNP调控的eQTL Gene
for(i in unique(all$snpid)){
  genes = eQTL$GeneSymbol[eQTL$SNP==i]
  if(length(genes)>0){
    all$eQTLGen[all$snpid==i] = paste(genes,collapse = ",")
    nearestGene = all$nearestGene[all$snpid==i]
    if(nearestGene[1]%in%genes){
      all$is.eQTLGen[all$snpid==i] = "yes"
    }
  }
}
write_tsv(all,"/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen")

# 注释差异表达eQTL基因，源于GEPIA数据库---------------------------------------------
library(stringr)
library(tidyr)
all = as.data.frame(fread2("/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen"))
traits = unique(c(all$trait1,all$trait2))
all$eQTLGen_trait1_DEG = NA
all$eQTLGen_trait2_DEG = NA
setwd("/home/yanyq/share_genetics/data/GEPIA_DEG/")
flag = FALSE
for(i in traits){
  if(file.exists(paste0(i,".txt"))){
    DEG = fread(paste0(i,".txt"))
    flag = TRUE
  }
  if(i=="kidney"){
    DEG_KICH = fread(paste0("KICH",".txt"))
    DEG_KIRC = fread(paste0("KIRC",".txt"))
    DEG_KIRP = fread(paste0("KIRP",".txt"))
    DEG = merge(DEG_KICH,DEG_KIRC,by = "V1",all=TRUE)
    flag = TRUE
  }
  if(i=="lung"){
    DEG_LUAD = fread(paste0("LUAD",".txt"))
    DEG_LUSC = fread(paste0("LUSC",".txt"))
    DEG = merge(DEG_LUAD,DEG_LUSC,by = "V1",all=TRUE)
    flag = TRUE
  }
  if(i=="CRC"){
    DEG_COAD = fread(paste0("COAD",".txt"))
    DEG_READ = fread(paste0("READ",".txt"))
    DEG = merge(DEG_COAD,DEG_READ,by = "V1",all=TRUE)
    flag = TRUE
  }
  
  tmp_all = all[all$trait1==i,]
  if(nrow(tmp_all)>0&flag){
    num_eQTLGene = max(str_count(tmp_all$eQTLGen,","),na.rm = T)+1 # 拆分eQTLGen列，列数为eQTLGen数目最大的
    tmp_all = tidyr::separate(data = tmp_all,
                              col = eQTLGen,
                              sep = ",",
                              into = as.character(1:num_eQTLGene)) 
    for(j in 1:num_eQTLGene){
      tmp_all[tmp_all[,c(as.character(j))]%in%DEG$V1==FALSE,as.character(j)] = NA # 不在DEG里的eQTLGen用NA表示
    }
    tmp_all = tmp_all%>%unite(eQTLGen_DEG,as.character(1:num_eQTLGene), sep = ",", na.rm = TRUE)
    all$eQTLGen_trait1_DEG[all$trait1==i] = tmp_all$eQTLGen_DEG
  }
  
  tmp_all = all[all$trait2==i,]
  if(nrow(tmp_all)>0&flag){
    num_eQTLGene = max(str_count(tmp_all$eQTLGen,","),na.rm = T)+1 # 拆分eQTLGen列，列数为eQTLGen数目最大的
    tmp_all = tidyr::separate(data = tmp_all,
                              col = eQTLGen,
                              sep = ",",
                              into = as.character(1:num_eQTLGene)) 
    for(j in 1:num_eQTLGene){
      tmp_all[tmp_all[,c(as.character(j))]%in%DEG$V1==FALSE,as.character(j)] = NA # 不在DEG里的eQTLGen用NA表示
    }
    tmp_all = tmp_all%>%unite(eQTLGen_DEG,as.character(1:num_eQTLGene), sep = ",", na.rm = TRUE)
    all$eQTLGen_trait2_DEG[all$trait2==i] = tmp_all$eQTLGen_DEG
  }
  flag = FALSE
}
write_tsv(all,"/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG")
