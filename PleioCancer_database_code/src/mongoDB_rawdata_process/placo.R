library(readr)
library(vroom)
library(GenomicRanges)
all_placo = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/PLACO/all"))
all_placo = all_placo[all_placo$trait1!="CORP"&all_placo$trait2!="CORP",]
all_placo = all_placo[,1:19]

abbrev = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/english_abbrev"))
colnames(abbrev) = c("cancer1","trait1")
all_placo = dplyr::left_join(all_placo,abbrev,by = "trait1")
colnames(abbrev) = c("cancer2","trait2")
all_placo = dplyr::left_join(all_placo,abbrev,by = "trait2")
which(is.na(all_placo$cancer1))
which(is.na(all_placo$cancer2))

all_placo = all_placo[,-(which(colnames(all_placo)%in%c("trait1","trait2")))]
# 每一行对cancer1和cancer2排序，保证cancer1小于cancer2
index = which(all_placo$cancer2<all_placo$cancer1)
col_name = colnames(all_placo)
tmp = all_placo[index,c("snpid","hg19chr","bp","a1","a2",
                        "or.trait2","se.trait2","pval.trait2","EURaf.trait2","zscore.trait2",
                        "or.trait1","se.trait1","pval.trait1","EURaf.trait1","zscore.trait1",
                        "T.placo","p.placo","cancer2","cancer1")]
colnames(tmp) = col_name
all_placo[index,] = tmp


# 排序
all_placo = all_placo[(order(all_placo$cancer1, all_placo$cancer2,all_placo$hg19chr,all_placo$bp)),]
write_tsv(all_placo, "/home/yanyq/database/flask_vue/data/all_placo")
all_placo = as.data.frame(read_tsv("/home/yanyq/database/flask_vue/data/all_placo"))
all_placo$log10P = -log10(all_placo$p.placo)
write_tsv(all_placo, "/home/yanyq/database/flask_vue/data/all_placo")
all_placo = as.data.frame(read_tsv("/home/yanyq/database/flask_vue/data/all_placo"))
all_placo$cancer1[all_placo$cancer1=="Endometrioid Cancer"] = "Endometrial cancer"
all_placo$cancer2[all_placo$cancer2=="Endometrioid Cancer"] = "Endometrial cancer"
write_tsv(all_placo, "/home/yanyq/database/flask_vue/data/all_placo")

################ 提取显著位点上下游1MB
all_placo = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/PLACO/all"))
all_placo = all_placo[all_placo$trait1!="CORP"&all_placo$trait2!="CORP",]
all_placo = all_placo[,1:19]

all_placo$traits = paste0(all_placo$trait1,"-",all_placo$trait2)
all_placo$start = ifelse(all_placo$bp<1000000,1,all_placo$bp-1000000)
all_placo$end = all_placo$bp+1000000
setwd("/home/yanyq/share_genetics/result/PLACO/")
placo_1MB = list()
for(i in unique(all_placo$traits)){
  traits_placo = as.data.frame(vroom(paste0("PLACO_",i,".gz")))
  cur_placo = all_placo[all_placo$traits==i,]
  
  cur_placo_GR = as(paste0(cur_placo$hg19chr,":",cur_placo$start,"-",cur_placo$end),"GRanges")
  traits_placo_GR = as(paste0(traits_placo$hg19chr,":",traits_placo$bp),"GRanges")
  
  ov = findOverlaps(cur_placo_GR,traits_placo_GR)
  tmp = traits_placo[unique(ov@to),c("snpid","p.placo")]
  tmp$trait1 = cur_placo$trait1[1]
  tmp$trait2 = cur_placo$trait2[1]
  placo_1MB[[i]] = tmp
}
placo_1MB = do.call(rbind, placo_1MB)

abbrev = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/english_abbrev"))
colnames(abbrev) = c("cancer1","trait1")
placo_1MB = dplyr::left_join(placo_1MB,abbrev,by = "trait1")
colnames(abbrev) = c("cancer2","trait2")
placo_1MB = dplyr::left_join(placo_1MB,abbrev,by = "trait2")
which(is.na(placo_1MB$cancer1))
which(is.na(placo_1MB$cancer2))

