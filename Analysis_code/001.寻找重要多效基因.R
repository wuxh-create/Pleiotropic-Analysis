# 策略1
# MAGMA基因、EMAGMA和SMR基因overlap → geneset
# geneset和TCGA 重要性top200的基因overlap
# 策略2
# MAGMA/EMAGMA/SMR多效基因分别和TCGAdeepmap overlap
library(data.table)
library(readr)
library(dplyr)

######################策略1
######################多效SMR基因和MAGMA结果overlap
dup_Gene_res = as.data.frame(read_tsv("/home/yanyq/cogenetics/result/多效基因"))
nrow(dup_Gene_res) # 203个
length(unique(dup_Gene_res$probeID)) # 165个多效的因果基因
which(dup_Gene_res$Gene.trait1!=dup_Gene_res$Gene.trait2)
symbol = as.data.frame(read_tsv("/home/yanyq/cogenetics/data/eQTL/eQTLGen/cis-eQTLs-full_eQTLGen_AF_incl_nr_formatted_20191212.new.txt_besd-dense.epi_symbol", col_names = ))
colnames(symbol)[c(2,5)] = c("probeID", "SYMBOL")
dup_Gene_res = left_join(dup_Gene_res, symbol[,c(2,5)], by = "probeID")
write_tsv(dup_Gene_res, "/home/yanyq/cogenetics/result/多效基因SYMBOL")

MAGMA = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/all"))
EMAGMA = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/EMAGMA/asso_merge_fdr_0.05/all"))
# 具有多效性的SMR基因，在MAGMA或EMAGMA中也多效
dup_Gene_res$inMAGMA = FALSE
dup_Gene_res$inEMAGMA = FALSE
tmp = as.data.frame(matrix(ncol = ncol(MAGMA), nrow = nrow(dup_Gene_res)))
tmp2 = as.data.frame(matrix(ncol = ncol(EMAGMA), nrow = nrow(dup_Gene_res)))
colnames(tmp) = paste0("MAGMA.",colnames(MAGMA))
colnames(tmp2) = paste0("EMAGMA.",colnames(EMAGMA))
dup_Gene_res = cbind(dup_Gene_res, tmp, tmp2)
dup_Gene_res_multiEMAGMA = list() # 一个SMR多效基因可能在多个EMAGMA组织中多效
index = 1
for(i in 1:length(dup_Gene_res)){
  tmp_MAGMA = MAGMA[MAGMA$SYMBOL==dup_Gene_res$SYMBOL[i]&MAGMA$trait==paste0(dup_Gene_res$cancer.trait1[i],"-",dup_Gene_res$cancer.trait2[i]),]
  tmp_EMAGMA = EMAGMA[EMAGMA$SYMBOL==dup_Gene_res$SYMBOL[i]&EMAGMA$trait==paste0(dup_Gene_res$cancer.trait1[i],"-",dup_Gene_res$cancer.trait2[i]),]
  if(nrow(tmp_MAGMA)>0){
    dup_Gene_res$inMAGMA[i] = TRUE
    dup_Gene_res[i,53:75] = tmp_MAGMA
  }
  if(nrow(tmp_EMAGMA)==1){
    dup_Gene_res$inEMAGMA[i] = TRUE
    dup_Gene_res[i,76:95] = tmp_EMAGMA
  }
  if(nrow(tmp_EMAGMA)>1){
    dup_Gene_res$inEMAGMA[i] = TRUE
    dup_Gene_res[i,76:95] = tmp_EMAGMA[1,]
    dup_Gene_res_multiEMAGMA[[index]] = bind_rows(replicate((nrow(tmp_EMAGMA)-1), dup_Gene_res[i,], simplify = FALSE))
    dup_Gene_res_multiEMAGMA[[index]][,76:95] = tmp_EMAGMA[2:nrow(tmp_EMAGMA),]
  }
}
dup_Gene_res_multiEMAGMA = do.call(rbind, dup_Gene_res_multiEMAGMA) # 24个，全是BRCA-PRAD中的ULK3
dup_Gene_res = rbind(dup_Gene_res, dup_Gene_res_multiEMAGMA)
length(which(dup_Gene_res$inMAGMA)) # 54-24 = 30个基因
length(which(dup_Gene_res$inEMAGMA)) # 55-24个基因
dup_Gene_res[dup_Gene_res$inEMAGMA&!dup_Gene_res$inMAGMA,] # 在MAGMA中不多效性在EMAGMA中多效的SMR基因
write_tsv(dup_Gene_res, "/home/yanyq/share_genetics/result/001.important_gene/SMReQTL_pleio_overlap_MAGMA_EMAGMA")

