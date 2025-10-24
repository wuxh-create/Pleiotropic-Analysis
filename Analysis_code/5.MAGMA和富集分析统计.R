setwd("/home/yanyq/share_genetics/result/MAGMA/asso_merge/")
# MAGMA统计
traits = c("BLCA","BRCA",	"HNSC",	"kidney",	"lung",	"OV",	'PAAD',	"PRAD",	'SKCM',	"UCEC",
           "BGC", "CRC", "DLBC", "ESCA", "STAD", "THCA","AML", "BAC", "BCC" ,"BGA", "BM",
           "CESC", "CML", "CORP" ,"EYAD" ,"GSS", "HL", "LIHC" ,"LL" ,"MCL", "MESO", "MM" ,
           "MS" ,"MZBL", "SCC" ,"SI", "TEST", "VULVA")
all_MAGMA = list()
for(trait1 in traits){
  for(trait2 in traits){
    if(file.exists(paste0(trait1,"-",trait2))){
      tmp = as.data.frame(read_tsv(paste0(trait1,"-",trait2)))
      if(nrow(tmp)>0){
        tmp$trait1 = trait1
        tmp$trait2 = trait2
        colnames(tmp)[13:16] = c("P.trait1", "fdr.trait1","P.trait2", "fdr.trait2")
        all_MAGMA[[paste0(trait1,"-",trait2)]] = tmp
      }
    }
  }
}
all_MAGMA = do.call(rbind, all_MAGMA)
length(unique(all_MAGMA$SYMBOL))
all_MAGMA_fdr = all_MAGMA[all_MAGMA$fdr.PLACO<0.05,]
length(unique(all_MAGMA_fdr$SYMBOL))
all_MAGMA_fdr_count = as.data.frame(table(all_MAGMA_fdr$SYMBOL))
length(which(all_MAGMA_fdr_count$Freq>1))
length(unique(c(all_MAGMA_fdr$trait1[all_MAGMA_fdr$SYMBOL=="TERT"],all_MAGMA_fdr$trait2[all_MAGMA_fdr$SYMBOL=="TERT"])))
length(unique(c(all_MAGMA_fdr$trait1[all_MAGMA_fdr$SYMBOL=="CLPTM1L"],all_MAGMA_fdr$trait2[all_MAGMA_fdr$SYMBOL=="CLPTM1L"])))

# 基因集富集统计
library(readr)
library(dplyr)
go_merge = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/gse/go/result/all_res"))
go_merge = go_merge[go_merge$NES>2&go_merge$p.adjust<0.05&!is.na(go_merge$NES)&!is.na(go_merge$p.adjust),] 
go_merge = go_merge[!grepl("CORP",go_merge$traits),] # 1079
kegg_merge = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/gse/kegg/result/all_res"))
kegg_merge = kegg_merge[kegg_merge$NES>2&kegg_merge$p.adjust<0.05&!is.na(kegg_merge$NES)&!is.na(kegg_merge$p.adjust),]
kegg_merge = kegg_merge[!grepl("CORP",kegg_merge$traits),] # 115
nrow(go_merge)+nrow(kegg_merge)

go_merge_frq = as.data.frame(table(go_merge$ID)) # 401
go_merge_frq$Var1 = as.character(go_merge_frq$Var1)
kegg_merge_frq = as.data.frame(table(kegg_merge$ID)) # 43
kegg_merge_frq$Var1 = as.character(kegg_merge_frq$Var1)

go_merge_cancer_frq = rbind(data.frame(ID = go_merge$ID, trait = do.call(rbind, strsplit(go_merge$traits, split = "-"))[,1]),
                            data.frame(ID = go_merge$ID, trait = do.call(rbind, strsplit(go_merge$traits, split = "-"))[,2]))
