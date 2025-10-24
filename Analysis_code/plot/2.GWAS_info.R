library(showtext)
library(ggplot2)
library(RColorBrewer)
library(ggbreak)
library(gridExtra)
library(patchwork)
library(readr)
library(extrafont)
library(forestplot)


showtext_auto()
font_add("SimSun", "/home/yanyq/usr/share/font/simsun.ttc")  # 使用宋体（SimSun）
font_add("Arial","/home/yanyq/usr/share/font/arial-font/arial.ttf")

#######################所有样本 GWAS summary case数目
samplesize = as.data.frame(read.table("/home/yanyq/share_genetics/data/sampleSize_case_control", header = T))
cancer_abbrev = as.data.frame(read.table("/home/yanyq/share_genetics/data/cancer_abbrev", header = F))
colnames(cancer_abbrev) = c("cancer", "name")
samplesize = dplyr::left_join(samplesize, cancer_abbrev, by = "cancer")
samplesize = samplesize[samplesize$cancer!="CORP",]
samplesize = samplesize[order(samplesize$case, decreasing = T),]
samplesize$name = factor(samplesize$name,levels = samplesize$name)

p = ggplot(data = samplesize, mapping = aes(x = name, fill = name, y = case)) +
  geom_bar(stat = "identity", width = 0.5, fill = "#4DAF4A") +
  geom_text(stat = 'identity', aes(label = case), vjust = -0.5, size = 3.5) +
  # 使用 ggbreak 设置 y 轴截断
  scale_y_break(c(8000,10000,35000, 70000),  # 设置截断位置及范围
                space = 0.1,        # 截断区域的间距
                scales = 0.5,      # 控制截断的显示比例
                expand = c(0, 0)) + # 上下方向不扩展
  scale_y_continuous(
    expand = c(0, 0), 
    limits = c(0, 130000),
    breaks = c(2000,4000,6000,10000, 20000, 30000, 70000, 100000, 130000)
  ) +
  labs(x = "癌症", y = "样本量") +

  theme(
    legend.position = "none",
    panel.grid.major = element_blank(),  # 去除主网格线
    panel.grid.minor = element_blank(),  # 去除次网格线
    panel.background = element_blank(),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, size = 12, colour = "black", family = "SimSun"),
    axis.text.y = element_text(size = 12, colour = "black", family = "Arial"),
    axis.text.y.right = element_blank(),
    axis.ticks.y.right = element_blank(), 
    axis.title = element_text(size = 12, family = "SimSun"),
    axis.line.x = element_line(color = "black", linewidth = 0.2),  # 显示坐标轴的横线和纵线
    axis.line.y.left = element_line(color = "black", linewidth = 0.2),  # 显示坐标轴的横线和纵线
    # axis.ticks = element_line(color = "black", linewidth = 0.5) 
  )
p
pdf("/home/yanyq/share_genetics/final_result/plot/2.1.GWAS_samplesize.pdf",width = 15, height=8)
p
dev.off()
png("/home/yanyq/share_genetics/final_result/plot/2.1.GWAS_samplesize.png",width = 1500, height=800)
p
dev.off()

##############################
# GWAS遗传力 Z大于2的样本，20个样本
# 用inkscape把森林图和条形图拼起来
###########条形图
samplesize = as.data.frame(read.table("/home/yanyq/share_genetics/data/sampleSize_case_control", header = T))
cancer_abbrev = as.data.frame(read.table("/home/yanyq/share_genetics/data/cancer_abbrev", header = F))
colnames(cancer_abbrev) = c("cancer", "name")

samplesize = dplyr::left_join(samplesize, cancer_abbrev, by = "cancer")
colnames(samplesize)[1] = "trait"

