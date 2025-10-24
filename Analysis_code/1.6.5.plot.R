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
local_cor = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/SUPERGNOVA/all_fdr0.05")) # 267
local_cor = local_cor[!is.na(local_cor$corr),] # 253
local_cor$color = ifelse(local_cor$corr>0,"#E41A1C", "#377EB8")
local_cor = tidyr::separate(local_cor, col = "traits", into = c("trait1", "trait2"), sep = "-")
nrow(local_cor)

locus_num = as.data.frame(table(paste0(local_cor$trait1, "-", local_cor$trait2))) # 该区域内有相关性的癌症对数，140对，共有703-37=666对
{ # 条形图：癌症对数，相关性区域数目，如88对癌症只有一个显著相关的区域，4对癌症有8个显著相关的区域
  ggplot(data=as.data.frame(table(locus_num$Freq)), mapping=aes(x=Var1,fill=Var1,y=Freq))+
    geom_bar(stat="identity",width=0.5, fill = brewer.pal(7, "Set1"))+
    # scale_color_manual(values=c(brewer.pal(12, "Set3"), brewer.pal(3, "Set1")))+
    geom_text(stat='identity',aes(label=Freq), vjust=-0.5, size=3.5)+
    
    scale_y_continuous(expand = c(0, 0), limits = c(0,100)) +
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

trait_num = as.data.frame(table(c(local_cor$trait1, local_cor$trait2))) # 基于癌症统计的显著相关区域数目
colnames(cancer_abbrev)[1] = "Var1"
trait_num = merge(trait_num, cancer_abbrev, by = "Var1")
trait_num = trait_num[order(trait_num$Freq, decreasing = T),]
# 将 Var1 转换为因子并按数据中的顺序排列
trait_num$Var1 = factor(trait_num$V2, levels = trait_num$V2)
{ # 条形图：癌症，相关性区域数目，每个表型检测到的显著双变量相关性总数
  ggplot(data=trait_num, mapping=aes(x=Var1,fill=Var1,y=Freq))+
    geom_bar(stat="identity",width=0.5, fill = "#4DAF4A")+
    # scale_color_manual(values=c(brewer.pal(12, "Set3"), brewer.pal(3, "Set1")))+
    geom_text(stat='identity',aes(label=Freq), vjust=-0.5, size=3.5)+
    scale_y_continuous(expand = c(0, 0), limits = c(0,80)) +
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


# 创建空的弦图
circos.clear()

# 设置弦图参数
circos.par(circle.margin = c(0.4,0.4,0.4,0.4))

# 初始化弦图
grid.col = unique(c(brewer.pal(9, "Set1"),brewer.pal(12, "Set3"),brewer.pal(8, "Set2"),brewer.pal(12,"Paired")))
grid.col = grid.col[1:length(unique(c(local_cor$trait1, local_cor$trait2)))]
names(grid.col) = trait_num$V2
plot_data = local_cor[,c(11,12,5,14)] %>%
  left_join(cancer_abbrev, by = c("trait1" = "Var1")) %>%
  rename(trait1_new = V2) %>%
  left_join(cancer_abbrev, by = c("trait2" = "Var1")) %>%
  rename(trait2_new = V2)
plot_data_order = trait_num$V2
# 将from列转换为因子并按照自定义顺序排序
plot_data$trait1_new = factor(plot_data$trait1_new, levels = plot_data_order)
plot_data$trait2_new = factor(plot_data$trait2_new, levels = plot_data_order)
# 按from列排序后，再按to列排序
plot_data_sorted = plot_data[,c(5,6,3,4)] %>%
  arrange(trait1_new, trait2_new, corr)
plot_data_sorted$corr = plot_data_sorted$corr/max(abs(plot_data_sorted$corr))
chordDiagram(plot_data_sorted[,c("trait1_new", "trait2_new", "corr")],
            #  transparency = 1-abs(plot_data$corr / abs(max(plot_data$corr))), # 根据数值调整颜色透明度颜色
             annotationTrack = "grid", # name显示label，grid显示扇形，c("grid", "name")同时显示
             # annotationTrackHeight = c(0.3, 0.5) # 0.3为label距离扇形的高度，0.5为扇形的径向高度
             grid.col = grid.col, 
            #  col = local_cor$color,
             col = colorRamp2(c(-1,0,1), c('#377EB8', 'white', '#E41A1C')))
# 调整name label为垂直角度
circos.trackPlotRegion(track.index = 1, panel.fun = function(x, y) {
  sector.name <- get.cell.meta.data("sector.index")
  circos.text(CELL_META$xcenter, CELL_META$ylim[1]+1.5, sector.name, 
              facing = "clockwise", niceFacing = TRUE, adj = c(0, 0.5))
}, bg.border = NA)

##########################LDSC显著trait间的局部相关性
# "CESC-lung","CORP-UCEC","CRC-HNSC","CRC-lung","ESCA-lung","OV-UCEC"有全局的遗传相关性，无局部的
ldsc = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/ldsc/ldsc_stat_sampleSize_effect_4_processed"))
ldsc = ldsc[ldsc$FDR<0.05,]
plot_data = local_cor[,c(11,12,5,14)] %>%
  left_join(cancer_abbrev, by = c("trait1" = "Var1")) %>%
  rename(trait1_new = V2) %>%
  left_join(cancer_abbrev, by = c("trait2" = "Var1")) %>%
  rename(trait2_new = V2)
plot_data = plot_data[paste0(plot_data$trait1,"-",plot_data$trait2)%in%paste0(ldsc$p1,"-",ldsc$p2),]
unique(paste0(plot_data$trait1,"-",plot_data$trait2))
plot_data_order = table(c(plot_data$trait1_new,plot_data$trait2_new))
plot_data_order = plot_data_order[order(plot_data_order, decreasing = T)]
# 将from列转换为因子并按照自定义顺序排序
plot_data$trait1_new = factor(plot_data$trait1_new, levels = names(plot_data_order))
plot_data$trait2_new = factor(plot_data$trait2_new, levels = names(plot_data_order))
# 按from列排序后，再按to列排序
plot_data_sorted = plot_data[,c(5,6,3,4)] %>%
  arrange(trait1_new, trait2_new, corr)
# 创建空的弦图
circos.clear()

# 设置弦图参数
circos.par(circle.margin = c(0.4,0.4,0.4,0.4))

# 初始化弦图
grid.col = unique(c(brewer.pal(9, "Set1"),brewer.pal(12, "Set3"),brewer.pal(8, "Set2"),brewer.pal(12,"Paired")))
grid.col = grid.col[1:length(plot_data_order)]
names(grid.col) = names(plot_data_order)
chordDiagram(plot_data_sorted[,c("trait1_new", "trait2_new", "corr")],
            #  transparency = 1-abs(plot_data$corr / abs(max(plot_data$corr))), # 根据数值调整颜色透明度颜色
             annotationTrack = "grid", # name显示label，grid显示扇形，c("grid", "name")同时显示
             # annotationTrackHeight = c(0.3, 0.5) # 0.3为label距离扇形的高度，0.5为扇形的径向高度
             grid.col = grid.col, 
            #  col = local_cor$color,
             col = colorRamp2(c(-8,0,8), c('#377EB8', 'white', '#E41A1C')))
# 调整name label为垂直角度
circos.trackPlotRegion(track.index = 1, panel.fun = function(x, y) {
  sector.name <- get.cell.meta.data("sector.index")
  circos.text(CELL_META$xcenter, CELL_META$ylim[1]+1.5, sector.name, 
              facing = "clockwise", niceFacing = TRUE, adj = c(0, 0.5))
}, bg.border = NA)
# ##########################LDSC不显著trait间的局部相关性
# ldsc = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/ldsc/ldsc_stat_sampleSize_effect_4_processed"))
# ldsc = ldsc[ldsc$FDR<0.05,]
# plot_data = local_cor[,c(11,12,5,14)] %>%
#   left_join(cancer_abbrev, by = c("trait1" = "Var1")) %>%
#   rename(trait1_new = V2) %>%
#   left_join(cancer_abbrev, by = c("trait2" = "Var1")) %>%
#   rename(trait2_new = V2)
# plot_data = plot_data[!paste0(plot_data$trait1,"-",plot_data$trait2)%in%paste0(ldsc$p1,"-",ldsc$p2),]
# unique(paste0(plot_data$trait1,"-",plot_data$trait2))
# plot_data_order = table(c(plot_data$trait1_new,plot_data$trait2_new))
# plot_data_order = plot_data_order[order(plot_data_order, decreasing = T)]
# # 将from列转换为因子并按照自定义顺序排序
# plot_data$trait1_new = factor(plot_data$trait1_new, levels = names(plot_data_order))
# plot_data$trait2_new = factor(plot_data$trait2_new, levels = names(plot_data_order))
# # 按from列排序后，再按to列排序
# plot_data_sorted = plot_data[,c(5,6,3,4)] %>%
#   arrange(trait1_new, trait2_new, corr)
# # 创建空的弦图
# circos.clear()

# # 设置弦图参数
# circos.par(circle.margin = c(0.4,0.4,0.4,0.4))

# # 初始化弦图
# grid.col = unique(c(brewer.pal(9, "Set1"),brewer.pal(12, "Set3"),brewer.pal(8, "Set2"),brewer.pal(12,"Paired")))
# grid.col = grid.col[1:length(plot_data_order)]
# names(grid.col) = names(plot_data_order)
# chordDiagram(plot_data_sorted[,c("trait1_new", "trait2_new", "corr")],
#             #  transparency = 1-abs(plot_data$corr / abs(max(plot_data$corr))), # 根据数值调整颜色透明度颜色
#              annotationTrack = "grid", # name显示label，grid显示扇形，c("grid", "name")同时显示
#              # annotationTrackHeight = c(0.3, 0.5) # 0.3为label距离扇形的高度，0.5为扇形的径向高度
#              grid.col = grid.col, 
#             #  col = local_cor$color,
#              col = colorRamp2(c(-5,0,5), c('#377EB8', 'white', '#E41A1C')))
# # 调整name label为垂直角度
# circos.trackPlotRegion(track.index = 1, panel.fun = function(x, y) {
#   sector.name <- get.cell.meta.data("sector.index")
#   circos.text(CELL_META$xcenter, CELL_META$ylim[1]+1.5, sector.name, 
#               facing = "clockwise", niceFacing = TRUE, adj = c(0, 0.5))
# }, bg.border = NA)

# 没改
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
