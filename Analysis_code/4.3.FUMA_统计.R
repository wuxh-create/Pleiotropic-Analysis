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

# 统计鉴定到的多效SNP及unique的数目
all_PLACO = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/PLACO/all")) # 76069
length(unique(all_PLACO$snpid)) # 31076
SNP_count = as.data.frame(table(all_PLACO$snpid))
tmp = all_PLACO[all_PLACO$snpid%in%SNP_count$Var1[SNP_count$Freq>30],]
tmp = unique(tmp[,c("snpid", "nearestGene","func", "dist")])
tmp_TERT = unique(tmp[tmp$nearestGene=="TERT",c("snpid", "func")])
length(unique(c(tmp$trait1[tmp$nearestGene=="TERT"], tmp$trait2[tmp$nearestGene=="TERT"])))
table(tmp_TERT$func)

SNP_cancer_count = as.data.frame(table(SNP_count$Freq)) # 多效SNP在癌症对中出现的次数
SNP_cancer_count$Var1 = as.numeric(as.character(SNP_cancer_count$Var1))
SNP_cancer_count$Freq[11] = sum(SNP_cancer_count$Freq[SNP_cancer_count$Var1>10&SNP_cancer_count$Var1<=20])
SNP_cancer_count$Freq[12] = sum(SNP_cancer_count$Freq[SNP_cancer_count$Var1>20&SNP_cancer_count$Var1<=30])
SNP_cancer_count$Freq[13] = sum(SNP_cancer_count$Freq[SNP_cancer_count$Var1>30])
SNP_cancer_count$Var1[11] = "11-20"
SNP_cancer_count$Var1[12] = "21-30"
SNP_cancer_count$Var1[13] = ">30"
SNP_cancer_count = SNP_cancer_count[1:13,]
sum(SNP_cancer_count$Freq)
SNP_cancer_count$Var1 = factor(SNP_cancer_count$Var1, levels = SNP_cancer_count$Var1)
{
  ggplot(data=SNP_cancer_count, mapping=aes(x=Var1,fill=Var1,y=Freq))+
    geom_bar(stat="identity",width=0.5, fill = c(brewer.pal(9, "Set1"),brewer.pal(4, "Set3")))+
    # scale_color_continuous(values=c(brewer.pal(12, "Set3"), brewer.pal(3, "Set1")))+
    geom_text(stat='identity',aes(label=Freq), vjust=-0.5, size=3.5)+
    scale_y_break(c(6000,16000),#截断位置及范围
                  space = 0.3,#间距大小
                  scales = 0.25,expand = c(0, 0)) +#上下显示比例，大于1上面比例大，小于1下面比例大
    scale_y_continuous(expand = c(0, 0), limits = c(0,17500)) +
    labs(x = "癌症对数", y = "多效SNP数")+
    theme_bw() +
    theme(legend.position="none",
          panel.grid.major = element_blank(), # 去除主网格线
          panel.grid.minor = element_blank(),  # 去除次网格线
          panel.background = element_blank(),
          axis.text = element_text(size = 10, colour = "black", family = "sans"),
          axis.text.y.right = element_blank(),
          axis.ticks.y.right = element_blank(), 
          axis.title = element_text(size = 12, family = "SimSun"))
}

# 统计FUMA注释到的多效基因座数目
traits = c("AML","BAC","BCC","BGA","BGC","BLCA","BM","BRCA","CESC","CML","CORP",
           "CRC","DLBC","ESCA","EYAD","GSS","HL","HNSC","kidney","LIHC","LL",
           "lung","MCL","MESO","MM","MS","MZBL","OV","PAAD","PRAD","SCC","SI",
           "SKCM","STAD","TEST","THCA","UCEC","VULVA")
all_FUMA = list()
for(trait1 in traits){
  for(trait2 in traits){
    if(file.exists(paste0("/home/yanyq/share_genetics/result/FUMA/",trait1,"-",trait2,"/GenomicRiskLoci.txt"))){
      all_FUMA[[paste0(trait1,"-",trait2)]] = as.data.frame(read_tsv(paste0("/home/yanyq/share_genetics/result/FUMA/",trait1,"-",trait2,"/GenomicRiskLoci.txt")))
    }
  }
}
all_FUMA = do.call(rbind, all_FUMA) # 2597
all_FUMA$traits = gsub("\\.\\d+$","",rownames(all_FUMA))

# 统计FUMA注释到无overlap的多效基因座数目
all_FUMA_GR = GRanges(seqnames = all_FUMA$chr, ranges = IRanges(start = all_FUMA$start, end = all_FUMA$end))
uni_FUMA = as.data.frame(reduce(all_FUMA_GR))
write_tsv(all_FUMA, "/home/yanyq/share_genetics/result/FUMA/all_FUMA_loci")
write_tsv(uni_FUMA, "/home/yanyq/share_genetics/result/FUMA/uni_FUMA_loci") # 560

# # 注释染色体区域
# cytoband = as.data.frame(read_tsv("/home/yanyq/data/cytoBand_hg19.txt.gz", col_names = F))
# cytoband$X1 = gsub("chr", "", cytoband$X1)
# cytoband$X4 = paste0(cytoband$X1, cytoband$X4)
# cytoband_GR = GRanges(seqnames = cytoband$X1,ranges = IRanges(start = cytoband$X2, end = cytoband$X3))
# FUMA_cytoband = as.data.frame(findOverlaps(all_FUMA_GR, cytoband_GR))
# FUMA_cytoband$subjectHits = cytoband$X4[FUMA_cytoband$subjectHits]
# length(unique(FUMA_cytoband$subjectHits)) # 353个独特的染色体区域
# # FUMA_cytoband <- FUMA_cytoband %>% group_by(queryHits) %>% summarise(subjectHits = paste(subjectHits, collapse = ","))
# FUMA_cytoband$queryHits = all_FUMA$traits[FUMA_cytoband$queryHits]
# FUMA_cytoband = unique(FUMA_cytoband)
# # all_FUMA$cytoband = NA
# # all_FUMA$cytoband[FUMA_cytoband$queryHits] = FUMA_cytoband$subjectHits
# # which(is.na(all_FUMA$cytoband))
# cytoband_freq = as.data.frame(table(FUMA_cytoband$subjectHits))
# length(unique(unlist(str_split(FUMA_cytoband$queryHits[FUMA_cytoband$subjectHits=="5p15.33"], pattern = "-"))))
# cytobank_freq_freq = as.data.frame(table(cytoband_freq$Freq)) # 多效染色体区域在癌症对中出现的次数
# tmp = all_FUMA[grep("5p15.33",all_FUMA$cytoband),]
# cytoband[cytoband$X4=="5p15.33",]
# tmp_PLACO = all_PLACO[all_PLACO$hg19chr==5&all_PLACO$bp<4500000,]
# # tmp$traits = gsub("\\.\\d+$", "", (rownames(tmp)))
# # length(unique(tmp$traits))
# cytobank_freq_freq$Var1 = as.numeric(as.character(cytobank_freq_freq$Var1))
# cytobank_freq_freq$Freq[11] = sum(cytobank_freq_freq$Freq[cytobank_freq_freq$Var1>10&cytobank_freq_freq$Var1<=20])
# cytobank_freq_freq$Freq[12] = sum(cytobank_freq_freq$Freq[cytobank_freq_freq$Var1>20&cytobank_freq_freq$Var1<=30])
# cytobank_freq_freq$Freq[13] = sum(cytobank_freq_freq$Freq[cytobank_freq_freq$Var1>30])
# cytobank_freq_freq$Var1[11] = "11-20"
# cytobank_freq_freq$Var1[12] = "21-30"
# cytobank_freq_freq$Var1[13] = ">30"
# cytobank_freq_freq = cytobank_freq_freq[1:13,]
# sum(cytobank_freq_freq$Freq)
# cytobank_freq_freq$Var1 = factor(cytobank_freq_freq$Var1, levels = cytobank_freq_freq$Var1)
# {
#   ggplot(data=cytobank_freq_freq, mapping=aes(x=Var1,fill=Var1,y=Freq))+
#     geom_bar(stat="identity",width=0.5, fill = c(brewer.pal(9, "Set1"),brewer.pal(4, "Set3")))+
#     # scale_color_continuous(values=c(brewer.pal(12, "Set3"), brewer.pal(3, "Set1")))+
#     geom_text(stat='identity',aes(label=Freq), vjust=-0.5, size=3.5)+
#     # scale_y_break(c(70,80),#截断位置及范围
#     #               space = 0.3,#间距大小
#     #               scales = 0.25,expand = c(0, 0)) +#上下显示比例，大于1上面比例大，小于1下面比例大
#     scale_y_continuous(expand = c(0, 0), limits = c(0,100)) +
#     labs(x = "癌症对数", y = "多效染色体区域数")+
#     theme_bw() +
#     theme(legend.position="none",
#           panel.grid.major = element_blank(), # 去除主网格线
#           panel.grid.minor = element_blank(),  # 去除次网格线
#           panel.background = element_blank(),
#           axis.text = element_text(size = 10, colour = "black", family = "sans"),
#           axis.text.y.right = element_blank(),
#           axis.ticks.y.right = element_blank(), 
#           axis.title = element_text(size = 12, family = "SimSun"))
# }
# { # 组合多效SNP和染色体区域
#   df_long <- tidyr::pivot_longer(left_join(SNP_cancer_count, cytobank_freq_freq, by = "Var1"), cols = c("Freq.x", "Freq.y"), names_to = "Group", values_to = "Value")
#   ggplot(df_long, aes(x = Var1, y =  ifelse(Group == "Freq.x", Value, Value * 180), fill = Group)) +
#     geom_bar(stat = "identity", position = position_dodge()) +
#     geom_text(aes(label = Value), position = position_dodge(width = 0.9), vjust = -0.5, size = 3, color = "black") +
#     # geom_text(stat='identity',aes(label=Value), vjust=-0.5, size=3.5, hjust = ifelse(df_long$Group == "Freq.x", 1.2,-1)) +
#     scale_fill_manual(values = c("Freq.x" = "#E41A1C", "Freq.y" = "#377EB8"),
#                       labels = c("Freq.x" = "SNP", "Freq.y" = "染色体区域")) +
#     scale_y_continuous(
#       expand = c(0,0),
#       name = "多效SNP数",
#       limits = c(0, 18000),
#       sec.axis = sec_axis(
#         trans = ~ . / 180,
#         name = "多效染色体区域数"
#       )
#     ) +
#     labs(x = "癌症对数")+
#     theme_bw() +
#     theme(panel.grid.major = element_blank(), # 去除主网格线
#           panel.grid.minor = element_blank(),  # 去除次网格线
#           panel.background = element_blank(),
#           axis.text = element_text(size = 10, colour = "black", family = "sans"),
#           axis.title = element_text(size = 12, family = "SimSun"),
#           legend.location = "right",
#           legend.title = element_blank(),
#           legend.key.size = unit(1, "lines"),
#           legend.text = element_text(size = 12, family = "SimSun"))
# }

