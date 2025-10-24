library(circlize)
library(RColorBrewer)
library(readr)
library(ggplot2)
library(ggbreak)
library(showtext)
library(dplyr)

showtext_auto()
font_add("SimSun", "/home/yanyq/usr/share/font/simsun.ttc")  # 使用宋体（SimSun）

cancer_abbrev = as.data.frame(read.table("/home/yanyq/share_genetics/data/cancer_abbrev"))

# 用所有的trait时，发现LIHC和BGC之间的局部相关基因座数目为四百多，而多效基因座FUMA仅2个
# 可能是由于二者的overlap过高引起的，0.6几，其他癌症间最多为0.0几，尽管LAVA声称可以对任意重叠比例的性状进行分析
# 可能的猜测
# 1. 这种情况是合理的，肝细胞癌和胆道癌都属于肝癌，在遗传上相似，由于样本量过小，导致LDSC和PLACO无法检出
# 2. 不合理的几种原因
# 尽管二者都是finngen数据，但其他finngen数据间的overlap仍较小
# 样本量小，导致估计值不准，其他癌症也存在样本量小的情况
# 目前还不太清楚是什么原因
# 使用h2的z分数>2将LIHC筛出去
traits = c("BLCA","BRCA", "HNSC", "kidney", "lung", "OV",   'PAAD', "PRAD", 'SKCM', "UCEC",
           "BGC", "CRC", "DLBC", "ESCA", "STAD", "THCA","AML", "BAC", "BCC" ,"BGA", "BM",
           "CESC", "CML", "CORP" ,"EYAD" ,"GSS", "HL", "LIHC" ,"LL" ,"MCL", "MESO", "MM" ,
           "MS" ,"MZBL", "SCC" ,"SI", "TEST", "VULVA")
traits = traits[order(traits)]

all_f = list()
# # 分别统计正相关和负相关的个数，正相关用红色，负相关用蓝色，但是看不清
# for(trait1 in traits){
#   for(trait2 in traits){
#     file_name = paste0("/home/yanyq/share_genetics/result/LAVA/", trait1, "-", trait2, ".bivar.lava")
#     if(file.exists(file_name)){
#       f = as.data.frame(read.table(file_name, header = T))
#       f = f[!is.na(f$rho),]
#       f$FDR = p.adjust(f$p, method = "BH")
#       f = f[f$FDR<0.05,]
#       if(nrow(f)>0){
#         f$color = ifelse(f$rho>0,"#ff4757", "#546de5")
#         f = as.data.frame(table(f$color))
#         f$from = trait1
#         f$to = trait2
#         f = f[order(f$Var1),]
#         all_f[[file_name]] = f
#       }
#     }
#   }
# }
# all_f = do.call(rbind, all_f)
# colnames(all_f) = c("color", "value", "from", "to")
# all_f = all_f[,c("from", "to", "value", "color")]

# 统计相关基因座个数，颜色根据from设置
for(trait1 in traits){
  for(trait2 in traits){
    file_name = paste0("/home/yanyq/share_genetics/result/LAVA/", trait1, "-", trait2, ".bivar.lava")
    if(file.exists(file_name)){
      f_uni = as.data.frame(read.table(gsub("bivar", "univ", file_name), header = T)) # 单变量检验
      tmp = table(f_uni$locus)
      f_uni = f_uni[f_uni$locus%in%names(tmp[tmp>1]),] # 去除只在一个表型中进行了单变量检验的locus
      f_uni_trait1 = f_uni[f_uni$phen == trait1,] # trait1单变量检验结果
      f_uni_trait2 = f_uni[f_uni$phen == trait2,] # trait2单变量检验结果
      f_uni = merge(f_uni_trait1, f_uni_trait2, by = "locus", suffixes = c(trait1, trait2))
      f_uni = f_uni[f_uni[,9]<0.05/2495&f_uni[,17]<0.05/2495,]
      
      f = as.data.frame(read.table(file_name, header = T))
      f = f[!is.na(f$rho),]
      f = f[f$locus%in%f_uni$locus,] # 仅对两种表型在 P < 0.05/2,495 处表现出单变量信号的位点进行双变量分析
      all_f[[file_name]] = f
      # f$FDR = p.adjust(f$p, method = "BH")
      # f = f[f$FDR<0.05,]
      # if(nrow(f)>0){
      #   f$from = trait1
      #   f$to = trait2
      #   f$value =nrow(f)
      #   all_f[[file_name]] = f[1,c("from", "to", "value")]
      # }
    }
  }
}
all_f = do.call(rbind, all_f)
write_tsv(all_f, "/home/yanyq/share_genetics/result/LAVA/all_uni_filtered_bivar")

