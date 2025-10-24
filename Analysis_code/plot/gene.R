library(showtext)
library(ggplot2)
library(RColorBrewer)
library(ggbreak)
library(gridExtra)
library(patchwork)
library(readr)
library(extrafont)
library(forestplot)


showtext_auto()
font_add("SimSun", "/home/yanyq/usr/share/font/simsun.ttc")  # 使用宋体（SimSun）
font_add("Arial","/home/yanyq/usr/share/font/arial-font/arial.ttf")


########################### 提取所有多效基因座上的MAGMA基因
###########################
###########################
###########################
###########################
{
  files = list.files("/home/yanyq/share_genetics/result/MAGMA/asso_merge/")
  files = files[!grepl("CORP", files)]
  MAGMA_all = list()
  for(f in files){
    print(f)
    MAGMA_all[[f]] = read_tsv(paste0("/home/yanyq/share_genetics/result/MAGMA/asso_merge/", f))
  }
  for(f in names(MAGMA_all)){
    MAGMA_all[[f]]$traits = f
    colnames(MAGMA_all[[f]])[c(13:16)] = c("P.triat1","fdr.trait1","P.trait2","fdr.trait2")
  }
  MAGMA_all = do.call(rbind, MAGMA_all) # 在FUMA基因座上的基因有8180
  write_tsv(MAGMA_all, "/home/yanyq/share_genetics/final_result/MAGMA/asso_merge_all")
  
  MAGMA_all = as.data.frame(read_tsv("/home/yanyq/share_genetics/final_result/MAGMA/asso_merge_all"))
  length(unique(MAGMA_all$GENE)) # 1875
  length(unique(MAGMA_all$SYMBOL))
  length((MAGMA_all$SYMBOL[MAGMA_all$fdr.PLACO<0.05])) # 4274个多效基因
  length(unique(MAGMA_all$SYMBOL[MAGMA_all$fdr.PLACO<0.05])) # 1182个unique多效基因
}

#################################################多效基因在肿瘤中的分布以及富集分析
###########################
###########################
###########################
###########################
{
  library(dplyr)
  library(tidyr)
  MAGMA_fdr = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/all"))
  MAGMA_fdr = MAGMA_fdr[!grepl("CORP", MAGMA_fdr$trait),] # 4274
  length(unique(MAGMA_fdr$GENE)) # 1182
  MAGMA_fdr = separate(MAGMA_fdr, col = "trait", into = c("trait1", "trait2"), sep = "-")
  MAGMA_fdr_cancer = unique(rbind(MAGMA_fdr[,c("SYMBOL", "trait1")],MAGMA_fdr[,c("SYMBOL", "trait2")]%>%rename(trait1= "trait2")))
  MAGMA_fdr_frq = as.data.frame(table(MAGMA_fdr_cancer$SYMBOL))
  
  ##########################富集的基因
  write_tsv(as.data.frame(MAGMA_fdr_frq$Var1[MAGMA_fdr_frq$Freq>5]), "/home/yanyq/share_genetics/final_result/MAGMA/gene_in_5Cancer", col_names = F)
  
  ##########################
  MAGMA_fdr_frq_frq = as.data.frame(table(MAGMA_fdr_frq$Freq))
  # 截断条形图
  library(showtext)
  library(ggplot2)
  library(RColorBrewer)
  library(ggbreak)
  showtext_auto()
  font_add("SimSun", "/home/yanyq/usr/share/font/simsun.ttc")  # 使用宋体（SimSun）
  font_add("Arial", "/home/yanyq/usr/share/font/arial-font/arial.ttf")
  
  p1 = ggplot(data=MAGMA_fdr_frq_frq, mapping=aes(x=Var1,fill=Var1,y=Freq))+
    geom_bar(stat="identity",width=0.5, fill = "#E0B673")+
    # scale_color_continuous(values=c(brewer.pal(12, "Set3"), brewer.pal(3, "Set1")))+
    geom_text(stat='identity',aes(label=Freq), vjust=-0.5, size=4, family = "Arial")+
    scale_y_continuous(expand = c(0,0), limits = c(0,550))+
    labs(x = "癌症数", y = "多效基因数")+
    # theme_bw() +
    theme(
      legend.position = "none",
      panel.grid.major = element_blank(),  # 去除主网格线
      panel.grid.minor = element_blank(),  # 去除次网格线
      panel.background = element_blank(),
      axis.text.x = element_text( size = 12, colour = "black", family = "Arial"),
      axis.text.y = element_text(size = 12, colour = "black", family = "Arial"),
      axis.text.y.right = element_blank(),
      axis.ticks.y.right = element_blank(), 
      axis.title = element_text(size = 12, family = "SimSun"),
      axis.line.x = element_line(color = "black", linewidth = 0.2),  # 显示坐标轴的横线和纵线
      axis.line.y.left = element_line(color = "black", linewidth = 0.2),  # 显示坐标轴的横线和纵线
      # axis.ticks = element_line(color = "black", linewidth = 0.5) 
    )
  p1
  pdf("~/tmp.pdf", width = 8, height = 5)
  p1
  dev.off()
  
  # TERT在3个癌症中无多效, "BAC"  "MZBL" "SI"
  all_trait = unique(MAGMA_fdr_cancer$trait1)
  all_trait[!all_trait%in%unique(MAGMA_fdr_cancer$trait1[MAGMA_fdr_cancer$SYMBOL=="TERT"])]
}

