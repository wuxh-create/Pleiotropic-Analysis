# 显著的多效SNP统计
# wc -l /home/yanyq/share_genetics/result/PLACO/sig_* > /home/yanyq/share_genetics/result/PLACO/sig_num
library(readr)
library(ggplot2)
library(ggnewscale)
library(RColorBrewer)
library(gridExtra)

# 所有显著的多效位点
f = read.table("/home/yanyq/share_genetics/result/PLACO/sig_num", header = F)
f = f[-704,]
f$V2 = gsub("/home/yanyq/share_genetics/result/PLACO/sig_","",f$V2)
f = tidyr::separate(f, col = "V2", into = c("trait1", "trait2"), sep = "-")
f$V1 = f$V1-1

# FUMA注释的多效基因座
# Based on the identified independent significant SNPs, independent lead SNPs are 
# defined if they are independent from each other at r 2 < 0.1. 
# Additionally, if LD blocks of independent significant SNPs are closely 
# located to each other (< 250 kb based on the most right and left SNPs from each LD block), 
# they are merged into one genomic locus. 
# Each genomic locus can thus contain multiple independent significant SNPs and lead SNPs.
lead = f
lead$V1[lead$V1!=0] = NA
for(i in 1:nrow(lead)){
  trait1 = lead$trait1[i]
  trait2 = lead$trait2[i]
  if(file.exists(paste0("/home/yanyq/share_genetics/result/FUMA/",trait1,"-",trait2,"/GenomicRiskLoci.txt"))){
    FUMA_both = read_tsv(paste0("/home/yanyq/share_genetics/result/FUMA/",trait1,"-",trait2,"/GenomicRiskLoci.txt"))
    lead$V1[i] = nrow(FUMA_both)
  }
}
which(lead$V1==0&f$V1!=0)
which(lead$V1!=0&f$V1==0)
which(lead$trait1!=f$trait1)
which(lead$trait2!=f$trait2)
write_tsv(lead, "/home/yanyq/share_genetics/result/FUMA/all_loci_num")

lead = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/FUMA/all_loci_num"))
samplesize = read_tsv("/home/yanyq/share_genetics/data/sampleSize_effect_4", col_names = F)
# 根据samplesize排序
trait = samplesize$X1[order(samplesize$X2, decreasing = T)]
m = matrix(nrow = length(trait),ncol = length(trait))
colnames(m) = trait
rownames(m) = trait
for(i in 1:nrow(m)){
  for(j in 1:i){
    pos = which((f$trait1==rownames(m)[i]&f$trait2==colnames(m)[j])|(f$trait2==rownames(m)[i]&f$trait1==colnames(m)[j]))
    if(length(pos)!=0){
     m[i,j] = f$V1[pos]
     m[j,i] = lead$V1[pos]
    }
  }
}
data_melted <- reshape2::melt(m)

data_melted$upper <- NA
data_melted$lower <- NA

for (i in 1:nrow(data_melted)) {
  row <- data_melted[i, "Var1"]
  col <- data_melted[i, "Var2"]
  if (as.numeric(row) <= as.numeric(col)) {
    data_melted[i, "upper"] <- data_melted[i, "value"]
  } else if (as.numeric(row) > as.numeric(col)) {
    data_melted[i, "lower"] <- data_melted[i, "value"]
  }
}

display.brewer.all()

colors_upper <- brewer.pal(9,'Spectral')
colors_upper = c("white", colors_upper[4:9])

# 绘制热图
# 定义上三角和下三角的颜色范围
lower_colors <- colorRampPalette(c("white", "#546de5"))(100)
upper_colors <- colorRampPalette(c("white", "#ff4757"))(100)

# 手动设置颜色
max_upper = 120 # 114
max_lower = 7200 # 7177
cut_upper = cut(c(max_upper,data_melted$upper[!is.na(data_melted$upper)]), breaks = 100, labels = FALSE)
cut_lower =  cut(c(max_lower, data_melted$lower[!is.na(data_melted$lower)]), breaks = 100, labels = FALSE)

data_melted$fill <- NA
data_melted$fill[!is.na(data_melted$lower)] <- lower_colors[cut_lower[-1]]
data_melted$fill[!is.na(data_melted$upper)] <- upper_colors[cut_upper[-1]]
data_melted$fill[data_melted$Var1==data_melted$Var2] = "#d2dae2"
# 绘制热图
ggplot(data_melted, aes(x = Var2, y = Var1)) +
  geom_tile(aes(fill = fill)) +
  geom_text(aes(label = value), color = "black", size = 3) +
  scale_fill_identity() +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 12, color = "black"),
        axis.text.y = element_text(size = 12, color = "black"),
        axis.title = element_blank(),
        panel.grid = element_blank())

legend_data <- data.frame(
  x = 0,
  y = rep(1:100),
  fill = c(lower_colors)
)
legend_data <- data.frame(
  x = 0,
  y = rep(1:100),
  fill = c(upper_colors)
)

ggplot(legend_data, aes(x = x, y = y, fill = fill)) +
  geom_tile() +
  scale_fill_identity() +
  scale_y_continuous(breaks = seq(0,100,10)) +
  scale_x_continuous(expand=c(0, 0))+
  theme(legend.position = "none",
        axis.text.y = element_text(size = 12, color = "black"))

# 样本量和鉴定到的多效基因座的关系
for(i in 1:nrow(lead)){
  lead$samplesize[i] = samplesize$X2[samplesize$X1==lead$trait1[i]]+samplesize$X2[samplesize$X1==lead$trait2[i]]
}

library(ggplot2)
library(ggExtra)

# 绘制散点图
p <- ggplot(lead, aes(x = samplesize, y = V1)) +
  geom_point() +
  theme_minimal()

# 添加柱状图
ggMarginal(p, type = "histogram")

