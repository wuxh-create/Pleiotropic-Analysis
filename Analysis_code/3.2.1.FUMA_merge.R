setwd("~/share_genetics/result/FUMA")
library(readr)
library(data.table)
library(GenomicRanges)
# arg = commandArgs(T)
# trait1 = arg[1]
# trait2 = arg[2]
# traits = c("BLCA","BRCA",	"HNSC",	"kidney",	"lung",	"OV",	'PAAD',	"PRAD",	'SKCM',	"UCEC")
traits = c("AML","BAC","BCC","BGA","BGC","BLCA","BM","BRCA","CESC","CML","CORP",
           "CRC","DLBC","ESCA","EYAD","GSS","HL","HNSC","kidney","LIHC","LL",
           "lung","MCL","MESO","MM","MS","MZBL","OV","PAAD","PRAD","SCC","SI",
           "SKCM","STAD","TEST","THCA","UCEC","VULVA")

for(trait1 in traits){
  for(trait2 in traits){
    if(file.exists(paste0("/home/yanyq/share_genetics/result/FUMA/",trait1,"-",trait2,"/GenomicRiskLoci.txt"))){
      FUMA_both = fread(paste0("/home/yanyq/share_genetics/result/FUMA/",trait1,"-",trait2,"/GenomicRiskLoci.txt"))
      FUMA_both$locus = paste0(FUMA_both$chr,":",FUMA_both$start,"-",FUMA_both$end)
      both_GR = as(FUMA_both$locus, "GRanges")
      if(file.exists(paste0("/home/yanyq/share_genetics/result/FUMA/",trait1))){
        FUMA_trait1 = fread(paste0("/home/yanyq/share_genetics/result/FUMA/",trait1,"/GenomicRiskLoci.txt"))
        FUMA_trait1$locus = paste0(FUMA_trait1$chr,":",FUMA_trait1$start,"-",FUMA_trait1$end)
        trait1_GR = as(FUMA_trait1$locus, "GRanges")
        # 寻找trait1和trait2与多效基因座的重叠
        trait1_overlap = findOverlaps(both_GR, trait1_GR)
        FUMA_both$exist_trait1 = 0
        FUMA_both$exist_trait1[trait1_overlap@from] = FUMA_trait1$locus[trait1_overlap@to]
      }else{
        FUMA_both$exist_trait1 = 0
      }
      if(file.exists(paste0("/home/yanyq/share_genetics/result/FUMA/",trait2))){
        FUMA_trait2 = fread(paste0("/home/yanyq/share_genetics/result/FUMA/",trait2,"/GenomicRiskLoci.txt"))
        FUMA_trait2$locus = paste0(FUMA_trait2$chr,":",FUMA_trait2$start,"-",FUMA_trait2$end)
        trait2_GR = as(FUMA_trait2$locus, "GRanges")
        trait2_overlap = findOverlaps(both_GR, trait2_GR)
        FUMA_both$exist_trait2 = 0
        FUMA_both$exist_trait2[trait2_overlap@from] = FUMA_trait2$locus[trait2_overlap@to]
      }else{
        FUMA_both$exist_trait2 = 0
      }
      
      # FUMA_both$exist_trait1 = ifelse(FUMA_both$locus%in%FUMA_trait1$locus,1,0) # PLACO注释的基因座，UCEC中同样注释到了
      # FUMA_both$exist_trait2 = ifelse(FUMA_both$locus%in%FUMA_trait2$locus,1,0)
      
      FUMA_both_anno = fread(paste0("/home/yanyq/share_genetics/result/FUMA/",trait1,"-",trait2,"/snps.txt"))
      FUMA_both = dplyr::left_join(FUMA_both,FUMA_both_anno[,c(1,7:10,12:21)],by = "uniqID")
      write_tsv(FUMA_both,paste0("~/share_genetics/result/FUMA/merge/",trait1,"-",trait2))
    }
  }
}
files = list.files("/home/yanyq/share_genetics/result/FUMA/merge")
files = files[!grepl("CORP", files)] # 372对癌症