# 统计leadSNP在两个GWAS中的效应方向，基因组区域
df = all_FUMA[,c("LeadSNPs", "traits")]
new_rows <- unlist(strsplit(df$LeadSNPs, ";"))
df_new <- data.frame(
  LeadSNPs = new_rows,
  traits = rep(df$traits, sapply(strsplit(df$LeadSNPs, ";"), length)),
  stringsAsFactors = FALSE
)
df_new = unique(df_new)
length(unique(df_new$LeadSNPs))
df_new$flag = paste0(df_new$traits, ":", df_new$LeadSNPs)
all_PLACO$flag = paste0(all_PLACO$trait1, "-", all_PLACO$trait2, ":", all_PLACO$snpid)
tmp = all_PLACO[all_PLACO$flag%in%df_new$flag,]
length(which((tmp$or.trait1>1&tmp$or.trait2>1)|(tmp$or.trait1<1&tmp$or.trait2<1))) # 2103
length(which(tmp$T.placo>0)) # 2103
length(which(tmp$T.placo<0))
same_tmp = tmp[tmp$T.placo>0,] # 效应方向相同的SNP信息
same_tmp = same_tmp[!(same_tmp$snpid%in%tmp$snpid[tmp$T.placo<0]),] # 去除在另一对癌症中效应方向不同的SNP，2103余1697
same_SNP = same_tmp$snpid # 在一对癌症中效应方向相同的SNP
dup_same_SNP = unique(same_SNP[duplicated(same_SNP)]) # 在多对癌症中效应相同的SNP,204个
length(unique(same_SNP[!same_SNP%in%dup_same_SNP])) # 1144个SNP，对所有相关癌症（一对）的作用方向相同，T大于0表明一对中方向相同
same_tmp$same_direction = F
# 筛选在所有相关癌症（多对）中的作用方向相同，需要beta方向相同
for(i in dup_same_SNP){
  same_tmp_tmp = same_tmp[same_tmp$snpid==i,]
  if(length(unique(same_tmp_tmp$a1))!=1|length(unique(same_tmp_tmp$a2))!=1){# 等位基因a1/a2对不上的
    allelle_pos = (same_tmp_tmp$a1!=same_tmp_tmp$a1[1])|(same_tmp_tmp$a2!=same_tmp_tmp$a2[1])
    { # 交换a1/a2位置
      same_tmp_tmp_a1 = same_tmp_tmp$a1[allelle_pos]
      same_tmp_tmp$a1[allelle_pos] = same_tmp_tmp$a2[allelle_pos]
      same_tmp_tmp$a2[allelle_pos] = same_tmp_tmp_a1
      same_tmp_tmp$or.trait1[allelle_pos] = exp(-log(same_tmp_tmp$or.trait1[allelle_pos]))
      same_tmp_tmp$or.trait2[allelle_pos] = exp(-log(same_tmp_tmp$or.trait2[allelle_pos]))
    }
    if(length(unique(same_tmp_tmp$a1))!=1|length(unique(same_tmp_tmp$a2))!=1){
      print(i)
    }
  }
  
  if((all(same_tmp_tmp$or.trait1>1)&all(same_tmp_tmp$or.trait2>1)) | (all(same_tmp_tmp$or.trait1<1)&all(same_tmp_tmp$or.trait2<1))){
    same_tmp$same_direction[same_tmp$snpid==i] = T
  }else{
    print(i)
  }
}
length(unique(same_tmp$snpid[same_tmp$same_direction])) # 204
same_tmp$same_direction[!(same_tmp$snpid%in%dup_same_SNP)] = T
length(unique(same_tmp$snpid[same_tmp$same_direction])) # 1348
write_tsv(same_tmp, "/home/yanyq/share_genetics/result/效应方向相同的多效SNP")
# 效应方向相同的SNP，有多少个是新的
same_tmp_new = same_tmp[same_tmp$pval.trait1>5e-8&same_tmp$pval.trait2>5e-8,]
same_tmp_NOT_new = same_tmp[same_tmp$pval.trait1<5e-8|same_tmp$pval.trait2<5e-8,]
same_tmp_new = same_tmp_new[!same_tmp_new$snpid%in%same_tmp_NOT_new$snpid,]

df = as.data.frame(table(tmp$func))
df = df[order(df$Freq, decreasing = T),]
df$Var1 = as.character(df$Var1)
df$Var1 = factor(df$Var1, levels = df$Var1)
df$percent <- round(df$Freq / sum(df$Freq) * 100,1)
{# 绘制饼图
  ggplot(df, aes(x = "", y = Freq, fill = Var1)) +
    geom_bar(width = 1, stat = "identity") +
    coord_polar(theta = "y") +
    geom_text(aes(label = ifelse(percent>=12.3,paste(percent, "%"), "")), 
              position = position_stack(vjust = 0.5), 
              size = 4, color = "black")+
    scale_fill_manual(values = c(brewer.pal(9, "Set1"),"#8DD3C7"))+
    labs(fill = "Var1") +
    theme_bw() +
    theme(panel.grid.major = element_blank(), # 去除主网格线
          panel.grid.minor = element_blank(),  # 去除次网格线
          panel.background = element_blank(),
          panel.border = element_blank(),
          axis.text.x = element_blank(),
          axis.title = element_blank(),
          legend.location = "right",
          legend.title = element_blank(),
          legend.key.size = unit(1, "lines"),
          legend.text = element_text(size = 12))
}

p <- 
  # 显示饼图
  print(p)

table(tmp$func)

##################################多效性lead SNP进行功能表征
all_PLACO = read_tsv("/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG")
all_FUMA = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/FUMA/all_FUMA_loci"))
df = all_FUMA[,c("LeadSNPs", "traits")]
new_rows <- unlist(strsplit(df$LeadSNPs, ";"))
df_new <- data.frame(
  LeadSNPs = new_rows,
  traits = rep(df$traits, sapply(strsplit(df$LeadSNPs, ";"), length)),
  stringsAsFactors = FALSE
)
df_new = unique(df_new)
length(unique(df_new$LeadSNPs))
df_new$flag = paste0(df_new$traits, ":", df_new$LeadSNPs)
all_PLACO$flag = paste0(all_PLACO$trait1, "-", all_PLACO$trait2, ":", all_PLACO$snpid)
all_PLACO$is.IndSig_lead = "not"
all_PLACO$is.IndSig_lead[all_PLACO$snpid==all_PLACO$IndSigSNP] = "IndSigSNP"
all_PLACO$is.IndSig_lead[all_PLACO$flag%in%df_new$flag] = "leadSNP"
# enhancerAtalas下载的增强子区域SNP，63938个
{
  enh_ATA = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/enhancer/all.bed", col_names = F))
  all_PLACO$is.enhancer = F
  all_PLACO$is.enhancer[all_PLACO$snpid%in%enh_ATA$X8] = T
}
write_tsv(all_PLACO, "/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer")