go_merge_cancer_frq = unique(go_merge_cancer_frq)
go_merge_cancer_frq = as.data.frame(table(go_merge_cancer_frq$ID))
go_merge_cancer_frq$Var1 = as.character(go_merge_cancer_frq$Var1)
kegg_merge_cancer_frq = rbind(data.frame(ID = kegg_merge$ID, trait = do.call(rbind, strsplit(kegg_merge$traits, split = "-"))[,1]),
                              data.frame(ID = kegg_merge$ID, trait = do.call(rbind, strsplit(kegg_merge$traits, split = "-"))[,2]))
kegg_merge_cancer_frq = unique(kegg_merge_cancer_frq)
kegg_merge_cancer_frq = as.data.frame(table(kegg_merge_cancer_frq$ID))
kegg_merge_cancer_frq$Var1 = as.character(kegg_merge_cancer_frq$Var1)

colnames(go_merge_frq) = c("ID","freq_traits")
colnames(go_merge_cancer_frq) = c("ID","freq_cancer")
colnames(kegg_merge_frq) = c("ID","freq_traits")
colnames(kegg_merge_cancer_frq) = c("ID","freq_cancer")
go_merge_20 = go_merge[go_merge$ID%in%go_merge_frq$ID[go_merge_frq$freq_traits>20],]
go_merge_20 = left_join(go_merge_20, go_merge_frq, by = "ID")
go_merge_20 = left_join(go_merge_20, go_merge_cancer_frq, by = "ID")
go_merge_20_merge <- go_merge_20 %>%
  group_by(ONTOLOGY,ID,Description) %>%
  summarise(
    avg_NES = mean(NES),       # 计算平均NES
    min_P_value = min(p.adjust), # 计算最小P值
    cancer_num = min(freq_cancer)
  )
write_tsv(go_merge_20_merge,"/home/yanyq/share_genetics/artical/enrich_table")

gene = read.table("/home/yanyq/share_genetics/data/MAGMA/NCBI37.3/NCBI37.3.gene.loc")
chr_structure_gene = gene[gene$V1%in%unique(as.numeric(unlist(strsplit(go_merge_20$core_enrichment[go_merge_20$ID=="GO:0030527"], split = "/")))),]
chr_structure_gene$V6

kegg_merge = left_join(kegg_merge, kegg_merge_frq, by = "ID")
kegg_merge = left_join(kegg_merge, kegg_merge_cancer_frq, by = "ID")
bladderCancer_gene = gene[gene$V1%in%unique(as.numeric(unlist(strsplit(kegg_merge$core_enrichment[kegg_merge$ID=="hsa05219"], split = "/")))),]


###################################
setwd("/home/yanyq/share_genetics/result/MAGMA/asso_merge/")
# MAGMA统计
traits = c("BLCA","BRCA",	"HNSC",	"kidney",	"lung",	"OV",	'PAAD',	"PRAD",	'SKCM',	"UCEC",
           "BGC", "CRC", "DLBC", "ESCA", "STAD", "THCA","AML", "BAC", "BCC" ,"BGA", "BM",
           "CESC", "CML", "CORP" ,"EYAD" ,"GSS", "HL", "LIHC" ,"LL" ,"MCL", "MESO", "MM" ,
           "MS" ,"MZBL", "SCC" ,"SI", "TEST", "VULVA")
all_MAGMA = list()
for(trait1 in traits){
  for(trait2 in traits){
    if(file.exists(paste0(trait1,"-",trait2))){
      tmp = as.data.frame(read_tsv(paste0(trait1,"-",trait2)))
      if(nrow(tmp)>0){
        tmp$trait1 = trait1
        tmp$trait2 = trait2
        colnames(tmp)[13:16] = c("P.trait1", "fdr.trait1","P.trait2", "fdr.trait2")
        all_MAGMA[[paste0(trait1,"-",trait2)]] = tmp
      }
    }
  }
}
all_MAGMA = do.call(rbind, all_MAGMA)
length(unique(all_MAGMA$SYMBOL))
all_MAGMA_fdr = all_MAGMA[all_MAGMA$fdr.PLACO<0.05,]
length(unique(all_MAGMA_fdr$SYMBOL))
all_MAGMA_fdr_count = as.data.frame(table(all_MAGMA_fdr$SYMBOL))
length(which(all_MAGMA_fdr_count$Freq>1))
length(unique(c(all_MAGMA_fdr$trait1[all_MAGMA_fdr$SYMBOL=="TERT"],all_MAGMA_fdr$trait2[all_MAGMA_fdr$SYMBOL=="TERT"])))
length(unique(c(all_MAGMA_fdr$trait1[all_MAGMA_fdr$SYMBOL=="CLPTM1L"],all_MAGMA_fdr$trait2[all_MAGMA_fdr$SYMBOL=="CLPTM1L"])))

