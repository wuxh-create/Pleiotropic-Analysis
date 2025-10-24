# 多效SNP在GWAS summary中的P值分布

library(readr)
library(GenomicRanges)
library(dplyr)
library(ggplot2)
library(RColorBrewer)
library(ggbreak)
library(showtext)
library(stringr)

showtext_auto()
font_add("SimSun", "/home/yanyq/usr/share/font/simsun.ttc")  # 使用宋体（SimSun）

all_PLACO = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer"))
all_SNP = as.data.frame(table(all_PLACO$sig_GWAS))
lead_SNP = all_PLACO[all_PLACO$is.IndSig_lead=="leadSNP",]
lead_SNP = as.data.frame(table(lead_SNP$sig_GWAS))


df_long <- tidyr::pivot_longer(left_join(all_SNP, lead_SNP, by = "Var1"), cols = c("Freq.x", "Freq.y"), names_to = "Group", values_to = "Value")
ggplot(df_long, aes(x = Var1, y =  ifelse(Group == "Freq.x", Value, Value * 13), fill = Group)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  geom_text(aes(label = Value), position = position_dodge(width = 0.9), vjust = -0.5, size = 3, color = "black") +
  # geom_text(stat='identity',aes(label=Value), vjust=-0.5, size=3.5, hjust = ifelse(df_long$Group == "Freq.x", 1.2,-1)) +
  scale_fill_manual(values = c("Freq.x" = "#E41A1C", "Freq.y" = "#377EB8"),
                    labels = c("Freq.x" = "所有多效SNP", "Freq.y" = "lead 多效SNP")) +
  scale_y_continuous(
    expand = c(0,0),
    name = "多效SNP数",
    limits = c(0, 65000),
    sec.axis = sec_axis(
      trans = ~ . / 16,
      name = "lead 多效SNP数"
    )
  ) +
  labs(x = "癌症对数")+
  theme_bw() +
  theme(panel.grid.major = element_blank(), # 去除主网格线
        panel.grid.minor = element_blank(),  # 去除次网格线
        panel.background = element_blank(),
        axis.text = element_text(size = 10, colour = "black", family = "sans"),
        axis.title = element_text(size = 12, family = "SimSun"),
        legend.location = "right",
        legend.title = element_blank(),
        legend.key.size = unit(1, "lines"),
        legend.text = element_text(size = 12, family = "SimSun"))