h2 = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/ldsc/ldsc_h2_cal_sampleSize_effect_4"))
h2 = h2[(h2$h2_obs/h2$h2_se)>=2,]
h2 = h2[h2$trait!="CORP",]
h2$upper = h2$h2_obs+1.96*h2$h2_se
h2$lower = h2$h2_obs-1.96*h2$h2_se
h2 = dplyr::left_join(h2,samplesize, by = "trait")
h2 = h2[order(h2$case, decreasing = T),]
# 提取leadSNP数目
h2$num_leadSNP = NA
for(i in 1:nrow(h2)){
  file_name = paste0("/home/yanyq/share_genetics/result/FUMA/",h2$trait[i],"/leadSNPs.txt")
  h2$num_leadSNP[i] = ifelse(file.exists(file_name),nrow(read_tsv(file_name)),0)
}
# 条形图
plot_data = h2
plot_data$name = factor(plot_data$name, levels = plot_data$name[order(h2$case)])
# plot_data$name = factor(plot_data$name, labels = plot_data$name)
p = ggplot(data = plot_data, mapping = aes(x = name, fill = name, y = num_leadSNP)) +
  geom_bar(stat = "identity", width = 0.5, fill = "#E0B673") +
  geom_text(stat = 'identity', aes(label = num_leadSNP), vjust = 0.5,hjust = -0.5, size = 3.5) +
  # 使用 ggbreak 设置 y 轴截断
  scale_y_break(c(500,800),  # 设置截断位置及范围
                space = 0.3,        # 截断区域的间距
                scales = 0.25,      # 控制截断的显示比例
                expand = c(0, 0)) + # 上下方向不扩展
  scale_y_continuous(
    expand = c(0, 0),
    limits = c(0, 900),
    breaks = c(100,200,300,400,800,900)
  ) +
  labs(y = "lead SNP数", x = "") +
  coord_flip() + # 坐标转换
  theme(
    legend.position = "none",
    panel.grid.major = element_blank(),  # 去除主网格线
    panel.grid.minor = element_blank(),  # 去除次网格线
    panel.background = element_blank(),
    axis.text.x = element_text(size = 12, colour = "black", family = "Arial"),
    axis.text.y = element_text(size = 12, colour = "black", family = "SimSun"),
    axis.text.y.right = element_blank(),
    axis.ticks.y = element_blank(),
    axis.ticks.x.top = element_blank(),
    axis.text.x.top = element_blank(),
    # axis.ticks.x.right = element_blank(),
    axis.title = element_text(size = 12, family = "SimSun"),
    axis.line.x.bottom = element_line(color = "black", linewidth = 0.2),  # 显示坐标轴的横线和纵线
    axis.line.y.left = element_line(color = "black", linewidth = 0.2),  # 显示坐标轴的横线和纵线
    # axis.ticks = element_line(color = "black", linewidth = 0.5) 
  ) 
pdf("/home/yanyq/share_genetics/final_result/plot/2.2.1.GWAS_num_leadSNP.pdf", width = 5, height = 5)
p
dev.off()
################################################森林图

# h2$name = factor(h2$name, levels = h2$name)
h2 = rbind(colnames(h2),h2)
h2[1,c("h2_obs","upper","lower")] = NA
h2$name[1] = "癌症"
h2$case[1] = "病例数"

p2 = forestplot(h2[,c("name", "case")], # 文字部分
           mean = h2$h2_obs,
           lower = h2$lower,
           upper = h2$upper,
           graph.pos = 3, # 图的位置在第几列，如：3代表图在第2列后第几出现。
           is.summary=c(TRUE,rep(FALSE,20)), #是否突出显示。传入一个长度等于图表行数的向量，下标为TRUE的行会被加粗，且该行上下会添加一条直线，但在未设置颜色时不显示。
           hrzl_lines = list("2" = gpar(lwd=1)),
           graphwidth = unit(0.17,"npc"), ##森林图的宽度，
           colgap = unit(0.5, "cm"),     # 设置列间距为1厘米
           clip=c(0,1.5), # 设置x轴的范围，若置信区间落在设定的范围外，则用箭头表示
           xlog=FALSE,# 是否设置x轴为对数坐标轴，默认否。
           boxsize = 0.4, # 设置box的大小
           fn.ci_norm = rep("fpDrawCircleCI",times = nrow(h2)),
           # 修改森林图轴标题和刻度的字体和大小
           txt_gp = fpTxtGp(ticks = gpar(cex=1, family = "SimSun"),
                            xlab = gpar(cex=1, family = "SimSun")),
           # txt_gp = fpTxtGp(label = gpar(fontfamily = "Roboto Condensed",cex = 0.8),
           #                  ticks = gpar(fontfamily = "Roboto Condensed", cex = .5)),
           xticks = c(0,0.5,1,1.5), #设置x轴ticks
           xlab = "遗传力", # x轴标题
           lwd.ci = 1,# 设置HR线宽度
           col=fpColors(line="black",box= "#7898CD", zero = "black"))
pdf("/home/yanyq/share_genetics/final_result/plot/2.2.2.GWAS_h2_forest.pdf", width = 5, height = 5)
p2
dev.off()

##############################
# GWAS遗传力 Z小于2的样本，17个样本
# 用inkscape把森林图和条形图拼起来
###########条形图
samplesize = as.data.frame(read.table("/home/yanyq/share_genetics/data/sampleSize_case_control", header = T))
cancer_abbrev = as.data.frame(read.table("/home/yanyq/share_genetics/data/cancer_abbrev", header = F))
colnames(cancer_abbrev) = c("cancer", "name")

samplesize = dplyr::left_join(samplesize, cancer_abbrev, by = "cancer")
colnames(samplesize)[1] = "trait"