#################################################多效基因在癌症对中的相关性
###########################
###########################
###########################
###########################
{
  library(vroom)
  library(GenomicRanges)
  library(readr)
  MAGMA_fdr = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/all"))
  MAGMA_fdr = MAGMA_fdr[!grepl("CORP", MAGMA_fdr$trait),] # 4274
  MAGMA_fdr$SNP_same_dire = NA # SNP效应方向相同
  MAGMA_fdr$SNP_diff_dire = NA # 效应方向相反
  MAGMA_fdr$SNP_corr = NA # Z值相关性
  MAGMA_fdr$SNP_corr_P = NA # Z值相关性
  
  flag = 1
  for(i in unique(MAGMA_fdr$trait)){
    print(flag)
    flag = flag+1
    trait1 = strsplit(i,"-")[[1]][1]
    trait2 = strsplit(i,"-")[[1]][2]
    
    SNP = as.data.frame(vroom(paste0("/home/yanyq/share_genetics/data/GWAS/overlap/", i, ".gz")))
    SNP_GR = as(paste0(SNP[,paste0("hg19chr.",trait1)], ":",SNP[,paste0("bp.",trait1)]), "GRanges")
    
    MAGMA_fdr_tmp = MAGMA_fdr[MAGMA_fdr$trait==i,]
    MAGMA_fdr_tmp_GR = as(paste0(MAGMA_fdr_tmp$CHR, ":", MAGMA_fdr_tmp$START, "-", MAGMA_fdr_tmp$STOP), "GRanges")
    
    ov = findOverlaps(MAGMA_fdr_tmp_GR,SNP_GR)
    
    for(j in 1:nrow(MAGMA_fdr_tmp)){
      SNP_tmp = SNP[ov@to[ov@from==j],]
      z1 = SNP_tmp[,paste0("zscore.",trait1)]
      z2 = SNP_tmp[,paste0("zscore.",trait2)]
      cor_pearson = tryCatch({cor.test(x = z1,y = z2, method = 'pearson')}, error = function(e){NA})
      MAGMA_fdr_tmp$SNP_same_dire[j] = length(which(z1*z2>0))
      MAGMA_fdr_tmp$SNP_diff_dire[j] = length(which(z1*z2<0))
      if(length(cor_pearson)>1){
        MAGMA_fdr_tmp$SNP_corr[j] = as.numeric(cor_pearson$estimate)
        MAGMA_fdr_tmp$SNP_corr_P[j] = cor_pearson$p.value
      }
    }
    
    MAGMA_fdr[MAGMA_fdr$trait==i,] = MAGMA_fdr_tmp
  }
  write_tsv(MAGMA_fdr, "/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/all_corr")
  
}

