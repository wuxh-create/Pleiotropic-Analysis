library(data.table)
library(readr)
library(dplyr)

######################多效SMR基因和MAGMA结果overlap
dup_Gene_res = as.data.frame(read_tsv("/home/yanyq/cogenetics/result/多效基因"))
length(unique(dup_Gene_res$SYMBOL)) # 165个多效的因果基因
which(dup_Gene_res$Gene.trait1!=dup_Gene_res$Gene.trait2)
symbol = as.data.frame(read_tsv("/home/yanyq/cogenetics/data/eQTL/eQTLGen/cis-eQTLs-full_eQTLGen_AF_incl_nr_formatted_20191212.new.txt_besd-dense.epi_symbol", col_names = ))
colnames(symbol)[c(2,5)] = c("probeID", "SYMBOL")
dup_Gene_res = left_join(dup_Gene_res, symbol[,c(2,5)], by = "probeID")
MAGMA = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/all"))
# 具有多效性的SMR基因，在MAGMA中也多效
dup_Gene_res$inMAGMA = FALSE
tmp = as.data.frame(matrix(ncol = ncol(MAGMA), nrow = nrow(dup_Gene_res)))
colnames(tmp) = colnames(MAGMA)
dup_Gene_res = cbind(dup_Gene_res, tmp)
for(i in 1:length(dup_Gene_res)){
  tmp_MAGMA = MAGMA[MAGMA$SYMBOL==dup_Gene_res$SYMBOL[i]&
                      MAGMA$trait==paste0(dup_Gene_res$cancer.trait1[i],"-",dup_Gene_res$cancer.trait2[i]),]
  if(nrow(tmp_MAGMA)>0){
    dup_Gene_res$inMAGMA[i] = TRUE
    dup_Gene_res[i,52:74] = tmp_MAGMA
  }
}
length(which(dup_Gene_res$inMAGMA)) # 23个基因
dup_Gene_res = dup_Gene_res[dup_Gene_res$inMAGMA,]
# 多效基因或甲基化与meQTL-eQTL结果overlap
dup_me_res = as.data.frame(read_tsv("/home/yanyq/cogenetics/result/多效甲基化"))
meQTL_eQTL = as.data.frame(read_tsv("/home/yanyq/cogenetics/result/smr_multiSNP_0.01/meQTL_eQTLGen/all_chr_fdr_0.05.msmr"))
meQTL_eQTL = meQTL_eQTL[meQTL_eQTL$Expo_ID%in%dup_me_res$probeID&meQTL_eQTL$Outco_ID%in%dup_Gene_res$probeID,]
dup_me_res = dup_me_res[dup_me_res$probeID%in%meQTL_eQTL$Expo_ID,]
dup_Gene_res = dup_Gene_res[dup_Gene_res$probeID%in%meQTL_eQTL$Outco_ID,] # 12个
write_tsv(dup_Gene_res, "/home/yanyq/share_genetics/result/MAGMA中的多效基因发现在SMR中具有同样的通路")

f = fread("/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/all")
f_Gene = as.data.frame(table(f$GENE))
f_Gene_7015 = f[f$GENE==7015,]

setwd("/home/yanyq/share_genetics/result/SMR_eQTL/tissue/")
eQTL_SMR = list()
files = list.files()
files = files[grep("smr",files)]
for(i in files){
  eQTL_SMR[[i]] = fread(i)
  eQTL_SMR[[i]]$cancer = gsub(".smr","",i)
  eQTL_SMR[[i]]$fdr = p.adjust(eQTL_SMR[[i]]$p_SMR,method = "BH")
}
eQTL_SMR = do.call(rbind,eQTL_SMR)
write_tsv(eQTL_SMR,"/home/yanyq/share_genetics/result/SMR_eQTL/tissue/all_fdr_0.05")
eQTL_SMR = eQTL_SMR[eQTL_SMR$fdr<0.05,]
eQTL_SMR_MAGMA = list()

setwd("/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/")
files = list.files()
files = files[-1]
for(i in files){
  f = fread(i)
  traits = strsplit(i,"-")
  eQTL_SMR_MAGMA[[traits[[1]][1]]] = eQTL_SMR[eQTL_SMR$cancer==traits[[1]][1]&eQTL_SMR$Gene%in%f$SYMBOL,]
  eQTL_SMR_MAGMA[[traits[[1]][2]]] = eQTL_SMR[eQTL_SMR$cancer==traits[[1]][2]&eQTL_SMR$Gene%in%f$SYMBOL,]
}
eQTL_SMR_MAGMA = do.call(rbind,eQTL_SMR_MAGMA)
write_tsv(eQTL_SMR_MAGMA,"/home/yanyq/share_genetics/result/MAGMA/eQTL_SMR_MAGMA")