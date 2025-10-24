# 多效SNP
placo = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer_MAGMA_SMR_GWASCatalog_cancer_separate_SUPERGNOVA_coloc_DEG_LAVA_SNPcoloc"))
placo = placo[!grepl("CORP",placo$traits),] # 75243个多效SNP
length(unique(placo$traits)) # 372对癌症
length(unique(placo$snpid)) # 30796个非重复SNP
table(placo$is.IndSig_lead) # 3472个lead SNP
length(unique(placo$snpid[placo$is.IndSig_lead=="leadSNP"])) # 2534个非重复lead SNP

# 显著的多效SNP和lead SNP统计
# wc -l /home/yanyq/share_genetics/result/PLACO/sig_* > /home/yanyq/share_genetics/result/PLACO/sig_num
library(readr)
library(ggplot2)
library(ggnewscale)
library(RColorBrewer)
library(gridExtra)
library(showtext)
showtext_auto()
font_add("Arial","/home/yanyq/usr/share/font/arial-font/arial.ttf")
font_add("SimSun", "/home/yanyq/usr/share/font/simsun.ttc")  # 使用宋体（SimSun）

# 所有显著的多效位点
f = read.table("/home/yanyq/share_genetics/result/PLACO/sig_num", header = F)
f = f[-704,]
f$V2 = gsub("/home/yanyq/share_genetics/result/PLACO/sig_","",f$V2)
f = f[!grepl("CORP", f$V2),]
f = tidyr::separate(f, col = "V2", into = c("trait1", "trait2"), sep = "-")
f$V1 = f$V1-1

lead = as.data.frame(read_tsv("/home/yanyq/share_genetics/final_result/FUMA/all_leadSNP_AND_loci_num"))
samplesize = read_tsv("/home/yanyq/share_genetics/data/sampleSize_case_control")
samplesize = samplesize[samplesize$cancer!="CORP",]
samplesize = samplesize[samplesize$case>1000,]
cancer_abbrev = read_tsv("/home/yanyq/share_genetics/data/cancer_abbrev", col_names = F)
colnames(cancer_abbrev) = c("cancer", "name")
samplesize = dplyr::left_join(samplesize, cancer_abbrev,by = "cancer")
# 根据samplesize排序
trait = samplesize$cancer[order(samplesize$case, decreasing = T)]
m = matrix(nrow = length(trait),ncol = length(trait))
colnames(m) = trait
rownames(m) = trait
for(i in 1:nrow(m)){
  for(j in 1:i){
    pos = which((f$trait1==rownames(m)[i]&f$trait2==colnames(m)[j])|(f$trait2==rownames(m)[i]&f$trait1==colnames(m)[j]))
    if(length(pos)!=0){
      m[i,j] = f$V1[pos]
      m[j,i] = lead$num_leadSNP[pos]
    }
  }
}
colnames(m) = samplesize$name[order(samplesize$case, decreasing = T)]
rownames(m) = samplesize$name[order(samplesize$case, decreasing = T)]
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

# colors_upper <- brewer.pal(9,'Spectral')
# colors_upper = c("white", colors_upper[4:9])

# 绘制热图
# 定义上三角和下三角的颜色范围 
#9AC4DB #ACA1BE
lower_colors <- colorRampPalette(c("white", "#7898CD"))(100)
upper_colors <- colorRampPalette(c("white", "#E0B673"))(100)
# lower_colors <- colorRampPalette(c("white", "#9AC4DB"))(100)
# upper_colors <- colorRampPalette(c("white", "#ACA1BE"))(100)

# 手动设置颜色
max_upper = 210 # 203
max_lower = 7200 # 7177
cut_upper = cut(c(max_upper,data_melted$upper[!is.na(data_melted$upper)]), breaks = 100, labels = FALSE)
cut_lower =  cut(c(max_lower, data_melted$lower[!is.na(data_melted$lower)]), breaks = 100, labels = FALSE)

data_melted$fill <- NA
data_melted$fill[!is.na(data_melted$lower)] <- lower_colors[cut_lower[-1]]
data_melted$fill[!is.na(data_melted$upper)] <- upper_colors[cut_upper[-1]]
data_melted$fill[data_melted$Var1==data_melted$Var2] = "#d2dae2"
# 绘制热图
# "/home/yanyq/share_genetics/artical/plot/placo_snp_heatmap.png"
pdf("/home/yanyq/share_genetics/artical/plot/placo_snp_heatmap.pdf",height = 8,width = 8)
ggplot(data_melted, aes(x = Var2, y = Var1)) +
  geom_tile(aes(fill = fill)) +
  geom_text(aes(label = value), color = "black", size = 3, family= "Arial") +
  scale_fill_identity() +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 10, color = "black", family = "SimSun"),
        axis.text.y = element_text(size = 10, color = "black",family = "SimSun"),
        axis.title = element_blank(),
        panel.grid = element_blank())
dev.off()
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

###################################################### 样本量和鉴定到的SNP、leadSNP的关系
samplesize = read_tsv("/home/yanyq/share_genetics/data/sampleSize_case_control")
lead = as.data.frame(read_tsv("/home/yanyq/share_genetics/final_result/FUMA/all_leadSNP_AND_loci_num"))
f = read.table("/home/yanyq/share_genetics/result/PLACO/sig_num", header = F)
f = f[-704,]
f$V2 = gsub("/home/yanyq/share_genetics/result/PLACO/sig_","",f$V2)
f = f[!grepl("CORP", f$V2),]
f = tidyr::separate(f, col = "V2", into = c("trait1", "trait2"), sep = "-")
f$V1 = f$V1-1

