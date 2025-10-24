# 肾癌和肺癌差异表达分析

# 样本信息表：第一列为样本名称ID，第二列为样本的分组
# 表达矩阵：每行是一个基因，每列是一个样本，表达数据为TPM
library(data.table)
setwd("/home/yanyq/share_genetics/data/TCGA_express/kidney/")
# 样本
samples = fread("/home/yanyq/share_genetics/data/TCGA_express/kidney_sample_sheet")
# 两个05A，9个01B，4*2个重复tumor样本
normal = samples[grep("11A",samples$`Sample ID`),]
tumor = samples[grep("01A",samples$`Sample ID`),]
normal[duplicated(normal$`Case ID`),] # 无
dup_case = tumor$`Case ID`[duplicated(tumor$`Case ID`)] # 4*2个重复样本，去除
tumor = tumor[!tumor$`Case ID`%in%dup_case,]
samples = rbind(tumor,normal) # 1009个
expression = as.data.frame(fread(paste0(samples$`File ID`[1],"/",samples$`File Name`)[1]))
expression = expression[,c(1,2,7)]
rownames(expression) = expression[,1]
colnames(expression)[3] = samples$`Sample ID`[1]
for(i in 2:nrow(samples)){
  tmp_expression = fread(paste0(samples$`File ID`[i],"/",samples$`File Name`)[i])
  tmp = tmp_expression$gene_id
  tmp_expression = as.data.frame(tmp_expression[,c(7)])
  rownames(tmp_expression) = tmp
  colnames(tmp_expression) = samples$`Sample ID`[i]
  expression = cbind(expression,tmp_expression)
}
expression = expression[-(1:4),]
dup_ENSG = expression[duplicated(substr(expression$gene_id,1,15)),] # ENSG重复，后缀均为_PAR_Y，44个
rowSums(dup_ENSG[,3:1011]) # 表达量均为零
expression = expression[!(expression$gene_id%in%dup_ENSG$gene_id),]
expression$gene_id = substr(expression$gene_id,1,15)
rownames(expression) = expression$gene_id # TCGA 60616 Genes 1009 Samples
# GTex
GTex_exp = fread("/home/yanyq/share_genetics/data/TCGA_express/bulk-gex_v8_rna-seq_tpms-by-tissue_gene_tpm_2017-06-05_v8_kidney_cortex.gct")
dup_ENSG = GTex_exp[duplicated(substr(GTex_exp$Name,1,15)),]
rowSums(dup_ENSG[,4:88])
GTex_exp = GTex_exp[!(GTex_exp$Name%in%dup_ENSG$Name),]
GTex_exp$Name = substr(GTex_exp$Name,1,15)
GTex_exp = GTex_exp[,-c(1,3)] # GTex 56156 Genes 85 Samples
expression_TCGA_GTex = merge(expression,GTex_exp,by.x="gene_id",by.y = "Name") # 55617 Genes 1094 Samples 880 Tumor 214 Normal
rownames(expression_TCGA_GTex) = expression_TCGA_GTex$gene_id

sample_TCGA_GTex = samples[,c("Sample ID","Sample Type")]
tmp = data.frame(`Sample ID` = colnames(GTex_exp)[2:86],`Sample Type` = "Tissue Normal")
colnames(tmp) = colnames(sample_TCGA_GTex)
sample_TCGA_GTex = rbind(sample_TCGA_GTex,tmp)
sample_TCGA_GTex$group = ifelse(sample_TCGA_GTex$`Sample Type`=="Tissue Normal","normal","tumor")

# 箱线图和PCA
{
  ## 01绘制整体表达的箱线图
  exprSet <- expression_TCGA_GTex[,-c(1,2)]
  ## [1] "matrix" "array"
  data <- data.frame(expression=c(exprSet),
                     sample=rep(colnames(exprSet),each=nrow(exprSet)))
  
  p1 <- ggplot(data = data,aes(x=sample,y=expression,fill=sample))+ geom_boxplot() + theme(axis.text.x = element_text(angle = 90)) + 
    xlab(NULL) + ylab("log2(CPM+1)")+theme_bw()
  
  ## 02绘制PCA图
  dat <- expression_TCGA_GTex[,-c(1,2)]
  dat <- as.data.frame(t(dat))
  dat <- na.omit(dat)
  dat$group_list <- group_list
  dat_pca <- PCA(dat[,-ncol(dat)], graph = FALSE)#画图仅需数值型数据，去掉最后一列的分组信息
  p2 <- fviz_pca_ind(dat_pca,
                     geom.ind = "point", # 只显示点，不显示文字
                     col.ind = dat$group_list, # 用不同颜色表示分组
                     palette = c("#00AFBB", "#E7B800"),
                     addEllipses = T, # 是否圈起来，少于4个样圈不起来
                     legend.title = "Groups") + theme_bw()
  p1+p2
}

library(dplyr)
library(limma)
expr_data = expression_TCGA_GTex[,-c(1,2)]
expr_data = log2(expr_data+1)
# 构建分组矩阵--design ---------------------------------------------------------
design <- model.matrix(~0+factor(sample_TCGA_GTex$group))
colnames(design) <- levels(factor(sample_TCGA_GTex$group))
rownames(design) <- colnames(expr_data)
# #构建比较矩阵——contrast -------------------------------------------------------
contrast.matrix <- makeContrasts(tumor-normal,levels = design) 
# #线性拟合模型构建 ---------------------------------------------------------------
fit <- lmFit(expr_data,design) #非线性最小二乘法
fit2 <- contrasts.fit(fit, contrast.matrix)
fit2 <- eBayes(fit2)#用经验贝叶斯调整t-test中方差的部分
DEG <- topTable(fit2, coef = 1,n = Inf,sort.by="logFC")
DEG <- na.omit(DEG)
DEG$regulate <- ifelse(DEG$adj.P.Val > 0.05, "unchanged",
                       ifelse(DEG$logFC > 1, "up-regulated",
                              ifelse(DEG$logFC < -1, "down-regulated", "unchanged")))
