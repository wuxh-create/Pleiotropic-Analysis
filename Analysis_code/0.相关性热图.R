# 相关性热图
library(data.table)
library(readr)
library(ggcorrplot)
library(ggplot2)
library(pheatmap)
library(clusterProfiler)
library(showtext)
library(ape)

showtext_auto()
font_add("SimSun", "/home/yanyq/usr/share/font/simsun.ttc")  # 使用宋体（SimSun）
# font_add("Arial", "/home/yanyq/usr/share/font/arial-font/arial.ttf")    # 使用Arial

samplesize = read_tsv("/home/yanyq/share_genetics/data/sampleSize_effect_4", col_names = F)
colnames(samplesize) = c("trait", "samplesize")
# 筛选Z>2的性状，共21个
{
  h2 = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/ldsc/ldsc_h2_sampleSize_effect_4"))
  h2$trait = gsub(".log","",h2$trait)
  h2$`Total Observed scale h2` = gsub("[()]","",h2$`Total Observed scale h2`)
  h2 = tidyr::separate(h2, col = "Total Observed scale h2", into = c("h2_obs", "h2_se"), sep = " ")
  h2$h2_obs = as.numeric(h2$h2_obs)
  h2$h2_se = as.numeric(h2$h2_se)
  h2$z = h2$h2_obs/h2$h2_se
  h2$p = 1-pchisq((h2$z)^2,df=1)
  h2 = dplyr::left_join(h2, samplesize, by = "trait")
  write_tsv(h2, "/home/yanyq/share_genetics/result/ldsc/ldsc_h2_cal_sampleSize_effect_4")
  h2 = h2[(h2$h2_obs/h2$h2_se)>=2,]
}

{
  f = as.data.frame(read.table("/home/yanyq/share_genetics/result/ldsc/ldsc_stat_sampleSize_effect_4", header = T))
  f$p1 = gsub("/home/yanyq/share_genetics/result/ldsc/munge_sampleSize_effect_4_filter/","",f$p1)
  f$p1 = gsub(".sumstats.gz","",f$p1)
  f$p2 = gsub("/home/yanyq/share_genetics/result/ldsc/munge_sampleSize_effect_4_filter/","",f$p2)
  f$p2 = gsub(".sumstats.gz","",f$p2)
  f = f[seq(1,nrow(f),2),]
  # f = f[!f$p1%in%c("AML","HL","VULVA")&!f$p2%in%c("AML","HL","VULVA"),]
  f = f[f$p1%in%h2$trait&f$p2%in%h2$trait,]
  f$rg = as.numeric(f$rg)
  f$p = as.numeric(f$p)
  f$FDR = p.adjust(f$p, method = "BH")
}
write_tsv(f, "/home/yanyq/share_genetics/result/ldsc/ldsc_stat_sampleSize_effect_4_processed")

f2 = f
f2$rg[f2$p>0.05] = 0

trait = unique(c(f$p1,f$p2))
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

# # 原始rg值，多效基因座数目+相关性，未完成
# {
#   loci = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/FUMA/all_loci_num"))
#   m = matrix(nrow = length(trait),ncol = length(trait))
#   colnames(m) = trait
#   rownames(m) = trait
#   m2 = m # 矩阵m为相关性系数，m2左下三角为多效基因座数目
#   p = m
#   for(i in 1:nrow(m)){
#     for(j in 1:ncol(m)){
#       if(i==j){
#         m[i,j]=1
#         m2[i,j]=1
#       }else{
#         m[i,j] = f$rg[(f2$p1==rownames(m)[i]&f2$p2==colnames(m)[j])|(f2$p1==colnames(m)[j]&f2$p2==rownames(m)[i])]
#         if(i<j){
#           m2[i,j] = f$rg[(f$p1==rownames(m)[i]&f$p2==colnames(m)[j])|(f$p1==colnames(m)[j]&f$p2==rownames(m)[i])]
#           p[i,j] = f$p[(f$p1==rownames(m)[i]&f$p2==colnames(m)[j])|(f$p1==colnames(m)[j]&f$p2==rownames(m)[i])]
#         }else{
#           m2[i,j] = loci$V1[(loci$trait1==rownames(m)[i]&loci$trait2==colnames(m)[j])|(loci$trait1==colnames(m)[j]&loci$trait2==rownames(m)[i])]
#         }
#       }
#     }
#   }
#   colnames(m) = array2
#   rownames(m) = colnames(m)
#   colnames(m2) = colnames(m)
#   rownames(m2) = rownames(m)
#   colnames(p) = colnames(m)
#   rownames(p) = rownames(m)
#   
#   # heatmap(as.matrix(m))
#   bk = unique(c(seq(-1,0,by=0.01),seq(0,1,by=0.01)))
#   pheatmap(m,clustering_method = "complete",
#            color = c(colorRampPalette(colors = c("blue","white"))(length(bk)/2),
#                      colorRampPalette(colors = c("white","red"))(length(bk)/2)),
#            breaks=bk)
#   
#   data_melted <- reshape2::melt(m2)
#   
#   data_melted$upper <- NA
#   data_melted$lower <- NA
#   
#   for (i in 1:nrow(data_melted)) {
#     row <- data_melted[i, "Var1"]
#     col <- data_melted[i, "Var2"]
#     if (as.numeric(row) <= as.numeric(col)) {
#       data_melted[i, "upper"] <- data_melted[i, "value"]
#     } else if (as.numeric(row) > as.numeric(col)) {
#       data_melted[i, "lower"] <- data_melted[i, "value"]
#     }
#   }
#   
#   # 绘制热图
#   pdf("/home/yanyq/share_genetics/result/ldsc/相关性热图.pdf", width = 12, height = 12, family="GB1")
#   ggplot(data_melted, aes(Var2, Var1)) +
#     geom_tile(aes(fill = upper), color = "white", na.rm = TRUE) +
#     geom_text(aes(label = ifelse(is.na(lower), "", format_value(lower)), 
#                   color = ifelse(lower < 0.05 / 210, "red", 
#                                  ifelse(lower < 0.05, "orange", "black"))), 
#               na.rm = TRUE, size = 4) +
#     scale_fill_gradient2(low = "blue", mid = "white", high = "red", midpoint = 0, limits = c(-1, 1), na.value = NA) +
#     scale_color_manual(values = c("black" = "black", "orange" = "orange", "red" = "red"), guide = "none") +
#     theme_minimal() +
#     theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 13),
#           axis.text.y = element_text(size = 13),
#           axis.title.x = element_blank(),
#           axis.title.y = element_blank(),
#           panel.grid = element_blank())
#   dev.off()
# }

