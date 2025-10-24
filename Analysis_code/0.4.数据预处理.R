# > 2. 过滤无rsid或有重复rsid的SNP，仅保留双等位基因SNV
# > 3. 去除主要组织相容性复合体区域，chr6:25-35MB
# > 4. 次等位基因频率>0.01
# 去除性染色体
# OV和PRAD反向链上重新注释到了rsid

setwd("~/share_genetics/data/GWAS")
library(data.table)
library(readr)
library(vroom)

f_remap = read.table("rsidmap/BRCA_transfer_remap",header = T)
f_remap = f_remap[grep("rs",f_remap$SNP),] # 全是Indel
f = read.table("rsidmap/BRCA.gz",header = T)
f = f[grep("rs",f$SNP),]
f = rbind(f,f_remap)
f = f[f$Effect.Meta%in%c("A","T","G","C")&f$Baseline.Meta%in%c("A","T","G","C"),]
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

f_remap = vroom("rsidmap/lung_transfer_remap")
f_remap = f_remap[grep("rs",f_remap$SNP),] # 无
f = vroom("rsidmap/lung.gz")
f = f[grep("rs",f$SNP),]
f = rbind(f,f_remap)
f = f[!((f$chromosome==6)&(f$base_pair_location>25000000&f$base_pair_location<35000000)),] # 去除主要组织相容性复合体区域
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

f_remap = vroom("rsidmap/CRC_transfer_remap")
f_remap = f_remap[grep("rs",f_remap$SNP),] # 七个
f = vroom("rsidmap/CRC.gz")
f = f[grep("rs",f$SNP),]
f = rbind(f,f_remap)
f = f[!((f$chromosome==6)&(f$base_pair_location>25000000&f$base_pair_location<35000000)),] # 去除主要组织相容性复合体区域
f = f[f$effect_allele%in%c("A","T","G","C")&f$other_allele%in%c("A","T","G","C"),]
f = f[f$chromosome!=23,]
table(f$chromosome)
f = f[!duplicated(f$SNP),]
f$SNP[duplicated(f$SNP)]
# 注释等位基因频率
frq = as.data.frame(read.table("~/share_genetics/data/MAGMA/g1000_eur/g1000_eur.frq", header = T))
frq$ID = paste0(frq$SNP,":",frq$A1,":",frq$A2)
f$ID = paste0(f$SNP,":",f$effect_allele,":",f$other_allele)
f = dplyr::left_join(f,frq[,c("ID", "MAF")], by  = "ID")
nrow(f[is.na(f$MAF),])
frq$ID = paste0(frq$SNP,":",frq$A2,":",frq$A1)
frq$MAF_2 = 1-frq$MAF
f = dplyr::left_join(f,frq[,c("ID", "MAF_2")], by  = "ID")
f$MAF[is.na(f$MAF)] = f$MAF_2[is.na(f$MAF)]
nrow(f[is.na(f$MAF),]) # 470856个RSID在G1000中找不到
{ # 无结果
  A_1 = (frq$A1=="A")
  T_1 = (frq$A1=="T")
  C_1 = (frq$A1=="C")
  G_1 = (frq$A1=="G")
  A_2 = (frq$A2=="A")
  T_2 = (frq$A2=="T")
  C_2 = (frq$A2=="C")
  G_2 = (frq$A2=="G")
  frq$A1[A_1] = "T"
  frq$A1[T_1] = "A"
  frq$A1[C_1] = "G"
  frq$A1[G_1] = "C"
  frq$A2[A_2] = "T"
  frq$A2[T_2] = "A"
  frq$A2[C_2] = "G"
  frq$A2[G_2] = "C"
  frq$ID = paste0(frq$SNP,":",frq$A1,":",frq$A2)
  frq$MAF_3 = frq$MAF
  f = dplyr::left_join(f,frq[,c("ID", "MAF_3")], by  = "ID")
  f$MAF[is.na(f$MAF)] = f$MAF_3[is.na(f$MAF)]
  nrow(f[is.na(f$MAF),])
  frq$ID = paste0(frq$SNP,":",frq$A2,":",frq$A1)
  frq$MAF_4 = 1-frq$MAF
  f = dplyr::left_join(f,frq[,c("ID", "MAF_4")], by  = "ID")
  f$MAF[is.na(f$MAF)] = f$MAF_4[is.na(f$MAF)]
  nrow(f[is.na(f$MAF),])
}
f = f[!is.na(f$MAF),] # 10422378 - 470856
f = f[f$MAF<0.99&f$MAF>0.01,] # 9951522 → 9951522
f$or = exp(f$beta)
f = f[,c("SNP","chromosome","base_pair_location","effect_allele","other_allele","or","standard_error","p_value","MAF")]
colnames(f) = c("snpid", "hg19chr", "bp", "a1", "a2", "or", "se", "pval","EURaf")
f = f[f$pval!=-99,]
write_tsv(f,"processed/CRC.gz")

