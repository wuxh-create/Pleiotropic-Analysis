# https://cloud.tencent.com/developer/article/2056804
####################### 4.关联基因模块与表型 #####################################
setwd("/home/yanyq/share_genetics/result/WGCNA/r2_0.85/one_step_net/")
library(gplots)
library(ggpubr)
library(grid)
library(gridExtra) 
library(WGCNA)

for(cancer in list.files()){
  load(cancer)
  load(paste0("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/",cancer))
  load(paste0("/home/yanyq/share_genetics/result/WGCNA/r2_0.85/sft/",cancer))
  
  group = ifelse(grepl("01A", rownames(filtered_expr)), "Tumor", "Normal")
  design = model.matrix(~0+group)
  colnames(design)[which(colnames(design)=="groupNormal")] = "Normal"
  colnames(design)[which(colnames(design)=="groupTumor")] = "Tumor"
  
  moduleColors = labels2colors(net$colors)
  MES0 = moduleEigengenes(filtered_expr,moduleColors)$eigengenes  #Calculate module eigengenes.
  MEs = orderMEs(MES0)  #Put close eigenvectors next to each other
  moduleTraitCor = cor(MEs,design,use = "p")
  moduleTraitPvalue = corPvalueStudent(moduleTraitCor,nSamples)
  textMatrix = paste0(signif(moduleTraitCor,2),"\n(",
                      signif(moduleTraitPvalue,1),")")
  dim(textMatrix) = dim(moduleTraitCor)
  
  pdf(paste0("/home/yanyq/share_genetics/result/WGCNA/r2_0.85/module_cancer_relation/heatmap/", gsub("Rda","pdf",cancer)),width = 5, height = 5)
  # width = 2*length(colnames(design)), 
  # height = 0.6*length(names(MEs)) )
  # par(mar=c(0.5,0.5,0.5,0.5)) #留白：下、左、上、右
  labeledHeatmap(Matrix = moduleTraitCor,
                 xLabels = colnames(design),
                 yLabels = names(MEs),
                 ySymbols = names(MEs),
                 colorLabels = F,
                 colors = blueWhiteRed(50),
                 textMatrix = textMatrix,
                 setStdMargins = F,
                 cex.text = 0.5,
                 zlim = c(-1,1), 
                 main = "Module-cancer relationships")
  dev.off()
  save(design, file = paste0("/home/yanyq/share_genetics/result/WGCNA/r2_0.85/module_cancer_relation/data/", cancer))
  
  ### 模块与表型的相关性boxplot图
  group = as.data.frame(group)
  rownames(group) = rownames(filtered_expr)
  mes_group = merge(MEs,group,by="row.names") 
  
  draw_ggboxplot = function(data,Module="Module",group="group"){
    ggboxplot(data,x=group, y=Module,
              ylab = paste0(Module),
              xlab = group,
              fill = group,
              palette = "jco",
              #add="jitter",
              legend = "") +stat_compare_means()
  }
  # 批量画boxplot
  colorNames <- names(MEs)
  pdf(paste0("/home/yanyq/share_genetics/result/WGCNA/r2_0.85/module_cancer_relation/boxplot/", gsub("Rda","pdf",cancer)), width = 6,height = 8)
  p = lapply(colorNames,function(x) {
    draw_ggboxplot(mes_group, Module = x, group = "group")
  })
  do.call(grid.arrange,c(p,ncol=3)) #排布为每行2个
  dev.off()
  
  ### 基因与模块、表型的相关性散点图
  #所有的模块都可以跟基因算出相关系数，所有的连续型性状也可以跟基因算出相关系数， 
  #如果跟性状显著相关的基因也跟某个模块显著相关，那么这些基因可能就非常重要。
  modNames = substring(names(MEs), 3)
  
  ### 计算模块与基因的相关性矩阵 
  ## Module Membership: 模块内基因表达与模块特征值的相关性
  geneModuleMembership = as.data.frame(cor(filtered_expr, MEs, use = "p"))
  MMPvalue = as.data.frame(corPvalueStudent(as.matrix(geneModuleMembership), nSamples))
  names(geneModuleMembership) = paste0("MM", modNames)
  names(MMPvalue) = paste0("p.MM", modNames)
  save(geneModuleMembership, file = paste0("/home/yanyq/share_genetics/result/WGCNA/r2_0.85/module_cancer_relation/relation_data/MM/",cancer))
  
  ###  计算性状与基因的相关性矩阵 
  ## Gene significance，GS：比较样本某个基因与对应表型的相关性
  ## 连续型性状
  # trait <- datTraits$groupNo  
  ## 非连续型性状，需转为0-1矩阵, 已存于design中
  trait = as.data.frame(design[,"Tumor"])
  
  geneTraitSignificance = as.data.frame(cor(filtered_expr,trait,use = "p"))
  GSPvalue = as.data.frame(corPvalueStudent(as.matrix(geneTraitSignificance),nSamples))
  names(geneTraitSignificance) = paste0("GS")
  names(GSPvalue) = paste0("GS")
  save(geneTraitSignificance, file = paste0("/home/yanyq/share_genetics/result/WGCNA/r2_0.85/module_cancer_relation/relation_data/GS/",cancer))
  
  ### 可视化基因与模块、表型的相关性.
  #selectModule<-c("blue","green","purple","grey")  ##可以选择自己想要的模块
  selectModule = modNames  ## 全部模块批量作图
  # par(mfrow=c(ceiling(length(selectModule)/2),2)) #批量作图开始
  for(module in selectModule){
    pdf(paste0("/home/yanyq/share_genetics/result/WGCNA/r2_0.85/module_cancer_relation/significance/", gsub(".Rda","",cancer),"_",module,".pdf"),width=5, height=5)
    column <- match(module,selectModule)
    print(module)
    moduleGenes <- moduleColors==module
    verboseScatterplot(abs(geneModuleMembership[moduleGenes, column]),
                       abs(geneTraitSignificance[moduleGenes, 1]),
                       xlab = paste("Module Membership in", module, "module"),
                       ylab = "Gene significance for trait",
                       main = paste("Module membership vs. gene significance\n"),
                       cex.main = 1.2, cex.lab = 1.2, cex.axis = 1.2, col = module)
    dev.off()
  }
}
