setwd("/home/yanyq/share_genetics/data/GWAS/")
library(readr)
library(vroom)
files_done = list.files("mixer_input")
files = list.files("processed")
files = files[!files%in%files_done]
sampleSize = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/sampleSize", col_names = F))

for(i in files){
  f = as.data.frame(vroom(paste0("processed/", i)))
  f$Z = log(f$or)/f$se
  f$N = sampleSize$X2[sampleSize$X1==gsub(".gz","",i)]
  f = f[,c("snpid", "a1", "a2", "Z", "N")]
  colnames(f) = c("SNP","A1","A2","Z","N")
  write_tsv(f, paste0("mixer_input/", i))
}