dup_Gene_res = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/001.important_gene/SMReQTL_pleio_overlap_MAGMA_EMAGMA"))
dup_Gene_res = dup_Gene_res[dup_Gene_res$inMAGMA|dup_Gene_res$inEMAGMA,]
unique(dup_Gene_res$cancer.trait1) # "BCC"  "BM"   "SCC"  "BRCA"
unique(dup_Gene_res$cancer.trait2) # "BM"   "SCC"  "SKCM" "BRCA" "CRC"  "PRAD" "OV"
dup_Gene_res = dup_Gene_res[dup_Gene_res$cancer.trait1=="BRCA",] # 只有BRCA在TCGA中
unique(dup_Gene_res$cancer.trait2) # "PRAD" "OV"

# 获取在两个癌症中均重要性top200的基因
TCGAdeepmap = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/TCGAdeepmap/all_means_after_3SD_top200"))
deepmapBRCA_PRAD = intersect(TCGAdeepmap[,"TCGA-BRCA"],TCGAdeepmap[,"TCGA-PRAD"])
deepmapBRCA_OV = intersect(TCGAdeepmap[,"TCGA-BRCA"],TCGAdeepmap[,"TCGA-OV"])
dup_Gene_res[dup_Gene_res$cancer.trait1=="BRCA"&dup_Gene_res$cancer.trait2=="PRAD"&dup_Gene_res$MAGMA.SYMBOL%in%deepmapBRCA_PRAD,] # 无
dup_Gene_res[dup_Gene_res$cancer.trait1=="BRCA"&dup_Gene_res$cancer.trait2=="OV"&dup_Gene_res$MAGMA.SYMBOL%in%deepmapBRCA_OV,] # 无

######################策略2:MAGMA/EMAGMA/SMR多效基因分别和TCGAdeepmap overlap
MAGMA = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/all"))
unique(MAGMA$trait)
EMAGMA = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/EMAGMA/asso_merge_fdr_0.05/all"))
dup_Gene_res = as.data.frame(read_tsv("/home/yanyq/cogenetics/result/多效基因SYMBOL"))
TCGAdeepmap = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/TCGAdeepmap/all_means_after_3SD_top200"))
TCGAdeepmap = TCGAdeepmap[,-34]
colnames(TCGAdeepmap) = gsub("TCGA-","",colnames(TCGAdeepmap))
traitPairs = unique(c(MAGMA$trait, EMAGMA$trait, paste0(dup_Gene_res$cancer.trait1, "-", dup_Gene_res$cancer.trait2)))
traitPairs = as.data.frame(do.call(rbind, strsplit(traitPairs, "-")))
traitPairs = traitPairs[traitPairs$V1%in%c("lung", "kidney", "CRC", colnames(TCGAdeepmap))&traitPairs$V2%in%c("lung", "kidney", colnames(TCGAdeepmap)),]
TCGAdeepmapPairs = list()
for(i in 1:nrow(traitPairs)){
    if(traitPairs$V1[i]%in%c("lung","kidney","CRC")|traitPairs$V2[i]%in%c("lung","kidney","CRC")){
        tmp_traits = traitPairs[i,]
        if(all(tmp_traits%in%c("lung","kidney","CRC"))){

        }else if(any(tmp_traits=="lung")){
            tmp_index = which(tmp_traits!="lung")
            TCGAdeepmapPairs[[i]] = data.frame(trait=paste0(traitPairs$V1[i],"-",traitPairs$V2[i]),intersect = intersect(TCGAdeepmap[,tmp_traits[1,tmp_index]],unique(c(TCGAdeepmap[,"LUAD"],TCGAdeepmap[,"LUSC"]))))
        }else if (any(tmp_traits=="kidney")) {
            tmp_index = which(tmp_traits!="kidney")
            TCGAdeepmapPairs[[i]] = data.frame(trait=paste0(traitPairs$V1[i],"-",traitPairs$V2[i]),intersect = intersect(TCGAdeepmap[,tmp_traits[1,tmp_index]],unique(c(TCGAdeepmap[,"KICH"],TCGAdeepmap[,"KIRP"],TCGAdeepmap[,"KIRP"]))))
        }else if (any(tmp_traits=="CRC")) {
            tmp_index = which(tmp_traits!="CRC")
            TCGAdeepmapPairs[[i]] = data.frame(trait=paste0(traitPairs$V1[i],"-",traitPairs$V2[i]),intersect = intersect(TCGAdeepmap[,tmp_traits[1,tmp_index]],unique(c(TCGAdeepmap[,"COAD"],TCGAdeepmap[,"READ"]))))
        }
    }else{
            TCGAdeepmapPairs[[i]] = data.frame(trait=paste0(traitPairs$V1[i],"-",traitPairs$V2[i]),intersect = intersect(TCGAdeepmap[,traitPairs$V1[i]],TCGAdeepmap[,traitPairs$V2[i]]))
    }
}
TCGAdeepmapPairs = do.call(rbind, TCGAdeepmapPairs)
TCGAdeepmapPairs = unique(TCGAdeepmapPairs)
MAGMA$top200Deepmap = paste0(MAGMA$trait, MAGMA$SYMBOL)%in%paste0(TCGAdeepmapPairs$trait,TCGAdeepmapPairs$intersect)
EMAGMA$top200Deepmap = paste0(EMAGMA$trait, EMAGMA$SYMBOL)%in%paste0(TCGAdeepmapPairs$trait,TCGAdeepmapPairs$intersect)
dup_Gene_res$top200Deepmap = paste0(dup_Gene_res$trait, dup_Gene_res$SYMBOL)%in%paste0(TCGAdeepmapPairs$trait,TCGAdeepmapPairs$intersect)
write_tsv(MAGMA[MAGMA$top200Deepmap,], "/home/yanyq/share_genetics/result/TCGAdeepmap/overlapMAGMA") # 13 rows
write_tsv(EMAGMA[EMAGMA$top200Deepmap,], "/home/yanyq/share_genetics/result/TCGAdeepmap/overlapEMAGMA") # 100 rows
write_tsv(dup_Gene_res[dup_Gene_res$top200Deepmap,], "/home/yanyq/share_genetics/result/TCGAdeepmap/overlapSMRpleio") # 0 rows