all_PLACO_lead = all_PLACO[all_PLACO$flag%in%df_new$flag,]
all_PLACO_lead_func = as.data.frame(table(all_PLACO_lead$func))
all_PLACO_lead_func = all_PLACO_lead_func[order(all_PLACO_lead_func$Freq, decreasing = T),]
all_PLACO_lead_func$Var1 = factor(all_PLACO_lead_func$Var1, levels = all_PLACO_lead_func$Var1)
{# ANNOVAR条形图
  library(showtext)
  library(ggplot2)
  library(RColorBrewer)
  library(ggbreak)
  showtext_auto()
  font_add("SimSun", "/home/yanyq/usr/share/font/simsun.ttc")  # 使用宋体（SimSun）
  
  ggplot(data=all_PLACO_lead_func, mapping=aes(x=Var1,fill=Var1,y=Freq))+
    geom_bar(stat="identity",width=0.6, fill = c(brewer.pal(9, "Set1"),"#8DD3C7"))+
    geom_text(stat='identity',aes(label=Freq), vjust=-0.5, size=3.5)+
    scale_y_continuous(expand = c(0, 0) , limits = c(0,1700)) +
    labs(y = "多效lead SNP数")+
    theme_bw() +
    theme(legend.position="none",
          panel.grid.major = element_blank(), # 去除主网格线
          panel.grid.minor = element_blank(),  # 去除次网格线
          panel.background = element_blank(),
          axis.text = element_text(size = 10, colour = "black", family = "sans"),
          axis.text.y.right = element_blank(),
          axis.ticks.y.right = element_blank(), 
          axis.title.y = element_text(size = 12, family = "SimSun"),
          axis.title.x = element_blank())
}
active_region = all_PLACO_lead$snpid[all_PLACO_lead$commonChrState<=7]
# enhancer = all_PLACO_lead$snpid[all_PLACO_lead$commonChrState==6|all_PLACO_lead$commonChrState==7]
# enhancerAtalas下载的增强子区域SNP，63938个
{
  enh_ATA = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/enhancer/all.bed", col_names = F))
  enhancer = all_PLACO_lead$snpid[all_PLACO_lead$snpid%in%unique(enh_ATA$X8)]
}
eQTL = all_PLACO_lead$snpid[!is.na(all_PLACO_lead$eQTLGen)]
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
               filename="/home/yanyq/share_genetics/result/FUMA/lead-region-venn.png",# 文件保存
               imagetype="png",  # 类型（tiff png svg）
               resolution = 400,  # 分辨率
               compression = "lzw"# 压缩算法
  )
}

############################################################## 作为eQTL的SNP调节基因的数目
eQTL = as.data.frame(all_PLACO_lead[!is.na(all_PLACO_lead$eQTLGen),])
eQTL$comma_count <- sapply(gregexpr(",", eQTL$eQTLGen), function(x) ifelse(x[1] == -1, 0, length(x)))
eQTL$comma_count = eQTL$comma_count+1
eQTL_count = as.data.frame(table(eQTL$comma_count))
eQTL_count$Var1 = as.numeric(as.character(eQTL_count$Var1))
(2093-639)/2093
{
  ggplot(data=eQTL_count, mapping=aes(x=Var1,fill=Var1,y=Freq))+
    geom_bar(stat="identity",width=0.7, fill = "#4DAF4A")+
    geom_text(stat='identity',aes(label=Freq), vjust=-0.5, size=3.5)+
    scale_y_continuous(expand = c(0, 0) , limits = c(0,700)) +
    scale_x_continuous(breaks = c(0, 5, 10, 15, 20, 25)) +
    labs(x = "基因数", y = "多效lead SNP数")+
    theme_bw() +
    theme(legend.position="none",
          panel.grid.major = element_blank(), # 去除主网格线
          panel.grid.minor = element_blank(),  # 去除次网格线
          panel.background = element_blank(),
          axis.text = element_text(size = 10, colour = "black", family = "sans"),
          axis.text.y.right = element_blank(),
          axis.ticks.y.right = element_blank(), 
          axis.title = element_text(size = 12, family = "SimSun"))
}

#################################################SNP所在的位置是否与MAGMA基因位置重叠（上游10kb和下游1.5kb）
library(GenomicRanges)
library(stringr)
rm(list = ls())
MAGMA = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/all"))
all_PLACO = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer"))
all_PLACO$MAGMA_PLACO = NA # 多效基因
all_PLACO$MAGMA_trait1 = NA # cancer1的基因
all_PLACO$MAGMA_trait2 = NA # cancer2的基因
for(i in unique(MAGMA$trait)){
  all_PLACO_tmp = all_PLACO[all_PLACO$traits==i,-(80:82)]
  MAGMA_tmp = MAGMA[MAGMA$trait==i,]
  all_PLACO_tmp_GR = as(paste0(all_PLACO_tmp$hg19chr, ":", all_PLACO_tmp$bp), "GRanges")
  MAGMA_tmp_GR = as(MAGMA_tmp$locus.MAGMA, "GRanges")
  ov = findOverlaps(all_PLACO_tmp_GR, MAGMA_tmp_GR)
  ov_snp_gene = data.frame(snpid = all_PLACO_tmp$snpid[ov@from])
  
  ov_snp_gene = cbind(ov_snp_gene, MAGMA_tmp[ov@to,c("SYMBOL", "fdr.trait1", "fdr.trait2")])
  ov_snp_gene = unique(ov_snp_gene)
  ov_snp_gene_trait1 = ov_snp_gene[ov_snp_gene$fdr.trait1<0.05,]
  ov_snp_gene_trait1 = unique(ov_snp_gene_trait1)
  ov_snp_gene_trait2 = ov_snp_gene[ov_snp_gene$fdr.trait2<0.05,]
  ov_snp_gene_trait2 = unique(ov_snp_gene_trait2)
  
  ov_snp_gene <- ov_snp_gene %>%
    group_by(snpid) %>%
    summarise(MAGMA_PLACO = str_c(SYMBOL, collapse = ","))
  ov_snp_gene_trait1 <- ov_snp_gene_trait1 %>%
    group_by(snpid) %>%
    summarise(MAGMA_trait1 = str_c(SYMBOL, collapse = ","))
  ov_snp_gene_trait2 <- ov_snp_gene_trait2 %>%
    group_by(snpid) %>%
    summarise(MAGMA_trait2 = str_c(SYMBOL, collapse = ","))
  
  ov_snp_gene = as.data.frame(ov_snp_gene)
  ov_snp_gene_trait1 = as.data.frame(ov_snp_gene_trait1)
  ov_snp_gene_trait2 = as.data.frame(ov_snp_gene_trait2)
  
  ov_snp_gene = left_join(ov_snp_gene, ov_snp_gene_trait1, by = "snpid")
  ov_snp_gene = left_join(ov_snp_gene, ov_snp_gene_trait2, by = "snpid")
  
  
  if(any(duplicated(ov_snp_gene$snpid))){
    print(i)
  }else{
    all_PLACO_tmp = left_join(all_PLACO_tmp, ov_snp_gene, by = "snpid")
    all_PLACO[all_PLACO$traits==i,] = all_PLACO_tmp
  }
}
write_tsv(all_PLACO, "/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer_MAGMA")
#################################################SNP调控的基因或所在的MAGMA基因是否为SMR因果基因
library(pbmcapply)
all_PLACO = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer_MAGMA"))
all_PLACO$SMR_eQTLGen_trait1 = NA
all_PLACO$SMR_eQTLGen_trait2 = NA
all_PLACO$SMR_MAGMA_trait1 = NA
all_PLACO$SMR_MAGMA_trait2 = NA
SMR = as.data.frame(read_tsv("/home/yanyq/cogenetics/result/smr_multiSNP_0.01/eQTLGen/all_cancer_fdr_0.05.msmr"))
symbol = as.data.frame(read_tsv("/home/yanyq/cogenetics/data/eQTL/eQTLGen/cis-eQTLs-full_eQTLGen_AF_incl_nr_formatted_20191212.new.txt_besd-dense.epi_symbol"))
colnames(symbol)[c(2,5)] = c("probeID","SYMBOL")
SMR = left_join(SMR, symbol[,c(2,5)], by = "probeID")
all_PLACO_SMR = pbmclapply(1:nrow(all_PLACO), FUN = function(i) {
  all_PLACO_tmp = all_PLACO[i,]
  eQTL_gene = unlist(str_split(all_PLACO_tmp$eQTLGen, pattern = ","))
  SMR_tmp = SMR[SMR$cancer==all_PLACO_tmp$trait1&SMR$SYMBOL%in%eQTL_gene,]
  if(nrow(SMR_tmp)>0){
    all_PLACO$SMR_eQTLGen_trait1[i] = paste(SMR_tmp$SYMBOL, collapse = ",")
  }
  SMR_tmp = SMR[SMR$cancer==all_PLACO_tmp$trait2&SMR$SYMBOL%in%eQTL_gene,]
  if(nrow(SMR_tmp)>0){
    all_PLACO$SMR_eQTLGen_trait2[i] = paste(SMR_tmp$SYMBOL, collapse = ",")
  }
  
  MAGMA_gene = unlist(str_split(all_PLACO_tmp$MAGMA_PLACO, pattern = ","))
  SMR_tmp = SMR[SMR$cancer==all_PLACO_tmp$trait1&SMR$SYMBOL%in%MAGMA_gene,]
  if(nrow(SMR_tmp)>0){
    all_PLACO$SMR_MAGMA_trait1[i] = paste(SMR_tmp$SYMBOL, collapse = ",")
  }
  SMR_tmp = SMR[SMR$cancer==all_PLACO_tmp$trait2&SMR$SYMBOL%in%MAGMA_gene,]
  if(nrow(SMR_tmp)>0){
    all_PLACO$SMR_MAGMA_trait2[i] = paste(SMR_tmp$SYMBOL, collapse = ",")
  }
  
  all_PLACO[i,]
}, mc.cores = 40)
all_PLACO_SMR = do.call(rbind, all_PLACO_SMR)
write_tsv(all_PLACO_SMR, "/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer_MAGMA_SMR")

