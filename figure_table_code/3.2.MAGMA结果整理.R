library(data.table)
library(readr)
# FUMA和MAGMAoverlap
# MAGMA数据源于https://ctg.cncr.nl/software/MAGMA/aux_files/NCBI37.3.zip

# MAGMA_loci = fread("/home/yanyq/share_genetics/data/NCBI37.3/NCBI37.3.gene.loc")
# 
# library(IRanges)
# library(GenomicRanges)
# overlap = findOverlaps(query = as(paste0(FUMA_loci$chr,":",FUMA_loci$start,"-",FUMA_loci$end),"GRanges"),subject = as(paste0(MAGMA_loci$V2,":",MAGMA_loci$V3,"-",MAGMA_loci$V4),"GRanges"))
# FUMA_MAGMA = cbind(FUMA_loci[overlap@from,],MAGMA_loci[overlap@to,])
# tmp = fread("/home/yanyq/share_genetics/data/NCBI37.3/yoi220099supp1_prod_1680639129.01366.txt")
# tmp[!(tmp$`Locus position`%in%paste0(FUMA_MAGMA$start,"-",FUMA_MAGMA$end)&tmp$`Gene position`%in%paste0(FUMA_MAGMA$V3,"\xa8C",FUMA_MAGMA$V4)),]

setwd("~/share_genetics/data/GWAS/processed")