# 原始rg值,P值绘图
# {
#   m = matrix(nrow = length(trait),ncol = length(trait))
#   colnames(m) = trait
#   rownames(m) = trait
#   m2 = m # 矩阵m为相关性系数，m2左下三角为P值
#   for(i in 1:nrow(m)){
#     for(j in 1:ncol(m)){
#       if(i==j){
#         m[i,j]=1
#         m2[i,j]=1
#       }else{
#         m[i,j] = f$rg[(f2$p1==rownames(m)[i]&f2$p2==colnames(m)[j])|(f2$p1==colnames(m)[j]&f2$p2==rownames(m)[i])]
#         if(i<=j){
#           m2[i,j] = f$rg[(f$p1==rownames(m)[i]&f$p2==colnames(m)[j])|(f$p1==colnames(m)[j]&f$p2==rownames(m)[i])]
#         }else{
#           m2[i,j] = f$p[(f$p1==rownames(m)[i]&f$p2==colnames(m)[j])|(f$p1==colnames(m)[j]&f$p2==rownames(m)[i])]
#         }
#       }
#     }
#   }
#   colnames(m) = array2
#   rownames(m) = colnames(m)
#   colnames(m2) = colnames(m)
#   rownames(m2) = rownames(m)
#   # heatmap(as.matrix(m))
#   bk = unique(c(seq(-1,0,by=0.01),seq(0,1,by=0.01)))
#   pheatmap(m,clustering_method = "complete",
#            color = c(colorRampPalette(colors = c("blue","white"))(length(bk)/2),
#                      colorRampPalette(colors = c("white","red"))(length(bk)/2)),
#            breaks=bk)
#   
#   # 聚类
#   Tree = hclust(dist(m)) # compete方法
#   pdf("/home/yanyq/share_genetics/result/ldsc/ldsc聚类.pdf", width = 10, height = 5, family="GB1")
#   plot(Tree, main = "Sample clustering to detect outliers", sub="", xlab="", cex.lab = 1.5,
#        cex.axis = 1.5, cex.main = 1.5)
#   dev.off()
#   
#   data_melted <- reshape2::melt(m2)
#   data_melted$upper <- NA
#   data_melted$lower <- NA
# 
#   for (i in 1:nrow(data_melted)) {
#     row <- data_melted[i, "Var1"]
#     col <- data_melted[i, "Var2"]
#     if (as.numeric(row) <= as.numeric(col)) {
#       data_melted[i, "upper"] <- data_melted[i, "value"]
#     } else if (as.numeric(row) > as.numeric(col)) {
#       data_melted[i, "lower"] <- data_melted[i, "value"]
#     }
#   }
#   # 格式化数值
#   format_value <- function(value) {
#     sapply(value, function(x) {
#       if (is.na(x)) {
#         return("")
#       } else if (abs(x) < 0.01) {
#         return(format(x, scientific = TRUE, digits = 1))
#       } else {
#         return(round(x, 2))
#       }
#     })
#   }
# 
#   # 绘制热图
#   pdf("/home/yanyq/share_genetics/result/ldsc/相关性热图.pdf", width = 12, height = 12)
#   ggplot(data_melted, aes(Var2, Var1)) +
#     geom_tile(aes(fill = upper), color = "white", na.rm = TRUE) +
#     geom_text(aes(label = ifelse(is.na(lower), "", format_value(lower)),
#                   color = ifelse(lower < 0.05 / 210, "red",
#                                  ifelse(lower < 0.05, "orange", "black"))),
#               na.rm = TRUE, size = 4) +
#     scale_fill_gradient2(low = "blue", mid = "white", high = "red", midpoint = 0, limits = c(-1, 1), na.value = NA) +
#     scale_color_manual(values = c("black" = "black", "orange" = "orange", "red" = "red"), guide = "none") +
#     theme_minimal() +
#     theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 13, family = "SimSun"),
#           axis.text.y = element_text(size = 13, family = "SimSun"),
#           axis.title.x = element_blank(),
#           axis.title.y = element_blank(),
#           panel.grid = element_blank())
#   # ggsave(filename = "/home/yanyq/share_genetics/result/ldsc/相关性热图.pdf",g,width = 12, height = 12, dpi = 300 ,units = "in",device='pdf')
#   dev.off()
# }