#########################################多效SNP与其他性状中的关联情况，筛选多效性鉴定到的新的关联，有点问题，catalog里的是hg38坐标
{
#   # # Phenoscanner网站无法访问
#   library(readr)
#   all_PLACO = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer_MAGMA_SMR"))
#   
#   # lead = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/PLACO/all_lead_GWAS_cancer_SNP"))
#   # 对SNP注释染色体区域
#   library(GenomicRanges)
#   all_PLACO_SNP = unique(all_PLACO[, c("snpid","hg19chr", "bp")])
#   all_PLACO_SNP_GR = as(paste0(all_PLACO_SNP$hg19chr, ":", all_PLACO_SNP$bp), "GRanges")
#   cytoband = as.data.frame(read_tsv("/home/yanyq/data/cytoBand_hg19.txt.gz", col_names = F))
#   cytoband$X1 = gsub("chr", "", cytoband$X1)
#   cytoband$X4 = paste0(cytoband$X1, cytoband$X4)
#   cytoband_GR = GRanges(seqnames = cytoband$X1,ranges = IRanges(start = cytoband$X2, end = cytoband$X3))
#   all_PLACO_SNP_cytoband = as.data.frame(findOverlaps(all_PLACO_SNP_GR, cytoband_GR))
#   which(duplicated(all_PLACO_SNP_cytoband$queryHits))
#   all_PLACO_SNP$cytoband[all_PLACO_SNP_cytoband$queryHits] = cytoband$X4[all_PLACO_SNP_cytoband$subjectHits]
#   all_PLACO_SNP = all_PLACO_SNP[,c(1,4)]
#   all_PLACO = dplyr::left_join(all_PLACO, all_PLACO_SNP, by = "snpid")
#   write_tsv(all_PLACO, "/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer_MAGMA_SMR_cytoband")
#   {# 染色体区域统计
#     # 癌症对多效SNP涉及的染色体区域统计
#     cancer_cytoband = unique(all_PLACO[,c("traits", "cytoband")])
#     cytoband_freq = as.data.frame(table(cancer_cytoband$cytoband))
#     cytobank_freq_freq = as.data.frame(table(cytoband_freq$Freq)) # 多效染色体区域在癌症对中出现的次数
#     cytobank_freq_freq$Var1 = as.numeric(as.character(cytobank_freq_freq$Var1))
#     cytobank_freq_freq$Freq[11] = sum(cytobank_freq_freq$Freq[cytobank_freq_freq$Var1>10&cytobank_freq_freq$Var1<=20])
#     cytobank_freq_freq$Freq[12] = sum(cytobank_freq_freq$Freq[cytobank_freq_freq$Var1>20&cytobank_freq_freq$Var1<=30])
#     cytobank_freq_freq$Freq[13] = sum(cytobank_freq_freq$Freq[cytobank_freq_freq$Var1>30])
#     cytobank_freq_freq$Var1[11] = "11-20"
#     cytobank_freq_freq$Var1[12] = "21-30"
#     cytobank_freq_freq$Var1[13] = ">30"
#     cytobank_freq_freq = cytobank_freq_freq[1:13,]
#     sum(cytobank_freq_freq$Freq)
#     cytobank_freq_freq$Var1 = factor(cytobank_freq_freq$Var1, levels = cytobank_freq_freq$Var1)
#     {
#       ggplot(data=cytobank_freq_freq, mapping=aes(x=Var1,fill=Var1,y=Freq))+
#         geom_bar(stat="identity",width=0.5, fill = c(brewer.pal(9, "Set1"),brewer.pal(4, "Set3")))+
#         # scale_color_continuous(values=c(brewer.pal(12, "Set3"), brewer.pal(3, "Set1")))+
#         geom_text(stat='identity',aes(label=Freq), vjust=-0.5, size=3.5)+
#         # scale_y_break(c(70,80),#截断位置及范围
#         #               space = 0.3,#间距大小
#         #               scales = 0.25,expand = c(0, 0)) +#上下显示比例，大于1上面比例大，小于1下面比例大
#         scale_y_continuous(expand = c(0, 0), limits = c(0,100)) +
#         labs(x = "癌症对数", y = "多效染色体区域数")+
#         theme_bw() +
#         theme(legend.position="none",
#               panel.grid.major = element_blank(), # 去除主网格线
#               panel.grid.minor = element_blank(),  # 去除次网格线
#               panel.background = element_blank(),
#               axis.text = element_text(size = 10, colour = "black", family = "sans"),
#               axis.text.y.right = element_blank(),
#               axis.ticks.y.right = element_blank(), 
#               axis.title = element_text(size = 12, family = "SimSun"))
#     }
#     { # 组合多效SNP和染色体区域
#       df_long <- tidyr::pivot_longer(left_join(SNP_cancer_count, cytobank_freq_freq, by = "Var1"), cols = c("Freq.x", "Freq.y"), names_to = "Group", values_to = "Value")
#       ggplot(df_long, aes(x = Var1, y =  ifelse(Group == "Freq.x", Value, Value * 180), fill = Group)) +
#         geom_bar(stat = "identity", position = position_dodge()) +
#         geom_text(aes(label = Value), position = position_dodge(width = 0.9), vjust = -0.5, size = 3, color = "black") +
#         # geom_text(stat='identity',aes(label=Value), vjust=-0.5, size=3.5, hjust = ifelse(df_long$Group == "Freq.x", 1.2,-1)) +
#         scale_fill_manual(values = c("Freq.x" = "#E41A1C", "Freq.y" = "#377EB8"),
#                           labels = c("Freq.x" = "SNP", "Freq.y" = "染色体区域")) +
#         scale_y_continuous(
#           expand = c(0,0),
#           name = "多效SNP数",
#           limits = c(0, 18000),
#           sec.axis = sec_axis(
#             trans = ~ . / 180,
#             name = "多效染色体区域数"
#           )
#         ) +
#         labs(x = "癌症对数")+
#         theme_bw() +
#         theme(panel.grid.major = element_blank(), # 去除主网格线
#               panel.grid.minor = element_blank(),  # 去除次网格线
#               panel.background = element_blank(),
#               axis.text = element_text(size = 10, colour = "black", family = "sans"),
#               axis.title = element_text(size = 12, family = "SimSun"),
#               legend.location = "right",
#               legend.title = element_blank(),
#               legend.key.size = unit(1, "lines"),
#               legend.text = element_text(size = 12, family = "SimSun"))
#     }
#     
#     
#   }
#   library(dplyr)
#   library(readr)
#   library(GenomicRanges)
#   # 多效SNP与癌症SNP处于LD
#   LD = as.data.frame(read.table("/home/yanyq/share_genetics/result/GWAS_cancer_LD/plink_output_LD_0.5.ld", header = T))# 多效SNP是癌症SNP
#   # 显著的SNP
#   catalog = as.data.frame(read_tsv("/home/yanyq/data/gwas_catalog_v1.0.2-associations/gwas_catalog_v1.0.2-cancer_dbsnp156"))
#   catalog = catalog[catalog$`P-VALUE`<5e-8,]
#   sig_GWAS = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/GWAS/processed/sigGWAS"))
#   # 癌症SNP
#   SNP_cancer = rbind(catalog[,c("SNPID_dbsnp156", "CHR_ID", "CHR_POS")] %>%dplyr::rename(snpid = "SNPID_dbsnp156", hg19chr = "CHR_ID", bp = "CHR_POS"),
#                      sig_GWAS[,c("snpid","hg19chr","bp")])
#   SNP_cancer = rbind(SNP_cancer,LD[LD$SNP_A%in%SNP_cancer$snpid,c("SNP_B", "CHR_B", "BP_B")]%>%dplyr::rename(snpid = "SNP_B", hg19chr = "CHR_B", bp = "BP_B"))
#   SNP_cancer = unique(SNP_cancer)
#   nrow(SNP_cancer)
#   nrow(SNP_cancer[,c("hg19chr","bp")])
#   ######################################## 癌症SNP区域
#   SNP_cancer_GR = as(paste0(SNP_cancer$hg19chr, ":", SNP_cancer$bp), "GRanges")
#   cytoband = as.data.frame(read_tsv("/home/yanyq/data/cytoBand_hg19.txt.gz", col_names = F))
#   cytoband$X1 = gsub("chr", "", cytoband$X1)
#   cytoband$X4 = paste0(cytoband$X1, cytoband$X4)
#   cytoband_GR = GRanges(seqnames = cytoband$X1,ranges = IRanges(start = cytoband$X2, end = cytoband$X3))
#   SNP_cancer_cytoband = as.data.frame(findOverlaps(SNP_cancer_GR, cytoband_GR))
#   which(duplicated(SNP_cancer_cytoband$queryHits))
#   SNP_cancer$cytoband = NA
#   SNP_cancer$cytoband[SNP_cancer_cytoband$queryHits] = cytoband$X4[SNP_cancer_cytoband$subjectHits]
#   which(is.na(SNP_cancer$cytoband))
#   write_tsv(SNP_cancer, "/home/yanyq/share_genetics/result/GWAS_cancer_LD/SNP_cancer_cytoband")
#   # SNP_cancer = unique(c(LD$var1, lead$snpid,all_PLACO$snpid[all_PLACO$pval.trait1<5e-8|all_PLACO$pval.trait2<5e-8]))
#   # SNP_cancer_cytoband = unique(all_PLACO_SNP$cytoband[all_PLACO_SNP$snpid%in%SNP_cancer]) # 癌症SNP区域
#   # 在该区域的多效SNP
#   all_PLACO = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer_MAGMA_SMR_cytoband"))
#   all_PLACO$in_cancer_cytoband = all_PLACO$cytoband%in%SNP_cancer$cytoband
#   nrow(all_PLACO[!all_PLACO$in_cancer_cytoband,]) # 20个不在癌症区域
#   # all_PLACO$in_cancer_cytoband = all_PLACO$snpid%in%all_PLACO_SNP$snpid[all_PLACO_SNP$cytoband%in%SNP_cancer_cytoband]
#   write_tsv(all_PLACO, "/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer_MAGMA_SMR_GWASCatalog")
#   ####################################################### 是否为癌症SNP
#   all_PLACO$is_cancer_SNP = all_PLACO$snpid%in%SNP_cancer$snpid
#   write_tsv(all_PLACO, "/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer_MAGMA_SMR_GWASCatalog_cancer")
#   
#   # 是否为其中一个癌症的SNP
#   rm(list = ls())
#   all_PLACO = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer_MAGMA_SMR_GWASCatalog_cancer"))
#   LD = as.data.frame(read.table("/home/yanyq/share_genetics/result/GWAS_cancer_LD/plink_output_LD_0.5.ld", header = T))# 多效SNP是癌症SNP
#   sig_GWAS = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/GWAS/processed/sigGWAS"))
#   catalogMapped = as.data.frame(read_tsv("/home/yanyq/data/gwas_catalog_v1.0.2-associations/gwas_catalog_v1.0.2-cancer_dbsnp156_traitMapped"))
#   sig_GWAS = sig_GWAS[,c("snpid", "trait")]
#   catalogMapped = catalogMapped[,c("SNPID_dbsnp156","trait")]%>%rename(snpid = "SNPID_dbsnp156")
#   cancer_SNP = unique(rbind(sig_GWAS, catalogMapped))
#   cancer_SNP_LD = merge(cancer_SNP, LD, by.x = "snpid", by.y = "SNP_A")
#   cancer_SNP_LD = cancer_SNP_LD[,c("SNP_B","trait")]%>%rename(snpid = SNP_B)
#   cancer_SNP = unique(rbind(cancer_SNP, cancer_SNP_LD))
#   nrow(cancer_SNP) # 92659
#   length(unique(cancer_SNP$snpid)) # 75493
#   unique(cancer_SNP$trait[!cancer_SNP$trait%in%c(all_PLACO$trait1, all_PLACO$trait2)])
#   all_PLACO$is_cancer1_SNP = paste0(all_PLACO$snpid, "-", all_PLACO$trait1)%in%paste0(cancer_SNP$snpid, "-", cancer_SNP$trait)
#   all_PLACO$is_cancer2_SNP = paste0(all_PLACO$snpid, "-", all_PLACO$trait2)%in%paste0(cancer_SNP$snpid, "-", cancer_SNP$trait)
#   length(which(all_PLACO$is_cancer1_SNP)) # 33783
#   length(which(all_PLACO$is_cancer2_SNP)) # 46141
#   length(which(all_PLACO$is_cancer1_SNP|all_PLACO$is_cancer2_SNP)) # 70558
#   all_PLACO$is_cancer1_SNP[all_PLACO$snpid%in%cancer_SNP$snpid[cancer_SNP$trait=="cancer"]] = TRUE
#   all_PLACO$is_cancer2_SNP[all_PLACO$snpid%in%cancer_SNP$snpid[cancer_SNP$trait=="cancer"]] = TRUE
#   length(which(all_PLACO$is_cancer1_SNP)) # 34234
#   length(which(all_PLACO$is_cancer2_SNP)) # 46489
#   length(which(all_PLACO$is_cancer1_SNP|all_PLACO$is_cancer2_SNP)) # 70596
#   all_PLACO$is_cancer1ANDcancer2_SNP = (all_PLACO$is_cancer1_SNP|all_PLACO$is_cancer2_SNP)
#   all_PLACO$is_cancer1ANDcancer2_SNP[(all_PLACO$is_cancer1_SNP&all_PLACO$is_cancer2_SNP)] = FALSE
#   write_tsv(all_PLACO, "/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer_MAGMA_SMR_GWASCatalog_cancer_separate")
#   
}
# # 多效SNP与癌症SNP处于LD
# LD = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/GWAS_catalog/all_results_r2_0.5"))
# # 多效SNP是癌症SNP
# lead = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/PLACO/all_lead_GWAS_cancer_SNP"))
# { # 在数据库检索癌症下载的association
#   setwd("/home/yanyq/share_genetics/data/gwas_catalog/")
#   BGC = rbind(as.data.frame(read_tsv("BGC_1.tsv")),as.data.frame(read_tsv("BGC_2.tsv")))
#   BGC = rbind(BGC,as.data.frame(read_tsv("BGC_3.tsv")))
#   BGC = rbind(BGC,as.data.frame(read_tsv("BGC_4.tsv")))
#   BGC = rbind(BGC,as.data.frame(read_tsv("BGC_5.tsv")))
#   BGC = rbind(BGC,as.data.frame(read_tsv("BGC_6.tsv")))
#   BGC = rbind(BGC,as.data.frame(read_tsv("BGC_7.tsv")))
#   BLCA = rbind(as.data.frame(read_tsv("BLCA_1.tsv")),as.data.frame(read_tsv("BLCA_2.tsv")))
#   BRCA = rbind(as.data.frame(read_tsv("BRCA_1.tsv")),as.data.frame(read_tsv("BRCA_2.tsv")))
#   BRCA = rbind(BRCA,as.data.frame(read_tsv("BRCA_3.tsv")))
#   BRCA = rbind(BRCA,as.data.frame(read_tsv("BRCA_4.tsv")))
#   BRCA = rbind(BRCA,as.data.frame(read_tsv("BRCA_5.tsv")))
#   BRCA = rbind(BRCA,as.data.frame(read_tsv("BRCA_6.tsv")))
#   BRCA = rbind(BRCA,as.data.frame(read_tsv("BRCA_7.tsv")))
#   BRCA = rbind(BRCA,as.data.frame(read_tsv("BRCA_8.tsv")))
#   BRCA = rbind(BRCA,as.data.frame(read_tsv("BRCA_9.tsv")))
#   BRCA = rbind(BRCA,as.data.frame(read_tsv("BRCA_10.tsv")))
#   BRCA = rbind(BRCA,as.data.frame(read_tsv("BRCA_11.tsv")))
#   BRCA = rbind(BRCA,as.data.frame(read_tsv("BRCA_12.tsv")))  
#   BRCA = rbind(BRCA,as.data.frame(read_tsv("BRCA_13.tsv")))
#   BRCA = rbind(BRCA,as.data.frame(read_tsv("BRCA_14.tsv")))
#   BRCA = rbind(BRCA,as.data.frame(read_tsv("BRCA_15.tsv")))
#   BRCA = rbind(BRCA,as.data.frame(read_tsv("BRCA_16.tsv")))
#   BRCA = rbind(BRCA,as.data.frame(read_tsv("BRCA_17.tsv")))
#   CESC = rbind(as.data.frame(read_tsv("CESC_1.tsv")),as.data.frame(read_tsv("CESC_2.tsv")))
#   CML = as.data.frame(read_tsv("CML.tsv"))
#   CORP = as.data.frame(read_tsv("CORP.tsv"))
#   CRC = rbind(as.data.frame(read_tsv("CRC_1.tsv")),as.data.frame(read_tsv("CRC_2.tsv")))
#   CRC = rbind(CRC,as.data.frame(read_tsv("CRC_3.tsv")))
#   CRC = rbind(CRC,as.data.frame(read_tsv("CRC_4.tsv")))
#   CRC = rbind(CRC,as.data.frame(read_tsv("CRC_5.tsv")))
#   CRC = rbind(CRC,as.data.frame(read_tsv("CRC_6.tsv")))
#   CRC = rbind(CRC,as.data.frame(read_tsv("CRC_7.tsv")))
#   CRC = rbind(CRC,as.data.frame(read_tsv("CRC_8.tsv")))
#   CRC = rbind(CRC,as.data.frame(read_tsv("CRC_9.tsv")))
#   CRC = rbind(CRC,as.data.frame(read_tsv("CRC_10.tsv")))
#   CRC = rbind(CRC,as.data.frame(read_tsv("CRC_11.tsv")))
#   CRC = rbind(CRC,as.data.frame(read_tsv("CRC_12.tsv")))
#   DLBC = as.data.frame(read_tsv("DLBC.tsv"))
#   ESCA = rbind(as.data.frame(read_tsv("ESCA_1.tsv")),as.data.frame(read_tsv("ESCA_2.tsv")))
#   ESCA = rbind(ESCA,as.data.frame(read_tsv("ESCA_3.tsv")))
#   ESCA = rbind(ESCA,as.data.frame(read_tsv("ESCA_4.tsv")))
#   HL = rbind(as.data.frame(read_tsv("HL_1.tsv")),as.data.frame(read_tsv("HL_2.tsv")))
#   HNSC = rbind(as.data.frame(read_tsv("HNSC_1.tsv")),as.data.frame(read_tsv("HNSC_2.tsv")))
#   kidney = rbind(as.data.frame(read_tsv("kidney_1.tsv")),as.data.frame(read_tsv("kidney_2.tsv")))
#   kidney = rbind(kidney,as.data.frame(read_tsv("kidney_3.tsv")))
#   kidney = rbind(kidney,as.data.frame(read_tsv("kidney_4.tsv")))
#   kidney = rbind(kidney,as.data.frame(read_tsv("kidney_5.tsv")))
#   kidney = rbind(kidney,as.data.frame(read_tsv("kidney_6.tsv")))
#   LIHC = rbind(as.data.frame(read_tsv("LIHC_1.tsv")),as.data.frame(read_tsv("LIHC_2.tsv")))
#   LL = rbind(as.data.frame(read_tsv("LL_1.tsv")),as.data.frame(read_tsv("LL_2.tsv")))
#   LL = rbind(LL,as.data.frame(read_tsv("LL_3.tsv")))
#   LL = rbind(LL,as.data.frame(read_tsv("LL_4.tsv")))
#   LL = rbind(LL,as.data.frame(read_tsv("LL_5.tsv")))
#   lung = rbind(as.data.frame(read_tsv("lung_1.tsv")),as.data.frame(read_tsv("lung_2.tsv")))
#   lung = rbind(lung,as.data.frame(read_tsv("lung_3.tsv")))
#   lung = rbind(lung,as.data.frame(read_tsv("lung_4.tsv")))
#   lung = rbind(lung,as.data.frame(read_tsv("lung_5.tsv")))
#   lung = rbind(lung,as.data.frame(read_tsv("lung_6.tsv")))
#   lung = rbind(lung,as.data.frame(read_tsv("lung_7.tsv")))
#   MM = as.data.frame(read_tsv("MM.tsv"))
#   MZBL = as.data.frame(read_tsv("MZBL.tsv"))
#   OV = rbind(as.data.frame(read_tsv("OV_1.tsv")),as.data.frame(read_tsv("OV_2.tsv")))
#   OV = rbind(OV,as.data.frame(read_tsv("OV_3.tsv")))
#   OV = rbind(OV,as.data.frame(read_tsv("OV_4.tsv")))
#   OV = rbind(OV,as.data.frame(read_tsv("OV_5.tsv")))
#   OV = rbind(OV,as.data.frame(read_tsv("OV_6.tsv")))
#   OV = rbind(OV,as.data.frame(read_tsv("OV_7.tsv")))
#   OV = rbind(OV,as.data.frame(read_tsv("OV_8.tsv")))
#   OV = rbind(OV,as.data.frame(read_tsv("OV_9.tsv")))
#   PAAD = rbind(as.data.frame(read_tsv("PAAD_1.tsv")),as.data.frame(read_tsv("PAAD_2.tsv")))
#   PAAD = rbind(PAAD,as.data.frame(read_tsv("PAAD_3.tsv")))
#   PRAD = rbind(as.data.frame(read_tsv("PRAD_1.tsv")),as.data.frame(read_tsv("PRAD_2.tsv")))
#   SCC = as.data.frame(read_tsv("SCC.tsv"))
#   SI = rbind(as.data.frame(read_tsv("SI_1.tsv")),as.data.frame(read_tsv("SI_2.tsv")))
#   SKCM = rbind(as.data.frame(read_tsv("SKCM_1.tsv")),as.data.frame(read_tsv("SKCM_2.tsv")))
#   STAD = rbind(as.data.frame(read_tsv("STAD_1.tsv")),as.data.frame(read_tsv("STAD_2.tsv")))
#   STAD = rbind(STAD,as.data.frame(read_tsv("STAD_3.tsv")))
#   STAD = rbind(STAD,as.data.frame(read_tsv("STAD_4.tsv")))
#   STAD = rbind(STAD,as.data.frame(read_tsv("STAD_5.tsv")))
#   TEST = as.data.frame(read_tsv("TEST.tsv"))
#   THCA = rbind(as.data.frame(read_tsv("THCA_1.tsv")),as.data.frame(read_tsv("THCA_2.tsv")))
#   THCA = rbind(THCA,as.data.frame(read_tsv("THCA_3.tsv")))
#   UCEC = rbind(as.data.frame(read_tsv("UCEC_1.tsv")),as.data.frame(read_tsv("UCEC_2.tsv")))
#   UCEC = rbind(UCEC,as.data.frame(read_tsv("UCEC_3.tsv")))
#   UCEC = rbind(UCEC,as.data.frame(read_tsv("UCEC_4.tsv")))
# }
# load("/home/yanyq/share_genetics/data/gwas_catalog/all_cancer.Rda.RData")
# {
#   gwascancer = data.frame(snpid = BGC$SNPS,gwascacner = "BGC")
#   gwascancer = rbind(gwascancer,data.frame(snpid = BLCA$SNPS,gwascacner = "BLCA"))
#   gwascancer = rbind(gwascancer,data.frame(snpid = BRCA$SNPS,gwascacner = "BRCA"))
#   gwascancer = rbind(gwascancer,data.frame(snpid = CESC$SNPS,gwascacner = "CESC"))
#   gwascancer = rbind(gwascancer,data.frame(snpid = CML$SNPS,gwascacner = "CML"))
#   # gwascancer = rbind(gwascancer,data.frame(snpid = CORP$SNPS,gwascacner = "CORP"))
#   gwascancer = rbind(gwascancer,data.frame(snpid = CRC$SNPS,gwascacner = "CRC"))
#   gwascancer = rbind(gwascancer,data.frame(snpid = ESCA$SNPS,gwascacner = "ESCA"))
#   gwascancer = rbind(gwascancer,data.frame(snpid = HL$SNPS,gwascacner = "HL"))
#   gwascancer = rbind(gwascancer,data.frame(snpid = HNSC$SNPS,gwascacner = "HNSC"))
#   gwascancer = rbind(gwascancer,data.frame(snpid = kidney$SNPS,gwascacner = "kidney"))
#   gwascancer = rbind(gwascancer,data.frame(snpid = LIHC$SNPS,gwascacner = "LIHC"))
#   gwascancer = rbind(gwascancer,data.frame(snpid = LL$SNPS,gwascacner = "LL"))
#   gwascancer = rbind(gwascancer,data.frame(snpid = lung$SNPS,gwascacner = "lung"))
#   gwascancer = rbind(gwascancer,data.frame(snpid = MM$SNPS,gwascacner = "MM"))
#   gwascancer = rbind(gwascancer,data.frame(snpid = MZBL$SNPS,gwascacner = "MZBL"))
#   gwascancer = rbind(gwascancer,data.frame(snpid = OV$SNPS,gwascacner = "OV"))
#   gwascancer = rbind(gwascancer,data.frame(snpid = PAAD$SNPS,gwascacner = "PAAD"))
#   gwascancer = rbind(gwascancer,data.frame(snpid = PRAD$SNPS,gwascacner = "PRAD"))
#   gwascancer = rbind(gwascancer,data.frame(snpid = SCC$SNPS,gwascacner = "SCC"))
#   gwascancer = rbind(gwascancer,data.frame(snpid = SI$SNPS,gwascacner = "SI"))
#   gwascancer = rbind(gwascancer,data.frame(snpid = SKCM$SNPS,gwascacner = "SKCM"))
#   gwascancer = rbind(gwascancer,data.frame(snpid = STAD$SNPS,gwascacner = "STAD"))
#   gwascancer = rbind(gwascancer,data.frame(snpid = TEST$SNPS,gwascacner = "TEST"))
#   gwascancer = rbind(gwascancer,data.frame(snpid = THCA$SNPS,gwascacner = "THCA"))
#   gwascancer = rbind(gwascancer,data.frame(snpid = UCEC$SNPS,gwascacner = "UCEC"))
# }

