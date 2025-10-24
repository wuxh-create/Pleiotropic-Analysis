library(data.table)
library(readr)
library(GenomicRanges)
library(IRanges)
library(clusterProfiler)
library(org.Hs.eg.db)

# 筛选EMAGMA和FUMA重叠的基因

setwd("/home/yanyq/share_genetics/result/EMAGMA/asso")
tissue = list.dirs() # 47种组织
tissue = tissue[-1]

traits = c("BLCA","BRCA",	"HNSC",	"kidney",	"lung",	"OV",	'PAAD',	"PRAD",	'SKCM',	"UCEC",
           "BGC", "CRC", "DLBC", "ESCA", "STAD", "THCA","AML", "BAC", "BCC" ,"BGA", "BM",
           "CESC", "CML", "CORP" ,"EYAD" ,"GSS", "HL", "LIHC" ,"LL" ,"MCL", "MESO", "MM" ,
           "MS" ,"MZBL", "SCC" ,"SI", "TEST", "VULVA")
gene = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/MAGMA/NCBI37.3/NCBI37.3.gene.loc", col_names = F))
colnames(gene)[c(1,6)] = c("GENE","SYMBOL")
all_p = list()
all_fdr = list()
for(trait1 in traits){
  for(trait2 in traits){
    tmp = paste0(trait1,"-",trait2)
    if(file.exists(paste0(tissue[1],"/PLACO_",trait1,"-",trait2,".genes.out"))&file.exists(paste0("~/share_genetics/result/FUMA/merge/",trait1,"-",trait2))){
      # FUMA结果
      FUMA = fread(paste0("~/share_genetics/result/FUMA/merge/",trait1,"-",trait2))
      for(cur_tissue in tissue){
        # cur_tissue = tissue[1]
        MAGMA_PLACO = fread(paste0(cur_tissue,"/PLACO_",trait1,"-",trait2,".genes.out"))
        MAGMA_PLACO$fdr = p.adjust(MAGMA_PLACO$P,method = "BH")
        
        # 筛选FUMA上的基因
        MAGMA_PLACO$locus = paste0(MAGMA_PLACO$CHR,":",MAGMA_PLACO$START,"-",MAGMA_PLACO$STOP)
        MAGMA_PLACO_overlap = findOverlaps(query = as(MAGMA_PLACO$locus,"GRanges"), subject = as(FUMA$locus,"GRanges"))
        MAGMA_PLACO = MAGMA_PLACO[MAGMA_PLACO_overlap@from,]
        MAGMA_PLACO$GenomicLocus = MAGMA_PLACO_overlap@to
        MAGMA_PLACO = unique(MAGMA_PLACO)
        MAGMA_PLACO = merge(MAGMA_PLACO, FUMA[,c(1,15)], suffixes = c(".MAGMA",".FUMA"), by = "GenomicLocus")
        
        MAGMA_PLACO = dplyr::left_join(MAGMA_PLACO,gene,by="GENE")
        if(length(which(is.na(MAGMA_PLACO$GENE)))!=0){
          print(tmp)
        }
        if(nrow(MAGMA_PLACO)>0){
          write_tsv(MAGMA_PLACO, paste0("../","asso_merge/",cur_tissue,"/",trait1,"-",trait2))
          write_tsv(MAGMA_PLACO[MAGMA_PLACO$P<0.05,],paste0("../","asso_merge_p_0.05/",cur_tissue,"/",trait1,"-",trait2))
          write_tsv(MAGMA_PLACO[MAGMA_PLACO$fdr<0.05,],paste0("../","asso_merge_fdr_0.05/",cur_tissue,"/",trait1,"-",trait2))
          MAGMA_PLACO$trait = paste0(trait1,"-",trait2)
          MAGMA_PLACO$tissue = cur_tissue
          all_p[[paste0(trait1,"-",trait2,gsub('./','-',cur_tissue))]] = MAGMA_PLACO[MAGMA_PLACO$P.PLACO<0.05,]
          all_fdr[[paste0(trait1,"-",trait2,gsub('./','-',cur_tissue))]] = MAGMA_PLACO[MAGMA_PLACO$fdr.PLACO<0.05,]
        }
      }
    }
  }
}
write_tsv(do.call(rbind,all_p),"/home/yanyq/share_genetics/result/EMAGMA/asso_merge_p_0.05/all")
write_tsv(do.call(rbind,all_fdr),"/home/yanyq/share_genetics/result/EMAGMA/asso_merge_fdr_0.05/all")
