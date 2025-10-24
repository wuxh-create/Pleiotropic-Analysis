# hclust去除离群样本

setwd("/home/yanyq/share_genetics/data/TCGA/expression_filtered/")
library(WGCNA)

clust_func = function(filtered_expr){
  ### 通过样本聚类识别离群样本，去除离群样本 ###
  sampleTree = hclust(dist(filtered_expr), method = "average");#使用hclust函数进行均值聚类
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

cancer = "BRCA.Rda"
load(cancer)

{
  sampleTree = clust_func(filtered_expr)
  # 根据上图判断，需要截取的高度参数h
  abline(h = 150, col = "red")
  # 去除离群得聚类样本
  clust = cutreeStatic(sampleTree, cutHeight = 150)
  table(clust) # 1 1080
  keepSamples = (clust==1)
  filtered_expr = filtered_expr[keepSamples, ]
  clust_func(filtered_expr)
  
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
  table(clust) # 1 402
  keepSamples = (clust==1)
  filtered_expr = filtered_expr[keepSamples, ]
  clust_func(filtered_expr)
  nGenes = ncol(filtered_expr)
  nSamples = nrow(filtered_expr)
  save(filtered_expr, nGenes, nSamples, file = paste0("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/", cancer))
}

cancer = "CESC.Rda"
load(cancer)

{
  sampleTree = clust_func(filtered_expr)
  abline(h = 150, col = "red")
  clust = cutreeStatic(sampleTree, cutHeight = 150)
  table(clust) # 1 295
  keepSamples = (clust==1)
  filtered_expr = filtered_expr[keepSamples, ]
  clust_func(filtered_expr)
  nGenes = ncol(filtered_expr)
  nSamples = nrow(filtered_expr)
  save(filtered_expr, nGenes, nSamples, file = paste0("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/", cancer))
}

cancer = "CHOL.Rda"
load(cancer)

{
  sampleTree = clust_func(filtered_expr)
  abline(h = 140, col = "red")
  clust = cutreeStatic(sampleTree, cutHeight = 140)
  table(clust) # 35 0
  keepSamples = !rownames(filtered_expr)%in%c("TCGA-W5-AA2H-01A","TCGA-W5-AA2X-01A")
  filtered_expr = filtered_expr[keepSamples, ]
  clust_func(filtered_expr)
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
  table(clust) # 3 615
  keepSamples = (clust==1)
  filtered_expr = filtered_expr[keepSamples, ]
  clust_func(filtered_expr)
  nGenes = ncol(filtered_expr)
  nSamples = nrow(filtered_expr)
  save(filtered_expr, nGenes, nSamples, file = paste0("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/", cancer))
}

cancer = "DLBC.Rda"
load(cancer)

{
  sampleTree = clust_func(filtered_expr)
  abline(h = 120, col = "red")
  clust = cutreeStatic(sampleTree, cutHeight = 120)
  table(clust) # 47 0
  keepSamples = !rownames(filtered_expr)%in%c("TCGA-FF-A7CW-01A")
  filtered_expr = filtered_expr[keepSamples, ]
  clust_func(filtered_expr)
  nGenes = ncol(filtered_expr)
  nSamples = nrow(filtered_expr)
  save(filtered_expr, nGenes, nSamples, file = paste0("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/", cancer))
}

cancer = "HNSC.Rda"
load(cancer)

{
  sampleTree = clust_func(filtered_expr)
  abline(h = 140, col = "red")
  clust = cutreeStatic(sampleTree, cutHeight = 140)
  table(clust) # 2 513
  keepSamples = (clust==1)
  filtered_expr = filtered_expr[keepSamples, ]
  clust_func(filtered_expr)
  nGenes = ncol(filtered_expr)
  nSamples = nrow(filtered_expr)
  save(filtered_expr, nGenes, nSamples, file = paste0("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/", cancer))
}

cancer = "kidney.Rda"
load(cancer)

{
  sampleTree = clust_func(filtered_expr)
  # abline(h = 180, col = "red")
  # clust = cutreeStatic(sampleTree, cutHeight = 180)
  # table(clust) # 0 884
  # keepSamples = (clust==1)
  # filtered_expr = filtered_expr[keepSamples, ]
  # clust_func(filtered_expr)
  nGenes = ncol(filtered_expr)
  nSamples = nrow(filtered_expr)
  save(filtered_expr, nGenes, nSamples, file = paste0("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/", cancer))
}

cancer = "LAML.Rda"
load(cancer)

{
  sampleTree = clust_func(filtered_expr)
  abline(h = 140, col = "red")
  clust = cutreeStatic(sampleTree, cutHeight = 140)
  table(clust) # 1 136
  keepSamples = (clust==1)
  filtered_expr = filtered_expr[keepSamples, ]
  clust_func(filtered_expr)
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
  table(clust) # 5 364
  keepSamples = (clust==1)
  filtered_expr = filtered_expr[keepSamples, ]
  clust_func(filtered_expr)
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
  table(clust) # 3 1006
  keepSamples = (clust==1)
  filtered_expr = filtered_expr[keepSamples, ]
  clust_func(filtered_expr)
  nGenes = ncol(filtered_expr)
  nSamples = nrow(filtered_expr)
  save(filtered_expr, nGenes, nSamples, file = paste0("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/", cancer))
}

cancer = "OV.Rda"
load(cancer)

{
  sampleTree = clust_func(filtered_expr)
  # abline(h = 125, col = "red")
  # clust = cutreeStatic(sampleTree, cutHeight = 125)
  # table(clust) # 3 398
  # keepSamples = (clust==1)
  # filtered_expr = filtered_expr[keepSamples, ]
  # clust_func(filtered_expr)
  nGenes = ncol(filtered_expr)
  nSamples = nrow(filtered_expr)
  save(filtered_expr, nGenes, nSamples, file = paste0("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/", cancer))
}

cancer = "PAAD.Rda"
load(cancer)

{
  sampleTree = clust_func(filtered_expr)
  # abline(h = 150, col = "red")
  # clust = cutreeStatic(sampleTree, cutHeight = 150)
  # table(clust) # 15 163
  # keepSamples = (clust==1)
  # filtered_expr = filtered_expr[keepSamples, ]
  # clust_func(filtered_expr)
  nGenes = ncol(filtered_expr)
  nSamples = nrow(filtered_expr)
  save(filtered_expr, nGenes, nSamples, file = paste0("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/", cancer))
}

cancer = "PRAD.Rda"
load(cancer)

{
  sampleTree = clust_func(filtered_expr)
  abline(h = 120, col = "red")
  clust = cutreeStatic(sampleTree, cutHeight = 120)
  table(clust) # 1 482
  keepSamples = (clust==1)
  filtered_expr = filtered_expr[keepSamples, ]
  clust_func(filtered_expr)
  nGenes = ncol(filtered_expr)
  nSamples = nrow(filtered_expr)
  save(filtered_expr, nGenes, nSamples, file = paste0("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/", cancer))
}

cancer = "SARC.Rda"
load(cancer)

{
  sampleTree = clust_func(filtered_expr)
  abline(h = 140, col = "red")
  clust = cutreeStatic(sampleTree, cutHeight = 140)
  table(clust) # 1 257
  keepSamples = (clust==1)
  filtered_expr = filtered_expr[keepSamples, ]
  clust_func(filtered_expr)
  nGenes = ncol(filtered_expr)
  nSamples = nrow(filtered_expr)
  save(filtered_expr, nGenes, nSamples, file = paste0("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/", cancer))
}

cancer = "SKCM.Rda"
load(cancer)

{
  sampleTree = clust_func(filtered_expr)
  abline(h = 130, col = "red")
  clust = cutreeStatic(sampleTree, cutHeight = 130)
  table(clust) # 1 102
  keepSamples = (clust==1)
  filtered_expr = filtered_expr[keepSamples, ]
  clust_func(filtered_expr)
  nGenes = ncol(filtered_expr)
  nSamples = nrow(filtered_expr)
  save(filtered_expr, nGenes, nSamples, file = paste0("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/", cancer))
}

cancer = "STAD.Rda"
load(cancer)

{
  sampleTree = clust_func(filtered_expr)
  abline(h = 135, col = "red")
  clust = cutreeStatic(sampleTree, cutHeight = 135)
  table(clust) # 3 407
  keepSamples = (clust==1)
  filtered_expr = filtered_expr[keepSamples, ]
  clust_func(filtered_expr)
  nGenes = ncol(filtered_expr)
  nSamples = nrow(filtered_expr)
  save(filtered_expr, nGenes, nSamples, file = paste0("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/", cancer))
}

cancer = "THYM.Rda"
load(cancer)

{
  sampleTree = clust_func(filtered_expr)
  abline(h = 150, col = "red")
  clust = cutreeStatic(sampleTree, cutHeight = 150)
  table(clust) # 5 115
  keepSamples = (clust==1)
  filtered_expr = filtered_expr[keepSamples, ]
  clust_func(filtered_expr)
  nGenes = ncol(filtered_expr)
  nSamples = nrow(filtered_expr)
  save(filtered_expr, nGenes, nSamples, file = paste0("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/", cancer))
}

cancer = "UCEC.Rda"
load(cancer)

{
  sampleTree = clust_func(filtered_expr)
  # abline(h = 150, col = "red")
  # clust = cutreeStatic(sampleTree, cutHeight = 150)
  # table(clust) # 3 536
  # keepSamples = (clust==1)
  # filtered_expr = filtered_expr[keepSamples, ]
  # clust_func(filtered_expr)
  nGenes = ncol(filtered_expr)
  nSamples = nrow(filtered_expr)
  save(filtered_expr, nGenes, nSamples, file = paste0("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/", cancer))
}