# 多效基因或甲基化与meQTL-eQTL结果overlap
dup_me_res = as.data.frame(read_tsv("/home/yanyq/cogenetics/result/多效甲基化"))
meQTL_eQTL = as.data.frame(read_tsv("/home/yanyq/cogenetics/result/smr_multiSNP_0.01/meQTL_eQTLGen/all_chr_fdr_0.05.msmr"))
meQTL_eQTL = meQTL_eQTL[meQTL_eQTL$Expo_ID%in%dup_me_res$probeID&meQTL_eQTL$Outco_ID%in%dup_Gene_res$probeID,]
dup_me_res = dup_me_res[dup_me_res$probeID%in%meQTL_eQTL$Expo_ID,]
dup_Gene_res = dup_Gene_res[dup_Gene_res$probeID%in%meQTL_eQTL$Outco_ID,] # 12个
write_tsv(dup_Gene_res, "/home/yanyq/share_genetics/result/MAGMA中的多效基因发现在SMR中具有同样的通路")

# f = fread("/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/all")
# f_Gene = as.data.frame(table(f$GENE))
# f_Gene_7015 = f[f$GENE==7015,]

# setwd("/home/yanyq/share_genetics/result/SMR_eQTL/tissue/")
# eQTL_SMR = list()
# files = list.files()
# files = files[grep("smr",files)]
# for(i in files){
#   eQTL_SMR[[i]] = fread(i)
#   eQTL_SMR[[i]]$cancer = gsub(".smr","",i)
#   eQTL_SMR[[i]]$fdr = p.adjust(eQTL_SMR[[i]]$p_SMR,method = "BH")
# }
# eQTL_SMR = do.call(rbind,eQTL_SMR)
# write_tsv(eQTL_SMR,"/home/yanyq/share_genetics/result/SMR_eQTL/tissue/all_fdr_0.05")
# eQTL_SMR = eQTL_SMR[eQTL_SMR$fdr<0.05,]
# eQTL_SMR_MAGMA = list()

# setwd("/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/")
# files = list.files()
# files = files[-1]
# for(i in files){
#   f = fread(i)
#   traits = strsplit(i,"-")
#   eQTL_SMR_MAGMA[[traits[[1]][1]]] = eQTL_SMR[eQTL_SMR$cancer==traits[[1]][1]&eQTL_SMR$Gene%in%f$SYMBOL,]
#   eQTL_SMR_MAGMA[[traits[[1]][2]]] = eQTL_SMR[eQTL_SMR$cancer==traits[[1]][2]&eQTL_SMR$Gene%in%f$SYMBOL,]
# }
# eQTL_SMR_MAGMA = do.call(rbind,eQTL_SMR_MAGMA)
# write_tsv(eQTL_SMR_MAGMA,"/home/yanyq/share_genetics/result/MAGMA/eQTL_SMR_MAGMA")