f_remap = vroom("rsidmap/ESCA_transfer_remap")
f_remap = f_remap[grep("rs",f_remap$SNP),] # 0个
f = vroom("rsidmap/ESCA.gz")
f = f[grep("rs",f$SNP),] # 12691837
f = rbind(f,f_remap)
f = f[!((f$chromosome==6)&(f$base_pair_location>25000000&f$base_pair_location<35000000)),] # 去除主要组织相容性复合体区域
f = f[f$effect_allele%in%c("A","T","G","C")&f$other_allele%in%c("A","T","G","C"),]
f = f[f$chromosome!=23,] # 12604487
table(f$chromosome)
f = f[!duplicated(f$SNP),]
f$SNP[duplicated(f$SNP)]
# 注释等位基因频率
frq = as.data.frame(read.table("~/share_genetics/data/MAGMA/g1000_eur/g1000_eur.frq", header = T))
frq$ID = paste0(frq$SNP,":",frq$A1,":",frq$A2)
f$ID = paste0(f$SNP,":",f$effect_allele,":",f$other_allele)
f = dplyr::left_join(f,frq[,c("ID", "MAF")], by  = "ID")
nrow(f[is.na(f$MAF),]) # 5583359
frq$ID = paste0(frq$SNP,":",frq$A2,":",frq$A1)
frq$MAF_2 = 1-frq$MAF
f = dplyr::left_join(f,frq[,c("ID", "MAF_2")], by  = "ID")
f$MAF[is.na(f$MAF)] = f$MAF_2[is.na(f$MAF)]
nrow(f[is.na(f$MAF),]) # 803154个RSID在G1000中找不到
{ # 无结果
  A_1 = (frq$A1=="A")
  T_1 = (frq$A1=="T")
  C_1 = (frq$A1=="C")
  G_1 = (frq$A1=="G")
  A_2 = (frq$A2=="A")
  T_2 = (frq$A2=="T")
  C_2 = (frq$A2=="C")
  G_2 = (frq$A2=="G")
  frq$A1[A_1] = "T"
  frq$A1[T_1] = "A"
  frq$A1[C_1] = "G"
  frq$A1[G_1] = "C"
  frq$A2[A_2] = "T"
  frq$A2[T_2] = "A"
  frq$A2[C_2] = "G"
  frq$A2[G_2] = "C"
  frq$ID = paste0(frq$SNP,":",frq$A1,":",frq$A2)
  frq$MAF_3 = frq$MAF
  f = dplyr::left_join(f,frq[,c("ID", "MAF_3")], by  = "ID")
  f$MAF[is.na(f$MAF)] = f$MAF_3[is.na(f$MAF)]
  nrow(f[is.na(f$MAF),])
  frq$ID = paste0(frq$SNP,":",frq$A2,":",frq$A1)
  frq$MAF_4 = 1-frq$MAF
  f = dplyr::left_join(f,frq[,c("ID", "MAF_4")], by  = "ID")
  f$MAF[is.na(f$MAF)] = f$MAF_4[is.na(f$MAF)]
  nrow(f[is.na(f$MAF),])
}
f = f[!is.na(f$MAF),] # 11718403 - 803154
f = f[f$MAF<0.99&f$MAF>0.01,] # 10915249 → 10915249
f$or = exp(f$beta)
f = f[,c("SNP","chromosome","base_pair_location","effect_allele","other_allele","or","standard_error","p_value","MAF")]
colnames(f) = c("snpid", "hg19chr", "bp", "a1", "a2", "or", "se", "pval","EURaf")
f = f[f$pval!=-99,]
write_tsv(f,"processed/ESCA.gz")

f_remap = vroom("rsidmap/OV_transfer_remap")
f_remap = f_remap[grep("rs",f_remap$SNP),] # 756
f = vroom("/home/yanyq/share_genetics/data/GWAS/rsidmap/OV.gz")
f = f[grep("rs",f$SNP),]
f = f[!((f$Chromosome==6)&(f$Position>25000000&f$Position<35000000)),] # 去除主要组织相容性复合体区域
f = f[f$EAF<0.99&f$EAF>0.01,]
f = f[f$Effect%in%c("A","T","G","C")&f$Baseline%in%c("A","T","G","C"),]
f = f[!duplicated(f$SNP),]
f$SNP[duplicated(f$SNP)]
f$overall_OR = exp(f$overall_OR)
f = f[,c("SNP","Chromosome","Position","Effect","Baseline","overall_OR","overall_SE","overall_pvalue","EAF")]
colnames(f) = c("snpid", "hg19chr", "bp", "a1", "a2", "or", "se", "pval", "EURaf")
f = f[f$pval!=-99,]
write_tsv(f,"processed/OV.gz")

