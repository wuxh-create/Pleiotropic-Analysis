# 全局和局部的遗传相关性绘图
# 相关性热图
library(data.table)
library(readr)
library(ggcorrplot)
library(ggplot2)
library(pheatmap)
library(clusterProfiler)
library(showtext)
library(ape)
library(tidyr)
{
  showtext_auto()
  font_add("SimSun", "/home/yanyq/usr/share/font/simsun.ttc")  # 使用宋体（SimSun）
  # font_add("Arial", "/home/yanyq/usr/share/font/arial-font/arial.ttf")    # 使用Arial
  
  samplesize = read_tsv("/home/yanyq/share_genetics/data/sampleSize_effect_4", col_names = F)
  colnames(samplesize) = c("trait", "samplesize")
  
  # 筛选Z>2的性状，共21个，出去子宫体癌，有20个,190对
  h2 = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/ldsc/ldsc_h2_cal_sampleSize_effect_4"))
  h2 = h2[(h2$h2_obs/h2$h2_se)>=2,]
  h2 = h2[h2$trait!="CORP",]
  # LDSC计算的全局遗传相关性，190对
  global_cor = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/ldsc/ldsc_stat_sampleSize_effect_4_processed"))
  global_cor = global_cor[global_cor$p1!="CORP"&global_cor$p2!="CORP",]
  length(which(global_cor$p<0.05)) # 44对
  length(which(global_cor$FDR<0.05)) # 18对

# {
#   # 计算平均局部遗传相关性
#   # 1. 不经过双变量P值筛选
#   # 2. 用P<0.05筛选
#   # 3. 在每一对癌症中矫正，用FDR<0.05筛选
#   # 4. 在所有癌症中矫正，用FDR<0.05筛选
#   local_cor = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/LAVA/all_uni_filtered_bivar"))
#   # local_cor = local_cor[local_cor$p<0.05,] # 2
#   local_cor$FDR = p.adjust(local_cor$p, method = "BH") # 4
#   local_cor$traits = paste0(local_cor$phen1, "-", local_cor$phen2)
#   local_cor_mean = data.frame(traits = unique(local_cor$traits), rho = NA, sig_loci_num = NA)
#   for(i in 1:nrow(local_cor_mean)){
#     tmp_local_cor = local_cor[local_cor$traits==local_cor_mean$traits[i],]
#     # tmp_local_cor$FDR = p.adjust(tmp_local_cor$p, method = "BH") # 3
#     tmp_local_cor = tmp_local_cor[tmp_local_cor$FDR<0.05,]
#     local_cor_mean$rho[i] = ifelse(nrow(tmp_local_cor)>0, mean(tmp_local_cor$rho), 0)
#     local_cor_mean$sig_loci_num[i] = nrow(tmp_local_cor)
#     
#   }
#   local_cor_mean = separate(local_cor_mean, traits, into = c("p1", "p2"), sep = "-")
# }

  local_cor = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/SUPERGNOVA/all"))
  local_cor_mean = data.frame(traits = unique(local_cor$traits), corr = NA, sig_loci_num = NA)
  for(i in 1:nrow(local_cor_mean)){
    tmp_local_cor = local_cor[local_cor$traits==local_cor_mean$traits[i],]
    local_cor_mean$corr[i] = ifelse(nrow(tmp_local_cor)>0, mean(tmp_local_cor$corr), 0)
    local_cor_mean$sig_loci_num[i] = nrow(tmp_local_cor[tmp_local_cor$FDR<0.05,])
  }
  
  length(unique(paste0(global_cor$p1,"-",global_cor$p2))) # 190
  local_cor_mean = local_cor_mean[local_cor_mean$traits%in%paste0(global_cor$p1,"-",global_cor$p2),]
  local_cor_mean = separate(local_cor_mean, traits, into = c("p1", "p2"), sep = "-") 
  sum(local_cor_mean$sig_loci_num) # 267
  length(unique(paste0(local_cor_mean$p1[local_cor_mean$sig_loci_num>0],"-",local_cor_mean$p2[local_cor_mean$sig_loci_num>0]))) # 91
  
  global_sig_trait = unique(paste0(global_cor$p1[global_cor$FDR<0.05],"-",global_cor$p2[global_cor$FDR<0.05]))
  local_sig_trait = unique(paste0(local_cor_mean$p1[local_cor_mean$sig_loci_num>0],"-",local_cor_mean$p2[local_cor_mean$sig_loci_num>0]))
  length(global_sig_trait[global_sig_trait%in%local_sig_trait])
  global_sig_trait[!global_sig_trait%in%local_sig_trait]
  
  # 全局和局部相关性计算一致性
  tmp1 = global_cor
  tmp1$trait = paste0(tmp1$p1,"-",tmp1$p2)
  tmp2 = local_cor_mean
  tmp2$trait = paste0(tmp2$p1,"-",tmp2$p2)
  tmp = merge(tmp1,tmp2,by = "trait")
  cor(tmp$rg,tmp$corr, method = "spearman")
  cor.test(tmp$rg,tmp$corr, method = "spearman")
  
  # tmp$absrg = abs(tmp$rg)
  # tmp[tmp$absrg<0.01,] # BCC-GSS/BLCA-SKCM/MCL-PRAD
  # tmp = tmp[tmp$absrg<0.1&tmp$sig_loci_num!=0,]
  # t = local_cor[(local_cor$traits=="ESCA-PRAD")&local_cor$FDR<0.05,]
  # gene_loc = as.data.frame(read.table("/home/yanyq/share_genetics/data/MAGMA/NCBI37.3/NCBI37.3.gene.loc"))
  # gene_loc$region = paste0(gene_loc$V2,":",gene_loc$V3,"-",gene_loc$V4)
  # library(GenomicRanges)
  # t_GR = as(t$region,"GRanges")
  # gene_GR = as(gene_loc$region,"GRanges")
  # ov = findOverlaps(t_GR,gene_GR)
  # for(i in 1:8){
  #   t$gene[i] = paste(gene_loc$V6[ov@to[ov@from==i]],collapse = ",")
  # }
  # ov@from==1
  # 
  # tmp = local_cor[(local_cor$traits=="BCC-GSS"|local_cor$traits=="BLCA-SKCM"|local_cor$traits=="MCL-PRAD")&local_cor$FDR<0.05,]
  # 
  # # 显著的全局遗传相关性，相关性越高，局部数目越多
  # tmp = tmp[tmp$FDR<0.05,]
  # x = order(abs(tmp$rg))
  # y = order(abs(tmp$sig_loci_num))
  # plot(x,y)
  # cor(x,y)
  
  trait = unique(c(global_cor$p1,global_cor$p2))
  trait = trait[order(trait)]
  # ldsc聚类前的trait顺序
  array1 = c("皮肤基底细胞癌", "膀胱癌", "脑膜瘤", '乳腺癌', '子宫颈癌',
             '结直肠癌', '食管癌', '胃肠道间质瘤和肉瘤',
             '头颈癌','肾癌','肺癌', '套细胞淋巴瘤', '多发性骨髓瘤',
             '卵巢癌', '前列腺癌', '皮肤鳞状细胞癌', '小肠癌',
             '皮肤黑色素瘤', '甲状腺癌', '子宫内膜癌')
  
  # 聚类后的trait顺序
  array2 = c("套细胞淋巴瘤","甲状腺癌","子宫内膜癌","卵巢癌","膀胱癌",
             "肺癌","结直肠癌","食管癌","子宫颈癌","乳腺癌","前列腺癌",
             "肾癌","多发性骨髓瘤","皮肤黑色素瘤","皮肤基底细胞癌","皮肤鳞状细胞癌",
             "胃肠道间质瘤和肉瘤","脑膜瘤","头颈癌","小肠癌")
  trait = trait[match(array2,array1)]
  
  m = matrix(nrow = length(trait),ncol = length(trait))
  colnames(m) = trait
  rownames(m) = trait
  m_clust = m
  # 显示的label
  label = matrix(nrow = length(trait),ncol = length(trait))
  colnames(label) = trait
  rownames(label) = trait
  for(i in 1:nrow(m)){
    for(j in 1:ncol(m)){
      if(i==j){
        m[i,j]=1
        m_clust[i,j] = 1
        label[i,j] = " "
      }else{
        m_clust[i,j] = global_cor$rg[(global_cor$p1==rownames(m)[i]&global_cor$p2==colnames(m)[j])|(global_cor$p1==colnames(m)[j]&global_cor$p2==rownames(m)[i])]
        if(i<=j){
          flag = (global_cor$p1==rownames(m)[i]&global_cor$p2==colnames(m)[j])|(global_cor$p1==colnames(m)[j]&global_cor$p2==rownames(m)[i])
          m[i,j] = global_cor$rg[flag]
          label[i,j] = ifelse(global_cor$p[flag]>0.05," ",ifelse(global_cor$FDR[flag]>0.05, "*","**"))
        }else{
          flag = (local_cor_mean$p1==rownames(m)[i]&local_cor_mean$p2==colnames(m)[j])|(local_cor_mean$p1==colnames(m)[j]&local_cor_mean$p2==rownames(m)[i])
          if(any(flag)){
            m[i,j] = local_cor_mean$corr[flag]
            label[i,j] = local_cor_mean$sig_loci_num[flag]
          }else{
            m[i,j] = 0
            label[i,j] = 0
          }
        }
      }
    }
  }
  label[label==0] = " "
  colnames(m) = array2
  rownames(m) = colnames(m)
  colnames(label) = array2
  rownames(label) = colnames(label)
  colnames(m_clust) = array2
  rownames(m_clust) = colnames(m_clust)
  for(i in 1:nrow(m)){
    for(j in 1:ncol(m)){
      if((label[i,j]=="**"&label[j,i]!=" ")|(label[i,j]!=" "&(label[j,i]=="**"|label[j,i]=="(**)"))){
        label[i,j] = paste0("(",label[i,j],")")
      }
    }
  }
  
}
Tree = hclust(dist(m_clust)) # compete方法
plot(Tree, main = "Sample clustering to detect outliers", sub="", xlab="", cex.lab = 1.2,
     cex.axis = 1.2, cex.main = 1.2)
{
  library(ggplot2)
  corr = m
  ggtheme = ggplot2::theme_minimal
  lab = T # 显示label
  tl.srt = 90 # 横坐标倾斜
  tl.cex = 10 # 字体大小
  title = "" # 标题
  show.legend = TRUE # 展示图例
  
  legend.title = "相关性"
  colors = c("#377EB8","white", "#E41A1C")
  outline.color = "gray"
 
  
  lab_col = "black"
  lab_size = 4

  as.is = FALSE
}