placo_1MB = placo_1MB[,-(which(colnames(placo_1MB)%in%c("trait1","trait2")))]
# 每一行对cancer1和cancer2排序，保证cancer1小于cancer2
index = which(placo_1MB$cancer2<placo_1MB$cancer1)
col_name = colnames(placo_1MB)
tmp = placo_1MB[index,c("snpid","p.placo","cancer2","cancer1")]
colnames(tmp) = col_name
placo_1MB[index,] = tmp

placo_1MB$log10P = -log10(placo_1MB$`p.placo`)
write_tsv(placo_1MB, "/home/yanyq/database/flask_vue/data/placo_1MB")
placo_1MB = as.data.frame(read_tsv("/home/yanyq/database/flask_vue/data/placo_1MB"))
placo_1MB$cancer1[placo_1MB$cancer1=="Endometrioid Cancer"] = "Endometrial cancer"
placo_1MB$cancer2[placo_1MB$cancer2=="Endometrioid Cancer"] = "Endometrial cancer"
write_tsv(placo_1MB, "/home/yanyq/database/flask_vue/data/placo_1MB")

#####################################################
# 多效基因，并加入共定位信息
#####################################################
placo_gene = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/all"))
placo_gene = placo_gene[!grepl("CORP",placo_gene$trait),]
placo_gene$flag = paste0(placo_gene$trait,":",placo_gene$locus.MAGMA)
placo_gene[placo_gene$flag%in%placo_gene$flag[c(2361,2771)],] # 有两个重复，位于多个locus.FUMA
placo_gene = placo_gene[!duplicated(placo_gene$flag),]

coloc = as.data.frame(read_tsv("~/share_genetics/result/coloc_MAGMA/summary/all"))
coloc$flag = paste0(coloc$traits,":",coloc$locus) # 14个重复
tmp = coloc[coloc$flag%in%coloc$flag[which(duplicated(coloc$flag))],] 
coloc = unique(coloc)

placo_gene = dplyr::left_join(placo_gene,coloc,by = "flag")
which(is.na(placo_gene$PP.H4.abf))

placo_gene = tidyr::separate(placo_gene,'trait',into = c("trait1","trait2"),sep = "-")

abbrev = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/english_abbrev"))
colnames(abbrev) = c("cancer1","trait1")
placo_gene = dplyr::left_join(placo_gene,abbrev,by = "trait1")
colnames(abbrev) = c("cancer2","trait2")
placo_gene = dplyr::left_join(placo_gene,abbrev,by = "trait2")
which(is.na(placo_gene$cancer1))
which(is.na(placo_gene$cancer2))


placo_gene = placo_gene[,-(which(colnames(placo_gene)%in%c("trait1","trait2")))]
# 每一行对cancer1和cancer2排序，保证cancer1小于cancer2
index = which(placo_gene$cancer2<placo_gene$cancer1)
tmp = placo_gene$cancer1[index]
placo_gene$cancer1[index] = placo_gene$cancer2[index]
placo_gene$cancer2[index] = tmp
tmp = placo_gene$P.triat1[index]
placo_gene$P.triat1[index] = placo_gene$P.trait2[index]
placo_gene$P.trait2[index] = tmp
tmp = placo_gene$fdr.trait1[index]
placo_gene$fdr.trait1[index] = placo_gene$fdr.trait2[index]
placo_gene$fdr.trait2[index] = tmp
# 排序
placo_gene = placo_gene[(order(placo_gene$cancer1, placo_gene$cancer2,placo_gene$CHR,placo_gene$START)),]
write_tsv(placo_gene, "/home/yanyq/database/flask_vue/data/placo_gene")
placo_gene = as.data.frame(read_tsv("/home/yanyq/database/flask_vue/data/placo_gene"))
placo_gene$log10FDR = -log10(placo_gene$fdr.PLACO)
write_tsv(placo_gene, "/home/yanyq/database/flask_vue/data/placo_gene")
placo_gene = as.data.frame(read_tsv("/home/yanyq/database/flask_vue/data/placo_gene"))
placo_gene$cancer1[placo_gene$cancer1=="Endometrioid Cancer"] = "Endometrial cancer"
placo_gene$cancer2[placo_gene$cancer2=="Endometrioid Cancer"] = "Endometrial cancer"
write_tsv(placo_gene, "/home/yanyq/database/flask_vue/data/placo_gene")

