# 表型富集分析
# 组织特异性富集分析
# 没必要做组织特异性富集
# 原文做脑肠病的共享机制，本研究做不同组织的癌症
library(data.table)
library(readr)
# grep MP MGI_phenotype_annotation.txt > MGI_phenotype_annotation_withMP
anno = fread("/home/yanyq/share_genetics/data/MGI_phenotype_annotation.txt",header = F) # 基因表型注释
length(unique(anno$V1))
# MAGMA = fread("/home/yanyq/share_genetics/result/MAGMA/asso_merge")
MAGMA = fread("/home/yanyq/share_genetics/MAGMA_correct.txt")
MAGMA$PPLACO = gsub("–","-",MAGMA$PPLACO)
MAGMA$PPSY = gsub("–","-",MAGMA$PPSY)
MAGMA$PGIT = gsub("–","-",MAGMA$PGIT)
tmp = strsplit(MAGMA$PPLACO,"×")
tmp = do.call(rbind,tmp)
tmp[,2] = substring(tmp[,2],3)
MAGMA$PPLACO = as.numeric(paste0(tmp[,1],rep("e",nrow(tmp)),tmp[,2]))
tmp = strsplit(MAGMA$PPSY,"×")
tmp = do.call(rbind,tmp)
tmp[,2] = substring(tmp[,2],3)
MAGMA$PPSY = as.numeric(paste0(tmp[,1],rep("e",nrow(tmp)),tmp[,2]))
tmp = strsplit(MAGMA$PGIT,"×")
tmp = do.call(rbind,tmp)
tmp[,2] = substring(tmp[,2],3)
MAGMA$PGIT = as.numeric(paste0(tmp[,1],rep("e",nrow(tmp)),tmp[,2]))
MAGMA = MAGMA[MAGMA$PGIT<0.05&MAGMA$PPLACO<0.05&MAGMA$PPSY<0.05&MAGMA$SigPLACO=="TRUE",]
ple = unique(MAGMA$EntrezID) # 多效基因座

length(unique(anno$V2[anno$V2%in%MAGMA$EntrezID]))
pheno = as.matrix(anno[anno$V2%in%MAGMA$EntrezID,5:30])
pheno_uniq = c()
for(i in 1:ncol(pheno)){
  pheno_uniq = c(pheno_uniq,pheno[,i])
}
pheno_uniq = unique(pheno_uniq)
pheno_uniq = pheno_uniq[grep("MP",pheno_uniq)] # 表型
anno = as.matrix(anno)
anno[,2] = as.numeric(anno[,2])
pheno_enrich_table = list()
for(p in pheno_uniq){
  gene_P = c() # 被表型注释的基因
  for(i in 5:30){
    gene_P = c(gene_P,anno[which(anno[,i]==p),2])
  }
  gene_P = unique(gene_P)
  gene_P = as.numeric(gene_P)
  gene_P_ple = unique(gene_P[gene_P%in%ple]) # 与该表型相关的多效基因座
  gene_nP = unique(anno[!(anno[,2]%in%gene_P),2]) # 未被该表型注释的基因
  gene_nP_ple = unique(gene_nP[gene_nP%in%ple])
  # 构建列联表
  pheno_enrich_table [[p]] = c(length(gene_P_ple),length(gene_nP_ple),length(gene_P)-length(gene_P_ple),
                               length(gene_nP)-length(gene_nP_ple))
}
# Fisher检验
pheno_enrich_table = as.data.frame(do.call(rbind,pheno_enrich_table))
pheno_enrich_table$fisher_P = NA
for(i in 1:nrow(pheno_enrich_table)){
  tmp = matrix(unlist(pheno_enrich_table[i,1:4]),nrow = 2)
  p = fisher.test(tmp)
  pheno_enrich_table$fisher_P[i] = p$p.value
}
write_tsv(pheno_enrich_table,"")

##################################################################################
library(deTS)
library(pheatmap)
data(GTEx_t_score) # the t-statistic matrix for the GTEx panel
data(ENCODE_z_score) # the z-score matrix for the ENCODE panel
data(correction_factor) # the summary statistics for the GTEx tissues
query.genes = unique(MAGMA$`Gene symbol`)
# Tissue-specific analysis for query gene list.
#  c("holm", "hochberg", "hommel", "bonferroni", "BH", "BY","fdr", "none")