all_f = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/LAVA/all_uni_filtered_bivar"))
h2 = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/ldsc/ldsc_h2_cal_sampleSize_effect_4"))
h2 = h2[(h2$h2_obs/h2$h2_se)>=2,]
traits = h2$trait
all_f = all_f[all_f$phen1%in%traits&all_f$phen2%in%traits,]
all_f$FDR = p.adjust(all_f$p, method = "BH") # 对所有表型对进行校正
all_f = all_f[all_f$FDR<0.05,]
write_tsv(all_f,"/home/yanyq/share_genetics/result/LAVA/all_uni_filtered_bivar_fdr0.05")

length(unique(c(all_f$phen1, all_f$phen2))) # 有相关性的性状数
length(unique(all_f$locus)) # 有相关性的区域数目
locus_num = as.data.frame(table(all_f$locus)) # 该区域内有相关性的癌症对数
{ # 条形图：癌症对数，相关性区域数目，如590个区域只在一对癌症中显著，204个区域在两对癌症中显著
  ggplot(data=as.data.frame(table(locus_num$Freq)), mapping=aes(x=Var1,fill=Var1,y=Freq))+
    geom_bar(stat="identity",width=0.5, fill = c(brewer.pal(9, "Set1"),brewer.pal(6, "Set3")))+
    # scale_color_manual(values=c(brewer.pal(12, "Set3"), brewer.pal(3, "Set1")))+
    geom_text(stat='identity',aes(label=Freq), vjust=-0.5, size=3.5)+
    scale_y_break(c(250,580),#截断位置及范围
                  space = 0.3,#间距大小
                  scales = 0.25,expand = c(0, 0), ticklabels = c(50,100,150,200,250,580,590,600)) +#上下显示比例，大于1上面比例大，小于1下面比例大
    scale_y_continuous(expand = c(0, 0), limits = c(0,600)) +
    labs(x = "癌症对数", y = "显著相关的基因座数")+
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

length(which(locus_num$Freq>1)) # 在多个表型对中显著相关的区域
trait_num = as.data.frame(table(c(all_f$phen1, all_f$phen2))) # 基于癌症统计的显著相关区域数目
colnames(cancer_abbrev)[1] = "Var1"
trait_num = merge(trait_num, cancer_abbrev, by = "Var1")
trait_num = trait_num[order(trait_num$Freq, decreasing = T),]
# 将 Var1 转换为因子并按数据中的顺序排列
trait_num$Var1 = factor(trait_num$V2, levels = trait_num$V2)
{ # 条形图：癌症，相关性区域数目，每个表型检测到的显著双变量相关性总数
  ggplot(data=trait_num, mapping=aes(x=Var1,fill=Var1,y=Freq))+
    geom_bar(stat="identity",width=0.5, fill = c(brewer.pal(9, "Set1"),brewer.pal(12, "Set3")))+
    # scale_color_manual(values=c(brewer.pal(12, "Set3"), brewer.pal(3, "Set1")))+
    geom_text(stat='identity',aes(label=Freq), vjust=-0.5, size=3.5)+
    # scale_y_break(c(250,580),#截断位置及范围
    #               space = 0.3,#间距大小
    #               scales = 0.25,expand = c(0, 0), ticklabels = c(50,100,150,200,250,580,590,600)) +#上下显示比例，大于1上面比例大，小于1下面比例大
    scale_y_continuous(expand = c(0, 0), limits = c(0,500)) +
    labs(x = "",y = "显著相关的基因座数")+
    theme_bw() +
    theme(legend.position="none",
          panel.grid.major = element_blank(), # 去除主网格线
          panel.grid.minor = element_blank(),  # 去除次网格线
          panel.background = element_blank(),
          axis.text = element_text(size = 10, colour = "black", family = "sans"),
          axis.text.x = element_text(angle = 45, hjust = 1, family = "SimSun"),
          axis.text.y.right = element_blank(),
          axis.ticks.y.right = element_blank(), 
          axis.title = element_text(size = 12, family = "SimSun"))
  
}

# # 保留区域数目大于500的癌症进行绘图
# all_f = all_f[all_f$phen1%in%trait_num$Var1[trait_num$Freq>500]&all_f$phen2%in%trait_num$Var1[trait_num$Freq>500],]
all_f$pairs = paste0(all_f$phen1, "-", all_f$phen2)
all_f = as.data.frame(table(all_f$pairs))
all_f = tidyr::separate(all_f, col = "Var1", into = c("from", "to"), sep = "-")
colnames(cancer_abbrev)[1] = "from"
all_f = merge(all_f, cancer_abbrev, by = "from")
colnames(all_f)[4] = "from"
colnames(cancer_abbrev)[1] = "to"
all_f = merge(all_f[,-1], cancer_abbrev, by = "to")
colnames(all_f)[4] = "to"
all_f = all_f[,c(3,4,2)]
all_f_order = trait_num$V2
# 将from列转换为因子并按照自定义顺序排序
all_f$from = factor(all_f$from, levels = all_f_order)
all_f$to = factor(all_f$to, levels = all_f_order)
# 按from列排序后，再按to列排序
all_f_sorted = all_f %>%
  arrange(from, to)

# 创建空的弦图
circos.clear()

# 设置弦图参数
circos.par(circle.margin = c(0.4,0.4,0.4,0.4))

# 初始化弦图
# display.brewer.all()
# grid.col = unique(c(brewer.pal(12, "Paired"), brewer.pal(9, "Set1"),brewer.pal(8, "Set2"),brewer.pal(12, "Set3")))
# grid.col[grid.col=="#E31A1C"] = "#E6AB02"
grid.col = unique(c(brewer.pal(9, "Set1"),brewer.pal(12, "Set3")))
# grid.col = grid.col[order(grid.col)]
grid.col = grid.col[1:length(unique(c(all_f$from, all_f$to)))]
names(grid.col) = trait_num$V2
tmp = as.data.frame(grid.col)
colnames(tmp) = "color"
tmp$from = rownames(tmp)
all_f_sorted = dplyr::left_join(all_f_sorted[,1:3], tmp, by = "from")
chordDiagram(all_f_sorted, 
             # transparency = 0.5, 
             annotationTrack = "grid", # name显示label，grid显示扇形，c("grid", "name")同时显示
             # annotationTrackHeight = c(0.3, 0.5) # 0.3为label距离扇形的高度，0.5为扇形的径向高度
             grid.col = grid.col, 
             col = all_f$color)
# 调整name label为垂直角度
circos.trackPlotRegion(track.index = 1, panel.fun = function(x, y) {
  sector.name <- get.cell.meta.data("sector.index")
  circos.text(CELL_META$xcenter, CELL_META$ylim[1]+1.5, sector.name, 
              facing = "clockwise", niceFacing = TRUE, adj = c(0, 0.5))
}, bg.border = NA)


# 热图
all_f = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/LAVA/all_uni_filtered_bivar"))
h2 = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/ldsc/ldsc_h2_cal_sampleSize_effect_4"))
h2 = h2[(h2$h2_obs/h2$h2_se)>=2,]
trait = h2$trait
all_f = all_f[all_f$phen1%in%trait&all_f$phen2%in%trait,]
all_f$FDR = p.adjust(all_f$p, method = "BH")
all_f = all_f[all_f$FDR<0.05,]
trait = trait[order(trait)]
# ldsc聚类前的trait顺序
array1 = c("基底细胞癌", "膀胱癌", "脑膜瘤", '乳腺癌', '子宫颈癌',
           '子宫体癌', '结直肠癌', '食管癌', '胃肠道间质瘤和肉瘤',
           '头颈癌','肾癌','肺癌', '套细胞淋巴瘤', '多发性骨髓瘤',
           '卵巢癌', '前列腺癌', '皮肤鳞状细胞癌', '小肠癌',
           '皮肤黑色素瘤', '甲状腺癌', '子宫内膜癌')

# 聚类后的trait顺序
array2 = c("子宫颈癌","子宫体癌","子宫内膜癌","套细胞淋巴瘤","甲状腺癌","乳腺癌",
           "前列腺癌","胃肠道间质瘤和肉瘤","结直肠癌","膀胱癌","肺癌","肾癌","多发性骨髓瘤",
           "皮肤黑色素瘤","基底细胞癌","皮肤鳞状细胞癌","脑膜瘤","食管癌","头颈癌","卵巢癌","小肠癌")
trait = trait[match(array2,array1)]

all_f$pair = paste0(all_f$phen1,"-",all_f$phen2)
average_rg = data.frame(pair = unique(all_f$pair), rg = NA)
for(i in 1:nrow(average_rg)){
  average_rg$rg[i] = mean(all_f$rho[all_f$pair==average_rg$pair[i]])
}
average_rg = separate(average_rg, col = "pair", into = c("trait1", "trait2"))
m = matrix(nrow = length(trait),ncol = length(trait))
colnames(m) = trait
rownames(m) = trait
for(i in 1:nrow(m)){
  for(j in 1:ncol(m)){
    if(i==j){
      m[i,j]=1
    }else{
      tmp = average_rg$rg[(average_rg$trait1==rownames(m)[i]&average_rg$trait2==colnames(m)[j])|(average_rg$trait1==colnames(m)[j]&average_rg$trait2==rownames(m)[i])]
      m[i,j] = ifelse(length(tmp)==0, 0, tmp)
    }
  }
}
colnames(m) = array2
rownames(m) = colnames(m)
m[is.na(m)] = 0
data_melted <- reshape2::melt(m)

ggplot(data_melted, aes(Var2, Var1)) +
  geom_tile(aes(fill = value), color = "white", na.rm = TRUE) +
  scale_fill_gradient2(low = "#546de5", mid = "white", high = "#ff4757", midpoint = 0, limits = c(-1, 1), na.value = NA) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 13, family = "SimSun", color = "black"),
        axis.text.y = element_text(size = 13, family = "SimSun" ,color = "black"),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        panel.grid = element_blank())
