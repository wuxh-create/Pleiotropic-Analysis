library(data.table)
library(readr)
library(GenomicRanges)
library(IRanges)
# library(clusterProfiler)
library(org.Hs.eg.db)

# 筛选和FUMA重叠的基因
rm(list = ls())
setwd("/home/yanyq/share_genetics/result/MAGMA/asso")
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
    if(file.exists(paste0("/home/yanyq/share_genetics/result/MAGMA/asso/PLACO_",trait1,"-",trait2,"_10_1.5.genes.out"))&file.exists(paste0("~/share_genetics/result/FUMA/merge/",trait1,"-",trait2))){
      FUMA = fread(paste0("~/share_genetics/result/FUMA/merge/",trait1,"-",trait2))
      MAGMA_PLACO = fread(paste0("/home/yanyq/share_genetics/result/MAGMA/asso/PLACO_",trait1,"-",trait2,"_10_1.5.genes.out"))
      MAGMA_PLACO$fdr = p.adjust(MAGMA_PLACO$P,method = "BH")
      MAGMA_PLACO$locus = paste0(MAGMA_PLACO$CHR,":",MAGMA_PLACO$START,"-",MAGMA_PLACO$STOP)
      MAGMA_PLACO_overlap = findOverlaps(query = as(MAGMA_PLACO$locus,"GRanges"), subject = as(FUMA$locus,"GRanges"))
      MAGMA_PLACO = MAGMA_PLACO[MAGMA_PLACO_overlap@from,]
      MAGMA_PLACO$GenomicLocus = MAGMA_PLACO_overlap@to
      MAGMA_PLACO = unique(MAGMA_PLACO)
      
      MAGMA_trait1 = fread(paste0("/home/yanyq/share_genetics/result/MAGMA/asso/",trait1,"_10_1.5.genes.out"))
      MAGMA_trait1$fdr = p.adjust(MAGMA_trait1$P,method = "BH")
      MAGMA_trait1$locus = paste0(MAGMA_trait1$CHR,":",MAGMA_trait1$START,"-",MAGMA_trait1$STOP)
      MAGMA_trait1Oerlap = findOverlaps(query = as(MAGMA_trait1$locus,"GRanges"), subject = as(FUMA$locus,"GRanges"))
      MAGMA_trait1 = MAGMA_trait1[MAGMA_trait1Oerlap@from,]
      MAGMA_trait1$GenomicLocus = MAGMA_trait1Oerlap@to
      MAGMA_trait1 = unique(MAGMA_trait1)
      MAGMA_trait1 = MAGMA_trait1[MAGMA_trait1$GENE%in%MAGMA_PLACO$GENE,]
      
      MAGMA_trait2 = fread(paste0("/home/yanyq/share_genetics/result/MAGMA/asso/",trait2,"_10_1.5.genes.out"))
      MAGMA_trait2$fdr = p.adjust(MAGMA_trait2$P,method = "BH")
      MAGMA_trait2$locus = paste0(MAGMA_trait2$CHR,":",MAGMA_trait2$START,"-",MAGMA_trait2$STOP)
      MAGMA_trait2_overlap = findOverlaps(query = as(MAGMA_trait2$locus,"GRanges"), subject = as(FUMA$locus,"GRanges"))
      MAGMA_trait2 = MAGMA_trait2[MAGMA_trait2_overlap@from,]
      MAGMA_trait2$GenomicLocus = MAGMA_trait2_overlap@to
      colnames(MAGMA_trait2)[9] = paste0("P.",trait2)
      colnames(MAGMA_trait2)[10] = paste0("fdr.",trait2)
      MAGMA_trait2 = unique(MAGMA_trait2)
      MAGMA_trait2 = MAGMA_trait2[MAGMA_trait2$GENE%in%MAGMA_PLACO$GENE,]
      
      if(nrow(MAGMA_PLACO)==nrow(MAGMA_trait1)&nrow(MAGMA_PLACO)==nrow(MAGMA_trait2)){
        MAGMA_PLACO = merge(MAGMA_PLACO, MAGMA_trait1[,c(1,9,10)], suffixes = c(".PLACO",paste0(".",trait1)),by = "GENE")
        MAGMA_PLACO = merge(MAGMA_PLACO, MAGMA_trait2[,c(1,9,10)], by = "GENE")
        MAGMA_PLACO = merge(MAGMA_PLACO, FUMA[,c(1,15)], suffixes = c(".MAGMA",".FUMA"), by = "GenomicLocus")
        # gene = bitr(MAGMA_PLACO$GENE,"ENTREZID","SYMBOL","org.Hs.eg.db")
        # gene$ENTREZID = as.numeric(gene$ENTREZID)
        # if((nrow(gene)==nrow(MAGMA_PLACO))&(length(unique(gene$ENTREZID))==nrow(gene))){
        #   MAGMA_PLACO = merge(MAGMA_PLACO,gene,by.x = "GENE",by.y = "ENTREZID")
        # }else{
        #   print(paste0("error geneID map: ", trait1,"-",trait2))
        #   colnames(gene)[1] = "GENE"
        #   MAGMA_PLACO = dplyr::left_join(MAGMA_PLACO,gene,by="GENE")
        # }
        MAGMA_PLACO = dplyr::left_join(MAGMA_PLACO,gene,by="GENE")
        if(length(which(is.na(MAGMA_PLACO$GENE)))!=0){
          print(tmp)
        }
        MAGMA_PLACO = unique(MAGMA_PLACO)
        write_tsv(MAGMA_PLACO, paste0("/home/yanyq/share_genetics/result/MAGMA/asso_merge/",trait1,"-",trait2))
        write_tsv(MAGMA_PLACO[MAGMA_PLACO$P.PLACO<0.05,],paste0("/home/yanyq/share_genetics/result/MAGMA/asso_merge_p_0.05/",trait1,"-",trait2))
        write_tsv(MAGMA_PLACO[MAGMA_PLACO$fdr.PLACO<0.05,],paste0("/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/",trait1,"-",trait2))
        MAGMA_PLACO$trait = paste0(trait1,"-",trait2)
        colnames(MAGMA_PLACO)[c(13:16)] = c("P.triat1","fdr.trait1","P.trait2","fdr.trait2")
        all_p[[paste0(trait1,"-",trait2)]] = MAGMA_PLACO[MAGMA_PLACO$P.PLACO<0.05,]
        all_fdr[[paste0(trait1,"-",trait2)]] = MAGMA_PLACO[MAGMA_PLACO$fdr.PLACO<0.05,]
      }else{
        print(paste0("error merge: ", trait1,"-",trait2))
      }
    }
  }
}
write_tsv(do.call(rbind,all_p),"/home/yanyq/share_genetics/result/MAGMA/asso_merge_p_0.05/all")
write_tsv(do.call(rbind,all_fdr),"/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/all")