{
  library(vroom)
  library(GenomicRanges)
  library(readr)
  MAGMA_fdr = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/all"))
  MAGMA_fdr = MAGMA_fdr[!grepl("CORP", MAGMA_fdr$trait),] # 4274
  MAGMA_fdr$SNP_same_dire = NA # SNP效应方向相同
  MAGMA_fdr$SNP_diff_dire = NA # 效应方向相反
  MAGMA_fdr$SNP_corr = NA # Z值相关性
  MAGMA_fdr$SNP_corr_P = NA # Z值相关性
  
  for(i in 1:6){
    MAGMA_all_tmp = as.data.frame(read_tsv(paste0("/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/all_corr_",i)))
    if(i!=6){
      traits = unique(MAGMA_fdr$trait)[((i-1)*50+1):(i*50)]
    }else{
      traits = unique(MAGMA_fdr$trait)[((i-1)*50+1):293]
    }
    for(j in traits){
      MAGMA_fdr[MAGMA_fdr$trait==j,] = MAGMA_all_tmp[MAGMA_all_tmp$trait==j,]
    }
  }
  MAGMA_fdr[is.na(MAGMA_fdr$SNP_corr_P),] # 只有两个SNP，太少了
  MAGMA_fdr = MAGMA_fdr[!is.na(MAGMA_fdr$SNP_corr),]
  
  length(which(MAGMA_fdr$SNP_corr>0)) # 2616个
  length(which(abs(MAGMA_fdr$SNP_corr)>0.5)) # 3143
  length(which(abs(MAGMA_fdr$SNP_corr)>0.9)) # 567
  length(which(MAGMA_fdr$SNP_corr<(-0.9))) # 157个
  length(which(MAGMA_fdr$SNP_corr<(-0.5))) # 1123个
  ##########相关性直方图分布
  library(ggplot2)
  # 绘制直方图
  hist(MAGMA_fdr$SNP_corr,breaks = 20,col = "#7898CD",xlab = "SNP Z分数在癌症对中的相关性",ylab = "多效基因数",cex.axis = 2, cex.lab = 2)
  ggplot(MAGMA_fdr, aes(x = SNP_corr)) +
    geom_histogram(binwidth = 0.1, color = "black", fill = "#7898CD") +
    scale_x_continuous(limits = c(-1.1, 1.1), breaks = seq(-1, 1, by = 0.1)) +
    labs(x = "SNP Z分数在癌症对中的相关性", y = "多效基因数") +
    theme(
      legend.position = "none",
      panel.grid.major = element_blank(),  # 去除主网格线
      panel.grid.minor = element_blank(),  # 去除次网格线
      panel.background = element_blank(),
      axis.text.x = element_text( size = 12, colour = "black", family = "Arial"),
      axis.text.y = element_text(size = 12, colour = "black", family = "Arial"),
      axis.text.y.right = element_blank(),
      axis.ticks.y.right = element_blank(), 
      axis.title = element_text(size = 14, family = "SimSun"),
      axis.line.x = element_line(color = "black", linewidth = 0.2),  # 显示坐标轴的横线和纵线
      axis.line.y.left = element_line(color = "black", linewidth = 0.2),  # 显示坐标轴的横线和纵线
      # axis.ticks = element_line(color = "black", linewidth = 0.5) 
    )
 

}
######################################################富集分析
###########################
###########################
###########################
###########################
################### 对所有的基因做富集分析
library(org.Hs.eg.db)
library(clusterProfiler)
MAGMA_fdr = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/all"))
MAGMA_fdr = MAGMA_fdr[!grepl("CORP", MAGMA_fdr$trait),] # 4274
length(unique(MAGMA_fdr$GENE)) # 1182
enrich.go = enrichGO(gene = unique(MAGMA_fdr$GENE),  #待富集的基因列表
                     OrgDb = 'org.Hs.eg.db',  #指定物种的基因数据库，示例物种是绵羊（sheep）
                     keyType = 'ENTREZID',  #指定给定的基因名称类型，例如这里以 entrze id 为例
                     ont = 'ALL',  #GO Ontology，可选 BP、MF、CC，也可以指定 ALL 同时计算 3 者
                     pAdjustMethod = 'fdr',  #指定 p 值校正方法
                     pvalueCutoff = 1,  #指定 p 值阈值（可指定 1 以输出全部）
                     qvalueCutoff = 1,  #指定 q 值阈值（可指定 1 以输出全部）
                     readable = T)