# 原始rg值,FDR绘图
{
  m = matrix(nrow = length(trait),ncol = length(trait))
  colnames(m) = trait
  rownames(m) = trait
  m2 = m # 矩阵m为相关性系数，m2左下三角为P值
  for(i in 1:nrow(m)){
    for(j in 1:ncol(m)){
      if(i==j){
        m[i,j]=1
        m2[i,j]=1
      }else{
        m[i,j] = f$rg[(f2$p1==rownames(m)[i]&f2$p2==colnames(m)[j])|(f2$p1==colnames(m)[j]&f2$p2==rownames(m)[i])]
        if(i<=j){
          m2[i,j] = f$rg[(f$p1==rownames(m)[i]&f$p2==colnames(m)[j])|(f$p1==colnames(m)[j]&f$p2==rownames(m)[i])]
        }else{
          m2[i,j] = f$FDR[(f$p1==rownames(m)[i]&f$p2==colnames(m)[j])|(f$p1==colnames(m)[j]&f$p2==rownames(m)[i])]
        }
      }
    }
  }
  colnames(m) = array2
  rownames(m) = colnames(m)
  colnames(m2) = colnames(m)
  rownames(m2) = rownames(m)
  # heatmap(as.matrix(m))
  bk = unique(c(seq(-1,0,by=0.01),seq(0,1,by=0.01)))
  pheatmap(m,clustering_method = "complete",
           color = c(colorRampPalette(colors = c("blue","white"))(length(bk)/2),
                     colorRampPalette(colors = c("white","red"))(length(bk)/2)),
           breaks=bk)

  # 聚类
  Tree = hclust(dist(m)) # compete方法
  pdf("/home/yanyq/share_genetics/result/ldsc/ldsc聚类.pdf", width = 10, height = 5, family="GB1")
  plot(Tree, main = "Sample clustering to detect outliers", sub="", xlab="", cex.lab = 1.5,
       cex.axis = 1.5, cex.main = 1.5)
  dev.off()

  data_melted <- reshape2::melt(m2)
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
  # 格式化数值
  format_value <- function(value) {
    sapply(value, function(x) {
      if (is.na(x)) {
        return("")
      } else if (abs(x) < 0.01) {
        return(format(x, scientific = TRUE, digits = 1))
      } else {
        return(round(x, 2))
      }
    })
  }

  # 绘制热图
  pdf("/home/yanyq/share_genetics/result/ldsc/相关性热图.pdf", width = 12, height = 12)
  ggplot(data_melted, aes(Var2, Var1)) +
    geom_tile(aes(fill = upper), color = "white", na.rm = TRUE) +
    geom_text(aes(label = ifelse(is.na(lower), "", format_value(lower)),
                  color = ifelse(lower < 0.05 , "red",
                                 ifelse(lower < 0.2052, "orange", "black"))),
              na.rm = TRUE, size = 4) +
    scale_fill_gradient2(low = "#546de5", mid = "white", high = "#ff4757", midpoint = 0, limits = c(-1, 1), na.value = NA) +
    scale_color_manual(values = c("black" = "black", "orange" = "orange", "red" = "red"), guide = "none") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 13, family = "SimSun", color = "black"),
          axis.text.y = element_text(size = 13, family = "SimSun" ,color = "black"),
          axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          panel.grid = element_blank())
  # ggsave(filename = "/home/yanyq/share_genetics/result/ldsc/相关性热图.pdf",g,width = 12, height = 12, dpi = 300 ,units = "in",device='pdf')
  dev.off()
}

