library(showtext)
library(ggplot2)
library(RColorBrewer)
library(ggbreak)
showtext_auto()
font_add("SimSun", "/home/yanyq/usr/share/font/simsun.ttc")  # 使用宋体（SimSun）
font_add("Arial","/home/yanyq/usr/share/font/arial-font/arial.ttf")

##################################多效性SNP进行功能表征
all_PLACO = read_tsv("/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer")
all_PLACO = all_PLACO[!grepl("CORP",all_PLACO$traits),]

# leadSNP 的功能区域统计
all_PLACO_lead = all_PLACO[all_PLACO$is.IndSig_lead=="leadSNP",]
all_PLACO_lead_func = as.data.frame(table(all_PLACO_lead$func))
all_PLACO_lead_func = all_PLACO_lead_func[order(all_PLACO_lead_func$Freq, decreasing = T),]
all_PLACO_lead_func$Var1 = factor(all_PLACO_lead_func$Var1, levels = all_PLACO_lead_func$Var1)
all_PLACO_lead_func$flag = "lead"

# 所有SNP 的功能区域统计
all_PLACO_func = as.data.frame(table(all_PLACO$func))
all_PLACO_func = all_PLACO_func[order(all_PLACO_func$Freq, decreasing = T),]
all_PLACO_func$Var1 = factor(all_PLACO_func$Var1, levels = all_PLACO_func$Var1)
all_PLACO_func$flag = "all"

# # "two_y_axis"
# library(ggplot2)
# library(RColorBrewer)
# library(dplyr)
# 
# ggplot(rbind(all_PLACO_func,all_PLACO_lead_func), aes(x = Var1, y =  ifelse(flag == "lead", Freq * 25, Freq), fill = flag)) +
#   geom_bar(stat = "identity", position = position_dodge()) +
#   geom_text(aes(label = Freq), position = position_dodge(width = 0.9), vjust = -0.5, size = 4, color = "black") +
#   # geom_text(stat='identity',aes(label=Value), vjust=-0.5, size=3.5, hjust = ifelse(df_long$Group == "Freq.x", 1.2,-1)) +
#   scale_fill_manual(values = c("all" = "#E41A1C", "lead" = "#377EB8"),
#                     labels = c("all" = "多效SNP", "lead" = "多效lead SNP")) +
#   scale_y_continuous(
#     expand = c(0,0),
#     name = "多效SNP",
#     limits = c(0, 40000),
#     sec.axis = sec_axis(
#       trans = ~ . / 25,
#       name = "多效lead SNP"
#     )
#   ) +
#   labs(x = "癌症对数")+
#   theme_bw() +
#   theme(panel.grid.major = element_blank(), # 去除主网格线
#         panel.grid.minor = element_blank(),  # 去除次网格线
#         panel.background = element_blank(),
#         axis.text = element_text(size = 12, colour = "black", family = "Arial"),
#         axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),
#         axis.title = element_text(size = 12, family = "SimSun"),
#         legend.location = "right",
#         legend.title = element_blank(),
#         legend.key.size = unit(1, "lines"),
#         legend.text = element_text(size = 12, family = "SimSun"))
# 拿到FUMA里面做一下功能区域富集检验，三维注释
all_PLACO = read_tsv("/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer")
all_PLACO = all_PLACO[!grepl("CORP",all_PLACO$traits),]
all_PLACO_lead = all_PLACO[all_PLACO$is.IndSig_lead=="leadSNP",]
all_PLACO_lead = all_PLACO_lead[,c("snpid", "hg19chr","bp","a1")]
all_PLACO_lead = all_PLACO_lead[!duplicated(all_PLACO_lead$snpid),]
all_PLACO_lead$P = 5e-9
write_tsv(all_PLACO_lead, "~/tmp")
# 单轴unique多效SNP
all_PLACO = read_tsv("/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer")
all_PLACO = all_PLACO[!grepl("CORP",all_PLACO$traits),]
all_PLACO_lead = all_PLACO[all_PLACO$is.IndSig_lead=="leadSNP",]
all_PLACO_lead = all_PLACO_lead[,c("snpid", "func", "commonChrState","eQTLGen")]
all_PLACO_lead = unique(all_PLACO_lead)
all_PLACO_lead_func = as.data.frame(table(all_PLACO_lead$func))
all_PLACO_lead_func = all_PLACO_lead_func[order(all_PLACO_lead_func$Freq, decreasing = T),]
all_PLACO_lead_func$Var1 = factor(all_PLACO_lead_func$Var1, levels = all_PLACO_lead_func$Var1)

