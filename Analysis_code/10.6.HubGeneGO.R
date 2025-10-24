# https://cloud.tencent.com/developer/article/2056804
# 筛选关联显著模块的Hub基因做富集
# 选择显著的模块
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
  
  # 显著的模块
  sig_modules = rownames(moduleTraitPvalue)[moduleTraitPvalue[,1]<0.05]
  # 提取显著模块中的基因
  gene_module = data.frame(genes = colnames(filtered_expr), module = moduleColors)
  gene_module = gene_module[gene_module$module%in%gsub("ME","",sig_modules),]
  write_tsv(gene_module, paste0("/home/yanyq/share_genetics/result/WGCNA/r2_0.85/sigMod_Gene/",gsub(".Rda",".tsv",cancer)))
  # 
  # 筛选hub基因
  geneModuleMembership = as.data.frame(cor(filtered_expr, MEs, use = "p"))
  trait = as.data.frame(design[,"Tumor"])
  geneTraitSignificance = as.data.frame(cor(filtered_expr,trait,use = "p"))
  hubs = list()
  for(mod in sig_modules){
    hub<- abs(geneModuleMembership[,mod]>0.8) & abs(geneTraitSignificance)>0.2
    if(any(hub)){
      hub<-data.frame(genes = dimnames(data.frame(filtered_expr))[[2]][hub], modules = mod)
      hubs[[mod]] = hub
    }
  }
  hubs = do.call(rbind,hubs)
  write_tsv(hubs, paste0("/home/yanyq/share_genetics/result/WGCNA/r2_0.85/hubGene/",gsub(".Rda",".tsv",cancer)))
}

# 筛选共有的核心基因
shared = list()
traits=c("BLCA","BRCA","CHOL","CRC","ESCA","HNSC","kidney","LIHC","lung","PRAD","STAD","THCA","UCEC")
for(i in 1:(length(traits)-1)){
  for(j in (i+1):length(traits)){
    t1=read_tsv(paste0("/home/yanyq/share_genetics/result/WGCNA/r2_0.85/hubGene/",traits[i],".tsv"))
    t2=read_tsv(paste0("/home/yanyq/share_genetics/result/WGCNA/r2_0.85/hubGene/",traits[j],".tsv"))
    shared[[paste0(i,"-",j)]] = data.frame(trait1 = traits[i],trait2 = traits[j],genes = intersect(t1$genes,t2$genes))
  }
}
shared = do.call(rbind,shared)
shared$pairs = paste0(shared$trait1,"-",shared$trait2)
write_tsv(shared,"/home/yanyq/share_genetics/result/WGCNA/r2_0.85/hubGene/all_overlap")

############### 筛选共享Hub基因数大于20的，做富集
shared = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/WGCNA/r2_0.85/hubGene/all_overlap"))
freq = as.data.frame(table(shared$pairs))
breaks <- seq(0, 200, by = 20)
hist(freq$Freq, breaks = breaks, main = "直方图", xlab = "癌症对共享Hub基因数目", ylab = "癌症对数数", col = "lightblue", border = "black")