# gwascancer = unique(gwascancer)
# gwascancer_lead = gwascancer[gwascancer$snpid%in%all_PLACO$snpid,]
# gwascancer_LD = merge(gwascancer,LD,by.x = "snpid",by.y = "var2")
# gwascancer_SNPs = rbind(gwascancer_lead[,c("snpid","gwascacner")],gwascancer_LD[,c("snpid","gwascacner")])
# gwascancer_SNPs$flag = paste0(gwascancer_SNPs$snpid,":",gwascancer_SNPs$gwascacner)
# all_PLACO$flag = paste0(all_PLACO$snpid,":",all_PLACO$trait1)
# all_PLACO$is_cancer1_SNP = (all_PLACO$flag%in%gwascancer_SNPs$flag)|(all_PLACO$pval.trait1<5e-8)
# all_PLACO$flag = paste0(all_PLACO$snpid,":",all_PLACO$trait2)
# all_PLACO$is_cancer2_SNP = (all_PLACO$flag%in%gwascancer_SNPs$flag)|(all_PLACO$pval.trait2<5e-8)
# write_tsv(all_PLACO, "/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer_MAGMA_SMR_GWASCatalog_cancer_separate")

############################### 多效lead SNP和局部遗传相关性区域overlap
rm(list = ls())
all_PLACO = read_tsv("/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer_MAGMA_SMR_GWASCatalog_cancer_separate")
all_PLACO$local_cor_region = NA
local_cor = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/SUPERGNOVA/all_fdr0.05"))
local_cor$region = paste0(local_cor$chr,":",local_cor$start,"-",local_cor$end)
for(i in unique(local_cor$traits)){
  tmp_all_PLACO = all_PLACO[all_PLACO$traits==i,]
  if(nrow(tmp_all_PLACO)>0){
    tmp_local_cor = local_cor[local_cor$traits==i,]
    tmp_PLACO_gr = as(paste0(tmp_all_PLACO$hg19chr,":",tmp_all_PLACO$bp), "GRanges")
    tmp_local_gr = as(tmp_local_cor$region, "GRanges")
    tmp_overlaps = findOverlaps(tmp_PLACO_gr,tmp_local_gr)
    if(length(tmp_overlaps@from)>0){
      tmp_all_PLACO$local_cor_region[tmp_overlaps@from] = tmp_local_cor$region[tmp_overlaps@to]
      all_PLACO$local_cor_region[all_PLACO$traits==i] = tmp_all_PLACO$local_cor_region
    }else{
      print(paste0(i,": no overlap"))
    }
  }else{
    print(i)
  }
}
write_tsv(all_PLACO,"/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer_MAGMA_SMR_GWASCatalog_cancer_separate_SUPERGNOVA")

