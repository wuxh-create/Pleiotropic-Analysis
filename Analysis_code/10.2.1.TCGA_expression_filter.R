# 基因表达量筛选
# cancers = c("BLCA","BRCA","HNSC","KICH","LUAD","OV","PAAD","PRAD","SKCM","UCEC",
#             "COAD","DLBC","CESC","STAD","THYM","CHOL","LAML","SARC","LIHC")

cancers = c("BLCA","BRCA","CHOL","COAD","ESCA","HNSC","KICH",
            "LIHC","LUAD","PRAD","STAD","THCA","UCEC")

setwd("/home/yanyq/share_genetics/data/TCGA/expression_merged/")
library(readr)
library(WGCNA)
library(dplyr)

for(cancer in cancers){
  if(cancer=="KICH"){
    tmp1 = as.data.frame(read_tsv("TCGA-KICH"))
    tmp2 = as.data.frame(read_tsv("TCGA-KIRC"))
    tmp3 = as.data.frame(read_tsv("TCGA-KIRP"))
    which(colnames(tmp1)[-(1:2)]%in%colnames(tmp2)[-(1:2)])
    which(colnames(tmp1)[-(1:2)]%in%colnames(tmp3)[-(1:2)])
    which(colnames(tmp3)[-(1:2)]%in%colnames(tmp2)[-(1:2)])
    expr_raw = left_join(tmp1, tmp2[,-2], by = "gene_id")
    expr_raw = left_join(expr_raw, tmp3[,-2], by = "gene_id")
    cancer = "kidney"
  }else if(cancer=="LUAD"){
    tmp1 = as.data.frame(read_tsv("TCGA-LUAD"))
    tmp2 = as.data.frame(read_tsv("TCGA-LUSC"))
    which(colnames(tmp1)[-(1:2)]%in%colnames(tmp2)[-(1:2)])
    expr_raw = left_join(tmp1, tmp2[,-2], by = "gene_id")
    cancer = "lung"
  }else if(cancer=="COAD"){
    tmp1 = as.data.frame(read_tsv("TCGA-COAD"))
    tmp2 = as.data.frame(read_tsv("TCGA-READ"))
    which(colnames(tmp1)[-(1:2)]%in%colnames(tmp2)[-(1:2)])
    expr_raw = left_join(tmp1, tmp2[,-2], by = "gene_id")
    cancer = "CRC"
  }else{
    expr_raw = as.data.frame(read_tsv(paste0("TCGA-", cancer)))
  }
  expr_raw = expr_raw[-(1:4),-2]
  # 行为样本、列为基因
  expr = as.data.frame(t(expr_raw[,-1]))
  colnames(expr) = expr_raw$gene_id
  rownames(expr) = colnames(expr_raw)[-1]
  expr = log2(expr+1)
  dim_before_filter = dim(expr)
  
  # 计算基因表达的中位平均方差，筛选前5000个基因构建共表达网络
  # https://blog.csdn.net/qq_32649321/article/details/118193970
  # MAD与标准差SD（ standard deviation）的区别：
  # MAD是一种鲁棒性统计量，比标准差更能适应数据集中的异常值。对于标准差，使用的是数据到均值的距离平方，较大的偏差权重较大，异常值对结果影响不能忽视。对于MAD，少量的异常值不会影响实验的结果。
  expr_mad = apply(expr, 2, mad)
  top5000_genes = names(sort(expr_mad, decreasing = T))[1:5000]
  filtered_expr = expr[,top5000_genes ]
  
  # # 删除平均FPKM小于0.01的基因
  # filtered_expr_mean = colMeans(filtered_expr)
  # filtered_expr = filtered_expr[, filtered_expr_mean >= 0.01]
  # dim(filtered_expr) # 1081×41384
  # 检查缺失值
  gsg = goodSamplesGenes(filtered_expr,verbose = 3);
  # 如果gsg$allOK的结果为TRUE，证明没有缺失值，可以直接下一步
  # 如果为FALSE，则需要进行删除缺失值。
  if(!gsg$allOK) { # 没有过滤任何基因和样本
    # Optionally, print the gene and sample names that were removed:
    # if (sum(!gsg$goodGenes)>0)
    #   printFlush(paste(cancer, " Removing genes:", paste(names(filtered_expr)[!gsg$goodGenes], collapse = ", ")));
    # if (sum(!gsg$goodSamples)>0)
    #   printFlush(paste(cancer, "Removing samples:", paste(rownames(filtered_expr)[!gsg$goodSamples], collapse = ", ")));
    # Remove the offending genes and samples from the data:
    filtered_expr = filtered_expr[gsg$goodSamples, gsg$goodGenes]
  }
  dim_gsg = dim(filtered_expr)
  
  # filtered_expr = log2(filtered_expr+0.01)
  print(paste0("Dim: ", cancer, "-", dim_before_filter, "-", dim_gsg, "-", dim(filtered_expr)))
  save(filtered_expr, file = paste0("/home/yanyq/share_genetics/data/TCGA/expression_filtered/", cancer, ".Rda"))
}
