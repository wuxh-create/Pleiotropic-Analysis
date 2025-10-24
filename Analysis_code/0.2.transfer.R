# 链翻转上的SNP，rsidmap无法匹配到

setwd("~/share_genetics/data/GWAS")
library(data.table)
library(readr)
library(vroom)

f = read.table("rsidmap/BRCA.gz",header = T)
f = f[!grepl("rs",f$SNP),]
A_1 = (f$Baseline.Meta=="A")
T_1 = (f$Baseline.Meta=="T")
C_1 = (f$Baseline.Meta=="C")
G_1 = (f$Baseline.Meta=="G")
A_2 = (f$Effect.Meta=="A")
T_2 = (f$Effect.Meta=="T")
C_2 = (f$Effect.Meta=="C")
G_2 = (f$Effect.Meta=="G")
f$Baseline.Meta[A_1] = "T"
f$Baseline.Meta[T_1] = "A"
f$Baseline.Meta[C_1] = "G"
f$Baseline.Meta[G_1] = "C"
f$Effect.Meta[A_2] = "T"
f$Effect.Meta[T_2] = "A"
f$Effect.Meta[C_2] = "G"
f$Effect.Meta[G_2] = "C"
SNP_col = which(colnames(f)=="SNP")
write_tsv(f[,-SNP_col],"rsidmap/BRCA_transfer.gz")

f = vroom("rsidmap/lung.gz")
f = f[!grepl("rs",f$SNP),]
A_1 = (f$other_allele=="A")
T_1 = (f$other_allele=="T")
C_1 = (f$other_allele=="C")
G_1 = (f$other_allele=="G")
A_2 = (f$effect_allele=="A")
T_2 = (f$effect_allele=="T")
C_2 = (f$effect_allele=="C")
G_2 = (f$effect_allele=="G")
f$other_allele[A_1] = "T"
f$other_allele[T_1] = "A"
f$other_allele[C_1] = "G"
f$other_allele[G_1] = "C"
f$effect_allele[A_2] = "T"
f$effect_allele[T_2] = "A"
f$effect_allele[C_2] = "G"
f$effect_allele[G_2] = "C"
SNP_col = which(colnames(f)=="SNP")
write_tsv(f[,-SNP_col],"rsidmap/lung_transfer.gz")

f = vroom("/home/yanyq/share_genetics/data/GWAS/rsidmap/OV.gz")
f = f[!grepl("rs",f$SNP),]
A_1 = (f$Baseline=="A")
T_1 = (f$Baseline=="T")
C_1 = (f$Baseline=="C")
G_1 = (f$Baseline=="G")
A_2 = (f$Effect=="A")
T_2 = (f$Effect=="T")
C_2 = (f$Effect=="C")
G_2 = (f$Effect=="G")
f$Baseline[A_1] = "T"
f$Baseline[T_1] = "A"
f$Baseline[C_1] = "G"
f$Baseline[G_1] = "C"
f$Effect[A_2] = "T"
f$Effect[T_2] = "A"
f$Effect[C_2] = "G"
f$Effect[G_2] = "C"
SNP_col = which(colnames(f)=="SNP")
write_tsv(f[,-SNP_col],"rsidmap/OV_transfer.gz")

f = vroom("/home/yanyq/share_genetics/data/GWAS/rsidmap/PRAD.gz")
f = f[!grepl("rs",f$SNP),]
A_1 = (f$other_allele=="A")
T_1 = (f$other_allele=="T")
C_1 = (f$other_allele=="C")
G_1 = (f$other_allele=="G")
A_2 = (f$effect_allele=="A")
T_2 = (f$effect_allele=="T")
C_2 = (f$effect_allele=="C")
G_2 = (f$effect_allele=="G")
f$other_allele[A_1] = "T"
f$other_allele[T_1] = "A"
f$other_allele[C_1] = "G"
f$other_allele[G_1] = "C"
f$effect_allele[A_2] = "T"
f$effect_allele[T_2] = "A"
f$effect_allele[C_2] = "G"
f$effect_allele[G_2] = "C"
SNP_col = which(colnames(f)=="SNP")
write_tsv(f[,-SNP_col],"rsidmap/PRAD_transfer.gz")

f = vroom("rsidmap/UCEC.gz")
f = f[!grepl("rs",f$SNP),]
A_1 = (f$other_allele=="A")
T_1 = (f$other_allele=="T")
C_1 = (f$other_allele=="C")
G_1 = (f$other_allele=="G")
A_2 = (f$effect_allele=="A")
T_2 = (f$effect_allele=="T")
C_2 = (f$effect_allele=="C")
G_2 = (f$effect_allele=="G")
f$other_allele[A_1] = "T"
f$other_allele[T_1] = "A"
f$other_allele[C_1] = "G"
f$other_allele[G_1] = "C"
f$effect_allele[A_2] = "T"
f$effect_allele[T_2] = "A"
f$effect_allele[C_2] = "G"
f$effect_allele[G_2] = "C"
SNP_col = which(colnames(f)=="SNP")
write_tsv(f[,-SNP_col],"rsidmap/UCEC_transfer.gz")

f = vroom("rsidmap/CRC.gz")
f = f[!grepl("rs",f$SNP),]
A_1 = (f$other_allele=="A")
T_1 = (f$other_allele=="T")
C_1 = (f$other_allele=="C")
G_1 = (f$other_allele=="G")
A_2 = (f$effect_allele=="A")
T_2 = (f$effect_allele=="T")
C_2 = (f$effect_allele=="C")
G_2 = (f$effect_allele=="G")
f$other_allele[A_1] = "T"
f$other_allele[T_1] = "A"
f$other_allele[C_1] = "G"
f$other_allele[G_1] = "C"
f$effect_allele[A_2] = "T"
f$effect_allele[T_2] = "A"
f$effect_allele[C_2] = "G"
f$effect_allele[G_2] = "C"
SNP_col = which(colnames(f)=="SNP")
write_tsv(f[,-SNP_col],"rsidmap/CRC_transfer.gz")

