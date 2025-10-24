# > 2. 过滤无rsid或有重复rsid的SNP，仅保留双等位基因SNV
# > 3. 去除主要组织相容性复合体区域，chr6:25-35MB
# > 4. 次等位基因频率>0.01
# 去除性染色体

setwd("~/share_genetics/data/GWAS")
library(data.table)
library(readr)
library(vroom)

# f_remap = read.table("rsidmap/BRCA_transfer_remap",header = T)
# f_remap = f_remap[grep("rs",f_remap$SNP),]
f = read.table("rsidmap/BRCA.gz",header = T)
f = f[f$Effect.Meta%in%c("A","T","G","C")&f$Baseline.Meta%in%c("A","T","G","C"),]
f = f[grep("rs",f$SNP),]
table(f$chr.iCOGs)
f = f[f$chr.iCOGs!=23,]
f = f[!((f$chr.iCOGs==6)&(f$Position.iCOGs>25000000&f$Position.iCOGs<35000000)),] # 去除主要组织相容性复合体区域
f = f[f$Freq.Gwas<0.99&f$Freq.Gwas>0.01,]
f$SNP[duplicated(f$SNP)]
f = f[!duplicated(f$SNP),] # 9206850-9193201
f$SNP[duplicated(f$SNP)]
f$OR = exp(f$Beta.meta)
f = f[,c("SNP","chr.iCOGs","Position.iCOGs","Effect.Meta","Baseline.Meta","OR","sdE.meta","p.meta","Freq.Gwas")]
colnames(f) = c("snpid", "hg19chr", "bp", "a1", "a2", "or", "se", "pval", "EURaf")
write_tsv(f,"processed/BRCA.gz")

f = vroom("rsidmap/lung.gz")
f = f[!((f$chromosome==6)&(f$base_pair_location>25000000&f$base_pair_location<35000000)),] # 去除主要组织相容性复合体区域
f = f[grep("rs",f$SNP),]
f = f[f$effect_allele%in%c("A","T","G","C")&f$other_allele%in%c("A","T","G","C"),]
f = f[f$chromosome!=23,]
table(f$chromosome)
f = f[!duplicated(f$SNP),]
f$SNP[duplicated(f$SNP)]
f = f[f$effect_allele_frequency<0.99&f$effect_allele_frequency>0.01,]
f = f[,c("SNP","chromosome","base_pair_location","effect_allele","other_allele","odds_ratio","standard_error","p_value","effect_allele_frequency")]
colnames(f) = c("snpid", "hg19chr", "bp", "a1", "a2", "or", "se", "pval","EURaf")
f = f[f$pval!=-99,]
write_tsv(f,"processed/lung.gz")

f = vroom("/home/yanyq/share_genetics/data/GWAS/rsidmap/OV.gz")
f = f[!((f$Chromosome==6)&(f$Position>25000000&f$Position<35000000)),] # 去除主要组织相容性复合体区域
f = f[f$EAF<0.99&f$EAF>0.01,]
f = f[f$Effect%in%c("A","T","G","C")&f$Baseline%in%c("A","T","G","C"),]
f = f[grep("rs",f$SNP),]
f = f[!duplicated(f$SNP),]
f$SNP[duplicated(f$SNP)]
f$overall_OR = exp(f$overall_OR)
f = f[,c("SNP","Chromosome","Position","Effect","Baseline","overall_OR","overall_SE","overall_pvalue","EAF")]
colnames(f) = c("snpid", "hg19chr", "bp", "a1", "a2", "or", "se", "pval", "EURaf")
f = f[f$pval!=-99,]
write_tsv(f,"processed/OV.gz")

f = vroom("/home/yanyq/share_genetics/data/GWAS/rsidmap/PRAD.gz")
f = as.data.frame(f)
f = f[(f$chromosome!=23)&(f$effect_allele%in%c("A","C","G","T"))&(f$other_allele%in%c("A","C","G","T")),]
f = f[f$effect_allele_frequency>0.01&f$effect_allele_frequency<0.99,]
f$base_pair_location = as.numeric(f$base_pair_location)
f$chromosome = as.numeric(f$chromosome)
f = f[!((f$chromosome==6)&(f$base_pair_location>25000000&f$base_pair_location<35000000)),] # 去除主要组织相容性复合体区域
f = f[grep("rs",f$SNP),]
f$SNP[duplicated(f$SNP)]
f = f[!duplicated(f$SNP),]
f$OR = exp(f$beta)
f = f[,c("SNP","chromosome","base_pair_location","effect_allele","other_allele","OR","standard_error","p_value","effect_allele_frequency")]
colnames(f) = c("snpid", "hg19chr", "bp", "a1", "a2", "or", "se", "pval", "EURaf")
write_tsv(f,"/home/yanyq/share_genetics/data/GWAS/processed/PRAD.gz")