my.tsea.analysis <-
  function(query_gene_list, score, ratio = 0.05, p.adjust.method = "BH"){
    if (mode(query_gene_list)!="character"){
      print ("Please input a gene symbol list!")
      stop;
    }
    if (length(query_gene_list) < 20){
      print("At least 20 genes are needed for tissue-specific enrichment analysis!")
      stop;
    }else{
      query_list_gene_matched = intersect(query_gene_list, rownames(score))
      query.tsea_FET.mat = matrix(1, nrow = ncol(score), ncol = 3);
      rownames(query.tsea_FET.mat) = colnames(score)
      colnames(query.tsea_FET.mat) = c("query","num","genes");
      for(k.tissue in 1:ncol(score)){
        which(as.numeric(as.vector(score[,k.tissue])) > quantile(as.numeric(as.vector(score[,k.tissue])), probs = (1 - ratio), na.rm = TRUE )) -> ii
        genes.for.test = rownames(score)[ii]
        common = length(intersect(query_list_gene_matched, genes.for.test))
        query.tsea_FET.mat[k.tissue, 2] = common
        query.tsea_FET.mat[k.tissue, 3] = paste(intersect(query_list_gene_matched, genes.for.test),collapse = ",")
        unique_query = length(setdiff(query_list_gene_matched, genes.for.test))
        unique_tissue = length(setdiff(genes.for.test, query_list_gene_matched))
        remain = nrow(score) - common - unique_query - unique_tissue
        fisher_test = fisher.test(matrix(c(common, unique_query, unique_tissue, remain), nrow=2), alternative = "greater")$p.value
        query.tsea_FET.mat[k.tissue, 1] = fisher_test
        
        cat(".", sep = "")
      }
    }
    query.tsea_FET.mat[,1] = p.adjust(query.tsea_FET.mat[,1], p.adjust.method)
    return(query.tsea_FET.mat)
  }

tsea_t = my.tsea.analysis(query.genes, GTEx_t_score,p.adjust.method = "none",ratio = 0.1)
tsea_t = my.tsea.analysis(query.genes, ENCODE_z_score,p.adjust.method = "none",ratio = 0.1)
# tsea.plot(tsea_t, 0.05)
# tsea.summary(tsea_t)

#########################################################################
# 基因集富集分析
library(clusterProfiler)
library(org.Hs.eg.db)
library(biomaRt)
library(DOSE)

IBD_AN = fread("~/share_genetics/result/MAGMA/asso/tmp.genes.out") # MAGMA对所有SNP分析的结果
IBD_AN = IBD_AN[order(IBD_AN$ZSTAT,decreasing = T),]
genelist = IBD_AN$ZSTAT
names(genelist) = IBD_AN$GENE

# nPerm = 1000, minGSSize = 10, maxGSSize = 1000,
Go_gseresult <- gseGO(genelist, 'org.Hs.eg.db', keyType = "ENTREZID", ont="all",  pvalueCutoff=1,scoreType = "pos")
KEGG_gseresult <- gseKEGG(genelist,  pvalueCutoff=0.05,scoreType = "pos")

#######################################################################
# E-MAGMA
eMAGMA = fread("~/share_genetics/result/EMAGMA/Whole_Blood/IBD_AN.genes.out")
eMAGMA$locus = paste0(eMAGMA$CHR,":",eMAGMA$START,"-",eMAGMA$STOP)
library(GenomicRanges)
library(IRanges)
MAGMA = MAGMA[MAGMA$`Trait pairs`=="IBD–AN",]
MAGMA$chr = NA
MAGMA$chr[1:2] = 1
MAGMA$chr[2:45] = 3
overlap = findOverlaps(as(eMAGMA$locus, "GRanges"),as(paste0(MAGMA$chr,":",MAGMA$`Locus position`),"GRanges"))
eMAGMA = eMAGMA[overlap@from,]
eMAGMA$no.locus = MAGMA$`No loci`[overlap@to]
eMAGMA = eMAGMA[eMAGMA$P<0.05,]
eMAGMA = unique(eMAGMA)