# P为0的rg为0
{
  m = matrix(nrow = length(trait),ncol = length(trait))
  colnames(m) = trait
  rownames(m) = trait
  for(i in 1:nrow(m)){
    for(j in 1:ncol(m)){
      if(i==j){
        m[i,j]=1
      }else{
        m[i,j] = f2$rg[(f2$p1==rownames(m)[i]&f2$p2==colnames(m)[j])|(f2$p1==colnames(m)[j]&f2$p2==rownames(m)[i])]
        # if(i<=j){
        #   m[i,j] = f2$rg[(f$p1==rownames(m)[i]&f$p2==colnames(m)[j])|(f$p1==colnames(m)[j]&f$p2==rownames(m)[i])]
        # }else{
        #   m[i,j] = f2$p[(f$p1==rownames(m)[i]&f$p2==colnames(m)[j])|(f$p1==colnames(m)[j]&f$p2==rownames(m)[i])]
        # }
      }
    }
  }
  colnames(m) = array2
  
  rownames(m) = colnames(m)
  heatmap(as.matrix(m))
  library(pheatmap)
  bk <- c(seq(-1,0,by=0.01),seq(0,1,by=0.01))
  bk = unique(bk)
  # 做热图：
  pheatmap(m,clustering_method = "complete",
           color = c(colorRampPalette(colors = c("blue","white"))(length(bk)/2),colorRampPalette(colors = c("white","red"))(length(bk)/2)),
           breaks=bk)
  ggcorrplot(m,lab=T)
  
  # 将数据转化为数据框格式，方便ggplot2使用
  data_melted <- reshape2::melt(m)
  
  data_melted$upper_diag <- NA
  data_melted$lower <- NA
  
  for (i in 1:nrow(data_melted)) {
    row <- data_melted[i, "Var1"]
    col <- data_melted[i, "Var2"]
    if (as.numeric(row) <= as.numeric(col)) {
      data_melted[i, "upper_diag"] <- data_melted[i, "value"]
    } else if (as.numeric(row) > as.numeric(col)) {
      data_melted[i, "lower"] <- data_melted[i, "value"]
    }
  }
  
  # 绘制热图
  ggplot(data_melted, aes(Var2, Var1)) +
    geom_tile(aes(fill = upper_diag), color = "white", na.rm = TRUE) +
    geom_text(aes(label = ifelse(is.na(lower), "", round(lower, 2))), na.rm = TRUE, size = 3) +
    scale_fill_gradient(low = "white", high = "red", na.value = NA) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1),
          axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          panel.grid = element_blank())
}

# colnames(m) = c("骨和关节软骨恶性肿瘤","基底细胞癌",'脑胶质母细胞瘤和星形细胞瘤',
#                 '胆道癌',"膀胱癌", "脑膜瘤", '乳腺癌', '子宫颈癌','慢性粒细胞白血病',
#                 '子宫体癌', '结直肠癌','弥漫性大B细胞淋巴瘤', '食管癌','眼部及附件恶性肿瘤',
#                 '胃肠道间质瘤和肉瘤','头颈癌','肾癌','肝癌','淋巴细胞白血病',
#                 '肺癌', '套细胞淋巴瘤','间皮瘤', '多发性骨髓瘤',
#                 '骨髓增生异常综合征','边缘区 B 细胞淋巴瘤',
#                 '卵巢癌','胰腺癌', '前列腺癌', '皮肤鳞状细胞癌', '小肠癌',
#                 '皮肤黑色素瘤', '胃癌','睾丸癌',
#                 '甲状腺癌', '子宫内膜癌')
                                






m = matrix(nrow = 10,ncol = 10)
colnames(m) = c("乳腺癌", '前列腺癌', '卵巢癌', '子宫内膜癌','肺癌','皮肤黑色素瘤','头颈癌','膀胱癌','胰腺癌','肾癌')
rownames(m) = c("乳腺癌", '前列腺癌', '卵巢癌', '子宫内膜癌','肺癌','皮肤黑色素瘤','头颈癌','膀胱癌','胰腺癌','肾癌')
suoxie = matrix(data = colnames(m),ncol = 2,nrow = 10)
suoxie[,2] = c("BRCA","PRAD","OV","UCEC","lung","SKCM","HNSC","BLCA", "PAAD",  "kidney")
for(i in 1:nrow(m)){
  for(j in 1:ncol(m)){
    if(i==j){
      m[i,j]=1
    }else{
      p1 = suoxie[i,2]
      p2 = suoxie[j,2]
      m[i,j] = f$rg[(f$p1==p1&f$p2==p2)|(f$p1==p2&f$p2==p1)]
    }
  }
}
m = apply(m,2,as.numeric)
rownames(m) = colnames(m)

library(ggcorrplot)
ggcorrplot(m,lab=T)
library(export)
graph2pdf(file="~/tmp.pdf",font="GB1")