##########################################MAGMA基因是否共定位
rm(list = ls())
library(pbmcapply)
MAGMA_coloc = as.data.frame(read_tsv("~/share_genetics/result/coloc_MAGMA/summary/all"))
MAGMA_coloc = MAGMA_coloc[MAGMA_coloc$PP.H4.abf>0.7,]
MAGMA = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/all"))
MAGMA_coloc = left_join(MAGMA_coloc,unique( MAGMA[,c("locus.MAGMA", "SYMBOL")]%>%rename(locus = "locus.MAGMA", symbol_coloc = "SYMBOL")), by = "locus")
MAGMA_coloc[is.na(MAGMA_coloc$symbol_coloc),]
all_PLACO = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer_MAGMA_SMR_GWASCatalog_cancer_separate_SUPERGNOVA"))
all_PLACO_COLOC = pbmclapply(1:nrow(all_PLACO), FUN = function(i) {
  tmp_PLACO = all_PLACO[i,]
  tmp_gene = unique(unlist(str_split(c(tmp_PLACO$nearestGene,tmp_PLACO$eQTLGen,tmp_PLACO$MAGMA_PLACO,
                                       tmp_PLACO$SMR_eQTLGen_trait1,tmp_PLACO$SMR_eQTLGen_trait2,
                                       tmp_PLACO$SMR_MAGMA_trait1,tmp_PLACO$SMR_MAGMA_trait2),",")))
  tmp_gene = tmp_gene[(!is.na(tmp_gene))&(tmp_gene!="NA")]
  
  # 用的是MAGMA基因共定位，所以实质上就是和all_PLACO$MAGMA_PLACO做overlap
  tmp_MAGMA_COLOC = MAGMA_coloc[(MAGMA_coloc$traits==tmp_PLACO$traits)&(MAGMA_coloc$symbol_coloc%in%tmp_gene),]
  if(nrow(tmp_MAGMA_COLOC)>0){
    tmp_MAGMA_COLOC_combined = apply(tmp_MAGMA_COLOC, 2, function(column) paste(column, collapse = ","))
    tmp_MAGMA_COLOC_combined = as.data.frame(t(tmp_MAGMA_COLOC_combined))
    tmp_MAGMA_COLOC_combined = tmp_MAGMA_COLOC_combined[,-19]
  }else{
    tmp_MAGMA_COLOC_combined = MAGMA_coloc[1,]
    tmp_MAGMA_COLOC_combined[1,] = NA
    tmp_MAGMA_COLOC_combined = tmp_MAGMA_COLOC_combined[,-19]
  }
  tmp_PLACO = cbind(tmp_PLACO,tmp_MAGMA_COLOC_combined)
  
  tmp_PLACO
}, mc.cores = 20)
all_PLACO_COLOC = do.call(rbind, all_PLACO_COLOC)
write_tsv(all_PLACO_COLOC, "/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer_MAGMA_SMR_GWASCatalog_cancer_separate_SUPERGNOVA_coloc")