{
  corr <- as.matrix(corr)
  corr_melted <- reshape2::melt(corr, na.rm = TRUE, as.is = as.is)
  
  # # 上三角和下三角取值范围不一样时
  # {
  #   corr_melted$upper <- NA
  #   corr_melted$lower <- NA
  #   
  #   for (i in 1:nrow(corr_melted)) {
  #     row <- corr_melted[i, "Var1"]
  #     col <- corr_melted[i, "Var2"]
  #     if (as.numeric(row) <= as.numeric(col)) {
  #       corr_melted[i, "upper"] <- (corr_melted[i, "value"]+1)/2 # 将 [-1, 1] 范围的值转换到 [0, 1]
  #     } else if (as.numeric(row) > as.numeric(col)) {
  #       corr_melted[i, "lower"] <- (corr_melted[i, "value"]+1)/2
  #     }
  #   }
  #   # 手动设置颜色，0,1为最大和最小值
  #   cut_upper = cut(c(0, 1, corr_melted$upper[!is.na(corr_melted$upper)]), breaks = 100, labels = FALSE)
  #   cut_lower = cut(c(0, 1, corr_melted$lower[!is.na(corr_melted$lower)]), breaks = 100, labels = FALSE)
  #   corr_melted$fill <- NA
  #   corr_melted$fill[!is.na(corr_melted$lower)] <- lower_colors[cut_lower[-(1:2)]]
  #   corr_melted$fill[!is.na(corr_melted$upper)] <- upper_colors[cut_upper[-(1:2)]]
  #   
  #   # 热图
  #   ggplot(corr_melted, aes(x = Var2, y = Var1)) +
  #     geom_tile(aes(fill = fill)) +
  #     # geom_text(aes(label = value), color = "black", size = 3) +
  #     scale_fill_identity() +
  #     theme_minimal() +
  #     theme(axis.text.x = element_text(angle = tl.srt, size = tl.cex, color = "black", hjust = 1, vjust = 1),
  #           axis.text.y = element_text(size = tl.cex, color = "black"),
  #           axis.title = element_blank(),
  #           panel.grid = element_blank())
  # }

  label <- as.matrix(label)
  label <- reshape2::melt(label, na.rm = TRUE, as.is = as.is)
  colnames(label) <- c("Var1", "Var2", "value")
  
  
  p <- ggplot(data = corr_melted, mapping = aes_string(x = "Var1",
                                                       y = "Var2", fill = "value")) + 
    geom_tile(color = outline.color, width = 1:nrow(corr_melted), height = 1:nrow(corr_melted)) +
    # 设置颜色
    scale_fill_gradient2(low = colors[1], high = colors[3], 
                         mid = colors[2], midpoint = 0, limit = c(-1, 1), space = "Lab", 
                         name = legend.title) + 
    ggtheme() + 
    theme(
      axis.text.x = element_text(angle = tl.srt, vjust = 1, size = tl.cex, hjust = 1, color = "black", family = "SimSun"), 
      axis.text.y = element_text(size = tl.cex, color = "black", family = "SimSun"), 
      axis.title = element_blank(),
      legend.title = element_text(family = "SimSun",vjust = 2,size = tl.cex), 
    ) + 
    coord_fixed()
  p

  
  # 标签
  label <- label[, "value"]
  if (lab) {
    p <- p + geom_text(mapping = aes_string(x = "Var1",
                                            y = "Var2"), label = label, color = lab_col, size = lab_size, family = "Arial")
  }
  p
  # 标题
  if (title != "") {
    p <- p + ggtitle(title)
  }
  # 图例
  if (!show.legend) {
    p <- p + ggplot2::theme(legend.position = "none")
  }
  # p <- p + .no_panel()
  p
}
pdf(file = "/home/yanyq/share_genetics/final_result/plot/1.LDSC_SUPERGNOVA.pdf", height = 8, width = 8)
p
dev.off()
png(file = "/home/yanyq/share_genetics/final_result/plot/1.LDSC_SUPERGNOVA.png", height = 600, width = 600)
p
dev.off()
