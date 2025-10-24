# 多效基因座网络图
library(networkD3)
library(readr)
library(GenomicRanges)
library(dplyr)

# 以1q13.3命名基因组区间的文件
chr_name = as.data.frame(read_tsv("/home/yanyq/data/cytoBand_hg19.txt.gz", col_names = F))
chr_name$X1 = gsub("chr","",chr_name$X1)
chr_name$X4 = paste0(chr_name$X1, chr_name$X4)
chr_GR = as(paste0(chr_name$X1, ":", chr_name$X2, "-", chr_name$X3), "GRanges")

traits = c("BLCA","BRCA", "HNSC", "kidney", "lung", "OV", 'PAAD', "PRAD", 'SKCM', "UCEC",
           "BGC", "CRC", "DLBC", "ESCA", "STAD", "THCA","AML", "BAC", "BCC" ,"BGA", "BM",
           "CESC", "CML", "CORP" ,"EYAD" ,"GSS", "HL", "LIHC" ,"LL" ,"MCL", "MESO", "MM" ,
           "MS" ,"MZBL", "SCC" ,"SI", "TEST", "VULVA")
MAGMA = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/all"))

for(trait in traits){
  children_1 = gsub(trait, "", unique(MAGMA$trait[grep(trait, MAGMA$trait)]))
  children_1 = gsub("-","",children_1)
  child_1_list = list()
  for(child_1 in 1:length(children_1)){
    this.MAGMA = MAGMA[MAGMA$trait%in%c(paste0(trait,"-", children_1[child_1]),paste0(children_1[child_1],"-", trait)),]
    FUMA_GR = as(this.MAGMA$locus.FUMA, "GRanges")
    FUMA_chr = findOverlaps(FUMA_GR, chr_GR, select = "first")
    this.MAGMA$chr_name = chr_name$X4[FUMA_chr]
    child_2_list = list()
    locus = unique(this.MAGMA$chr_name)
    for(loci in 1:length(locus)){
      this.gene = this.MAGMA$SYMBOL[this.MAGMA$chr_name==locus[loci]]
      this.fdr = this.MAGMA$fdr.PLACO[this.MAGMA$chr_name==locus[loci]]
      this.gene = this.gene[order(this.fdr)]
      child_3_list = list()
      for(gene in 1:length(this.gene)){
        child_3_list[[gene]] = list(name = this.gene[gene])
      }
      child_2_list[[loci]] = list(name = locus[loci], children = child_3_list)
    }
    child_1_list[[child_1]] = list(name = children_1[child_1], children = child_2_list)
  }
  relation = list(name = trait, children = child_1_list)
  # # Create graph
  # tmp = list(name = trait, 
  #            children = list(relation$children[[1]],
  #                            relation$children[[2]],
  #                            relation$children[[3]],
  #                            relation$children[[4]],
  #                            relation$children[[5]],
  #                            relation$children[[6]],
  #                            relation$children[[7]]))
  radialNetwork(List = relation, fontSize = 10, fontFamily = "arial") %>%
    saveNetwork(file = paste0("/home/yanyq/share_genetics/result/MAGMA/1_circ_plot/", trait, ".html"))
  # pdf(paste0("/home/yanyq/share_genetics/result/MAGMA/1_circ_plot/", trait, ".pdf") ,height = 10, width = 10)
  # p
  # dev.off()
}

# # FUMA注释的基因进行绘图
# for(trait in traits){
#   this_files = files[grepl(trait, files)&files!=trait]
#   # 第一层为各性状
#   children_1 = gsub(trait, "", this_files)
#   children_1 = gsub("-","",children_1)
#   child_1_list = list()
#   for(child_1 in 1:length(children_1)){
#     file_name = this_files[grep(children_1[child_1], this_files)]
#     FUMA = as.data.frame(read_tsv(paste0(file_name, "/GenomicRiskLoci.txt"))) # 性状对多效基因座
#     FUMA_GR = as(paste0(FUMA$chr, ":", FUMA$start, "-", FUMA$end), "GRanges")
#     FUMA_chr = findOverlaps(FUMA_GR, chr_GR)
#     FUMA$chr_name = NA
#     # 若不存在一个FUMA基因座匹配多个染色体分区
#     if(!any(duplicated(FUMA_chr@from))){
#       FUMA$chr_name[FUMA_chr@from] = chr_name$X4[FUMA_chr@to]
#       FUMA$chr_name = paste0(FUMA$chr, FUMA$chr_name) # 用染色体分区命名多效基因座
#       genes = as.data.frame(read_tsv(paste0(file_name, "/genes.txt")))
#       # 第二层为多效基因座
#       child_2_list = list()
#       for(loci in 1:nrow(FUMA)){
#         this.gene = genes$symbol[genes$GenomicLocus==FUMA$GenomicLocus[loci]]
#         this.pLI  = genes$pLI[genes$GenomicLocus==FUMA$GenomicLocus[loci]]
#         this.pLI[is.na(this.pLI)] = -1
#         this.gene = this.gene[order(this.pLI, decreasing = T)]
#         # 第三层为FUMA基因座注释的基因
#         child_3_list = list()
#         if(length(this.gene)>0){
#           this.length = ifelse(length(this.gene)>3, 3, length(this.gene))
#           for(i in 1:this.length){
#             child_3_list[[i]] = list(name = this.gene[i])
#           }
#           
#         }
#         child_2_list[[loci]] = list(name = FUMA$chr_name[loci], children = child_3_list)
#       }
#       child_1_list[[child_1]] = list(name = children_1[child_1], children = child_2_list)
#     }else{
#       print(file_name)
#     }
#   }
#   relation = list(name = trait, children = child_1_list)
#   # Create graph
#   tmp = list(name = "BLCA", 
#              children = list(relation$children[[1]],
#                              relation$children[[2]],
#                              relation$children[[3]],
#                              relation$children[[4]],
#                              relation$children[[5]],
#                              relation$children[[6]],
#                              relation$children[[7]],
#                              relation$children[[8]],
#                              relation$children[[9]],
#                              relation$children[[10]],
#                              relation$children[[11]],
#                              relation$children[[12]],
#                              relation$children[[13]]))
#   pdf(paste0("/home/yanyq/share_genetics/result/MAGMA/1_circ_plot/", trait, ".pdf") ,height = 10, width = 5)
#   p = radialNetwork(List = relation, fontSize = 7)
#   print(p)
#   dev.off()
# }
# 
# 

