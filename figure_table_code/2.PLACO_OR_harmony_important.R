# 2.PLACO.R中只协调了zscore的方向， 没有协调OR方向
library(data.table)
library(readr)

setwd("~/share_genetics/data/GWAS/overlap/")
files = list.files()
files = files[!grepl("DLBC",files)]
for(i in files){
  print(i)
  traits = gsub(".gz","",i)
  trait1 = strsplit(traits,"-")[[1]][1]
  trait2 = strsplit(traits,"-")[[1]][2]
  f = as.data.frame(fread(i))
  OR_trait1 = f[,paste0("or.",trait1)]
  OR_trait2 = f[,paste0("or.",trait2)]
  Z_trait1 = f[,paste0("zscore.",trait1)]
  Z_trait2 = f[,paste0("zscore.",trait2)]
  unharmonizad_trait1 = (OR_trait1<1&Z_trait1>0)|(OR_trait1>1&Z_trait1<0)
  unharmonizad_trait2 = (OR_trait2<1&Z_trait2>0)|(OR_trait2>1&Z_trait2<0)
  f[unharmonizad_trait1,paste0("or.",trait1)] = exp(-log(f[unharmonizad_trait1,paste0("or.",trait1)]))
  f[unharmonizad_trait2,paste0("or.",trait2)] = exp(-log(f[unharmonizad_trait2,paste0("or.",trait2)]))
  write_tsv(f,i)
}