##############功能位点筛选
# SNP在一个癌症中显著，另一个癌症中不显著
# SNP所在的MAGMA基因筛选，不一定都要满足
#### 差异表达
#### SMR
#### 共定位
########################################################################
library(readr)
library(stringr)
library(tidyr)
library(pbmcapply)
library(data.table)
rm(list = ls())

all_PLACO = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer_MAGMA_SMR_GWASCatalog_cancer_separate_SUPERGNOVA_coloc"))

setwd("/home/yanyq/share_genetics/data/GEPIA_DEG/")
all_PLACO$MAGMA_PLACO_DEG_trait1 = NA
all_PLACO$MAGMA_PLACO_DEG_trait2 = NA
all_PLACO_DEG = pbmclapply(1:nrow(all_PLACO), FUN = function(i) {
  all_PLACO_tmp = all_PLACO[i,]
  MAGMA_gene = unlist(str_split(all_PLACO_tmp$MAGMA_PLACO, pattern = ","))
  flag_trait1 = 0
  flag_trait2 = 0
  if(!any(is.na(MAGMA_gene))){
    trait1_tmp = all_PLACO_tmp$trait1
    trait2_tmp = all_PLACO_tmp$trait2
    ###################### 差异基因
    {
      if(file.exists(paste0(trait1_tmp,".txt"))){
        DEG_trait1 = fread(paste0(trait1_tmp,".txt"))
        flag_trait1 = 1
      }
      if(file.exists(paste0(trait2_tmp,".txt"))){
        DEG_trait2 = fread(paste0(trait2_tmp,".txt"))
        flag_trait2 = 1
      }
      {
        if(trait1_tmp=="kidney"){
          DEG_KICH_trait1 = fread(paste0("KICH",".txt"))
          DEG_KIRC_trait1 = fread(paste0("KIRC",".txt"))
          DEG_KIRP_trait1 = fread(paste0("KIRP",".txt"))
          # colnames(DEG_KIRP_trait1)[2:6] = paste0(colnames(DEG_KIRP_trait1)[2:6],".KIPR")
          # DEG_trait1 = merge(DEG_KICH_trait1,DEG_KIRC_trait1,by = "V1",all=TRUE, suffixes=c(".KICH", ".KIRC"))
          # DEG_trait1 = merge(DEG_trait1,DEG_KIRP_trait1,by = "V1",all=TRUE)
          DEG_trait1 = rbind(DEG_KICH_trait1,DEG_KIRC_trait1)
          DEG_trait1 = rbind(DEG_trait1, DEG_KIRP_trait1)
          flag_trait1 = 1
        }
        if(trait1_tmp=="lung"){
          DEG_LUAD_trait1 = fread(paste0("LUAD",".txt"))
          DEG_LUSC_trait1 = fread(paste0("LUSC",".txt"))
          # DEG_trait1 = merge(DEG_LUAD_trait1,DEG_LUSC_trait1,by = "V1",all=TRUE, suffixes=c(".LUAD", ".LUSC"))
          DEG_trait1 = rbind(DEG_LUAD_trait1,DEG_LUSC_trait1)
          flag_trait1 = 1
        }
        if(trait1_tmp=="CRC"){
          DEG_COAD_trait1 = fread(paste0("COAD",".txt"))
          DEG_READ_trait1 = fread(paste0("READ",".txt"))
          # DEG_trait1 = merge(DEG_COAD_trait1,DEG_READ_trait1,by = "V1",all=TRUE, suffixes=c(".COAD", ".READ"))
          DEG_trait1 = rbind(DEG_COAD_trait1,DEG_READ_trait1)
          flag_trait1 = 1
        }
      }
      {
        if(trait2_tmp=="kidney"){
          DEG_KICH_trait2 = fread(paste0("KICH",".txt"))
          DEG_KIRC_trait2 = fread(paste0("KIRC",".txt"))
          DEG_KIRP_trait2 = fread(paste0("KIRP",".txt"))
          # colnames(DEG_KIRP_trait2)[2:6] = paste0(colnames(DEG_KIRP_trait2)[2:6],".KIPR")
          # DEG_trait2 = merge(DEG_KICH_trait2,DEG_KIRC_trait2,by = "V1",all=TRUE, suffixes=c(".KICH", ".KIRC"))
          # DEG_trait2 = merge(DEG_trait2,DEG_KIRP_trait2,by = "V1",all=TRUE)
          DEG_trait2 = rbind(DEG_KICH_trait2,DEG_KIRC_trait2)
          DEG_trait2 = rbind(DEG_trait2, DEG_KIRP_trait2)
          flag_trait2 = 1
        }
        if(trait2_tmp=="lung"){
          DEG_LUAD_trait2 = fread(paste0("LUAD",".txt"))
          DEG_LUSC_trait2 = fread(paste0("LUSC",".txt"))
          # DEG_trait2 = merge(DEG_LUAD_trait2,DEG_LUSC_trait2,by = "V1",all=TRUE, suffixes=c(".LUAD", ".LUSC"))
          DEG_trait2 = rbind(DEG_LUAD_trait2,DEG_LUSC_trait2)
          flag_trait2 = 1
        }
        if(trait2_tmp=="CRC"){
          DEG_COAD_trait2 = fread(paste0("COAD",".txt"))
          DEG_READ_trait2 = fread(paste0("READ",".txt"))
          # DEG_trait2 = merge(DEG_COAD_trait2,DEG_READ_trait2,by = "V1",all=TRUE, suffixes=c(".COAD", ".READ"))
          DEG_trait2 = rbind(DEG_COAD_trait2,DEG_READ_trait2)
          flag_trait2 = 1
        }
      }
      
      if(flag_trait1==1){
        all_PLACO_tmp$MAGMA_PLACO_DEG_trait1 = paste(MAGMA_gene[MAGMA_gene%in%DEG_trait1$V1], collapse = ",")
      }
      if(flag_trait2==1){
        all_PLACO_tmp$MAGMA_PLACO_DEG_trait2 = paste(MAGMA_gene[MAGMA_gene%in%DEG_trait2$V1], collapse = ",")
      }
    }
    ###################### SMR基因
    # all_PLACO_tmp$SMR_MAGMA_trait1
    ###################### 共定位，上一段代码
    # 用的是MAGMA基因共定位，所以实质上就是和all_PLACO$MAGMA_PLACO做overlap
  }
  all_PLACO_tmp
}, mc.cores = 40)
all_PLACO_DEG = do.call(rbind,all_PLACO_DEG)
write_tsv(all_PLACO_DEG,"/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer_MAGMA_SMR_GWASCatalog_cancer_separate_SUPERGNOVA_coloc_DEG")