#################### 多效基因同时在两种癌症中有因果关系
dup_Gene = as.data.frame(read_tsv("/home/yanyq/cogenetics/result/多效基因"))
symbol = as.data.frame(read_tsv("/home/yanyq/cogenetics/data/eQTL/eQTLGen/cis-eQTLs-full_eQTLGen_AF_incl_nr_formatted_20191212.new.txt_besd-dense.epi_symbol"))
colnames(symbol)[2] = "probeID"
dup_Gene = left_join(dup_Gene, symbol[,c("probeID", "X5")], by = "probeID")
dup_Gene$trait = paste0(dup_Gene$cancer.trait1, "-", dup_Gene$cancer.trait2)

all_fdr = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/all"))
which(!dup_Gene$trait%in%all_fdr$trait)
dup_Gene$flag = paste0(dup_Gene$trait,":",dup_Gene$X5)
all_fdr$flag = paste0(all_fdr$trait, ":", all_fdr$SYMBOL)
dup_Gene = dup_Gene[dup_Gene$flag%in%all_fdr$flag,] # 49个

# 49个基因靶向药物
drug = as.data.frame(read_csv("/home/yanyq/share_genetics/data/Human_Drug_target_CRISPRko.csv", col_names = F))
dup_Gene$druggene = dup_Gene$X5%in%drug$X3

