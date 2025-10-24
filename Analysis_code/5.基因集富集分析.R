# 基因集富集分析
library(clusterProfiler)
library(org.Hs.eg.db)
library(biomaRt)
library(DOSE)
library(readr)
library(data.table)
library(pbmcapply)
library(tidyr)

# traits = c("AML","BAC","BCC","BGA","BGC","BLCA","BM","BRCA","CESC","CML","CORP",
#            "CRC","DLBC","ESCA","EYAD","GSS","HL","HNSC","kidney","LIHC","LL",
#            "lung","MCL","MESO","MM","MS","MZBL","OV","PAAD","PRAD","SCC","SI",
#            "SKCM","STAD","TEST","THCA","UCEC","VULVA")

files = list.files("/home/yanyq/share_genetics/result/MAGMA/asso/")
files = files[grep("_10_1.5.genes.out", files)]
files = files[grep("PLACO", files)]
files = gsub("PLACO_","",files)
files = gsub("_10_1.5.genes.out","",files)
go_merge = list()
kegg_merge = list()

process_trait <- function(traits) {
  trait1 = strsplit(traits, "-")[[1]][1]
  trait2 = strsplit(traits, "-")[[1]][2]
  
  f_name = paste0("/home/yanyq/share_genetics/result/MAGMA/asso/PLACO_", trait1, "-", trait2, "_10_1.5.genes.out")
  print(paste0(trait1, "-", trait2))
  PLACO = as.data.frame(fread(f_name))
  PLACO = PLACO[order(PLACO$ZSTAT, decreasing = TRUE), ]
  genelist = PLACO$ZSTAT
  names(genelist) = PLACO$GENE
  
  Go_gseresult <- gseGO(genelist, OrgDb = 'org.Hs.eg.db', ont = "all", pvalueCutoff = 1, pAdjustMethod = "BH")
  KEGG_gseresult <- gseKEGG(genelist, pvalueCutoff = 1, pAdjustMethod = "BH")
  
  # 保存结果
  write_rds(Go_gseresult, paste0("/home/yanyq/share_genetics/result/gse/go/", trait1, "-", trait2, ".rds"))
  write_rds(KEGG_gseresult, paste0("/home/yanyq/share_genetics/result/gse/kegg/", trait1, "-", trait2, ".rds"))
  write_tsv(Go_gseresult@result, paste0("/home/yanyq/share_genetics/result/gse/go/result/", trait1, "-", trait2))
  write_tsv(KEGG_gseresult@result, paste0("/home/yanyq/share_genetics/result/gse/kegg/result/", trait1, "-", trait2))
  
  list(
    go = if (nrow(Go_gseresult@result) > 0) {
      result <- Go_gseresult@result
      result$traits <- paste0(trait1, "-", trait2)
      result
    } else {
      NULL
    },
    kegg = if (nrow(KEGG_gseresult@result) > 0) {
      result <- KEGG_gseresult@result
      result$traits <- paste0(trait1, "-", trait2)
      result
    } else {
      NULL
    }
  )
}

# 使用 mclapply 并行处理
results <- mclapply(files, process_trait, mc.cores = 40)

# 合并结果
go_merge <- do.call(rbind, lapply(results, function(res) res$go))
kegg_merge <- do.call(rbind, lapply(results, function(res) res$kegg))

# 保存合并结果
write_tsv(go_merge, "/home/yanyq/share_genetics/result/gse/go/result/all_res")
write_tsv(kegg_merge, "/home/yanyq/share_genetics/result/gse/kegg/result/all_res")

####################################################
go_merge = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/gse/go/result/all_res"))
kegg_merge = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/gse/kegg/result/all_res"))
go_merge = go_merge[abs(go_merge$NES)>2&go_merge$p.adjust<0.05,]
kegg_merge = kegg_merge[abs(kegg_merge$NES)>2&kegg_merge$p.adjust<0.05,]
go_merge = go_merge[!grepl("CORP", go_merge$traits),] # 1622
kegg_merge = kegg_merge[!grepl("CORP", kegg_merge$traits),] # 177
# 癌症对frq
go_merge_frq = as.data.frame(table(go_merge$ID))
go_merge_frq$Var1 = as.character(go_merge_frq$Var1)
colnames(go_merge_frq)[1] = "ID"
go_merge_frq = left_join(go_merge_frq, unique(go_merge[,1:3]), by = "ID")
go_merge_frq$traits = NA
for(ID in go_merge_frq$ID){
  go_merge_frq$traits[go_merge_frq$ID==ID] = paste(unique(go_merge$traits[go_merge$ID==ID]), collapse = ",")
}
write_tsv(go_merge_frq,"/home/yanyq/share_genetics/result/gse/all_go_merge_frq")

