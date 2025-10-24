library(readr)
library(data.table)
setwd("/home/yanyq/share_genetics/data/GWAS/processed/")
samplesize = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/sampleSize",col_names = F))
files = list.files()
# tmp = samplesize$X1[1:10]
# tmp = paste0(tmp,".gz")
# files = files[!files%in%tmp]
for(i in files){
  f = fread(i)
  f$N = samplesize[samplesize$X1==gsub(".gz","",i),2]
  f$Z = log(f$or)/f$se
  f = f[,c("snpid","a1","a2","Z","N")]
  colnames(f) = c("SNP","A1","A2","Z","N")
  write_tsv(f,paste0("/home/yanyq/share_genetics/data/GWAS/SUPERGNOVA/",i))
}

setwd("/home/yanyq/share_genetics/data/GWAS/SUPERGNOVA/")

for(i in list.files()){
  f = read_tsv(i)
  write_tsv(f[!is.na(f$Z),],i)
}
