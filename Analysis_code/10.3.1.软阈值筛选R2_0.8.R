# https://www.bioinfoer.com/forum.php?mod=viewthread&tid=5
setwd("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/")
library(WGCNA)
enableWGCNAThreads(nThreads = 20)  #开启多线程
for(cancer in list.files()){
  load(cancer)
  # 2. 网络构建
  # 使用“pickSoftThreshold”函数根据无标度拓扑准则选择对应于 R2 = 0.9 的独立索引的软阈值功率 （β） 值。通过计算基因之间的拓扑重叠矩阵（TOM）差异来根据基因的连通性和协方差系数来识别模块，然后进行分层聚类。每个模块的最小基因数为30个，采用动态切割树法的合并模块阈值为0.25个。与疾病进展最相关的模块（COVID-19：健康-轻度-中度-重度;VTE：控制-VTE;假设 p < 0.05） 作为关键模块，使用 moduleTraitCor 和 moduleTraitPvalue 算法进行进一步分析。使用“ComplexHeatmap”包将每个模块的基因表达模式与热图一起显示。主成分分析（PCA）使用factoextra R软件包进行。对于鉴定的模块，进行GO富集分析以探索其生物学功能。
  # 2.1 构建自动化网络和检测模块
  # 选择软阈值
  pdf(file = paste0("/home/yanyq/share_genetics/result/WGCNA/r2_0.8/soft_thresh/", gsub(".Rda", "", cancer), ".pdf"), height = 5 ,width = 8)
  # sizeGrWindow(9, 5)
  par(mfrow = c(1,2))
  sft = pickSoftThreshold(filtered_expr, RsquaredCut = 0.8)
  # 无标度拓扑拟合指数
  # 一般来说，无标度拓扑拟合指数这个图是用来选择软阈值的一个根据。例如下图是1到20，有些教程会写到1到30。我们一般选择在0.9以上的，第一个达到0.9以上数值。下图的6是第一个达到0.9的数值，可以考虑6作为软阈值。
  # 如果在0.9以上就没有数值了，我们就不要降低标准，但是最低不能小于0.8。
  plot(sft$fitIndices[,1], -sign(sft$fitIndices[,3])*sft$fitIndices[,2],
       xlab="Soft Threshold (power)",ylab="Scale Free Topology Model Fit,signed R^2",type="n",
       main = paste("Scale independence"));
  text(sft$fitIndices[,1], -sign(sft$fitIndices[,3])*sft$fitIndices[,2],
       labels=c(c(1:10), seq(from = 12, to=20, by=2)),cex=0.9,col="red");
  abline(h=0.8,col="red")  #查看位于0.9以上的点，可以改变高度值   
  # 平均连接度
  # 从下图可以看出，数值为6的时候，已经开始持平，则软阈值为6时，网络的连通性好。
  plot(sft$fitIndices[,1], sft$fitIndices[,5],
       xlab="Soft Threshold (power)",ylab="Mean Connectivity", type="n",
       main = paste("Mean connectivity"))
  text(sft$fitIndices[,1], sft$fitIndices[,5], labels=c(c(1:10), seq(from = 12, to=20, by=2)), cex=0.9,col="red")
  dev.off()
  
  save(sft, file = paste0("/home/yanyq/share_genetics/result/WGCNA/r2_0.8/sft/", cancer))
  
  # 无尺度网络检验，验证构建的网络是否是无尺度网络
  softpower=sft$powerEstimate
  ADJ = abs(cor(filtered_expr,use="p"))^softpower#相关性取绝对值再幂次
  # ADJ = softConnectivity(filtered_expr,power=softpower)-1
  k = as.vector(apply(ADJ,2,sum,na.rm=T))#对ADJ的每一列取和，也就是频次
  pdf(file = paste0("/home/yanyq/share_genetics/result/WGCNA/r2_0.8/scale_free/", gsub(".Rda", "", cancer), ".pdf"), height = 5 ,width = 8)
  par(mfrow = c(1,2))
  hist(k)#直方图
  scaleFreePlot(k,main="Check scale free topology\n")
  dev.off()
}