enrich.go_table = as.data.frame(enrich.go)
write_tsv(enrich.go_table,"/home/yanyq/share_genetics/final_result/MAGMA/all_gene_go")

KEGG_enrich = enrichKEGG(gene = unique(MAGMA_fdr$GENE), #即待富集的基因列表
                         keyType = "kegg",
                         pAdjustMethod = 'fdr',  #指定p值校正方法
                         organism= "human",  #hsa，可根据你自己要研究的物种更改，可在https://www.kegg.jp/brite/br08611中寻找
                         qvalueCutoff = 1, #指定 p 值阈值（可指定 1 以输出全部）
                         pvalueCutoff=1) #指定 q 值阈值（可指定 1 以输出全部）
KEGG_enrich_table = as.data.frame(KEGG_enrich)
write_tsv(KEGG_enrich_table,"/home/yanyq/share_genetics/final_result/MAGMA/all_gene_kegg")


#气泡图
enrich.go_table = as.data.frame(read_tsv("/home/yanyq/share_genetics/final_result/MAGMA/all_gene_go"))
enrich.go_table = enrich.go_table[enrich.go_table$p.adjust<0.05,]
enrich.go_table$term <- paste(enrich.go_table$ID, enrich.go_table$Description, sep = ': ') #将ID与Description合并成新的一列
table(enrich.go_table$ONTOLOGY)# 217 1 2
enrich.go_table = enrich.go_table[enrich.go_table$ONTOLOGY=="BP",]
enrich.go_table = enrich.go_table[1:20,]
enrich.go_table = enrich.go_table[order(enrich.go_table$p.adjust,decreasing = T),]
enrich.go_table$term = factor(enrich.go_table$term, levels = enrich.go_table$term)
p4 = ggplot(enrich.go_table, 
             aes(x=term, y=Count, fill=pvalue)) +  # 根据 pvalue 排序 term
  geom_bar(stat="identity", width=0.8) +  # 设置柱状图宽度
  scale_fill_gradient(low = "red", high ="blue") +  # 填充颜色渐变#7898CD #E0B673
  ylab("基因数") +  # 设置 y 轴标签
  theme_bw() + 
  theme(
    panel.grid.major = element_blank(),  # 去除主网格线
    panel.grid.minor = element_blank(),  # 去除次网格线
    panel.background = element_blank(),
    axis.text.x = element_text( size = 12, colour = "black", family = "Arial"),
    axis.title.x = element_text(size = 14, colour = "black", family = "SimSun"),
    
    axis.text.y = element_text(size = 12, colour = "black", family = "Arial"),
    axis.text.y.right = element_blank(),
    axis.ticks.y.right = element_blank(), 
    axis.title.y = element_blank(),
    
    
    legend.text = element_text( size = 12, colour = "black", family = "Arial"),
    legend.title = element_text( size = 14, colour = "black", family = "Arial")
  )+coord_flip()