# 提取多效基因座的SNP，与MAGMA基因关联分析
# header = F
AN = fread("AN.gz")
for(i in c("GORD","IBD","IBS","PUD")){
  overlap = fread(paste0(i,".gz"))
  PLACO = as.data.frame(fread(paste0("~/share_genetics/result/PLACO/PLACO_AN_",i,".gz")))
  if(i =="GORD"){
    coloc_1 = (overlap$hg19chr==3&overlap$bp>= 49734229&overlap$bp<=50209053)
    coloc_2 = (overlap$hg19chr==3&overlap$bp>=70795054&overlap$bp<=71018894)
    coloc_3 = (overlap$hg19chr==11&overlap$bp>=112826867&overlap$bp<=112922254)
    coloc_4 = (overlap$hg19chr==12&overlap$bp>=56368708&overlap$bp<=56478658)
    # # coloc_1 = overlap$snpid=="rs199956414"
    # # coloc_2 = overlap$snpid=="rs13097265"
    # # coloc_3 = overlap$snpid=="rs7105462"
    # # coloc_4 = overlap$snpid=="rs1873914"
    write_tsv(overlap[coloc_1,c(1,8)],paste0("~/share_genetics/data/MAGMA/PLACO_SNP/GORD_1"))
    write_tsv(overlap[coloc_2,c(1,8)],paste0("~/share_genetics/data/MAGMA/PLACO_SNP/GORD_2"))
    write_tsv(overlap[coloc_3,c(1,8)],paste0("~/share_genetics/data/MAGMA/PLACO_SNP/GORD_3"))
    write_tsv(overlap[coloc_4,c(1,8)],paste0("~/share_genetics/data/MAGMA/PLACO_SNP/GORD_4"))
    
    coloc_1 = (AN$hg19chr==3&AN$bp>= 49734229&AN$bp<=50209053)
    coloc_2 = (AN$hg19chr==3&AN$bp>=70795054&AN$bp<=71018894)
    coloc_3 = (AN$hg19chr==11&AN$bp>=112826867&AN$bp<=112922254)
    coloc_4 = (AN$hg19chr==12&AN$bp>=56368708&AN$bp<=56478658)
    write_tsv(AN[coloc_1,c(1,8)],paste0("~/share_genetics/data/MAGMA/PLACO_SNP/AN_GORD_1"))
    write_tsv(AN[coloc_2,c(1,8)],paste0("~/share_genetics/data/MAGMA/PLACO_SNP/AN_GORD_2"))
    write_tsv(AN[coloc_3,c(1,8)],paste0("~/share_genetics/data/MAGMA/PLACO_SNP/AN_GORD_3"))
    write_tsv(AN[coloc_4,c(1,8)],paste0("~/share_genetics/data/MAGMA/PLACO_SNP/AN_GORD_4"))
    
    coloc_1 = (PLACO$hg19chr==3&PLACO$bp>= 49734229&PLACO$bp<=50209053)
    coloc_2 = (PLACO$hg19chr==3&PLACO$bp>=70795054&PLACO$bp<=71018894)
    coloc_3 = (PLACO$hg19chr==11&PLACO$bp>=112826867&PLACO$bp<=112922254)
    coloc_4 = (PLACO$hg19chr==12&PLACO$bp>=56368708&PLACO$bp<=56478658)
    write_tsv(PLACO[coloc_1,c(1,6)],paste0("~/share_genetics/data/MAGMA/PLACO_SNP/PLACO_AN_GORD_1"))
    write_tsv(PLACO[coloc_2,c(1,6)],paste0("~/share_genetics/data/MAGMA/PLACO_SNP/PLACO_AN_GORD_2"))
    write_tsv(PLACO[coloc_3,c(1,6)],paste0("~/share_genetics/data/MAGMA/PLACO_SNP/PLACO_AN_GORD_3"))
    write_tsv(PLACO[coloc_4,c(1,6)],paste0("~/share_genetics/data/MAGMA/PLACO_SNP/PLACO_AN_GORD_4"))
    
  }
  if(i == "IBD"){
    coloc_1 = (overlap$hg19chr==1&overlap$bp>=200864267&overlap$bp<=201024059)
    coloc_2 = (overlap$hg19chr==3&overlap$bp>=48446237&overlap$bp<=50519141)
    # # coloc_1 = overlap$snpid=="rs6427868"
    # # coloc_2 = overlap$snpid=="rs11717978"
    write_tsv(overlap[coloc_1,c(1,8)],paste0("~/share_genetics/data/MAGMA/PLACO_SNP/IBD_1"))
    write_tsv(overlap[coloc_2,c(1,8)],paste0("~/share_genetics/data/MAGMA/PLACO_SNP/IBD_2"))
    
    coloc_1 = (AN$hg19chr==1&AN$bp>=200864267&AN$bp<=201024059)
    coloc_2 = (AN$hg19chr==3&AN$bp>=48446237&AN$bp<=50519141)
    write_tsv(AN[coloc_1,c(1,8)],paste0("~/share_genetics/data/MAGMA/PLACO_SNP/AN_IBD_1"))
    write_tsv(AN[coloc_2,c(1,8)],paste0("~/share_genetics/data/MAGMA/PLACO_SNP/AN_IBD_2"))
    
    coloc_1 = (PLACO$hg19chr==1&PLACO$bp>=200864267&PLACO$bp<=201024059)
    coloc_2 = (PLACO$hg19chr==3&PLACO$bp>=48446237&PLACO$bp<=50519141)
    write_tsv(PLACO[coloc_1,c(1,6)],paste0("~/share_genetics/data/MAGMA/PLACO_SNP/PLACO_AN_IBD_1"))
    write_tsv(PLACO[coloc_2,c(1,6)],paste0("~/share_genetics/data/MAGMA/PLACO_SNP/PLACO_AN_IBD_2"))
  }
  if(i == "IBS"){
    coloc_1 = (overlap$hg19chr==9&overlap$bp>=96163260&overlap$bp<=96356004)
    coloc_2 = (overlap$hg19chr==11&overlap$bp>=112826311&overlap$bp<=113062983)
    # # coloc_1 = overlap$snpid=="rs7021689"
    # # coloc_2 = overlap$snpid=="rs55694714"
    write_tsv(overlap[coloc_1,c(1,8)],paste0("~/share_genetics/data/MAGMA/PLACO_SNP/IBS_1"))
    write_tsv(overlap[coloc_2,c(1,8)],paste0("~/share_genetics/data/MAGMA/PLACO_SNP/IBS_2"))
    
    coloc_1 = (AN$hg19chr==9&AN$bp>=96163260&AN$bp<=96356004)
    coloc_2 = (AN$hg19chr==11&AN$bp>=112826311&AN$bp<=113062983)
    write_tsv(AN[coloc_1,c(1,8)],paste0("~/share_genetics/data/MAGMA/PLACO_SNP/AN_IBS_1"))
    write_tsv(AN[coloc_2,c(1,8)],paste0("~/share_genetics/data/MAGMA/PLACO_SNP/AN_IBS_2"))
    
    coloc_1 = (PLACO$hg19chr==9&PLACO$bp>=96163260&PLACO$bp<=96356004)
    coloc_2 = (PLACO$hg19chr==11&PLACO$bp>=112826311&PLACO$bp<=113062983)
    write_tsv(PLACO[coloc_1,c(1,6)],paste0("~/share_genetics/data/MAGMA/PLACO_SNP/PLACO_AN_IBS_1"))
    write_tsv(PLACO[coloc_2,c(1,6)],paste0("~/share_genetics/data/MAGMA/PLACO_SNP/PLACO_AN_IBS_2"))
  }
  if(i ==  "PUD"){
    coloc_1 = (overlap$hg19chr==4&overlap$bp>=147216084&overlap$bp<=147337374)
    coloc_2 = (overlap$hg19chr==8&overlap$bp>=143752994&overlap$bp<=143809193)
    # # coloc_1 = overlap$snpid=="rs9784437"
    # # coloc_2 = overlap$snpid=="rs2978977"
    write_tsv(overlap[coloc_1,c(1,8)],paste0("~/share_genetics/data/MAGMA/PLACO_SNP/PUD_1"))
    write_tsv(overlap[coloc_2,c(1,8)],paste0("~/share_genetics/data/MAGMA/PLACO_SNP/PUD_2"))
    
    coloc_1 = (AN$hg19chr==4&AN$bp>=147216084&AN$bp<=147337374)
    coloc_2 = (AN$hg19chr==8&AN$bp>=143752994&AN$bp<=143809193)
    write_tsv(AN[coloc_1,c(1,8)],paste0("~/share_genetics/data/MAGMA/PLACO_SNP/AN_PUD_1"))
    write_tsv(AN[coloc_2,c(1,8)],paste0("~/share_genetics/data/MAGMA/PLACO_SNP/AN_PUD_2"))

    coloc_1 = (PLACO$hg19chr==4&PLACO$bp>=147216084&PLACO$bp<=147337374)
    coloc_2 = (PLACO$hg19chr==8&PLACO$bp>=143752994&PLACO$bp<=143809193)
    write_tsv(PLACO[coloc_1,c(1,6)],paste0("~/share_genetics/data/MAGMA/PLACO_SNP/PLACO_AN_PUD_1"))
    write_tsv(PLACO[coloc_2,c(1,6)],paste0("~/share_genetics/data/MAGMA/PLACO_SNP/PLACO_AN_PUD_2"))    
  }
}
# MAGMA.sh

