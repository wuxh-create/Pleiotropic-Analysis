# lead SNP功能方向
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

all_PLACO = read_tsv("/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer_MAGMA_SMR_GWASCatalog_cancer_separate_SUPERGNOVA_coloc_DEG_LAVA_SNPcoloc")
all_PLACO = all_PLACO[!grepl("CORP",all_PLACO$traits),]

all_PLACO_lead = all_PLACO[all_PLACO$is.IndSig_lead=="leadSNP",]
# 创建 direction 数据表
direction <- data.frame(traits = unique(all_PLACO_lead$traits),  opposite = NA,same = NA)

for(i in 1:nrow(direction)) {
  T_placo <- all_PLACO_lead$T.placo[all_PLACO_lead$traits == direction$traits[i]]
  direction$same[i] <- sum(T_placo > 0)
  direction$opposite[i] <- sum(T_placo < 0)
}
sum(direction$opposite) # 1426
length(which(all_PLACO_lead$T.placo<0))
sum(direction$same) # 2046
length(which(all_PLACO_lead$T.placo>0))
# 计算总和并排序
direction$sum <- direction$same + direction$opposite
# direction = direction[direction$sum<50,]
direction <- direction[order(direction$sum, decreasing = TRUE), ]

# 转换数据格式，并保留 sum 信息
direction_melted <- reshape2::melt(direction, measure.vars = c("same", "opposite"), 
                                   id.vars = c("traits", "sum"), variable.name = "direction", value.name = "freq")

library(plyr)
direction = direction[order(direction$same/direction$sum, decreasing = TRUE), ]
direction$same_order = 1:nrow(direction)
direction_melted_ratio = reshape2::melt(direction, measure.vars = c("same", "opposite"), 
                                        id.vars = c("traits", "same_order"), variable.name = "direction", value.name = "freq")
direction_melted_ratio = ddply(direction_melted_ratio,'traits',transform,percent_frq=freq/sum(freq)*100)

# 将 'direction' 列设为因子并指定顺序，确保 'same' 在 'opposite' 之前
direction_melted$direction <- factor(direction_melted$direction, levels = c("opposite","same"))
direction_melted_ratio$direction <- factor(direction_melted_ratio$direction, levels = c("opposite","same"))

# 绘制堆积柱状图
library(ggplot2)
p1 = ggplot(data = direction_melted, aes(x = reorder(traits, -sum), y = freq, fill = direction)) + 
  geom_bar(stat = "identity") +
  labs(x = "癌症对", y = "多效lead SNP数", fill = "SNP效应方向") +
  geom_col(width = 1) + # 去掉间隔
  scale_y_continuous(
    expand = c(0, 0), 
    # limits = c(0, 130000),
    # breaks = c(2000,4000,6000,10000, 20000, 30000, 70000, 100000, 130000)
  ) +
  scale_fill_manual(values = c("same" = "#7898CD", "opposite" = "#E0B673"), 
                    labels = c("same" = "相同", "opposite" = "相反"))+
  theme_bw()+
  theme(
    panel.grid.major = element_blank(),  # 去除主网格线
    panel.grid.minor = element_blank(),  # 去除次网格线
    panel.background = element_blank(),
    # 
    # legend.position = c(1, 1),
    # legend.justification = c(1.5, 1.3),
    legend.title = element_text(size = 14, colour = "black", family = "SimSun"),
    legend.text = element_text(size = 12, colour = "black", family = "SimSun"),
    
    
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    
    axis.text.y = element_text(size = 12, colour = "black", family = "Arial"),
    axis.text.y.right = element_blank(),
    axis.ticks.y.right = element_blank(), 
    axis.title = element_text(size = 14, family = "SimSun"),
    axis.line.x = element_line(color = "black", linewidth = 0.2),  # 显示坐标轴的横线和纵线
    axis.line.y.left = element_line(color = "black", linewidth = 0.2),  # 显示坐标轴的横线和纵线
    
    # axis.ticks = element_line(color = "black", linewidth = 0.5) 
  )
