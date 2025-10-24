# # PCA分析
# # 如果通过主成分分析鉴定的前两种主成分无法区分肿瘤组织和正常组织，则排除样本
# # https://portlandpress.com/bioscirep/article/41/7/BSR20211280/229248/Identification-of-hub-genes-in-colorectal-cancer
# library(factoextra)
# library(FactoMineR)
# library(readr)
# 
# setwd("/home/yanyq/share_genetics/data/TCGA/expression_filtered/")
# # 都区分不开，不做了
# for(cancer in list.files()){
#   group = ifelse(grepl("01A",rownames(expr)), "Tumor", "Normal")
#   expr.pca = PCA(expr,graph = F)
#   # pdf(paste0("/home/yanyq/share_genetics/data/TCGA/pca/", gsub(".Rda",".pdf",cancer)), height = 5, width = 5)
#   fviz_pca_ind(expr.pca,
#                geom.ind = "point",
#                col.ind = group, 
#                addEllipses = TRUE, 
#                legend.title = "Groups")
# }

# hclust去除离群样本

setwd("/home/yanyq/share_genetics/data/TCGA/expression_filtered/")
library(WGCNA)

clust_func = function(filtered_expr){
  ### 通过样本聚类识别离群样本，去除离群样本 ###
  sampleTree = hclust(dist(filtered_expr), method = "average");#使用hclust函数进行均值聚类
  group = ifelse(grepl("01A",rownames(filtered_expr)), "Tumor", "Normal")
  sample_colors = numbers2colors(as.numeric(factor(group)),
                                 colors = rainbow(length(table(group))),
                                 signed = FALSE)
  # 绘制样本聚类图确定离群样本
  sizeGrWindow(30,9)
  # pdf(file = "figures/Step01-sampleClustering.pdf", width = 30, height = 9)
  par(cex = 0.6)
  par(mar = c(0,4,2,0))
  plot(sampleTree, main = "Sample clustering to detect outliers", sub="", xlab="", cex.lab = 1.5,
       cex.axis = 1.5, cex.main = 2)
  sampleTree
  # dev.off()
}

clust_func2 = function(filtered_expr){
  ### 通过样本聚类识别离群样本，去除离群样本 ###
  sampleTree = hclust(dist(filtered_expr), method = "average");#使用hclust函数进行均值聚类
  group = ifelse(grepl("01A",rownames(filtered_expr)), "Tumor", "Normal")
  sample_colors = numbers2colors(as.numeric(factor(group)),
                                 colors = rainbow(length(table(group))),
                                 signed = FALSE)
  plotDendroAndColors(sampleTree, sample_colors,
                      groupLabels = "Group",
                      cex.dendroLabels = 0.6,
                      marAll = c(0,4,2,0),
                      cex.rowText = 0.01,
                      main = "Sample clustering to detect outliers" )
  sampleTree
  # dev.off()
}

cancer = "BRCA.Rda"
load(cancer)

{
  sampleTree = clust_func(filtered_expr)
  # 根据上图判断，需要截取的高度参数h
  abline(h = 150, col = "red")
  # 去除离群得聚类样本
  clust = cutreeStatic(sampleTree, cutHeight = 150)
  table(clust) # 1 1179
  keepSamples = (clust==1)
  filtered_expr = filtered_expr[keepSamples, ]
  clust_func(filtered_expr)
  clust_func2(filtered_expr)
  
  # 记录基因和样本数，方便后续可视化
  nGenes = ncol(filtered_expr)#基因数
  nSamples = nrow(filtered_expr)#样本数
  save(filtered_expr, nGenes, nSamples, file = paste0("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/", cancer))
}

cancer = "BLCA.Rda"
load(cancer)

{
  sampleTree = clust_func(filtered_expr)
  abline(h = 150, col = "red")
  clust = cutreeStatic(sampleTree, cutHeight = 150)
  table(clust) # 1 421
  keepSamples = (clust==1)
  filtered_expr = filtered_expr[keepSamples, ]
  clust_func(filtered_expr)
  clust_func2(filtered_expr)
  nGenes = ncol(filtered_expr)
  nSamples = nrow(filtered_expr)
  save(filtered_expr, nGenes, nSamples, file = paste0("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/", cancer))
}

cancer = "CHOL.Rda"
load(cancer)

{
  sampleTree = clust_func(filtered_expr)
  clust_func(filtered_expr)
  clust_func2(filtered_expr)
  nGenes = ncol(filtered_expr)
  nSamples = nrow(filtered_expr)
  save(filtered_expr, nGenes, nSamples, file = paste0("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/", cancer))
}

cancer = "CRC.Rda"
load(cancer)

{
  sampleTree = clust_func(filtered_expr)
  abline(h = 140, col = "red")
  clust = cutreeStatic(sampleTree, cutHeight = 140)
  table(clust) # 3 666
  keepSamples = (clust==1)
  filtered_expr = filtered_expr[keepSamples, ]
  clust_func(filtered_expr)
  clust_func2(filtered_expr)
  nGenes = ncol(filtered_expr)
  nSamples = nrow(filtered_expr)
  save(filtered_expr, nGenes, nSamples, file = paste0("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/", cancer))
}