# 基因集富集统计
library(readr)
library(dplyr)
go_merge = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/gse/go/result/all_res"))
go_merge = go_merge[go_merge$NES>2&go_merge$p.adjust<0.05&!is.na(go_merge$NES)&!is.na(go_merge$p.adjust),] 
go_merge = go_merge[!grepl("CORP",go_merge$traits),] # 1079
kegg_merge = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/gse/kegg/result/all_res"))
kegg_merge = kegg_merge[kegg_merge$NES>2&kegg_merge$p.adjust<0.05&!is.na(kegg_merge$NES)&!is.na(kegg_merge$p.adjust),]
kegg_merge = kegg_merge[!grepl("CORP",kegg_merge$traits),] # 115
nrow(go_merge)+nrow(kegg_merge)

go_merge_frq = as.data.frame(table(go_merge$ID)) # 401
go_merge_frq$Var1 = as.character(go_merge_frq$Var1)
kegg_merge_frq = as.data.frame(table(kegg_merge$ID)) # 43
kegg_merge_frq$Var1 = as.character(kegg_merge_frq$Var1)

go_merge_cancer_frq = rbind(data.frame(ID = go_merge$ID, trait = do.call(rbind, strsplit(go_merge$traits, split = "-"))[,1]),
                            data.frame(ID = go_merge$ID, trait = do.call(rbind, strsplit(go_merge$traits, split = "-"))[,2]))
go_merge_cancer_frq = unique(go_merge_cancer_frq)
go_merge_cancer_frq = as.data.frame(table(go_merge_cancer_frq$ID))
go_merge_cancer_frq$Var1 = as.character(go_merge_cancer_frq$Var1)
kegg_merge_cancer_frq = rbind(data.frame(ID = kegg_merge$ID, trait = do.call(rbind, strsplit(kegg_merge$traits, split = "-"))[,1]),
                              data.frame(ID = kegg_merge$ID, trait = do.call(rbind, strsplit(kegg_merge$traits, split = "-"))[,2]))
kegg_merge_cancer_frq = unique(kegg_merge_cancer_frq)
kegg_merge_cancer_frq = as.data.frame(table(kegg_merge_cancer_frq$ID))
kegg_merge_cancer_frq$Var1 = as.character(kegg_merge_cancer_frq$Var1)

colnames(go_merge_frq) = c("ID","freq_traits")
colnames(go_merge_cancer_frq) = c("ID","freq_cancer")
colnames(kegg_merge_frq) = c("ID","freq_traits")
colnames(kegg_merge_cancer_frq) = c("ID","freq_cancer")
go_merge_20 = go_merge[go_merge$ID%in%go_merge_frq$ID[go_merge_frq$freq_traits>20],]
go_merge_20 = left_join(go_merge_20, go_merge_frq, by = "ID")
go_merge_20 = left_join(go_merge_20, go_merge_cancer_frq, by = "ID")
go_merge_20_merge <- go_merge_20 %>%
  group_by(ONTOLOGY,ID,Description) %>%
  summarise(
    avg_NES = mean(NES),       # 计算平均NES
    min_P_value = min(p.adjust), # 计算最小P值
    cancer_num = min(freq_cancer)
  )
write_tsv(go_merge_20_merge,"/home/yanyq/share_genetics/artical/enrich_table")