p4 
pdf("~/tmp.pdf", height = 5,width = 10)
p4
dev.off()
################### 对5个以上的基因做富集分析
{
  library(org.Hs.eg.db)
  library(clusterProfiler)
  library(dplyr)
  library(tidyr)
  library(readr)
  MAGMA_fdr = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/all"))
  MAGMA_fdr = MAGMA_fdr[!grepl("CORP", MAGMA_fdr$trait),] # 4274
  length(unique(MAGMA_fdr$GENE)) # 1182
  MAGMA_fdr = separate(MAGMA_fdr, col = "trait", into = c("trait1", "trait2"), sep = "-")
  MAGMA_fdr_cancer = unique(rbind(MAGMA_fdr[,c("GENE", "trait1")],MAGMA_fdr[,c("GENE", "trait2")]%>%dplyr::rename(trait1= "trait2")))
  MAGMA_fdr_frq = as.data.frame(table(MAGMA_fdr_cancer$GENE))
  
  ##########################富集的基因
  MAGMA_fdr_frq$Var1[MAGMA_fdr_frq$Freq>5]
  
  enrich.go = enrichGO(gene = unique(MAGMA_fdr_frq$Var1[MAGMA_fdr_frq$Freq>5]),  #待富集的基因列表
                       OrgDb = 'org.Hs.eg.db',  #指定物种的基因数据库，示例物种是绵羊（sheep）
                       keyType = 'ENTREZID',  #指定给定的基因名称类型，例如这里以 entrze id 为例
                       ont = 'ALL',  #GO Ontology，可选 BP、MF、CC，也可以指定 ALL 同时计算 3 者
                       pAdjustMethod = 'fdr',  #指定 p 值校正方法
                       pvalueCutoff = 1,  #指定 p 值阈值（可指定 1 以输出全部）
                       qvalueCutoff = 1,  #指定 q 值阈值（可指定 1 以输出全部）
                       readable = T)
  enrich.go_table = as.data.frame(enrich.go)
  write_tsv(enrich.go_table,"/home/yanyq/share_genetics/final_result/MAGMA/gene_5cancer_go")
  
  KEGG_enrich = enrichKEGG(gene = unique(MAGMA_fdr_frq$Var1[MAGMA_fdr_frq$Freq>5]), #即待富集的基因列表
                           keyType = "kegg",
                           pAdjustMethod = 'fdr',  #指定p值校正方法
                           organism= "human",  #hsa，可根据你自己要研究的物种更改，可在https://www.kegg.jp/brite/br08611中寻找
                           qvalueCutoff = 1, #指定 p 值阈值（可指定 1 以输出全部）
                           pvalueCutoff=1) #指定 q 值阈值（可指定 1 以输出全部）
  KEGG_enrich_table = as.data.frame(KEGG_enrich)
  write_tsv(KEGG_enrich_table,"/home/yanyq/share_genetics/final_result/MAGMA/gene_5cancer_kegg")
  
  
  #气泡图
  enrich.go_table = as.data.frame(read_tsv("/home/yanyq/share_genetics/final_result/MAGMA/gene_5cancer_go"))
  enrich.go_table = enrich.go_table[enrich.go_table$p.adjust<0.05,]
  enrich.go_table$term <- paste(enrich.go_table$ID, enrich.go_table$Description, sep = ': ') #将ID与Description合并成新的一列
  table(enrich.go_table$ONTOLOGY)# MF 1
  
  KEGG_enrich_table = as.data.frame(read_tsv("/home/yanyq/share_genetics/final_result/MAGMA/gene_5cancer_kegg"))
  KEGG_enrich_table = KEGG_enrich_table[KEGG_enrich_table$p.adjust<0.05,]
  KEGG_enrich_table$term <- paste(KEGG_enrich_table$ID, KEGG_enrich_table$Description, sep = ': ') #将ID与Description合并成新的一列
  
  KEGG_enrich_table = KEGG_enrich_table[order(KEGG_enrich_table$p.adjust,decreasing = T),]
  KEGG_enrich_table$term = factor(KEGG_enrich_table$term, levels = KEGG_enrich_table$term)
  p4 = ggplot(KEGG_enrich_table, 
              aes(x=term, y=Count, fill=p.adjust)) +  # 根据 pvalue 排序 term
    geom_bar(stat="identity", width=0.8) +  # 设置柱状图宽度
    scale_fill_gradient(name  = "FDR", low = "red", high ="blue") +  # 填充颜色渐变#7898CD #E0B673
    ylab("基因数") +  # 设置 y 轴标签
    theme_bw() + 
    theme(
      panel.grid.major = element_blank(),  # 去除主网格线
      panel.grid.minor = element_blank(),  # 去除次网格线
      panel.background = element_blank(),
      axis.text.x = element_text( size = 12, colour = "black", family = "Arial"),
      axis.title.x = element_text(size = 14, colour = "black", family = "SimSun"),
      
      axis.text.y = element_text(size = 12, colour = "black", family = "Arial"),
      axis.text.y.right = element_blank(),
      axis.ticks.y.right = element_blank(), 
      axis.title.y = element_blank(),
      
      
      legend.text = element_text( size = 12, colour = "black", family = "Arial"),
      legend.title = element_text( size = 14, colour = "black", family = "Arial")
    )+coord_flip()
  
  p4 
  pdf("~/tmp.pdf", height = 3,width = 7)
  p4
  dev.off()
  
  ###################提取某些途径基因涉及的癌症
  tmp = MAGMA_fdr[MAGMA_fdr$GENE%in%as.numeric(unlist(strsplit(KEGG_enrich_table$geneID[KEGG_enrich_table$ID=="hsa04917"], "/"))),]# 催乳素
  unique(c(tmp$trait1,tmp$trait2))
  tmp = MAGMA_fdr[MAGMA_fdr$GENE%in%as.numeric(unlist(strsplit(KEGG_enrich_table$geneID[KEGG_enrich_table$ID=="hsa05166"], "/"))),]# 人类 T 细胞白血病病毒 1 感染
  unique(c(tmp$trait1,tmp$trait2))
}


