library(readr)
library(vroom)

{
  setwd("/home/yanyq/share_genetics/result/ldsc/munge/")
  
  files = list.files()
  files = files[grep(".gz", files)]
  
  for(i in files){
    f = as.data.frame(vroom(i))
    f = f[!is.na(f$Z) & (f$Z)^2 < 80, ]
    write_tsv(f, paste0("/home/yanyq/share_genetics/result/ldsc/munge_filter/",i))
  }
}

{
  setwd("/home/yanyq/share_genetics/result/ldsc/munge_sampleSize_effect/")
  
  files = list.files()
  files = files[grep(".gz", files)]
  
  for(i in files){
    f = as.data.frame(vroom(i))
    f = f[!is.na(f$Z) & (f$Z)^2 < 80, ]
    write_tsv(f, paste0("/home/yanyq/share_genetics/result/ldsc/munge_sampleSize_effect_filter/",i))
  }
}

{
  setwd("/home/yanyq/share_genetics/result/ldsc/munge_sampleSize_effect_4/")
  
  files = list.files()
  files = files[grep(".gz", files)]
  
  for(i in files){
    f = as.data.frame(vroom(i))
    f = f[!is.na(f$Z) & (f$Z)^2 < 80, ]
    write_tsv(f, paste0("/home/yanyq/share_genetics/result/ldsc/munge_sampleSize_effect_4_filter/",i))
  }
}