gene = read.table("/home/yanyq/share_genetics/data/MAGMA/NCBI37.3/NCBI37.3.gene.loc")
chr_structure_gene = gene[gene$V1%in%unique(as.numeric(unlist(strsplit(go_merge_20$core_enrichment[go_merge_20$ID=="GO:0030527"], split = "/")))),]
chr_structure_gene$V6

kegg_merge = left_join(kegg_merge, kegg_merge_frq, by = "ID")
kegg_merge = left_join(kegg_merge, kegg_merge_cancer_frq, by = "ID")
bladderCancer_gene = gene[gene$V1%in%unique(as.numeric(unlist(strsplit(kegg_merge$core_enrichment[kegg_merge$ID=="hsa05219"], split = "/")))),]

###############################
setwd("~/adibd/smr")
library(readr)
ad_CD8T = as.data.frame(read_tsv("fdr0.05AD_CD8T.smr"))
ad_CD8T$FDR = p.adjust(ad_CD8T$p_SMR, method = "BH")
ad_CD8T = ad_CD8T[ad_CD8T$p_SMR<0.05,]
ad_mono = as.data.frame(read_tsv("fdr0.05AD_mono.smr"))
ad_mono$FDR = p.adjust(ad_mono$p_SMR, method = "BH")
ad_mono = ad_mono[ad_mono$p_SMR<0.05,]

cd_CD8T = as.data.frame(read_tsv("fdr0.05CD_CD8T.smr"))
cd_CD8T$FDR = p.adjust(cd_CD8T$p_SMR, method = "BH")
cd_CD8T = cd_CD8T[cd_CD8T$p_SMR<0.05,]
cd_mono = as.data.frame(read_tsv("fdr0.05CD_mono.smr"))
cd_mono$FDR = p.adjust(cd_mono$p_SMR, method = "BH")
cd_mono = cd_mono[cd_mono$p_SMR<0.05,]

ibd_CD8T = as.data.frame(read_tsv("fdr0.05IBD_CD8T.smr"))
ibd_CD8T$FDR = p.adjust(ibd_CD8T$p_SMR, method = "BH")
ibd_CD8T = ibd_CD8T[ibd_CD8T$p_SMR<0.05,]
ibd_mono = as.data.frame(read_tsv("fdr0.05IBD_mono.smr"))
ibd_mono$FDR = p.adjust(ibd_mono$p_SMR, method = "BH")
ibd_mono = ibd_mono[ibd_mono$p_SMR<0.05,]

uc_CD8T = as.data.frame(read_tsv("fdr0.05UC_CD8T.smr"))
uc_CD8T$FDR = p.adjust(uc_CD8T$p_SMR, method = "BH")
uc_CD8T = uc_CD8T[uc_CD8T$p_SMR<0.05,]
uc_mono = as.data.frame(read_tsv("fdr0.05UC_mono.smr"))
uc_mono$FDR = p.adjust(uc_mono$p_SMR, method = "BH")
uc_mono = uc_mono[uc_mono$p_SMR<0.05,]

write_tsv(ad_CD8T, "filter_AD_CD8T")
write_tsv(ad_mono, "filter_AD_mono")
write_tsv(cd_CD8T, "filter_CD_CD8T")
write_tsv(cd_mono, "filter_CD_mono")
write_tsv(ibd_CD8T, "filter_IBD_CD8T")
write_tsv(ibd_mono, "filter_IBD_mono")
write_tsv(uc_CD8T, "filter_UC_CD8T")
write_tsv(uc_mono, "filter_UC_mono")

ad_gene = unique(c(ad_CD8T$Gene,ad_mono$Gene))
cahng_gene = unique(c(cd_CD8T$Gene,cd_mono$Gene,
                      ibd_CD8T$Gene,ibd_mono$Gene,
                      uc_CD8T$Gene,uc_mono$Gene))
ad_gene[ad_gene%in%cahng_gene]