p = ggplot(all_PLACO_lead_func, aes(x = Var1, y =  Freq, fill = Var1)) +
  geom_bar(stat = "identity", fill = c(brewer.pal(9, "Set1"),"#8DD3C7"), width = 0.5) +
  geom_text(aes(label = Freq), vjust = -0.5, size = 4, color = "black", family = "Arial") +
  scale_y_continuous(
    expand = c(0,0),
    name = "多效lead SNP数",
    limits = c(0, 1250)
  ) +
  # labs(x = "癌症对数")+
  theme_bw() +
  theme(panel.grid.major = element_blank(), # 去除主网格线
        panel.grid.minor = element_blank(),  # 去除次网格线
        panel.background = element_blank(),
        axis.text = element_text(size = 12, colour = "black", family = "Arial"),
        axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),
        axis.title.y = element_text(size = 14, family = "SimSun"),
        axis.title.x = element_blank(),
        legend.location = "right",
        legend.title = element_blank(),
        legend.key.size = unit(1, "lines"),
        legend.text = element_text(size = 12, family = "SimSun"))
p

active_region = all_PLACO_lead$snpid[all_PLACO_lead$commonChrState<=7] # 799
# enhancer = all_PLACO_lead$snpid[all_PLACO_lead$commonChrState==6|all_PLACO_lead$commonChrState==7]
# enhancerAtalas下载的增强子区域SNP，63938个
{
  enh_ATA = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/enhancer/all.bed", col_names = F))
  enhancer = all_PLACO_lead$snpid[all_PLACO_lead$snpid%in%unique(enh_ATA$X8)] # 235
}
eQTL = all_PLACO_lead$snpid[!is.na(all_PLACO_lead$eQTLGen)] # 1579
{# 维恩图，染色质开放、增强子、调节基因区
  library (VennDiagram)
  venn.diagram(x=list(active_region,eQTL, enhancer),
               scaled = F, # 根据比例显示大小
               alpha= 0.3, #透明度
               lwd=1,lty=1,col=c("#E41A1C", "#377EB8", "#4DAF4A"), #圆圈线条粗细、形状、颜色；1 实线, 2 虚线, blank无线条
               label.col ='black' , # 数字颜色abel.col=c('#FFFFCC','#CCFFFF',......)根据不同颜色显示数值颜色
               cex = 2, # 数字大小
               # fontface = "bold",  # 字体粗细；加粗bold
               fill=c("#E41A1C", "#377EB8", "#4DAF4A"), # 填充色 配色https://www.58pic.com/
               category.names = c("染色质开放区","eQTL", "增强子") , #标签名
               cat.dist = 0.02, # 标签距离圆圈的远近
               cat.pos = -180, # 标签相对于圆圈的角度cat.pos = c(-10, 10, 135)
               cat.cex = 2, #标签字体大小
               # cat.fontface = "bold",  # 标签字体加粗
               cat.col='black' ,   #cat.col=c('#FFFFCC','#CCFFFF',.....)根据相应颜色改变标签颜色
               cat.default.pos = "outer",  # 标签位置, outer内;text 外
               output=TRUE,
               filename="/home/yanyq/share_genetics/final_result/plot/lead-region-venn.png",# 文件保存
               imagetype="png",  # 类型（tiff png svg）
               resolution = 400,  # 分辨率
               compression = "lzw"# 压缩算法
  )
}
