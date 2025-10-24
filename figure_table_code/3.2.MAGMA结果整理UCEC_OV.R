library(data.table)
library(readr)
library(GenomicRanges)
library(IRanges)

PLACO = fread("~/share_genetics/result/FUMA/merge/UCEC_OV")

MAGMA_UCEC_OV = fread("/home/yanyq/share_genetics/result/MAGMA/asso/UCEC_OV.genes.out")
MAGMA_UCEC_OV$locus = paste0(MAGMA_UCEC_OV$CHR,":",MAGMA_UCEC_OV$START,"-",MAGMA_UCEC_OV$STOP)
MAGMA_UCEC_OV_overlap = findOverlaps(query = as(MAGMA_UCEC_OV$locus,"GRanges"), subject = as(PLACO$locus,"GRanges"))
MAGMA_UCEC_OV = MAGMA_UCEC_OV[MAGMA_UCEC_OV_overlap@from,]
MAGMA_UCEC_OV$GenomicLocus = MAGMA_UCEC_OV_overlap@to
MAGMA_UCEC_OV = unique(MAGMA_UCEC_OV)

MAGMA_UCEC = fread("/home/yanyq/share_genetics/result/MAGMA/asso/UCEC.genes.out")
MAGMA_UCEC$locus = paste0(MAGMA_UCEC$CHR,":",MAGMA_UCEC$START,"-",MAGMA_UCEC$STOP)
MAGMA_UCEC_overlap = findOverlaps(query = as(MAGMA_UCEC$locus,"GRanges"), subject = as(PLACO$locus,"GRanges"))
MAGMA_UCEC = MAGMA_UCEC[MAGMA_UCEC_overlap@from,]
MAGMA_UCEC$GenomicLocus = MAGMA_UCEC_overlap@to
MAGMA_UCEC = unique(MAGMA_UCEC)

MAGMA_OV = fread("/home/yanyq/share_genetics/result/MAGMA/asso/OV.genes.out")
MAGMA_OV$locus = paste0(MAGMA_OV$CHR,":",MAGMA_OV$START,"-",MAGMA_OV$STOP)
MAGMA_OV_overlap = findOverlaps(query = as(MAGMA_OV$locus,"GRanges"), subject = as(PLACO$locus,"GRanges"))
MAGMA_OV = MAGMA_OV[MAGMA_OV_overlap@from,]
MAGMA_OV$GenomicLocus = MAGMA_OV_overlap@to
colnames(MAGMA_OV)[9] = "P.OV"
MAGMA_OV = unique(MAGMA_OV)

MAGMA_UCEC_OV = merge(MAGMA_UCEC_OV, MAGMA_UCEC[,c(1,9)], suffixes = c(".PLACO",".UCEC"),by = "GENE")
MAGMA_UCEC_OV = merge(MAGMA_UCEC_OV, MAGMA_OV[,c(1,9)], by = "GENE")
MAGMA_UCEC_OV = merge(MAGMA_UCEC_OV, PLACO[,c(1,15)], suffixes = c(".MAGMA",".FUMA"), by = "GenomicLocus")
library(clusterProfiler)
library(org.Hs.eg.db)
gene = bitr(MAGMA_UCEC_OV$GENE,"ENTREZID","SYMBOL","org.Hs.eg.db")
gene$ENTREZID = as.numeric(gene$ENTREZID)
if((nrow(gene)==nrow(MAGMA_UCEC_OV))&(length(unique(gene$ENTREZID))==nrow(gene))){
  MAGMA_UCEC_OV = merge(MAGMA_UCEC_OV,gene,by.x = "GENE",by.y = "ENTREZID")
}
write_tsv(MAGMA_UCEC_OV, "/home/yanyq/share_genetics/result/MAGMA/merge")