f = vroom("rsidmap/UCEC.gz")
f$base_pair_location = as.numeric(f$base_pair_location)
f = f[!((f$chromosome==6)&(f$base_pair_location>25000000&f$base_pair_location<35000000)),] # 去除主要组织相容性复合体区域
f = f[grep("rs",f$SNP),]
f = f[f$effect_allele_frequency<0.99&f$effect_allele_frequency>0.01,]
f = f[f$effect_allele%in%c("A","C","G","T")&f$other_allele%in%c("A","C","G","T"),]
f$SNP[duplicated(f$SNP)]
f$OR = exp(f$beta)
f = f[,c("SNP","chromosome","base_pair_location","effect_allele","other_allele","OR","standard_error","p_value","effect_allele_frequency")]
colnames(f) = c("snpid", "hg19chr", "bp", "a1", "a2", "or", "se", "pval", "EURaf")
f = f[f$pval!=-99,]
write_tsv(f,"processed/UCEC.gz")


# finngen
# 筛选MAF、rsid、双等位基因
# 提取所有的finngen SNP
finngen_SNP = c()
for(i in c("BLCA","HNSC","kidney","PAAD","SKCM")){
  f = as.data.frame(vroom(paste0("rsidmap/",i,".gz")))
  colnames(f)[1] = "chrom"
  f = f[(f$chrom!=23)&(f$ref%in%c("A","T","G","C"))&(f$alt%in%c("A","T","G","C")),]
  f = f[f$af_alt>0.01&f$af_alt<0.99,]
  f = f[grep("rs",f$SNP),]
  f = f[!duplicated(f$SNP),]
  finngen_SNP = c(finngen_SNP,f$SNP)
  finngen_SNP = unique(finngen_SNP)
}
finngen_SNP = as.data.frame(finngen_SNP)
finngen_SNP$chr = NA
finngen_SNP$pos = NA
colnames(finngen_SNP)[1] = "SNP"
write_tsv(finngen_SNP, "/home/yanyq/share_genetics/data/GWAS/rsidmap/finngen_SNP")
# 注释hg19 坐标
#######################gwaslab
import gwaslab as gl
mysumstats = gl.Sumstats("/home/yanyq/share_genetics/data/GWAS/rsidmap/finngen_SNP", snpid="SNP",chrom = "chr",pos = "pos")
mysumstats.data['rsID'] = mysumstats.data['SNPID']
mysumstats.data['CHR'] = mysumstats.data['CHR'].astype('Int64')
mysumstats.data['POS'] = mysumstats.data['POS'].astype('Int64')
mysumstats.data['CHR'].dtypes
mysumstats.data['POS'].dtypes
mysumstats.rsid_to_chrpos2(path="/home/yanyq/software/rsidmap/dbsnp/GCF_000001405.25.gz.rsID_CHR_POS_groups_20000000.h5")
mysumstats.data.to_csv("/home/yanyq/share_genetics/data/GWAS/rsidmap/finngen_SNP_hg19",header = True, index = False, sep = "\t")
##############################
finngen_SNP_hg19 = as.data.frame(vroom("/home/yanyq/share_genetics/data/GWAS/rsidmap/finngen_SNP_hg19"))
which(finngen_SNP_hg19$SNPID!=finngen_SNP_hg19$rsID)
table(finngen_SNP_hg19$CHR)
table(finngen_SNP_hg19$STATUS)
length(finngen_SNP_hg19$POS[is.na(finngen_SNP_hg19$POS)]) # 39462个无
finngen_SNP_hg19 = finngen_SNP_hg19[!is.na(finngen_SNP_hg19$POS),]
finngen_SNP_hg19 = finngen_SNP_hg19[,c(1,3,4)]
colnames(finngen_SNP_hg19) = c("SNP","chr_hg19","pos_hg19")
# library(SNPlocs.Hsapiens.dbSNP155.GRCh37) # dbSNP和下载的GCF_000001405.25.gz文件中同一个rs号对应不同的SNP，如rs370272972，不要用这个注释坐标
# snps = SNPlocs.Hsapiens.dbSNP155.GRCh37
# loc_hg19 = snpsById(snps,finngen_SNP,ifnotfound="drop")
# loc_hg19 = as.data.frame(loc_hg19)
# write_tsv(loc_hg19,"/home/yanyq/share_genetics/data/GWAS/rsidmap/loc_hg19")
# finngen_SNP_hg19_F = finngen_SNP[!finngen_SNP%in%loc_hg19$RefSNP_id] # 没有注释到hg19
# write_tsv(as.data.frame(finngen_SNP_hg19_F),"/home/yanyq/share_genetics/data/GWAS/rsidmap/finngen_SNP_hg19_F", col_names = F)
# # for(i in 1:396){
# #   write_tsv(as.data.frame(finngen_SNP_hg19_F[((i-1)*100+1):(i*100)]),paste0("/home/yanyq/share_genetics/data/GWAS/rsidmap/finngen_SNP_hg19_F_500/finngen_SNP_hg19_F_",i), col_names = F)
# # }
# # write_tsv(as.data.frame(finngen_SNP_hg19_F[((397-1)*100+1):length(finngen_SNP_hg19_F)]),paste0("/home/yanyq/share_genetics/data/GWAS/rsidmap/finngen_SNP_hg19_F_500/finngen_SNP_hg19_F_","397"), col_names = F)
# 
# ############################## python
# import json
# import pandas as pd
# import requests
# import bs4
# from bs4 import BeautifulSoup
# import os
# headers = { # 开发者工具 → network → request header → user-agent
#   "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36 Edg/116.0.1938.62"
# } # 把爬虫伪装成正常浏览器
# 
# SNP_with_hg19 = []
# SNP_without = []
# SNP_res_error = []
# with open("/home/yanyq/share_genetics/data/GWAS/rsidmap/finngen_SNP_hg19_F") as SNP_file:
#   for SNP in SNP_file:
#   SNP = ''.join(SNP).strip('\n')
# print(SNP)
# response = requests.get("https://www.ncbi.nlm.nih.gov/snp/?term="+SNP)
# if response.ok:
#   if not ":-1" in response.text:
#   SNP_with_hg19.append(SNP)
# else:
#   SNP_without.append(SNP)
# else:
#   SNP_res_error.append(SNP)
# 
# f = open("/home/yanyq/share_genetics/data/GWAS/rsidmap/finngen_SNP_hg19_F_search_with_hg19","w")
# for line in SNP_with_hg19:
#   f.write(line+'\n')
# f.close()
# f = open("/home/yanyq/share_genetics/data/GWAS/rsidmap/finngen_SNP_hg19_F_search_without","w")
# for line in SNP_without:
#   f.write(line+'\n')
# f.close()
# f = open("/home/yanyq/share_genetics/data/GWAS/rsidmap/finngen_SNP_hg19_F_search_res_error","w")
# for line in SNP_res_error:
#   f.write(line+'\n')
# f.close()
# ###########################
# SNP_with_hg19 = read_tsv("~/share_genetics/data/GWAS/rsidmap/finngen_SNP_hg19_F_search_with_hg19",col_names = F)
# write_tsv(as.data.frame(paste(SNP_with_hg19$X1, collapse = " OR ")), "~/tmp")
# SNP_with_hg19 = read_tsv("/home/yanyq/share_genetics/data/GWAS/rsidmap/SNP_hg19.txt") # dbsnp检索结果
# SNP_with_hg19 = SNP_with_hg19[,c("uid","SNP_ID","CHRPOS_PREV_ASSM")]
# colnames(SNP_with_hg19)[2] = "uid"
# SNP_with_hg19 = rbind(as.data.frame(SNP_with_hg19[,c(1,3)]),as.data.frame(SNP_with_hg19[,c(2,3)]))
# SNP_with_hg19 = unique(SNP_with_hg19)
# SNP_with_hg19 = tidyr::separate(SNP_with_hg19,col = "CHRPOS_PREV_ASSM",into = c("chr","pos"), sep = ":")
# SNP_with_hg19$uid = paste0("rs",SNP_with_hg19$uid)
# SNP_with_hg19[SNP_with_hg19$uid%in%duplicated(SNP_with_hg19$uid),]
# loc_hg19 = loc_hg19[,c(4,1,2)]
# colnames(loc_hg19) = c("SNP","chr_hg19","pos_hg19")
# colnames(SNP_with_hg19) = c("SNP","chr_hg19","pos_hg19")
# loc_hg19 = rbind(loc_hg19,SNP_with_hg19)
# table(loc_hg19$chr_hg19)
# loc_hg19[loc_hg19$chr_hg19=="NT_187369.1",]

for(i in c("BLCA","HNSC","kidney","PAAD","SKCM")){
  f = as.data.frame(vroom(paste0("rsidmap/",i,".gz")))
  colnames(f)[1] = "chrom"
  f = f[(f$chrom!=23)&(f$ref%in%c("A","T","G","C"))&(f$alt%in%c("A","T","G","C")),]
  f = f[f$af_alt>0.01&f$af_alt<0.99,]
  f = f[grep("rs",f$SNP),]
  f = f[!duplicated(f$SNP),]
  f = dplyr::left_join(f,finngen_SNP_hg19,by = "SNP")
  f = f[!is.na(f$pos_hg19),]
  print(length(which(f$chrom!=f$chr_hg19)))
  f = f[!((f$chrom==6)&(f$pos_hg19>25000000&f$pos_hg19<35000000)),] # 去除主要组织相容性复合体区域
  f$OR = exp(f$beta)
  f = f[,c("SNP","chrom","pos_hg19","alt","ref","OR","sebeta","pval","af_alt")]
  colnames(f) = c("snpid", "hg19chr", "bp", "a1", "a2", "or", "se", "pval", "EURaf")
  f = f[f$pval!=-99,]
  write_tsv(f,paste0("processed/",i,".gz"))
}