#################### 提取unique的基因，在FUMA中做gene2func
library(readr)
library(dplyr)
all_fdr = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/all"))
length(unique(all_fdr$GENE)) # 1184
# gene_symbol = bitr(unique(all_fdr$GENE), fromType = "ENTREZID", toType = c("ENSEMBL"),OrgDb = 'org.Hs.eg.db')
# length(unique(gene_symbol$ENSEMBL)) # 1263
# entrez_ENSG = as.data.frame(read_tsv("~/data/entrezID_ENSG"))
# gene_symbol = unique(all_fdr$GENE)
# entrez_ENSG = entrez_ENSG[entrez_ENSG$GeneID%in%gene_symbol,]
# entrez_ENSG = unique(entrez_ENSG) # 找到1170个entrez对应的ENSG，有四个entrez对应了两个ENSG存在重复
# length(unique(entrez_ENSG$Ensembl_gene_identifier)) # 1168
# entrez_ENSG[entrez_ENSG$Ensembl_gene_identifier%in%entrez_ENSG$Ensembl_gene_identifier[duplicated(entrez_ENSG$Ensembl_gene_identifier)],]
# write_tsv(as.data.frame(unique(entrez_ENSG$Ensembl_gene_identifier)), "/home/yanyq/share_genetics/result/MAGMA/uniqueGene" ,col_names = F)
write_tsv(as.data.frame(unique(all_fdr$GENE)), "/home/yanyq/share_genetics/result/MAGMA/uniqueGene" ,col_names = F)
# 统计多效基因在几个癌症中多效
all_fdr = all_fdr[,c("GENE", "trait")]
all_fdr = tidyr::separate(all_fdr, col = "trait", into = c("trait1","trait2"), sep = "-")
all_fdr = rbind(all_fdr[,c(1,2)],all_fdr[,c(1,3)]%>%rename(trait1=trait2))
all_fdr = unique(all_fdr)
all_fdr_frq = as.data.frame(table(all_fdr$GENE))
all_fdr_frq$Var1 = as.numeric(as.character(all_fdr_frq$Var1))
all_fdr_frq_frq = as.data.frame(table(all_fdr_frq$Freq))
write_tsv(all_fdr_frq_frq, "/home/yanyq/share_genetics/result/MAGMA/Gene_in_frq")
# 提取在五个以上的癌症中多效的基因
write_tsv(as.data.frame(unique(all_fdr_frq$Var1[all_fdr_frq$Freq>5])), "/home/yanyq/share_genetics/result/MAGMA/Gene_in_5cancer" ,col_names = F)
write_tsv(as.data.frame(unique(all_fdr_frq$Var1[all_fdr_frq$Freq>10])), "/home/yanyq/share_genetics/result/MAGMA/Gene_in_10cancer" ,col_names = F)

# all_fdr_frq_frq = as.data.frame(table(all_fdr_frq$Freq))
# all_fdr_frq_frq$Var1 = as.numeric(as.character(all_fdr_frq_frq$Var1))

################### 对所有的基因做富集分析
library(org.Hs.eg.db)
library(clusterProfiler)
all_fdr = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/all"))
enrich.go = enrichGO(gene = unique(all_fdr$GENE),  #待富集的基因列表
                      OrgDb = 'org.Hs.eg.db',  #指定物种的基因数据库，示例物种是绵羊（sheep）
                      keyType = 'ENTREZID',  #指定给定的基因名称类型，例如这里以 entrze id 为例
                      ont = 'ALL',  #GO Ontology，可选 BP、MF、CC，也可以指定 ALL 同时计算 3 者
                      pAdjustMethod = 'fdr',  #指定 p 值校正方法
                      pvalueCutoff = 1,  #指定 p 值阈值（可指定 1 以输出全部）
                      qvalueCutoff = 1,  #指定 q 值阈值（可指定 1 以输出全部）
                      readable = T)
enrich.go_table = as.data.frame(enrich.go)
KEGG_enrich = enrichKEGG(gene = unique(all_fdr$GENE), #即待富集的基因列表
                         keyType = "kegg",
                         pAdjustMethod = 'fdr',  #指定p值校正方法
                         organism= "human",  #hsa，可根据你自己要研究的物种更改，可在https://www.kegg.jp/brite/br08611中寻找
                         qvalueCutoff = 1, #指定 p 值阈值（可指定 1 以输出全部）
                         pvalueCutoff=1) #指定 q 值阈值（可指定 1 以输出全部）
KEGG_enrich_table = as.data.frame(KEGG_enrich)
