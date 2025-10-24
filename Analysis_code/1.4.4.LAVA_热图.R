setwd("/home/yanyq/share_genetics/result/LAVA")
library(readr)
files = list.files()
files = files[grep("BLCA", files)]
files = files[grep("bivar.lava", files)]
all_f = as.data.frame(read.table(files[1], header = T))
all_f = all_f[!is.na(all_f$p),]
colnames(all_f)[9] = "BRCA"
all_f = all_f[,c(1,9)]

for(i in files[-1]){
  f = as.data.frame(read.table(i, header = T))
  f = f[!is.na(f$p),]
  colnames(f)[9] = f$phen2[1]
  all_f = merge(all_f, f[,c(1,9)], by = "locus", all.x = T, all.y = T)
}
all_f[is.na(all_f)] = 0
write_tsv(all_f, "/home/yanyq/share_genetics/result/LAVA/BLCA")

pheatmap(as.matrix(all_f[,-1]))

library(reshape2)
my_data = melt(all_f, id.vars = "locus", measure.vars = colnames(all_f)[-1])
my_data$locus = as.character(my_data$locus)
head(my_data)
library(ggplot2)
ggplot(data = my_data, aes(x=variable, y=locus, fill=value)) + 
  geom_tile(color = "white")+
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 0, limit = c(-1,1), space = "Lab", 
                       name="Pearson\nCorrelation")

#############################################

setwd("/home/yanyq/share_genetics/result/LAVA")
library(readr)
files = list.files()
files = files[grep("bivar.lava", files)]
# files = c("BLCA-HNSC.bivar.lava","BLCA-kidney.bivar.lava","BLCA-lung.bivar.lava","BLCA-OV.bivar.lava",
#           "BLCA-PAAD.bivar.lava","BLCA-PRAD.bivar.lava","BLCA-SKCM.bivar.lava","BLCA-UCEC.bivar.lava",
#           "BRCA-HNSC.bivar.lava","BRCA-kidney.bivar.lava","BRCA-lung.bivar.lava","BRCA-OV.bivar.lava",
#           "BRCA-PAAD.bivar.lava","BRCA-PRAD.bivar.lava","BRCA-SKCM.bivar.lava","BRCA-UCEC.bivar.lava",
#           "HNSC-kidney.bivar.lava","HNSC-PAAD.bivar.lava","HNSC-PRAD.bivar.lava","HNSC-SKCM.bivar.lava",
#           "kidney-lung.bivar.lava","kidney-PAAD.bivar.lava","kidney-PRAD.bivar.lava","kidney-SKCM.bivar.lava",
#           "lung-OV.bivar.lava","lung-PRAD.bivar.lava","lung-SKCM.bivar.lava","lung-UCEC.bivar.lava",
#           "OV-PAAD.bivar.lava","OV-PRAD.bivar.lava","OV-SKCM.bivar.lava","OV-UCEC.bivar.lava","PAAD-PRAD.bivar.lava",
#           "PAAD-SKCM.bivar.lava","PRAD-SKCM.bivar.lava","PRAD-UCEC.bivar.lava")

# files = files[grep("BLCA", files)]
chr=22

all_f = as.data.frame(read.table(files[1], header = T))
all_f = all_f[!is.na(all_f$p),]
all_f$FDR = p.adjust(all_f$p, method = "BH")
all_f = all_f[all_f$FDR<0.05,]
# all_f = all_f[all_f$chr==chr,]
colnames(all_f)[9] = paste0(all_f$phen1[1], "-", all_f$phen2[1])
all_f = all_f[,c(1,9)]

for(i in files[-1]){
  f = as.data.frame(read.table(i, header = T))
  f = f[!is.na(f$p),]
  f$FDR = p.adjust(f$p, method = "BH")
  f = f[f$FDR<0.05,]
  # f = f[f$chr==chr,]
  if(nrow(f)>0){
    print(i)
    colnames(f)[9] = paste0(f$phen1[1], "-", f$phen2[1])
    colnames(f)[9] = paste0(f$phen1[1], "-", f$phen2[1])
    all_f = merge(all_f, f[,c(1,9)], by = "locus", all.x = T, all.y = T)
  }
  
}
if(length(which(is.na(all_f[,2])))==nrow(all_f)){
  all_f = all_f[,-2]
}

# 每个位点有多少对癌症存在遗传相关性
all_f$asso_num = 0
for(i in 1:nrow(all_f)){
  all_f$asso_num[i] = length(which(!is.na(all_f[i,-c(1, ncol(all_f))])))
}
write_tsv(all_f, "/home/yanyq/share_genetics/result/LAVA/all_sig_asso")
# all_f[is.na(all_f)] = 0

# pheatmap(as.matrix(all_f[,-1]))

library(reshape2)
my_data = melt(all_f, id.vars = "locus", measure.vars = colnames(all_f)[-1])
my_data$locus = as.character(my_data$locus)
head(my_data)
library(ggplot2)
pdf(file = paste0("all",".pdf"), height = 80, width =15)
ggplot(data = my_data, aes(x=variable, y=locus, fill=value)) + 
  geom_tile(color = "white")+
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 0, limit = c(-1,1), space = "Lab", 
                       name="Pearson\nCorrelation") 
dev.off()

