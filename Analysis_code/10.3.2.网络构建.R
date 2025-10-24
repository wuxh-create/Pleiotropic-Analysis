setwd("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/")
library(WGCNA)
library(gplots)
for(cancer in list.files()){
  load(cancer)
  load(paste0("/home/yanyq/share_genetics/result/WGCNA/sft/", cancer))
  enableWGCNAThreads(nThreads = 20)  #开启多线程
  
  # 无尺度网络检验，验证构建的网络是否是无尺度网络
  softpower=sft$powerEstimate
  ADJ = abs(cor(filtered_expr,use="p"))^softpower#相关性取绝对值再幂次
  # ADJ = softConnectivity(filtered_expr,power=softpower)-1
  k = as.vector(apply(ADJ,2,sum,na.rm=T))#对ADJ的每一列取和，也就是频次
  
  ### 一步构建网络 ###
  net = blockwiseModules(filtered_expr, #处理好的表达矩阵
                         power = sft$powerEstimate,#选择的软阈值
                         TOMType = "unsigned", #拓扑矩阵类型，none表示邻接矩阵聚类，unsigned最常用，构建无方向
                         minModuleSize = 30,#网络模块包含的最少基因数
                         reassignThreshold = 0, #模块间基因重分类的阈值
                         mergeCutHeight = 0.25,#合并相异度低于0.25的模块
                         numericLabels = TRUE, #true，返回模块的数字标签 false返回模块的颜色标签
                         pamRespectsDendro = FALSE,#调用动态剪切树算法识别网络模块后，进行第二次的模块比较，合并相关性高的模块
                         saveTOMs = TRUE,#保存拓扑矩阵
                         saveTOMFileBase = paste0("/home/yanyq/share_genetics/result/WGCNA/fpkmTOM/", gsub(".Rda","",cancer)),
                         verbose = 3)#0，不反回任何信息，＞0返回计算过程
  # 保存网络构建结果
  save(net, file = paste0("/home/yanyq/share_genetics/result/WGCNA/one_step_net/", cancer))
  
  # # 加载网络构建结果
  # load(file = paste0("/home/yanyq/share_genetics/result/WGCNA/one_step_net/", cancer))
  # 打开绘图窗口
  pdf(file = paste0("/home/yanyq/share_genetics/result/WGCNA/moduleCluster/", gsub(".Rda", "", cancer), ".pdf"), width = 12, height = 9);
  # 将标签转化为颜色
  mergedColors = labels2colors(net$colors)
  # 绘制聚类和网络模块对应图
  plotDendroAndColors(dendro = net$dendrograms[[1]], #hclust函数生成的聚类结果
                      colors = mergedColors[net$blockGenes[[1]]],#基因对应的模块颜色
                      groupLabels = "Module colors",#分组标签
                      dendroLabels = FALSE, #false,不显示聚类图的每个分支名称
                      hang = 0.03,#调整聚类图分支所占的高度
                      addGuide = TRUE, #为聚类图添加辅助线
                      guideHang = 0.05,#辅助线所在高度
                      main = "Gene dendrogram and module colors")
  dev.off()
  
  # 加载TOM矩阵
  load(paste0("/home/yanyq/share_genetics/result/WGCNA/fpkmTOM/", gsub(".Rda","",cancer), "-block.1.RData"))
  # 网络特征向量
  MEs = moduleEigengenes(filtered_expr, mergedColors)$eigengenes
  # 对特征向量排序
  MEs = orderMEs(MEs)
  # 可视化模块间的相关性
  pdf(file = paste0("/home/yanyq/share_genetics/result/WGCNA/moduleCor/", gsub(".Rda", "", cancer), ".pdf"), width = 5, height = 7.5);
  par(cex = 0.9)
  plotEigengeneNetworks(MEs, "", marDendro = c(0,4,1,2),
                        marHeatmap = c(3,4,1,2), cex.lab = 0.8,
                        xLabelsAngle = 90)
  dev.off()
  
  ## TOMplot
  dissTOM = 1-TOMsimilarityFromExpr(filtered_expr, power = sft$powerEstimate); #1-相关性=相异性
  
  # nSelect = 400
  # # 随机选取400个基因进行可视化，设置seed值，保证结果的可重复性
  # set.seed(10);#设置随机种子数
  # select = sample(nGenes, size = nSelect);#从5000个基因选择400个
  # selectTOM = dissTOM[select, select];#选择这400*400的矩阵
  # # 对选取的基因进行重新聚类
  # selectTree = hclust(as.dist(selectTOM), method = "average")#用hclust重新聚类
  # selectColors = mergedColors[select];#提取相应的颜色模块
  # pdf(file = paste0("/home/yanyq/share_genetics/result/WGCNA/TOMplot/", gsub(".Rda", "", cancer), ".pdf"), width = 5, height = 5);
  # # 美化图形的设置
  # plotDiss = selectTOM^7;
  # diag(plotDiss) = NA;
  # # 绘制TOM图
  # TOMplot(plotDiss, #拓扑矩阵，该矩阵记录了每个节点之间的相关性
  #         selectTree, #基因的聚类结果
  #         selectColors, #基因对应的模块颜色
  #         main = "Network heatmap plot, selected genes")
  # dev.off()
  
  ## TOMplot
  dissTOM = 1-TOMsimilarityFromExpr(filtered_expr, power = sft$powerEstimate); # 1-相关性=相异性
  geneTree = net$dendrograms[[1]]
  pdf(file = paste0("/home/yanyq/share_genetics/result/WGCNA/TOMplot/", gsub(".Rda", "", cancer), ".pdf"), width = 5, height = 5);
  # 美化图形的设置
  plotDiss = dissTOM^7
  diag(plotDiss) = NA
  myheatcol = colorpanel(250,'red',"orange",'lemonchiffon')
  # 绘制TOM图
  TOMplot(plotDiss, #拓扑矩阵，该矩阵记录了每个节点之间的相关性
          geneTree, #基因的聚类结果
          mergedColors, #基因对应的模块颜色
          main = "Network heatmap plot, all genes",
          col=myheatcol)
  dev.off()
}