p1_ratio = ggplot(data = direction_melted_ratio, aes(x = reorder(traits, same_order), y = percent_frq, fill = direction)) + 
  geom_bar(stat = "identity") +
  labs(x = "癌症对", y = "多效lead SNP比例", fill = "SNP效应方向") +
  geom_col(width = 1) + # 去掉间隔
  scale_y_continuous(
    expand = c(0, 0), 
    # limits = c(0, 130000),
    # breaks = c(2000,4000,6000,10000, 20000, 30000, 70000, 100000, 130000)
  ) +
  scale_fill_manual(values = c("same" = "#7898CD", "opposite" = "#E0B673"), 
                    labels = c("same" = "相同", "opposite" = "相反"))+
  theme_bw()+
  theme(
    panel.grid.major = element_blank(),  # 去除主网格线
    panel.grid.minor = element_blank(),  # 去除次网格线
    panel.background = element_blank(),
    # 
    # legend.position = c(1, 1),
    # legend.justification = c(1.5, 1.3),
    legend.title = element_text(size = 14, colour = "black", family = "SimSun"),
    legend.text = element_text(size = 12, colour = "black", family = "SimSun"),
    
    
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    
    axis.text.y = element_text(size = 12, colour = "black", family = "Arial"),
    axis.text.y.right = element_blank(),
    axis.ticks.y.right = element_blank(), 
    axis.title = element_text(size = 14, family = "SimSun"),
    axis.line.x = element_line(color = "black", linewidth = 0.2),  # 显示坐标轴的横线和纵线
    axis.line.y.left = element_line(color = "black", linewidth = 0.2),  # 显示坐标轴的横线和纵线
    
    # axis.ticks = element_line(color = "black", linewidth = 0.5) 
  )

p1_ratio
# 绘制小提琴图
library("vioplot")
# 绘制小提琴图，显示均值和标准差
direction_melted$direction <- factor(direction_melted$direction, levels = c("same", "opposite"))
p2=ggplot(data = direction_melted, aes(x = direction, y = freq, fill = direction)) +
  geom_violin(trim = FALSE) +  # 小提琴图
  stat_summary(fun = mean, geom = "point", shape = 20, size = 3, color = "black") +  # 均值点
  stat_summary(fun.data = mean_sdl, fun.args = list(mult = 1), geom = "pointrange", 
                color = "black") +  # 标准差
  labs(x = "效应方向", y = "多效lead SNP数") + 
  scale_x_discrete(labels = c("same" = "相同", "opposite" = "相反")) +
  scale_fill_manual(values = c("same" = "#7898CD", "opposite" = "#E0B673"), 
                    labels = c("same" = "相同", "opposite" = "相反"))+
  theme_bw()+
  theme(
    panel.grid.major = element_blank(),  # 去除主网格线
    panel.grid.minor = element_blank(),  # 去除次网格线
    panel.background = element_blank(),
    
    # legend.title = element_text(size = 14, colour = "black", family = "SimSun"),
    # legend.text = element_text(size = 12, colour = "black", family = "SimSun"),
    legend.position = "none",
    
    axis.text.x = element_text(size = 12, colour = "black", family = "SimSun"),

    axis.text.y = element_text(size = 12, colour = "black", family = "Arial"),
    axis.text.y.right = element_blank(),
    axis.ticks.y.right = element_blank(), 
    axis.title = element_text(size = 14, family = "SimSun"),
    axis.line.x = element_line(color = "black", linewidth = 0.2),  # 显示坐标轴的横线和纵线
    axis.line.y.left = element_line(color = "black", linewidth = 0.2),  # 显示坐标轴的横线和纵线
    
    # axis.ticks = element_line(color = "black", linewidth = 0.5) 
  )
pdf("~/tmp.pdf",width = 8,height = 4)
p1
dev.off()
pdf("~/tmp.pdf",width = 3.5,height = 3)
p2
dev.off()
p