################### 对BCC、SKCM、SCC基因做富集分析
{
  library(org.Hs.eg.db)
  library(clusterProfiler)
  library(dplyr)
  library(tidyr)
  MAGMA_fdr = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/all"))
  MAGMA_fdr = MAGMA_fdr[!grepl("CORP", MAGMA_fdr$trait),] # 4274
  length(unique(MAGMA_fdr$GENE)) # 1182
  MAGMA_fdr = MAGMA_fdr[MAGMA_fdr$trait%in%c("BCC-SCC","BCC-SKCM","SCC-SKCM"),]
  
  MAGMA_fdr = separate(MAGMA_fdr, col = "trait", into = c("trait1", "trait2"), sep = "-")
  MAGMA_fdr_cancer = unique(rbind(MAGMA_fdr[,c("GENE", "trait1")],MAGMA_fdr[,c("GENE", "trait2")]%>%dplyr::rename(trait1= "trait2")))
  MAGMA_fdr_frq = as.data.frame(table(MAGMA_fdr_cancer$GENE)) # 33 49
  
  
  enrich.go = enrichGO(gene = unique(MAGMA_fdr_frq$Var1[MAGMA_fdr_frq$Freq==3]),  #待富集的基因列表
                       OrgDb = 'org.Hs.eg.db',  #指定物种的基因数据库，示例物种是绵羊（sheep）
                       keyType = 'ENTREZID',  #指定给定的基因名称类型，例如这里以 entrze id 为例
                       ont = 'ALL',  #GO Ontology，可选 BP、MF、CC，也可以指定 ALL 同时计算 3 者
                       pAdjustMethod = 'fdr',  #指定 p 值校正方法
                       pvalueCutoff = 1,  #指定 p 值阈值（可指定 1 以输出全部）
                       qvalueCutoff = 1,  #指定 q 值阈值（可指定 1 以输出全部）
                       readable = T)
  enrich.go_table = as.data.frame(enrich.go)
  write_tsv(enrich.go_table,"/home/yanyq/share_genetics/final_result/MAGMA/gene_skin_cancer_go")
  
  KEGG_enrich = enrichKEGG(gene = unique(MAGMA_fdr_frq$Var1[MAGMA_fdr_frq$Freq==3]), #即待富集的基因列表
                           keyType = "kegg",
                           pAdjustMethod = 'fdr',  #指定p值校正方法
                           organism= "human",  #hsa，可根据你自己要研究的物种更改，可在https://www.kegg.jp/brite/br08611中寻找
                           qvalueCutoff = 1, #指定 p 值阈值（可指定 1 以输出全部）
                           pvalueCutoff=1) #指定 q 值阈值（可指定 1 以输出全部）
  KEGG_enrich_table = as.data.frame(KEGG_enrich)
  write_tsv(KEGG_enrich_table,"/home/yanyq/share_genetics/final_result/MAGMA/gene_skin_cancer_kegg")
  
  
  #气泡图
  enrich.go_table = as.data.frame(read_tsv("/home/yanyq/share_genetics/final_result/MAGMA/gene_skin_cancer_go"))
  enrich.go_table = enrich.go_table[enrich.go_table$p.adjust<0.05,]
  enrich.go_table$term <- paste(enrich.go_table$ID, enrich.go_table$Description, sep = ': ') #将ID与Description合并成新的一列
  table(enrich.go_table$ONTOLOGY)# MF 1
  
  
  KEGG_enrich_table = as.data.frame(read_tsv("/home/yanyq/share_genetics/final_result/MAGMA/gene_skin_cancer_kegg"))
  KEGG_enrich_table = KEGG_enrich_table[KEGG_enrich_table$p.adjust<0.05,] # 无
}
################### 对BRCA、PRAD、CESC基因做富集分析
{
  library(org.Hs.eg.db)
  library(clusterProfiler)
  library(dplyr)
  library(tidyr)
  MAGMA_fdr = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/all"))
  MAGMA_fdr = MAGMA_fdr[!grepl("CORP", MAGMA_fdr$trait),] # 4274
  length(unique(MAGMA_fdr$GENE)) # 1182
  MAGMA_fdr = MAGMA_fdr[MAGMA_fdr$trait%in%c("BRCA-PRAD","CESC-BRCA","CESC-PRAD"),]
  
  MAGMA_fdr = separate(MAGMA_fdr, col = "trait", into = c("trait1", "trait2"), sep = "-")
  MAGMA_fdr_cancer = unique(rbind(MAGMA_fdr[,c("GENE", "trait1")],MAGMA_fdr[,c("GENE", "trait2")]%>%dplyr::rename(trait1= "trait2")))
  MAGMA_fdr_frq = as.data.frame(table(MAGMA_fdr_cancer$GENE)) # 2:371 3:26
  
  
  enrich.go = enrichGO(gene = unique(MAGMA_fdr_frq$Var1[MAGMA_fdr_frq$Freq==3]),  #待富集的基因列表
                       OrgDb = 'org.Hs.eg.db',  #指定物种的基因数据库，示例物种是绵羊（sheep）
                       keyType = 'ENTREZID',  #指定给定的基因名称类型，例如这里以 entrze id 为例
                       ont = 'ALL',  #GO Ontology，可选 BP、MF、CC，也可以指定 ALL 同时计算 3 者
                       pAdjustMethod = 'fdr',  #指定 p 值校正方法
                       pvalueCutoff = 1,  #指定 p 值阈值（可指定 1 以输出全部）
                       qvalueCutoff = 1,  #指定 q 值阈值（可指定 1 以输出全部）
                       readable = T)
  enrich.go_table = as.data.frame(enrich.go)
  write_tsv(enrich.go_table,"/home/yanyq/share_genetics/final_result/MAGMA/gene_BRCA_PRAD_CESC_go")
  
  KEGG_enrich = enrichKEGG(gene = unique(MAGMA_fdr_frq$Var1[MAGMA_fdr_frq$Freq==3]), #即待富集的基因列表
                           keyType = "kegg",
                           pAdjustMethod = 'fdr',  #指定p值校正方法
                           organism= "human",  #hsa，可根据你自己要研究的物种更改，可在https://www.kegg.jp/brite/br08611中寻找
                           qvalueCutoff = 1, #指定 p 值阈值（可指定 1 以输出全部）
                           pvalueCutoff=1) #指定 q 值阈值（可指定 1 以输出全部）
  KEGG_enrich_table = as.data.frame(KEGG_enrich)
  write_tsv(KEGG_enrich_table,"/home/yanyq/share_genetics/final_result/MAGMA/gene_BRCA_PRAD_CESC_kegg")
  
  
  #气泡图
  enrich.go_table = as.data.frame(read_tsv("/home/yanyq/share_genetics/final_result/MAGMA/gene_BRCA_PRAD_CESC_go"))
  enrich.go_table = enrich.go_table[enrich.go_table$p.adjust<0.05,]
  enrich.go_table$term <- paste(enrich.go_table$ID, enrich.go_table$Description, sep = ': ') #将ID与Description合并成新的一列
  table(enrich.go_table$ONTOLOGY)# BP 1 CC 4
  
  KEGG_enrich_table = as.data.frame(read_tsv("/home/yanyq/share_genetics/final_result/MAGMA/gene_BRCA_PRAD_CESC_kegg"))
  KEGG_enrich_table = KEGG_enrich_table[KEGG_enrich_table$p.adjust<0.05,] # 无
}