f_remap = vroom("rsidmap/PRAD_transfer_remap")
f_remap = f_remap[grep("rs",f_remap$SNP),] # 5854个
f = vroom("/home/yanyq/share_genetics/data/GWAS/rsidmap/PRAD.gz")
f = f[grep("rs",f$SNP),]
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

f_remap = vroom("rsidmap/UCEC_transfer_remap")
f_remap = f_remap[grep("rs",f_remap$SNP),] # 全是Indel
f = vroom("/home/yanyq/share_genetics/data/GWAS/rsidmap/UCEC.gz")
f = f[grep("rs",f$SNP),]
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
{
  finngen_SNP = c()
  for(i in c("BLCA","HNSC","kidney","PAAD","SKCM","DLBC","BGC", "STAD", "THCA")){
    f_remap = as.data.frame(vroom(paste0("rsidmap/",i,"_transfer_remap"))) # 均无
    f_remap = f_remap[grep("rs",f_remap$SNP),]
    f = as.data.frame(vroom(paste0("rsidmap/",i,".gz")))
    f = f[grep("rs",f$SNP),]
    
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
}
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
length(finngen_SNP_hg19$POS[is.na(finngen_SNP_hg19$POS)]) # 39467个无
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

for(i in c("BLCA","HNSC","kidney","PAAD","SKCM","DLBC","BGC", "STAD", "THCA")){
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

# THCA-BGC后补充的癌症
f_remap = as.data.frame(vroom("/home/yanyq/share_genetics/data/GWAS/rsidmap/CESC-HL-LL_transfer_remap"))
f_remap = f_remap[grep("rs",f_remap$SNP),] # 只有一个2:155054470:A:G，在LL和CESC中

{
  f = as.data.frame(vroom("rsidmap/CESC.gz")) # 9984823
  f$SNP[f$uniqID=="2:155054470_A_G"] = "rs528216662"
  f = f[grep("rs",f$SNP),] # 9095038
  f = f[!((f$chromosome==6)&(f$base_pair_location>25000000&f$base_pair_location<35000000)),] # 去除主要组织相容性复合体区域, 9025102
  f = f[f$effect_allele%in%c("A","T","G","C")&f$other_allele%in%c("A","T","G","C"),]
  f = f[f$chromosome!=23,]
  table(f$chromosome)
  f = f[!duplicated(f$SNP),] # 8776574
  f$SNP[duplicated(f$SNP)]
  {
    # 注释等位基因频率
    frq = as.data.frame(read.table("~/share_genetics/data/MAGMA/g1000_eur/g1000_eur.frq", header = T))
    frq$ID = paste0(frq$SNP,":",frq$A1,":",frq$A2)
    f$ID = paste0(f$SNP,":",f$effect_allele,":",f$other_allele)
    f = dplyr::left_join(f,frq[,c("ID", "MAF")], by  = "ID")
    nrow(f[is.na(f$MAF),]) # 7222297
    frq$ID = paste0(frq$SNP,":",frq$A2,":",frq$A1)
    frq$MAF_2 = 1-frq$MAF
    f = dplyr::left_join(f,frq[,c("ID", "MAF_2")], by  = "ID")
    f$MAF[is.na(f$MAF)] = f$MAF_2[is.na(f$MAF)]
    nrow(f[is.na(f$MAF),]) # 324745个RSID在G1000中找不到
    { # 无结果
      A_1 = (frq$A1=="A")
      T_1 = (frq$A1=="T")
      C_1 = (frq$A1=="C")
      G_1 = (frq$A1=="G")
      A_2 = (frq$A2=="A")
      T_2 = (frq$A2=="T")
      C_2 = (frq$A2=="C")
      G_2 = (frq$A2=="G")
      frq$A1[A_1] = "T"
      frq$A1[T_1] = "A"
      frq$A1[C_1] = "G"
      frq$A1[G_1] = "C"
      frq$A2[A_2] = "T"
      frq$A2[T_2] = "A"
      frq$A2[C_2] = "G"
      frq$A2[G_2] = "C"
      frq$ID = paste0(frq$SNP,":",frq$A1,":",frq$A2)
      frq$MAF_3 = frq$MAF
      f = dplyr::left_join(f,frq[,c("ID", "MAF_3")], by  = "ID")
      f$MAF[is.na(f$MAF)] = f$MAF_3[is.na(f$MAF)]
      nrow(f[is.na(f$MAF),])
      frq$ID = paste0(frq$SNP,":",frq$A2,":",frq$A1)
      frq$MAF_4 = 1-frq$MAF
      f = dplyr::left_join(f,frq[,c("ID", "MAF_4")], by  = "ID")
      f$MAF[is.na(f$MAF)] = f$MAF_4[is.na(f$MAF)]
      nrow(f[is.na(f$MAF),])
    }
    f = f[!is.na(f$MAF),] # 8776574-324745
    f = f[f$MAF<0.99&f$MAF>0.01,] # 8451829 → 7982102
  }
  f$se = abs(log(f$odds_ratio)/qnorm(f$p_value/2))
  f = f[,c("SNP","chromosome","base_pair_location","effect_allele","other_allele","odds_ratio","se","p_value","MAF")]
  colnames(f) = c("snpid", "hg19chr", "bp", "a1", "a2", "or", "se", "pval","EURaf")
  f = f[f$pval!=-99,]
  write_tsv(f,"processed/CESC.gz")
}
{
  f = as.data.frame(vroom("rsidmap/LL.gz")) # 9987446
  f$SNP[f$uniqID=="2:155054470_A_G"] = "rs528216662"
  f = f[grep("rs",f$SNP),] # 9097438
  f = f[!((f$chromosome==6)&(f$base_pair_location>25000000&f$base_pair_location<35000000)),] # 去除主要组织相容性复合体区域, 9027422
  f = f[f$effect_allele%in%c("A","T","G","C")&f$other_allele%in%c("A","T","G","C"),] # 8782563
  f = f[f$chromosome!=23,]
  table(f$chromosome)
  f = f[!duplicated(f$SNP),] # 8778817
  f$SNP[duplicated(f$SNP)]
  {
    # 注释等位基因频率
    frq = as.data.frame(read.table("~/share_genetics/data/MAGMA/g1000_eur/g1000_eur.frq", header = T))
    frq$ID = paste0(frq$SNP,":",frq$A1,":",frq$A2)
    f$ID = paste0(f$SNP,":",f$effect_allele,":",f$other_allele)
    f = dplyr::left_join(f,frq[,c("ID", "MAF")], by  = "ID")
    nrow(f[is.na(f$MAF),]) # 7224396
    frq$ID = paste0(frq$SNP,":",frq$A2,":",frq$A1)
    frq$MAF_2 = 1-frq$MAF
    f = dplyr::left_join(f,frq[,c("ID", "MAF_2")], by  = "ID")
    f$MAF[is.na(f$MAF)] = f$MAF_2[is.na(f$MAF)]
    nrow(f[is.na(f$MAF),]) # 324796个RSID在G1000中找不到
    { # 无结果
      A_1 = (frq$A1=="A")
      T_1 = (frq$A1=="T")
      C_1 = (frq$A1=="C")
      G_1 = (frq$A1=="G")
      A_2 = (frq$A2=="A")
      T_2 = (frq$A2=="T")
      C_2 = (frq$A2=="C")
      G_2 = (frq$A2=="G")
      frq$A1[A_1] = "T"
      frq$A1[T_1] = "A"
      frq$A1[C_1] = "G"
      frq$A1[G_1] = "C"
      frq$A2[A_2] = "T"
      frq$A2[T_2] = "A"
      frq$A2[C_2] = "G"
      frq$A2[G_2] = "C"
      frq$ID = paste0(frq$SNP,":",frq$A1,":",frq$A2)
      frq$MAF_3 = frq$MAF
      f = dplyr::left_join(f,frq[,c("ID", "MAF_3")], by  = "ID")
      f$MAF[is.na(f$MAF)] = f$MAF_3[is.na(f$MAF)]
      nrow(f[is.na(f$MAF),])
      frq$ID = paste0(frq$SNP,":",frq$A2,":",frq$A1)
      frq$MAF_4 = 1-frq$MAF
      f = dplyr::left_join(f,frq[,c("ID", "MAF_4")], by  = "ID")
      f$MAF[is.na(f$MAF)] = f$MAF_4[is.na(f$MAF)]
      nrow(f[is.na(f$MAF),])
    }
    f = f[!is.na(f$MAF),] # 8778817-324796
    f = f[f$MAF<0.99&f$MAF>0.01,] # 8454021 → 7983386
  }
  f$se = abs(log(f$odds_ratio)/qnorm(f$p_value/2))
  f = f[,c("SNP","chromosome","base_pair_location","effect_allele","other_allele","odds_ratio","se","p_value","MAF")]
  colnames(f) = c("snpid", "hg19chr", "bp", "a1", "a2", "or", "se", "pval","EURaf")
  f = f[f$pval!=-99,]
  write_tsv(f,"processed/LL.gz")
}
{
  f = as.data.frame(vroom("rsidmap/HL.gz")) # 11831924
  f = f[grep("rs",f$SNP),] # 11830582
  f = f[!((f$chromosome==6)&(f$base_pair_location>25000000&f$base_pair_location<35000000)),] # 去除主要组织相容性复合体区域, 11751328
  f = f[f$effect_allele%in%c("A","T","G","C")&f$other_allele%in%c("A","T","G","C"),] # 11751328
  f = f[f$chromosome!=23,]
  table(f$chromosome)
  f = f[!duplicated(f$SNP),] # 11751328
  f$SNP[duplicated(f$SNP)]
  f = f[f$effect_allele_frequency<0.99&f$effect_allele_frequency>0.01,] # 7958446
  f$or = exp(f$beta)
  f = f[,c("SNP","chromosome","base_pair_location","effect_allele","other_allele","or","standard_error","p_value","effect_allele_frequency")]
  colnames(f) = c("snpid", "hg19chr", "bp", "a1", "a2", "or", "se", "pval","EURaf")
  f = f[f$pval!=-99,]
  write_tsv(f,"processed/HL.gz")
}

# finngen
# 筛选MAF、rsid、双等位基因
# 提取所有的finngen SNP
sed '1d' /home/yanyq/share_genetics/data/GWAS/rsidmap/finngen_BCC_SCC_rest_transfer_remap >> /home/yanyq/share_genetics/data/GWAS/rsidmap/finngen_transfer_remap
f_remap = as.data.frame(vroom("/home/yanyq/share_genetics/data/GWAS/rsidmap/finngen_transfer_remap"))
f_remap[grep("rs",f_remap$SNP),] # 无
finngen_SNP = as.data.frame(vroom("/home/yanyq/share_genetics/data/GWAS/rsidmap/finngen_SNP_loc_hg38"))
finngen_SNP = finngen_SNP[grep("rs",finngen_SNP$SNP),]
finngen_SNP = unique(finngen_SNP$SNP)
finngen_SNP = as.data.frame(finngen_SNP)
finngen_SNP$chr = NA
finngen_SNP$pos = NA
colnames(finngen_SNP)[1] = "SNP"
write_tsv(finngen_SNP, "/home/yanyq/share_genetics/data/GWAS/rsidmap/finngen_SNP_afterTHCA")
# 注释hg19 坐标
#######################gwaslab
import gwaslab as gl
mysumstats = gl.Sumstats("/home/yanyq/share_genetics/data/GWAS/rsidmap/finngen_SNP_afterTHCA", snpid="SNP",chrom = "chr",pos = "pos")
mysumstats.data['rsID'] = mysumstats.data['SNPID']
mysumstats.data['CHR'] = mysumstats.data['CHR'].astype('Int64')
mysumstats.data['POS'] = mysumstats.data['POS'].astype('Int64')
mysumstats.data['CHR'].dtypes
mysumstats.data['POS'].dtypes
mysumstats.rsid_to_chrpos2(path="/home/yanyq/software/rsidmap/dbsnp/GCF_000001405.25.gz.rsID_CHR_POS_groups_20000000.h5")
mysumstats.data.to_csv("/home/yanyq/share_genetics/data/GWAS/rsidmap/finngen_SNP_afterTHCA_hg19",header = True, index = False, sep = "\t")
##############################
finngen_SNP_hg19 = as.data.frame(vroom("/home/yanyq/share_genetics/data/GWAS/rsidmap/finngen_SNP_afterTHCA_hg19"))
which(finngen_SNP_hg19$SNPID!=finngen_SNP_hg19$rsID)
table(finngen_SNP_hg19$CHR)
table(finngen_SNP_hg19$STATUS)
length(finngen_SNP_hg19$POS[is.na(finngen_SNP_hg19$POS)]) # 146168个无
finngen_SNP_hg19 = finngen_SNP_hg19[!is.na(finngen_SNP_hg19$POS),]
finngen_SNP_hg19 = finngen_SNP_hg19[,c(1,3,4)]
colnames(finngen_SNP_hg19) = c("SNP","chr_hg19","pos_hg19")
for(i in c("AML","BAC","CML","CORP","EYAD","GSS","BGA","LIHC","MCL","MZBL",
           "BM","MESO","MM","MS","SI","TEST","VULVA","BCC","SCC")){
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