h2 = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/ldsc/ldsc_h2_cal_sampleSize_effect_4"))
h2 = h2[(h2$h2_obs/h2$h2_se)<2,]
h2 = h2[h2$trait!="CORP",]
h2$upper = h2$h2_obs+1.96*h2$h2_se
h2$lower = h2$h2_obs-1.96*h2$h2_se
h2 = dplyr::left_join(h2,samplesize, by = "trait")
h2 = h2[order(h2$case, decreasing = T),]
# 提取leadSNP数目
h2$num_leadSNP = NA
for(i in 1:nrow(h2)){
  file_name = paste0("/home/yanyq/share_genetics/result/FUMA/",h2$trait[i],"/leadSNPs.txt")
  h2$num_leadSNP[i] = ifelse(file.exists(file_name),nrow(read_tsv(file_name)),0)
}
# 条形图
plot_data = h2
plot_data$name = factor(plot_data$name, levels = plot_data$name[order(h2$case)])
# plot_data$name = factor(plot_data$name, labels = plot_data$name)
p = ggplot(data = plot_data, mapping = aes(x = name, fill = name, y = num_leadSNP)) +
  geom_bar(stat = "identity", width = 0.5, fill = "#E0B673") +
  geom_text(stat = 'identity', aes(label = num_leadSNP), vjust = 0.5,hjust = -0.5, size = 3.5) +
  # 使用 ggbreak 设置 y 轴截断
  # scale_y_break(c(500,800),  # 设置截断位置及范围
  #               space = 0.3,        # 截断区域的间距
  #               scales = 0.25,      # 控制截断的显示比例
  #               expand = c(0, 0)) + # 上下方向不扩展
  scale_y_continuous(
    expand = c(0, 0),
    limits = c(0, 8),

  ) +
  labs(y = "lead SNP数", x = "") +
  coord_flip() + # 坐标转换
  theme(
    legend.position = "none",
    panel.grid.major = element_blank(),  # 去除主网格线
    panel.grid.minor = element_blank(),  # 去除次网格线
    panel.background = element_blank(),
    axis.text.x = element_text(size = 12, colour = "black", family = "Arial"),
    axis.text.y = element_text(size = 12, colour = "black", family = "SimSun"),
    axis.text.y.right = element_blank(),
    axis.ticks.y = element_blank(),
    axis.ticks.x.top = element_blank(),
    axis.text.x.top = element_blank(),
    # axis.ticks.x.right = element_blank(),
    axis.title = element_text(size = 12, family = "SimSun"),
    axis.line.x.bottom = element_line(color = "black", linewidth = 0.2),  # 显示坐标轴的横线和纵线
    axis.line.y.left = element_line(color = "black", linewidth = 0.2),  # 显示坐标轴的横线和纵线
    # axis.ticks = element_line(color = "black", linewidth = 0.5) 
  ) 
pdf("/home/yanyq/share_genetics/final_result/plot/2.2.1.GWAS_num_leadSNP_h2_SMALL_2.pdf", width = 5, height = 5)
p
dev.off()
################################################森林图

# h2$name = factor(h2$name, levels = h2$name)
h2 = rbind(colnames(h2),h2)
h2[1,c("h2_obs","upper","lower")] = NA
h2$name[1] = "癌症"
h2$case[1] = "病例数"

p2 = forestplot(h2[,c("name", "case")], # 文字部分
                mean = h2$h2_obs,
                lower = h2$lower,
                upper = h2$upper,
                graph.pos = 3, # 图的位置在第几列，如：3代表图在第2列后第几出现。
                is.summary=c(TRUE,rep(FALSE,20)), #是否突出显示。传入一个长度等于图表行数的向量，下标为TRUE的行会被加粗，且该行上下会添加一条直线，但在未设置颜色时不显示。
                hrzl_lines = list("2" = gpar(lwd=1)),
                graphwidth = unit(0.17,"npc"), ##森林图的宽度，
                colgap = unit(0.5, "cm"),     # 设置列间距为1厘米
                clip=c(-2,2), # 设置x轴的范围，若置信区间落在设定的范围外，则用箭头表示
                xlog=FALSE,# 是否设置x轴为对数坐标轴，默认否。
                boxsize = 0.4, # 设置box的大小
                fn.ci_norm = rep("fpDrawCircleCI",times = nrow(h2)),
                # 修改森林图轴标题和刻度的字体和大小
                txt_gp = fpTxtGp(ticks = gpar(cex=1, family = "SimSun"),
                                 xlab = gpar(cex=1, family = "SimSun")),
                # txt_gp = fpTxtGp(label = gpar(fontfamily = "Roboto Condensed",cex = 0.8),
                #                  ticks = gpar(fontfamily = "Roboto Condensed", cex = .5)),
                xticks = c(-2,-1,0,1,2), #设置x轴ticks
                xlab = "遗传力", # x轴标题
                lwd.ci = 1,# 设置HR线宽度
                col=fpColors(line="black",box= "#7898CD", zero = "black"))
pdf("/home/yanyq/share_genetics/final_result/plot/2.2.2.GWAS_h2_forest_h2_SMALL_2.pdf", width = 5, height = 5)
p2
dev.off()