correct = fread("/home/yanyq/share_genetics/yoi220099supp1_prod_1680639129.01366.txt")
tmp = strsplit(correct$PPLACO,"E")
tmp = do.call(rbind,tmp)
tmp[,2] = substring(tmp[,2],3)
correct$PPLACO = as.numeric(paste0(tmp[,1],rep("e",nrow(tmp)),tmp[,2]))
tmp = strsplit(correct$PPSY,"E")
tmp = do.call(rbind,tmp)
tmp[,2] = substring(tmp[,2],3)
correct$PPSY = as.numeric(paste0(tmp[,1],rep("e",nrow(tmp)),tmp[,2]))
tmp = strsplit(correct$PGIT,"E")
tmp = do.call(rbind,tmp)
tmp[,2] = substring(tmp[,2],3)
correct$PGIT = as.numeric(paste0(tmp[,1],rep("e",nrow(tmp)),tmp[,2]))
correct$flag = paste0(correct$`No loci`,":",correct$`Gene position`)

setwd("/home/yanyq/share_genetics/result/MAGMA/asso/")
files = list.files()
files = files[grep(".genes.out",files)]
PLACO = files[grep("PLACO",files)]
# PLACO = data.frame(files = PLACO,
#                    `No loci` = c(80:83,49,50,62,63,19,20))
PLACO = data.frame(files = PLACO,
                   `No loci` = c(80:83,19,20,49,50,62,63))