shared = shared[shared$pairs%in%freq$Var1[freq$Freq>20],]
library(AnnotationDbi)
library(org.Hs.eg.db)#基因注释包
library(clusterProfiler)#富集包
library(dplyr)
library(ggplot2)#画图包
shared$genes = gsub("\\..*", "", shared$genes)
for(traits in unique(shared$pairs)){
  tmp_shared = shared[shared$pairs==traits,]
  gene.df <- bitr(tmp_shared$genes,fromType="ENSEMBL",toType="ENTREZID", OrgDb = org.Hs.eg.db)#TCGA数据框如果没有进行基因注释，那么fromType应该是Ensembl，各种ID之间可以互相转换,toType可以是一个字符串，也可以是一个向量，看自己需求                     
  gene <- gene.df$ENTREZID
  {
    #3、GO富集
    #https://blog.csdn.net/weixin_46544135/article/details/115750241
    ##CC表示细胞组分，MF表示分子功能，BP表示生物学过程，ALL表示同时富集三种过程，选自己需要的,我一般是做BP,MF,CC这3组再合并成一个数据框，方便后续摘取部分通路绘图。
    ego_ALL <- enrichGO(gene = gene,#我们上面定义了
                        OrgDb=org.Hs.eg.db,
                        keyType = "ENTREZID",
                        ont = "ALL",#富集的GO类型
                        pAdjustMethod = "BH",#这个不用管，一般都用的BH
                        minGSSize = 1,
                        pvalueCutoff = 1,#P值可以取0.05
                        qvalueCutoff = 1,
                        readable = TRUE)
    
    #4、将结果保存到当前路径
    write_tsv(as.data.frame(ego_ALL),paste0("/home/yanyq/share_genetics/result/WGCNA/r2_0.85/hubGene/GO/",traits))
    
    # barplot(ego_ALL)  #富集柱形图
    p = dotplot(ego_ALL)  #富集气泡图
    # cnetplot(ego_ALL) #网络图展示富集功能和基因的包含关系
    # emapplot(ego_ALL) #网络图展示各富集功能之间共有基因关系
    # heatplot(ego_ALL) #热图展示富集功能和基因的包含关系
    pdf(paste0("/home/yanyq/share_genetics/result/WGCNA/r2_0.85/hubGene/GO/",traits,".pdf"),height = 5,width=7)
    print(p)
    dev.off()
  }
}

setwd("/home/yanyq/share_genetics/result/WGCNA/r2_0.85/hubGene/GO/")
cancers = list.files()
cancers = cancers[-grep(".pdf",cancers)]
all_go_result = list()
for(cancer in cancers){
  all_go_result[[cancer]] = as.data.frame(read_tsv(cancer))
  all_go_result[[cancer]]$traits = cancer
}
all_go_result = do.call(rbind,all_go_result)
all_go_result = all_go_result[all_go_result$qvalue<0.05,]

###################### top 10的通路
all_BP_result_top10 = list()
all_CC_result_top10 = list()
all_MF_result_top10 = list()
setwd("/home/yanyq/share_genetics/result/WGCNA/r2_0.85/hubGene/GO/")
cancers = list.files()
cancers = cancers[-grep(".pdf",cancers)]
for(cancer in cancers){
  tmp = as.data.frame(read_tsv(cancer))
  all_BP_result_top10[[cancer]] = tmp[tmp$ONTOLOGY=="BP",]
  all_BP_result_top10[[cancer]] = all_BP_result_top10[[cancer]][order(all_BP_result_top10[[cancer]]$qvalue)[1:10],]
  all_BP_result_top10[[cancer]]$traits = cancer
  
  all_MF_result_top10[[cancer]] = tmp[tmp$ONTOLOGY=="MF",]
  all_MF_result_top10[[cancer]] = all_MF_result_top10[[cancer]][order(all_MF_result_top10[[cancer]]$qvalue)[1:10],]
  all_MF_result_top10[[cancer]]$traits = cancer
  
  all_CC_result_top10[[cancer]] = tmp[tmp$ONTOLOGY=="CC",]
  all_CC_result_top10[[cancer]] = all_CC_result_top10[[cancer]][order(all_CC_result_top10[[cancer]]$qvalue)[1:10],]
  all_CC_result_top10[[cancer]]$traits = cancer
}
all_BP_result_top10 = do.call(rbind, all_BP_result_top10)
all_MF_result_top10 = do.call(rbind, all_MF_result_top10)
all_CC_result_top10 = do.call(rbind, all_CC_result_top10)

all_BP_result_top10_frq = as.data.frame(table(all_BP_result_top10$Description))
all_MF_result_top10_frq = as.data.frame(table(all_MF_result_top10$Description))
all_CC_result_top10_frq = as.data.frame(table(all_CC_result_top10$Description))