cancer = "ESCA.Rda"
load(cancer)

{
  sampleTree = clust_func(filtered_expr)
  abline(h = 140, col = "red")
  clust = cutreeStatic(sampleTree, cutHeight = 140)
  table(clust) # 2 184
  keepSamples = (clust==1)
  filtered_expr = filtered_expr[keepSamples, ]
  clust_func(filtered_expr)
  clust_func2(filtered_expr)
  nGenes = ncol(filtered_expr)
  nSamples = nrow(filtered_expr)
  save(filtered_expr, nGenes, nSamples, file = paste0("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/", cancer))
}

cancer = "HNSC.Rda"
load(cancer)
{
  sampleTree = clust_func(filtered_expr)
  abline(h = 160, col = "red")
  clust = cutreeStatic(sampleTree, cutHeight = 160)
  table(clust) # 2 558
  keepSamples = (clust==1)
  filtered_expr = filtered_expr[keepSamples, ]
  clust_func(filtered_expr)
  clust_func2(filtered_expr)
  nGenes = ncol(filtered_expr)
  nSamples = nrow(filtered_expr)
  save(filtered_expr, nGenes, nSamples, file = paste0("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/", cancer))
}

cancer = "kidney.Rda"
load(cancer)

{
  sampleTree = clust_func(filtered_expr)
  clust_func2(filtered_expr)
  nGenes = ncol(filtered_expr)
  nSamples = nrow(filtered_expr)
  save(filtered_expr, nGenes, nSamples, file = paste0("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/", cancer))
}

cancer = "LIHC.Rda"
load(cancer)

{
  sampleTree = clust_func(filtered_expr)
  abline(h = 140, col = "red")
  clust = cutreeStatic(sampleTree, cutHeight = 140)
  table(clust) # 5 414
  keepSamples = (clust==1)
  filtered_expr = filtered_expr[keepSamples, ]
  clust_func(filtered_expr)
  clust_func2(filtered_expr)
  nGenes = ncol(filtered_expr)
  nSamples = nrow(filtered_expr)
  save(filtered_expr, nGenes, nSamples, file = paste0("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/", cancer))
}

cancer = "lung.Rda"
load(cancer)

{
  sampleTree = clust_func(filtered_expr)
  abline(h = 140, col = "red")
  clust = cutreeStatic(sampleTree, cutHeight = 140)
  table(clust) # 3 1115
  keepSamples = (clust==1)
  filtered_expr = filtered_expr[keepSamples, ]
  clust_func(filtered_expr)
  clust_func2(filtered_expr)
  nGenes = ncol(filtered_expr)
  nSamples = nrow(filtered_expr)
  save(filtered_expr, nGenes, nSamples, file = paste0("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/", cancer))
}

cancer = "PRAD.Rda"
load(cancer)

{
  sampleTree = clust_func(filtered_expr)
  abline(h = 110, col = "red")
  clust = cutreeStatic(sampleTree, cutHeight = 110)
  table(clust) # 9 525
  keepSamples = (clust==1)
  filtered_expr = filtered_expr[keepSamples, ]
  clust_func(filtered_expr)
  clust_func2(filtered_expr)
  nGenes = ncol(filtered_expr)
  nSamples = nrow(filtered_expr)
  save(filtered_expr, nGenes, nSamples, file = paste0("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/", cancer))
}

cancer = "STAD.Rda"
load(cancer)

{
  sampleTree = clust_func(filtered_expr)
  abline(h = 140, col = "red")
  clust = cutreeStatic(sampleTree, cutHeight = 140)
  table(clust) # 11 435
  keepSamples = (clust==1)
  filtered_expr = filtered_expr[keepSamples, ]
  clust_func(filtered_expr)
  clust_func2(filtered_expr)
  nGenes = ncol(filtered_expr)
  nSamples = nrow(filtered_expr)
  save(filtered_expr, nGenes, nSamples, file = paste0("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/", cancer))
}

cancer = "THCA.Rda"
load(cancer)

{
  sampleTree = clust_func(filtered_expr)
  abline(h = 110, col = "red")
  clust = cutreeStatic(sampleTree, cutHeight = 110)
  table(clust) # 2 555
  keepSamples = (clust==1)
  filtered_expr = filtered_expr[keepSamples, ]
  clust_func(filtered_expr)
  clust_func2(filtered_expr)
  nGenes = ncol(filtered_expr)
  nSamples = nrow(filtered_expr)
  save(filtered_expr, nGenes, nSamples, file = paste0("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/", cancer))
}

cancer = "UCEC.Rda"
load(cancer)

{
  sampleTree = clust_func(filtered_expr)
  clust_func2(filtered_expr)
  nGenes = ncol(filtered_expr)
  nSamples = nrow(filtered_expr)
  save(filtered_expr, nGenes, nSamples, file = paste0("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/", cancer))
}
