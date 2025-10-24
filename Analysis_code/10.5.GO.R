#################### 6. 选择感兴趣基因模块进行GO分析 ####################
setwd("/home/yanyq/share_genetics/result/WGCNA/one_step_net/")
library(clusterProfiler)
library(org.Hs.eg.db)
library(WGCNA)
library(ggplot2)

for(cancer in list.files()){
  load(cancer)
  load(paste0("/home/yanyq/share_genetics/data/TCGA/WGCNA_input/",cancer))
  load(paste0("/home/yanyq/share_genetics/result/WGCNA/sft/",cancer))
  load(paste0("/home/yanyq/share_genetics/result/WGCNA/module_cancer_relation/data/", cancer))
  moduleColors = labels2colors(net$colors)
  
  gene_module = data.frame(gene=colnames(filtered_expr),
                            module=moduleColors)
  gene_module$gene = sub("\\..*", "", gene_module$gene)
  
  ###run go analysis
  tmp = bitr(gene_module$gene,fromType = "ENSEMBL",  # "SYMBOL"   "ENSEMBL"
             toType = "ENTREZID",OrgDb = "org.Hs.eg.db" )
  gene_module_entrz = merge(tmp,gene_module, by.x="ENSEMBL", by.y="gene")
  formula_res = compareCluster(
    ENTREZID~module,
    data = gene_module_entrz[gene_module_entrz$module%in%c("turquoise","yellow","brown","purple"),],
    fun = "enrichGO",
    OrgDb = "org.Hs.eg.db",
    ont = "ALL",
    # ont = "BP",  #One of "BP", "MF", and "CC"  or "ALL"
    pAdjustMethod = "BH",
    pvalueCutoff = 0.25,
    qvalueCutoff = 0.25
  )
  
  ###精简GO富集的结果,去冗余
  lineage1_ego = simplify( 
    formula_res,
    cutoff=0.5,
    by="p.adjust",
    select_fun=min
  )
  save(gene_module, formula_res, lineage1_ego, file=paste0("/home/yanyq/share_genetics/result/WGCNA/GO/", cancer))
  # write.csv(lineage1_ego@compareClusterResult,
  #           file="step6_module_GO_term.csv")
  ### 绘制dotplot图
  dotp = dotplot(lineage1_ego,
                  showCategory=10,
                  includeAll = TRUE, #将有overlap的结果也展示出来
                  label_format=90)
  ggsave(dotp,filename= paste0("/home/yanyq/share_genetics/result/WGCNA/GO/", gsub("Rda","pdf",cancer)), #device = cairo_pdf,
         width = 12, 
         height = 15)
}
