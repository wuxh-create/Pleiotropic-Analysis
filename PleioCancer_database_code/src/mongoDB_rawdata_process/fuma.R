# FUMA loci
library(readr)
library(GenomicRanges)
library(dplyr)
library(tidyr)

# start-end并不是输入GWAS SNP的范围，还包括了LD 中非 GWAS 标记的 SNP
# 有的由于ref、alt对不上，SNP没有分配loci，重新FUMA注释，只有BAC-PRAD多了一个loci，其他的因为没有这个SNP，所以都不重注释了
all_FUMA = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/FUMA/all_FUMA_loci"))
all_FUMA = all_FUMA[!grepl("CORP",all_FUMA$traits),]# 2,527个风险基因座上
all_FUMA$num_pleio = NA
placo = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer_MAGMA_SMR_GWASCatalog_cancer_separate_SUPERGNOVA_coloc_DEG_LAVA_SNPcoloc"))
placo = placo[!grepl("CORP",placo$traits),] # 75243个多效SNP
for(i in unique(all_FUMA$traits)){
  tmp_fuma = all_FUMA[all_FUMA$traits==i,]
  tmp_placo = placo[placo$traits==i,]
  ov = findOverlaps(as(paste0(tmp_placo$hg19chr,":",tmp_placo$bp),"GRanges"),
                    as(paste0(tmp_fuma$chr,":",tmp_fuma$start,"-",tmp_fuma$end),"GRanges"))
  if(length(which(duplicated(ov@from)))>0){
    print(i)
  } else {
    tmp = as.data.frame(table(ov@to))
    all_FUMA$num_pleio[all_FUMA$traits==i][tmp$Var1] = tmp$Freq
    if(length(ov@to)!=nrow(tmp_placo)){
      print(i)
    }
  }
}
sum(all_FUMA$num_pleio) # 75207

cancer = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/english_abbrev"))

all_FUMA = separate(all_FUMA, col = "traits", into = c("trait1", "trait2"))
all_FUMA = left_join(all_FUMA, cancer, by = c("trait1" = "abbrev"))
all_FUMA = left_join(all_FUMA, cancer, by = c("trait2" = "abbrev"))
all_FUMA = all_FUMA[,c(1:8,11:14,17,18,20)]

cytoband = as.data.frame(read_tsv("/home/yanyq/data/cytoBand_hg19.txt.gz", col_names = F))
cytoband$X1 = gsub("chr","",cytoband$X1)
cytoband$X4 = paste0(cytoband$X1,cytoband$X4)
table(cytoband$X1)
cytoband = cytoband[cytoband$X1!="X"&cytoband$X1!="Y",]
ov = findOverlaps(as(paste0(all_FUMA$chr,":",all_FUMA$start,"-",all_FUMA$end),"GRanges"),
                  as(paste0(cytoband$X1,":",cytoband$X2,"-",cytoband$X3),"GRanges"))
which(duplicated(ov@from))
ov_df = data.frame(fuma_row = ov@from, cyto = cytoband$X4[ov@to])
# 按 fuma_from 分组，并将 cyto_to 合并为逗号分隔的字符串
ov_df_uni <- ov_df %>%
  group_by(fuma_row) %>%
  summarise(cyto_uni = paste(cyto, collapse = ", "),.groups = 'drop')
all_FUMA$Cytoband[ov_df_uni$fuma_row] = ov_df_uni$cyto_uni
write_tsv(all_FUMA,"/home/yanyq/database/flask_vue/data/fuma")