FUMA_loci = data.frame(trait = c("GORD","GORD","GORD","GORD","IBD","IBD","IBS","IBS","PUD","PUD"),
                       `No loci` = c(80:83,19,20,49,50,62,63),
                       chr = c(3,3,11,12,1,3,9,11,4,8),
                       start = c(49734229,70795054,112826867,56368708,200864267,48446237,96163260,112826311,147216084,143752994),
                       end = c(50209053,71018894,112922254,56478658,201024059,50519141,96356004,113062983,147337374,143809193)) # 多效性基因座
library(IRanges)
library(GenomicRanges)
merge_f = list()
for(i in 1:nrow(PLACO)){
  f = fread(PLACO$files[i])
  f$`No loci` = PLACO$No.loci[i]
  flag = which(FUMA_loci$No.loci==PLACO$No.loci[i])
  subjects = as(paste0(FUMA_loci$chr[flag],":",FUMA_loci$start[flag],"-",FUMA_loci$end[flag]),"GRanges")
  ol = findOverlaps(as(paste0(f$CHR,":",f$START,"-",f$STOP),"GRanges"),subjects)
  merge_f[[i]] = f[ol@from,]
}
merge_f = do.call(rbind,merge_f)
colnames(merge_f)[9] = "P_PLACO"

PLACO = files[1:10]
PLACO = data.frame(files = PLACO,
                   `No loci` = c(80:83,19,20,49,50,62,63))
merge_f2 = list()
for(i in 1:nrow(PLACO)){
  f = fread(PLACO$files[i])
  f$`No loci` = PLACO$No.loci[i]
  flag = which(FUMA_loci$No.loci==PLACO$No.loci[i])
  subjects = as(paste0(FUMA_loci$chr[flag],":",FUMA_loci$start[flag],"-",FUMA_loci$end[flag]),"GRanges")
  ol = findOverlaps(as(paste0(f$CHR,":",f$START,"-",f$STOP),"GRanges"),subjects)
  merge_f2[[i]] = f[ol@from,]
}
merge_f2 = do.call(rbind,merge_f2)
colnames(merge_f2)[9] = "P_AN"

PLACO = files[c(11:18,29,30)]
PLACO = data.frame(files = PLACO,
                   `No loci` = c(80:83,19,20,49,50,62,63))
merge_f3 = list()
for(i in 1:nrow(PLACO)){
  f = fread(PLACO$files[i])
  f$`No loci` = PLACO$No.loci[i]
  flag = which(FUMA_loci$No.loci==PLACO$No.loci[i])
  subjects = as(paste0(FUMA_loci$chr[flag],":",FUMA_loci$start[flag],"-",FUMA_loci$end[flag]),"GRanges")
  ol = findOverlaps(as(paste0(f$CHR,":",f$START,"-",f$STOP),"GRanges"),subjects)
  merge_f3[[i]] = f[ol@from,]
}
merge_f3 = do.call(rbind,merge_f3)
colnames(merge_f2)[9] = "P_"

merge_f$flag = paste0(merge_f$`No loci`,":",merge_f$START,"-",merge_f$STOP)
merge_f2$flag = paste0(merge_f2$`No loci`,":",merge_f2$START,"-",merge_f2$STOP)
merge_f3$flag = paste0(merge_f3$`No loci`,":",merge_f3$START,"-",merge_f3$STOP)

all_merge = merge(merge_f,merge_f2[,c(11,9)],by = "flag")
all_merge = merge(all_merge,merge_f3[,c(11,9)],by = "flag")
write_tsv(all_merge,"/home/yanyq/share_genetics/result/MAGMA/asso_merge")
# merge_f$flag = paste0(merge_f$`No loci`,":",merge_f$START,"-",merge_f$STOP)
# merge_f = merge(merge_f,correct,by="flag")

colnames(FUMA_loci)[2] = "No loci"
merge_f = dplyr::left_join(merge_f,FUMA_loci,by = "No loci")
# 与MAGMA基因overlap