f = vroom("rsidmap/ESCA.gz")
f = f[!grepl("rs",f$SNP),]
A_1 = (f$other_allele=="A")
T_1 = (f$other_allele=="T")
C_1 = (f$other_allele=="C")
G_1 = (f$other_allele=="G")
A_2 = (f$effect_allele=="A")
T_2 = (f$effect_allele=="T")
C_2 = (f$effect_allele=="C")
G_2 = (f$effect_allele=="G")
f$other_allele[A_1] = "T"
f$other_allele[T_1] = "A"
f$other_allele[C_1] = "G"
f$other_allele[G_1] = "C"
f$effect_allele[A_2] = "T"
f$effect_allele[T_2] = "A"
f$effect_allele[C_2] = "G"
f$effect_allele[G_2] = "C"
SNP_col = which(colnames(f)=="SNP")
write_tsv(f[,-SNP_col],"rsidmap/ESCA_transfer.gz")

for(i in c("BLCA","HNSC","kidney","PAAD","SKCM","DLBC","BGC", "STAD", "THCA")){
  f = as.data.frame(vroom(paste0("rsidmap/",i,".gz")))
  f = f[!grepl("rs",f$SNP),]
  A_1 = (f$ref=="A")
  T_1 = (f$ref=="T")
  C_1 = (f$ref=="C")
  G_1 = (f$ref=="G")
  A_2 = (f$alt=="A")
  T_2 = (f$alt=="T")
  C_2 = (f$alt=="C")
  G_2 = (f$alt=="G")
  f$ref[A_1] = "T"
  f$ref[T_1] = "A"
  f$ref[C_1] = "G"
  f$ref[G_1] = "C"
  f$alt[A_2] = "T"
  f$alt[T_2] = "A"
  f$alt[C_2] = "G"
  f$alt[G_2] = "C"
  SNP_col = which(colnames(f)=="SNP")
  write_tsv(f[,-SNP_col],paste0("rsidmap/", i, "_transfer.gz"))
}

# THCA-BGC后补充的癌症
{
  setwd("~/share_genetics/data/GWAS/rsidmap")
  f_all = data.frame(ID = character(),chromosome = numeric(),base_pair_location = numeric(),effect_allele= character(),other_allele= character())
  for(i in c("CESC","HL","LL")){
    f = vroom(paste0(i,".gz"))
    f = f[!grepl("rs",f$SNP),]
    A_1 = (f$other_allele=="A")
    T_1 = (f$other_allele=="T")
    C_1 = (f$other_allele=="C")
    G_1 = (f$other_allele=="G")
    A_2 = (f$effect_allele=="A")
    T_2 = (f$effect_allele=="T")
    C_2 = (f$effect_allele=="C")
    G_2 = (f$effect_allele=="G")
    f$other_allele[A_1] = "T"
    f$other_allele[T_1] = "A"
    f$other_allele[C_1] = "G"
    f$other_allele[G_1] = "C"
    f$effect_allele[A_2] = "T"
    f$effect_allele[T_2] = "A"
    f$effect_allele[C_2] = "G"
    f$effect_allele[G_2] = "C"
    f = f[,c("SNP","chromosome","base_pair_location","effect_allele", "other_allele")]
    colnames(f)[1] = "ID"
    f = f[!f$ID%in%f_all$ID,]
    f_all = rbind(f_all,f)
  }
  write_tsv(f_all, "CESC-HL-LL_transfer.gz")
  
  f = as.data.frame(vroom("/home/yanyq/share_genetics/data/GWAS/rsidmap/finngen_SNP_loc_hg38"))
  {
    f = f[!grepl("rs",f$SNP),]
    A_1 = (f$ref=="A")
    T_1 = (f$ref=="T")
    C_1 = (f$ref=="C")
    G_1 = (f$ref=="G")
    A_2 = (f$alt=="A")
    T_2 = (f$alt=="T")
    C_2 = (f$alt=="C")
    G_2 = (f$alt=="G")
    f$ref[A_1] = "T"
    f$ref[T_1] = "A"
    f$ref[C_1] = "G"
    f$ref[G_1] = "C"
    f$alt[A_2] = "T"
    f$alt[T_2] = "A"
    f$alt[C_2] = "G"
    f$alt[G_2] = "C"
  }
  write_tsv(f[,1:6],"/home/yanyq/share_genetics/data/GWAS/rsidmap/finngen_transfer.gz")
  
  f = as.data.frame(vroom("/home/yanyq/share_genetics/data/GWAS/rsidmap/finngen_SNP_loc_hg38_BCC_SCC_rest"))
  {
    f = f[!grepl("rs",f$SNP),]
    A_1 = (f$ref=="A")
    T_1 = (f$ref=="T")
    C_1 = (f$ref=="C")
    G_1 = (f$ref=="G")
    A_2 = (f$alt=="A")
    T_2 = (f$alt=="T")
    C_2 = (f$alt=="C")
    G_2 = (f$alt=="G")
    f$ref[A_1] = "T"
    f$ref[T_1] = "A"
    f$ref[C_1] = "G"
    f$ref[G_1] = "C"
    f$alt[A_2] = "T"
    f$alt[T_2] = "A"
    f$alt[C_2] = "G"
    f$alt[G_2] = "C"
  }
  write_tsv(f[,1:6],"/home/yanyq/share_genetics/data/GWAS/rsidmap/finngen_BCC_SCC_rest_transfer.gz")
}