DEG$gene_id = rownames(DEG)
DEG = left_join(DEG,expression_TCGA_GTex[,1:2],by = "gene_id")
write_tsv(DEG[DEG$regulate!="unchanged",],"/home/yanyq/share_genetics/data/TCGA_express/DEG_kidney")




{
  # 样本信息表：第一列为样本名称ID，第二列为样本的分组
  # 表达矩阵：每行是一个基因，每列是一个样本，表达数据为TPM
  library(data.table)
  setwd("/home/yanyq/share_genetics/data/TCGA_express/lung/")
  # 样本
  samples = fread("/home/yanyq/share_genetics/data/TCGA_express/lung_sample_sheet")
  samples = samples[samples$`Data Type`=="Gene Expression Quantification"]
  # 两个02A，19个01B，1个11B,1个01C,12*2个重复tumor样本
  normal = samples[grep("11A",samples$`Sample ID`),]
  tumor = samples[grep("01A",samples$`Sample ID`),]
  normal[duplicated(normal$`Case ID`),] # 无
  dup_case = tumor$`Case ID`[duplicated(tumor$`Case ID`)] # 12*2个重复样本，去除
  tumor = tumor[!tumor$`Case ID`%in%dup_case,]
  samples = rbind(tumor,normal) # 1106个
  expression = as.data.frame(fread(paste0(samples$`File ID`[1],"/",samples$`File Name`)[1]))
  expression = expression[,c(1,2,7)]
  rownames(expression) = expression[,1]
  colnames(expression)[3] = samples$`Sample ID`[1]
  for(i in 2:nrow(samples)){
    tmp_expression = fread(paste0(samples$`File ID`[i],"/",samples$`File Name`)[i])
    tmp = tmp_expression$gene_id
    tmp_expression = as.data.frame(tmp_expression[,c(7)])
    rownames(tmp_expression) = tmp
    colnames(tmp_expression) = samples$`Sample ID`[i]
    expression = cbind(expression,tmp_expression)
  }
  expression = expression[-(1:4),]
  dup_ENSG = expression[duplicated(substr(expression$gene_id,1,15)),] # ENSG重复，后缀均为_PAR_Y，44个
  rowSums(dup_ENSG[,3:1011]) # 表达量均为零
  expression = expression[!(expression$gene_id%in%dup_ENSG$gene_id),]
  expression$gene_id = substr(expression$gene_id,1,15)
  rownames(expression) = expression$gene_id # TCGA 60616 Genes 1106 Samples
  # GTex
  GTex_exp = fread("/home/yanyq/share_genetics/data/TCGA_express/bulk-gex_v8_rna-seq_tpms-by-tissue_gene_tpm_2017-06-05_v8_lung.gct")
  dup_ENSG = GTex_exp[duplicated(substr(GTex_exp$Name,1,15)),]
  rowSums(dup_ENSG[,4:88])
  GTex_exp = GTex_exp[!(GTex_exp$Name%in%dup_ENSG$Name),]
  GTex_exp$Name = substr(GTex_exp$Name,1,15)
  GTex_exp = GTex_exp[,-c(1,3)] # GTex 56156 Genes 578 Samples
  expression_TCGA_GTex = merge(expression,GTex_exp,by.x="gene_id",by.y = "Name") # 55617 Genes 1684 Samples 997 Tumor 687 Normal
  rownames(expression_TCGA_GTex) = expression_TCGA_GTex$gene_id
  
  sample_TCGA_GTex = samples[,c("Sample ID","Sample Type")]
  tmp = data.frame(`Sample ID` = colnames(GTex_exp)[2:579],`Sample Type` = "Tissue Normal")
  colnames(tmp) = colnames(sample_TCGA_GTex)
  sample_TCGA_GTex = rbind(sample_TCGA_GTex,tmp)
  sample_TCGA_GTex$group = ifelse(sample_TCGA_GTex$`Sample Type`=="Tissue Normal","normal","tumor")
  
  library(dplyr)
  library(limma)
  expr_data = expression_TCGA_GTex[,-c(1,2)]
  expr_data = log2(expr_data+1)
  # 构建分组矩阵--design ---------------------------------------------------------
  design <- model.matrix(~0+factor(sample_TCGA_GTex$group))
  colnames(design) <- levels(factor(sample_TCGA_GTex$group))
  rownames(design) <- colnames(expr_data)
  # #构建比较矩阵——contrast -------------------------------------------------------
  contrast.matrix <- makeContrasts(tumor-normal,levels = design) 
  # #线性拟合模型构建 ---------------------------------------------------------------
  fit <- lmFit(expr_data,design) #非线性最小二乘法
  fit2 <- contrasts.fit(fit, contrast.matrix)
  fit2 <- eBayes(fit2)#用经验贝叶斯调整t-test中方差的部分
  DEG <- topTable(fit2, coef = 1,n = Inf,sort.by="logFC")
  DEG <- na.omit(DEG)
  DEG$regulate <- ifelse(DEG$adj.P.Val > 0.05, "unchanged",
                         ifelse(DEG$logFC > 1, "up-regulated",
                                ifelse(DEG$logFC < -1, "down-regulated", "unchanged")))
  DEG$gene_id = rownames(DEG)
  DEG = left_join(DEG,expression_TCGA_GTex[,1:2],by = "gene_id")
  write_tsv(DEG[DEG$regulate!="unchanged",],"/home/yanyq/share_genetics/data/TCGA_express/DEG_lung")
}