kegg_merge_frq = as.data.frame(table(kegg_merge$ID))
kegg_merge_frq$Var1 = as.character(kegg_merge_frq$Var1)
colnames(kegg_merge_frq)[1] ="ID"
kegg_merge_frq = left_join(kegg_merge_frq, unique(kegg_merge[,1:2]), by = "ID")
kegg_merge_frq$traits = NA
for(ID in kegg_merge_frq$ID){
  kegg_merge_frq$traits[kegg_merge_frq$ID==ID] = paste(unique(kegg_merge$traits[kegg_merge$ID==ID]), collapse = ",")
}
write_tsv(kegg_merge_frq,"/home/yanyq/share_genetics/result/gse/all_kegg_merge_frq")


# 癌症frq
go_merge_cancer = separate(go_merge, traits, into = c("trait1", "trait2"), sep = "-")
go_merge_cancer = rbind(go_merge_cancer[,c("ID","trait1")], go_merge_cancer[,c("ID","trait2")]%>%dplyr::rename(trait1 = "trait2"))
go_merge_cancer = unique(go_merge_cancer)
go_merge_cancer_frq = as.data.frame(table(go_merge_cancer$ID))
go_merge_cancer_frq$Var1 = as.character(go_merge_cancer_frq$Var1)
colnames(go_merge_cancer_frq)[1] = "ID"
go_merge_cancer_frq = left_join(go_merge_cancer_frq, unique(go_merge[,1:3]), by = "ID")
go_merge_cancer_frq$traits = NA
for(ID in go_merge_cancer_frq$ID){
  go_merge_cancer_frq$traits[go_merge_cancer_frq$ID==ID] = paste(unique(go_merge_cancer$trait1[go_merge_cancer$ID==ID]), collapse = ",")
}
write_tsv(go_merge_cancer_frq,"/home/yanyq/share_genetics/result/gse/all_go_merge_cancer_frq")
grep("CORP",go_merge_cancer_frq$traits)
go_merge_cancer_frq_BP = go_merge_cancer_frq[go_merge_cancer_frq$ONTOLOGY=="BP",]
go_merge_cancer_frq_CC = go_merge_cancer_frq[go_merge_cancer_frq$ONTOLOGY=="CC",]
go_merge_cancer_frq_MF = go_merge_cancer_frq[go_merge_cancer_frq$ONTOLOGY=="MF",]


kegg_merge_cancer = separate(kegg_merge, traits, into = c("trait1", "trait2"), sep = "-")
kegg_merge_cancer = rbind(kegg_merge_cancer[,c("ID","trait1")], kegg_merge_cancer[,c("ID","trait2")]%>%dplyr::rename(trait1 = trait2))
kegg_merge_cancer = unique(kegg_merge_cancer)
kegg_merge_cancer_frq = as.data.frame(table(kegg_merge_cancer$ID))
kegg_merge_cancer_frq$Var1 = as.character(kegg_merge_cancer_frq$Var1)
colnames(kegg_merge_cancer_frq)[1] = "ID"
kegg_merge_cancer_frq = left_join(kegg_merge_cancer_frq, unique(kegg_merge[,1:2]), by = "ID")
kegg_merge_cancer_frq$traits = NA
for(ID in kegg_merge_cancer_frq$ID){
  kegg_merge_cancer_frq$traits[kegg_merge_cancer_frq$ID==ID] = paste(unique(kegg_merge_cancer$trait1[kegg_merge_cancer$ID==ID]), collapse = ",")
}
write_tsv(kegg_merge_cancer_frq,"/home/yanyq/share_genetics/result/gse/all_kegg_merge_cancer_frq")
grep("CORP",kegg_merge_cancer_frq$traits)
