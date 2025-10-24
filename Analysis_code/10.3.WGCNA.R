# https://www.bioinfoer.com/forum.php?mod=viewthread&tid=5
setwd("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/")
library(WGCNA)
for(cancer in list.files()){
  load(cancer)
  # 2. 网络构建
  # 使用“pickSoftThreshold”函数根据无标度拓扑准则选择对应于 R2 = 0.85 的独立索引的软阈值功率 （β） 值。通过计算基因之间的拓扑重叠矩阵（TOM）差异来根据基因的连通性和协方差系数来识别模块，然后进行分层聚类。每个模块的最小基因数为30个，采用动态切割树法的合并模块阈值为0.25个。与疾病进展最相关的模块（COVID-19：健康-轻度-中度-重度;VTE：控制-VTE;假设 p < 0.05） 作为关键模块，使用 moduleTraitCor 和 moduleTraitPvalue 算法进行进一步分析。使用“ComplexHeatmap”包将每个模块的基因表达模式与热图一起显示。主成分分析（PCA）使用factoextra R软件包进行。对于鉴定的模块，进行GO富集分析以探索其生物学功能。
  # 2.1 构建自动化网络和检测模块
  # 选择软阈值
  enableWGCNAThreads(nThreads = 20)  #开启多线程
  pdf(file = paste0("/home/yanyq/share_genetics/result/WGCNA/soft_thresh/", gsub(".Rda", "", cancer), ".pdf"), height = 5 ,width = 8)
  # sizeGrWindow(9, 5)
  par(mfrow = c(1,2))
  sft = pickSoftThreshold(filtered_expr, RsquaredCut = 0.85)
  # 无标度拓扑拟合指数
  # 一般来说，无标度拓扑拟合指数这个图是用来选择软阈值的一个根据。例如下图是1到20，有些教程会写到1到30。我们一般选择在0.9以上的，第一个达到0.9以上数值。下图的6是第一个达到0.9的数值，可以考虑6作为软阈值。
  # 如果在0.9以上就没有数值了，我们就不要降低标准，但是最低不能小于0.8。
  plot(sft$fitIndices[,1], -sign(sft$fitIndices[,3])*sft$fitIndices[,2],
       xlab="Soft Threshold (power)",ylab="Scale Free Topology Model Fit,signed R^2",type="n",
       main = paste("Scale independence"));
  text(sft$fitIndices[,1], -sign(sft$fitIndices[,3])*sft$fitIndices[,2],
       labels=c(c(1:10), seq(from = 12, to=20, by=2)),cex=0.85,col="red");
  abline(h=0.85,col="red")  #查看位于0.85以上的点，可以改变高度值   
  # 平均连接度
  # 从下图可以看出，数值为6的时候，已经开始持平，则软阈值为6时，网络的连通性好。
  plot(sft$fitIndices[,1], sft$fitIndices[,5],
       xlab="Soft Threshold (power)",ylab="Mean Connectivity", type="n",
       main = paste("Mean connectivity"))
  text(sft$fitIndices[,1], sft$fitIndices[,5], labels=c(c(1:10), seq(from = 12, to=20, by=2)), cex=0.85,col="red")
  dev.off()
  
  # 无尺度网络检验，验证构建的网络是否是无尺度网络
  softpower=sft$powerEstimate
  ADJ = abs(cor(filtered_expr,use="p"))^softpower#相关性取绝对值再幂次
  # ADJ = softConnectivity(filtered_expr,power=softpower)-1
  k = as.vector(apply(ADJ,2,sum,na.rm=T))#对ADJ的每一列取和，也就是频次
  pdf(file = paste0("/home/yanyq/share_genetics/result/WGCNA/scale_free/", gsub(".Rda", "", cancer), ".pdf"), height = 5 ,width = 8)
  par(mfrow = c(1,2))
  hist(k)#直方图
  scaleFreePlot(k,main="Check scale free topology\n")
  dev.off()
  
  
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
  
  nSelect = 400
  # 随机选取400个基因进行可视化，设置seed值，保证结果的可重复性
  set.seed(10);#设置随机种子数
  select = sample(nGenes, size = nSelect);#从5000个基因选择400个
  selectTOM = dissTOM[select, select];#选择这400*400的矩阵
  # 对选取的基因进行重新聚类
  selectTree = hclust(as.dist(selectTOM), method = "average")#用hclust重新聚类
  selectColors = mergedColors[select];#提取相应的颜色模块
  pdf(file = paste0("/home/yanyq/share_genetics/result/WGCNA/TOMplot/", gsub(".Rda", "", cancer), ".pdf"), width = 5, height = 5);
  # 美化图形的设置
  plotDiss = selectTOM^7;
  diag(plotDiss) = NA;
  # 绘制TOM图
  TOMplot(plotDiss, #拓扑矩阵，该矩阵记录了每个节点之间的相关性
          selectTree, #基因的聚类结果
          selectColors, #基因对应的模块颜色
          main = "Network heatmap plot, selected genes")
  dev.off()
}