######################################################多效SNP在LAVA上的情况
rm(list = ls())
library(GenomicRanges)
lava = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/bak/LAVA/all_uni_filtered_bivar"))
lava$traits = paste0(lava$phen1, "-", lava$phen2)
lava$region = paste0(lava$chr,":",lava$start,"-",lava$stop)
all_PLACO = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer_MAGMA_SMR_GWASCatalog_cancer_separate_SUPERGNOVA_coloc_DEG"))
all_PLACO$lava_region = NA
for(i in unique(lava$traits)){
  tmp_all_PLACO = all_PLACO[all_PLACO$traits==i,]
  if(nrow(tmp_all_PLACO)>0){
    tmp_lava = lava[lava$traits==i,]
    tmp_PLACO_gr = as(paste0(tmp_all_PLACO$hg19chr,":",tmp_all_PLACO$bp), "GRanges")
    tmp_lava_gr = as(tmp_lava$region, "GRanges")
    tmp_overlaps = findOverlaps(tmp_PLACO_gr,tmp_lava_gr)
    if(length(tmp_overlaps@from)>0){
      tmp_all_PLACO$lava_region[tmp_overlaps@from] = tmp_lava$region[tmp_overlaps@to]
      all_PLACO$lava_region[all_PLACO$traits==i] = tmp_all_PLACO$lava_region
    }else{
      print(paste0(i,": no overlap"))
    }
  }else{
    print(i)
  }
}
write_tsv(all_PLACO,"/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer_MAGMA_SMR_GWASCatalog_cancer_separate_SUPERGNOVA_coloc_DEG_LAVA")


###############################################PLACO SNP的共定位情况
rm(list = ls())
all_PLACO = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer_MAGMA_SMR_GWASCatalog_cancer_separate_SUPERGNOVA_coloc_DEG_LAVA"))
all_PLACO$this.SNP.PP.H4 = NA
setwd("/home/yanyq/share_genetics/result/coloc_MAGMA/raw/")
for(traits in unique(all_PLACO$traits)){
  tmp_all_PLACO = all_PLACO[all_PLACO$traits==traits,-ncol(all_PLACO)]
  flag = nrow(tmp_all_PLACO)
  if(file.exists(traits)){
    coloc = read_rds(traits)
    if(length(coloc)>0){
      coloc_snp = coloc[[1]]$results
    }
    if(length(coloc)>1){
      for(i in 2:length(coloc)){
        coloc_snp = rbind(coloc_snp,coloc[[i]]$results)
      }
      coloc_snp = unique(coloc_snp)
      coloc_snp = coloc_snp %>% group_by(snp) %>% summarise(PP.H4 = str_c(SNP.PP.H4, collapse = ","))
      coloc_snp = as.data.frame(coloc_snp)
      tmp_all_PLACO = left_join(tmp_all_PLACO, coloc_snp%>%rename(snpid = "snp", this.SNP.PP.H4 = "PP.H4"), by = "snpid")
    }
  }else{
    tmp_all_PLACO$this.SNP.PP.H4 = NA
  }
  if(nrow(tmp_all_PLACO)==flag){
    all_PLACO[all_PLACO$traits==traits,] = tmp_all_PLACO
  }else{
    print(traits)
  }
}
write_tsv(all_PLACO, "/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer_MAGMA_SMR_GWASCatalog_cancer_separate_SUPERGNOVA_coloc_DEG_LAVA_SNPcoloc")