for(i in 1:nrow(lead)){
  lead$samplesize[i] = samplesize$case[samplesize$cancer==lead$trait1[i]]+samplesize$case[samplesize$cancer==lead$trait2[i]]
  f$samplesize[i] = samplesize$case[samplesize$cancer==f$trait1[i]]+samplesize$case[samplesize$cancer==f$trait2[i]]
}
which(lead$samplesize[order(lead$samplesize)]!=f$samplesize[order(f$samplesize)])

cancer_abbrev = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/cancer_abbrev", col_names = F))
colnames(cancer_abbrev) = c("trait1", "name1")
lead = left_join(lead, cancer_abbrev, by = "trait1")
f = left_join(f, cancer_abbrev, by = "trait1")
colnames(cancer_abbrev) = c("trait2", "name2")
lead = left_join(lead, cancer_abbrev, by = "trait2")
f = left_join(f, cancer_abbrev, by = "trait2")

library(ggplot2)
library(ggExtra)
# trait_color = c("#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd", "#8c564b",
#                 "#e377c2", "#7f7f7f", "#bcbd22", "#17becf", "#8b0000", "#ff4500",
#                 "#32cd32", "#ffd700", "#7b68ee", "#f4a300", "#556b2f", "#c71585",
#                 "#20b2aa", "#ff1493", "#ff6347", "#4682b4", "#00fa9a", "#ff8c00",
#                 "#ff00ff", "#1e90ff", "#ff69b4", "#d2691e", "#ff6347", "#dcdcdc", 
#                 "#ffb6c1", "#a52a2a", "#228b22", "#800080", "#f08080", "#008080",
#                 "#add8e6", "#ffff00")
# names(trait_color) = unique(c(lead$name1, lead$name1))
# ggplot(lead, aes(x = samplesize, y = num_leadSNP )) +
#   geom_point(aes(color = name1), shape = "\u2BCA", size = 1, fill = "white", stroke = 2) + 
#   geom_point(aes(color = name2), shape = "\u2BCA", size = 1, fill = "white", stroke = 2) +
#   theme_minimal() +
#   scale_color_manual(values = trait_color) +
#   labs(x = "X Axis", y = "Y Axis", title = "Scatter plot with two traits")

# 绘制散点图
# Add regression line and confidence interval
# Add correlation coefficient: stat_cor()
library(ggpubr)
f$group = "多效SNP"
lead$group = "多效lead SNP"
colnames(lead)[3] = "V1"
data_plot = rbind(f[,c(1,4,7)],lead[,c(3,5,8)])
pdf("/home/yanyq/share_genetics/artical/plot/snp_case_scratter.pdf",height = 3,width=4)
ggplot(data_plot, aes(x = samplesize, y =  ifelse(group == "多效SNP", V1, V1 * 20), color = group )) +
  geom_point(size = 1) +
  geom_smooth(formula = y ~ x, se = TRUE,
              method = "lm", fullrange = TRUE, linewidth = 0.5) +
  stat_cor(method = 'spearman', aes(x = samplesize, y = V1, color = group)) +
  scale_color_manual(values = c("多效SNP" = "#377EB8", "多效lead SNP" = "#E41A1C")) +
  scale_y_continuous(
    expand = c(0,0),
    name = "多效SNPs数",
    limits = c(0, 8000),
    sec.axis = sec_axis(
      trans = ~ . / 20,
      name = "多效lead SNPs数"
    )
  ) +
  labs(x = "病例数")+
  theme_bw() +
  theme(axis.text = element_text(size = 10, color = "black", family = "Arial"),
        axis.title = element_text(size = 10, color = "black", family = "SimSun"),
        panel.grid = element_blank(),
        panel.background = element_blank(),
        legend.title = element_blank(),
        legend.text = element_text(size = 10, color = "black", family = "SimSun"),
        legend.position = "top")
dev.off()

ggplot(f, aes(x = samplesize, y = V1 )) +
  geom_point(size = 1,color="#7898CD") +
  geom_smooth(color = "black", formula = y ~ x, se = TRUE,
              method = "lm", fullrange = TRUE, linewidth = 0.5) +
  stat_cor(method = 'spearman', aes(x = samplesize, y = V1)) +
  labs(x = "病例数",y = "多效SNP数")+
  theme_bw() +
  theme(axis.text = element_text(size = 10, color = "black", family = "Arial"),
        axis.title = element_text(size = 10, color = "black", family = "SimSun"),
        panel.grid = element_blank(),
        panel.background = element_blank())

ggplot(lead, aes(x = samplesize, y = V1 )) +
  geom_point(size = 1,color="#7898CD") +
  geom_smooth(color = "black", formula = y ~ x, se = TRUE,
              method = "lm", fullrange = TRUE, linewidth = 0.5) +
  stat_cor(method = 'spearman', aes(x = samplesize, y = V1)) +
  labs(x = "病例数",y = "多效lead SNP数")+
  theme_bw() +
  theme(axis.text = element_text(size = 10, color = "black", family = "Arial"),
        axis.title = element_text(size = 10, color = "black", family = "SimSun"),
        panel.grid = element_blank(),
        panel.background = element_blank())

# 添加柱状图
ggMarginal(p, type = "histogram")

