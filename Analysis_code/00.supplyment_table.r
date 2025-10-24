library(readr)
library(GenomicRanges)
library(dplyr)
library(tidyr)

# 补充表1，GWAS info
h2 = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/ldsc/ldsc_h2_sampleSize_effect_4"))
h2$trait = gsub(".log", "", h2$trait)

cancer = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/english_abbrev"))
colnames(cancer)[2] = "trait"

samplesize = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/sampleSize_case_control"))
colnames(samplesize)[1] = "trait"

all_table = merge(h2, cancer, by = "trait")
all_table = merge(all_table, samplesize, by = "trait")
all_table = all_table[all_table$trait!="CORP",]
write_tsv(all_table[order(all_table$case, decreasing = T),], "~/tmp")

# 补充表2，显著的LDSC相关性
global = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/ldsc/ldsc_stat_sampleSize_effect_4_processed"))
# write_tsv(global[,-13],"/home/yanyq/share_genetics/result/ldsc/ldsc_stat_sampleSize_effect_4_processed")
global = global[global$p1!="CORP"&global$p2!="CORP",]
global$FDR = p.adjust(global$p, method = "BH")
cancer = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/english_abbrev"))
global = merge(global, cancer, by.x = "p1", by.y = "abbrev")
global = merge(global, cancer, by.x = "p2", by.y = "abbrev")
write_tsv(global[order(global$FDR),], "~/tmp")

# 补充表3，局部遗传相关性
local_cor = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/SUPERGNOVA/all"))
local_cor = local_cor[local_cor$FDR<0.05,]
local_cor = local_cor[!grepl("CORP",local_cor$traits),]
local_cor = local_cor[local_cor$traits%in%paste0(global$p1,"-",global$p2),]
local_cor = separate(local_cor, col = "traits", sep = "-", into = c("p1","p2"))
cancer = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/english_abbrev"))
local_cor = merge(local_cor, cancer, by.x = "p1", by.y = "abbrev")
local_cor = merge(local_cor, cancer, by.x = "p2", by.y = "abbrev")
write_tsv(local_cor[order(local_cor$abbrev_use.x,local_cor$abbrev_use.y,local_cor$chr,local_cor$start),], "~/tmp")

# 补充表4，FUMA
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
write_tsv(all_FUMA,"~/tmp")

# 补充表5，Pathway
# 在所有癌症对的基因集富集分析中，共鉴定出1,194条显著富集的通路（NES > 2且FDR < 0.05），其中1,079条（401条非重复）为GO术语，115条（43条非重复）为KEGG通路。
go_merge = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/gse/go/result/all_res"))
go_merge = go_merge[go_merge$NES>2&go_merge$p.adjust<0.05&!is.na(go_merge$NES)&!is.na(go_merge$p.adjust),] 
go_merge = go_merge[!grepl("CORP",go_merge$traits),] # 1079
kegg_merge = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/gse/kegg/result/all_res"))
kegg_merge = kegg_merge[kegg_merge$NES>2&kegg_merge$p.adjust<0.05&!is.na(kegg_merge$NES)&!is.na(kegg_merge$p.adjust),]
kegg_merge = kegg_merge[!grepl("CORP",kegg_merge$traits),] # 115

gene = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/MAGMA/NCBI37.3/NCBI37.3.gene.loc", col_names = F))

for(i in 1:nrow(go_merge)){
  tmp = as.numeric(unlist(strsplit(go_merge$core_enrichment[i],"/")))
  tmp_gene = gene$X6[gene$X1%in%tmp]
  if(length(tmp)==length(tmp_gene)){
    go_merge$core_enrichment[i] = paste(tmp_gene[order(tmp_gene)],collapse = "/")
  }else{
    print(i)
  }
}
cancer = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/english_abbrev"))
go_merge = separate(go_merge, col = "traits", into = c("trait1", "trait2"))
go_merge = left_join(go_merge, cancer, by = c("trait1" = "abbrev"))
go_merge = left_join(go_merge, cancer, by = c("trait2" = "abbrev"))
write_tsv(go_merge, "~/tmp")
for(i in 1:nrow(kegg_merge)){
  tmp = as.numeric(unlist(strsplit(kegg_merge$core_enrichment[i],"/")))
  tmp_gene = gene$X6[gene$X1%in%tmp]
  if(length(tmp)==length(tmp_gene)){
    kegg_merge$core_enrichment[i] = paste(tmp_gene[order(tmp_gene)],collapse = "/")
  }else{
    print(i)
  }
}
cancer = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/english_abbrev"))
kegg_merge = separate(kegg_merge, col = "traits", into = c("trait1", "trait2"))
kegg_merge = left_join(kegg_merge, cancer, by = c("trait1" = "abbrev"))
kegg_merge = left_join(kegg_merge, cancer, by = c("trait2" = "abbrev"))
write_tsv(kegg_merge, "~/tmp")
