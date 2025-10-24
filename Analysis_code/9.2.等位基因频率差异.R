library(readr)
library(tidyr)

# 分组样本量
BRCA_sample = 17417
OV_sample = 1170
BRCA_OV_sample = 71
OV_BRCA_sample = 45

# UKB提取的分四组SNP频率
BRCA = read.table("~/share_genetics/data/UKB_multi_cancer/genotype/BRCA_all.frq",header = T)
OV = read.table("~/share_genetics/data/UKB_multi_cancer/genotype/OV_all.frq",header = T)
BRCA_OV = read.table("~/share_genetics/data/UKB_multi_cancer/genotype/BRCA_OV_all.frq",header = T)
OV_BRCA = read.table("~/share_genetics/data/UKB_multi_cancer/genotype/OV_BRCA_all.frq",header = T)

# 分两组频率
single = read.table("~/share_genetics/data/UKB_multi_cancer/genotype/all_single.frq",header = T)
multi = read.table("~/share_genetics/data/UKB_multi_cancer/genotype/all_multi.frq",header = T)

# 多效SNP
raw_BRCA_OV = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer_MAGMA_SMR"))
raw_BRCA_OV = raw_BRCA_OV[raw_BRCA_OV$traits=="BRCA-OV",]
raw_BRCA_OV$SNP = paste0(raw_BRCA_OV$snpid,":",raw_BRCA_OV$a1,":",raw_BRCA_OV$a2)

{# 所有SNP
  {
    BRCA_cur = BRCA[BRCA$SNP%in%raw_BRCA_OV$SNP,] # 剩下的14个为基因型不一致的复等位基因
    OV_cur = OV[OV$SNP%in%raw_BRCA_OV$SNP,]
    BRCA_OV_cur = BRCA_OV[BRCA_OV$SNP%in%raw_BRCA_OV$SNP,]
    OV_BRCA_cur = OV_BRCA[OV_BRCA$SNP%in%raw_BRCA_OV$SNP,]
    
    colnames(BRCA_cur) = paste0(colnames(BRCA_cur),".BRCA")
    colnames(OV_cur) = paste0(colnames(OV_cur),".OV")
    colnames(BRCA_OV_cur) = paste0(colnames(BRCA_OV_cur),".BRCA_OV")
    colnames(OV_BRCA_cur) = paste0(colnames(OV_BRCA_cur),".OV_BRCA")
    all = merge(BRCA_cur[,c(2,5)],OV_cur[,c(2,5)],by.x = "SNP.BRCA",by.y = "SNP.OV")
    all = merge(all,BRCA_OV_cur[,c(2,5)],by.x = "SNP.BRCA",by.y = "SNP.BRCA_OV")
    all = merge(all,OV_BRCA_cur[,c(2,5)],by.x = "SNP.BRCA",by.y = "SNP.OV_BRCA")
    
    # 箱线图
    library(ggplot2)#绘图包
    library(ggpubr)#基于ggplot2的可视化包，主要用于绘制符合出版要求的图形
    library(ggsignif)#用于P值计算和显著性标记
    library(tidyverse)#数据预处理
    library(ggprism)#提供了GraphPad prism风格的主题和颜色，主要用于美化我们的图形
    
    df = all[,2:5]%>%gather(key = 'group',value = 'values') #gather()函数可以把多列数据合并成一列数据
    df$values[df$values>0.5] = 1-df$values[df$values>0.5]
    df$group = factor(df$group,levels = c("MAF.BRCA","MAF.OV","MAF.BRCA_OV","MAF.OV_BRCA"))
    ggplot(df,aes(x=group,y=values))+#指定数据
      stat_boxplot(geom = "errorbar", width=0.1,linewidth=0.8)+#添加误差线,注意位置，放到最后则这条先不会被箱体覆盖
      geom_boxplot(aes(fill=group), #绘制箱线图函数
                   outlier.colour="white",linewidth=0.8)+ 
      geom_signif(comparisons = list(c("MAF.BRCA","MAF.OV"),c("MAF.BRCA","MAF.BRCA_OV"),c("MAF.BRCA","MAF.OV_BRCA"),
                                     c("MAF.OV","MAF.BRCA_OV"),c("MAF.OV","MAF.OV_BRCA"),c("MAF.BRCA_OV","MAF.OV_BRCA")),#设置需要比较的组
                  test = wilcox.test, ##计算方法
                  y_position = c(0.5,0.6,0.7,0.8,0.9,1.0),#图中横线位置设置
                  tip_length = c(c(0.05,0.05),c(0.05,0.05),c(0.05,0.05)),#横线下方的竖线设置
                  size=0.8,color="black")
  }
  {
    {
      single_cur = single[single$SNP%in%raw_BRCA_OV$SNP,]
      multi_cur = multi[multi$SNP%in%raw_BRCA_OV$SNP,]
      
      colnames(single_cur) = paste0(colnames(single_cur),".single")
      colnames(multi_cur) = paste0(colnames(multi_cur),".multi")
      all = merge(single_cur[,c(2,5)],multi_cur[,c(2,5)],by.x = "SNP.single",by.y = "SNP.multi")
      
      df = all[,2:3]%>%gather(key = 'group',value = 'values') #gather()函数可以把多列数据合并成一列数据
      df$values[df$values>0.5] = 1-df$values[df$values>0.5]
      df$group = factor(df$group,levels = c("MAF.single","MAF.multi"))
      ggplot(df,aes(x=group,y=values))+#指定数据
        stat_boxplot(geom = "errorbar", width=0.1,linewidth=0.8)+#添加误差线,注意位置，放到最后则这条先不会被箱体覆盖
        geom_boxplot(aes(fill=group), #绘制箱线图函数
                     outlier.colour="white",linewidth=0.8)+ 
        geom_signif(comparisons = list(c("MAF.single","MAF.multi")),#设置需要比较的组
                    test = wilcox.test, ##计算方法
                    y_position = c(0.5,0.6,0.7,0.8,0.9,1.0),#图中横线位置设置
                    tip_length = c(c(0.05,0.05),c(0.05,0.05),c(0.05,0.05)),#横线下方的竖线设置
                    size=0.8,color="black")
    }
  }
  
  # df = all[,2:5]%>%gather(key = 'group',value = 'values')
  # df$values[df$values>0.5] = 1-df$values[df$values>0.5]
  # df$group[df$group=="MAF.OV_BRCA"] = "MAF.BRCA_OV"
  # df$group = factor(df$group,levels = c("MAF.BRCA","MAF.OV","MAF.BRCA_OV"))
  # ggplot(df,aes(x=group,y=values))+#指定数据
  #   stat_boxplot(geom = "errorbar", width=0.1,linewidth=0.8)+#添加误差线,注意位置，放到最后则这条先不会被箱体覆盖
  #   geom_boxplot(aes(fill=group), #绘制箱线图函数
  #                outlier.colour="white",linewidth=0.8)+ 
  #   geom_signif(comparisons = list(c("MAF.BRCA","MAF.OV"),c("MAF.BRCA","MAF.BRCA_OV"),
  #                                  c("MAF.OV","MAF.BRCA_OV")),#设置需要比较的组
  #               test = wilcox.test, ##计算方法
  #               y_position = c(0.5,0.6,0.7,0.8,0.9,1.0),#图中横线位置设置
  #               tip_length = c(c(0.05,0.05),c(0.05,0.05),c(0.05,0.05)),#横线下方的竖线设置
  #               size=0.8,color="black")
  # 
  # df = all[,2:5]%>%gather(key = 'group',value = 'values')
  # df$values[df$values>0.5] = 1-df$values[df$values>0.5]
  # df$group[df$group=="MAF.OV_BRCA"] = "MAF.BRCA_OV"
  # df$group[df$group=="MAF.BRCA_OV"] = "BRCA and OV"
  # df$group[df$group=="MAF.BRCA"|df$group=="MAF.OV"] = "BRCA or OV"
  # df$group = factor(df$group,levels = c("BRCA or OV","BRCA and OV"))
  # ggplot(df,aes(x=group,y=values))+#指定数据
  #   stat_boxplot(geom = "errorbar", width=0.1,linewidth=0.8)+#添加误差线,注意位置，放到最后则这条先不会被箱体覆盖
  #   geom_boxplot(aes(fill=group), #绘制箱线图函数
  #                outlier.colour="white",linewidth=0.8)+ 
  #   geom_signif(comparisons = list(c("BRCA or OV","BRCA and OV")),#设置需要比较的组
  #               test = wilcox.test, ##计算方法
  #               y_position = c(0.5,0.6,0.7,0.8,0.9,1.0),#图中横线位置设置
  #               tip_length = c(c(0.05,0.05),c(0.05,0.05),c(0.05,0.05)),#横线下方的竖线设置
  #               size=0.8,color="black")
}

# {# lead SNP
#   {
#     lead_BRCA_OV = raw_BRCA_OV[raw_BRCA_OV$is.IndSig_lead=="leadSNP",]
#     BRCA_cur = BRCA[BRCA$SNP%in%lead_BRCA_OV$SNP,] # 剩下的14个为基因型不一致的复等位基因
#     OV_cur = OV[OV$SNP%in%lead_BRCA_OV$SNP,]
#     BRCA_OV_cur = BRCA_OV[BRCA_OV$SNP%in%lead_BRCA_OV$SNP,]
#     OV_BRCA_cur = OV_BRCA[OV_BRCA$SNP%in%lead_BRCA_OV$SNP,]
#     
#     colnames(BRCA_cur) = paste0(colnames(BRCA_cur),".BRCA")
#     colnames(OV_cur) = paste0(colnames(OV_cur),".OV")
#     colnames(BRCA_OV_cur) = paste0(colnames(BRCA_OV_cur),".BRCA_OV")
#     colnames(OV_BRCA_cur) = paste0(colnames(OV_BRCA_cur),".OV_BRCA")
#     all = merge(BRCA_cur[,c(2,5)],OV_cur[,c(2,5)],by.x = "SNP.BRCA",by.y = "SNP.OV")
#     all = merge(all,BRCA_OV_cur[,c(2,5)],by.x = "SNP.BRCA",by.y = "SNP.BRCA_OV")
#     all = merge(all,OV_BRCA_cur[,c(2,5)],by.x = "SNP.BRCA",by.y = "SNP.OV_BRCA")
#     
#     df = all[,2:5]%>%gather(key = 'group',value = 'values') #gather()函数可以把多列数据合并成一列数据
#     df$values[df$values>0.5] = 1-df$values[df$values>0.5]
#     df$group = factor(df$group,levels = c("MAF.BRCA","MAF.OV","MAF.BRCA_OV","MAF.OV_BRCA"))
#     ggplot(df,aes(x=group,y=values))+#指定数据
#       stat_boxplot(geom = "errorbar", width=0.1,linewidth=0.8)+#添加误差线,注意位置，放到最后则这条先不会被箱体覆盖
#       geom_boxplot(aes(fill=group), #绘制箱线图函数
#                    outlier.colour="white",linewidth=0.8)+
#       geom_signif(comparisons = list(c("MAF.BRCA","MAF.OV"),c("MAF.BRCA","MAF.BRCA_OV"),c("MAF.BRCA","MAF.OV_BRCA"),
#                                      c("MAF.OV","MAF.BRCA_OV"),c("MAF.OV","MAF.OV_BRCA"),c("MAF.BRCA_OV","MAF.OV_BRCA")),#设置需要比较的组
#                   test = wilcox.test, ##计算方法
#                   y_position = c(0.5,0.6,0.7,0.8,0.9,1.0),#图中横线位置设置
#                   tip_length = c(c(0.05,0.05),c(0.05,0.05),c(0.05,0.05)),#横线下方的竖线设置
#                   size=0.8,color="black")
#   }
# 
#   {
#     {
#       single_cur = single[single$SNP%in%lead_BRCA_OV$SNP,]
#       multi_cur = multi[multi$SNP%in%lead_BRCA_OV$SNP,]
#       
#       colnames(single_cur) = paste0(colnames(single_cur),".single")
#       colnames(multi_cur) = paste0(colnames(multi_cur),".multi")
#       all = merge(single_cur[,c(2,5)],multi_cur[,c(2,5)],by.x = "SNP.single",by.y = "SNP.multi")
#       
#       df = all[,2:3]%>%gather(key = 'group',value = 'values') #gather()函数可以把多列数据合并成一列数据
#       df$values[df$values>0.5] = 1-df$values[df$values>0.5]
#       df$group = factor(df$group,levels = c("MAF.single","MAF.multi"))
#       ggplot(df,aes(x=group,y=values))+#指定数据
#         stat_boxplot(geom = "errorbar", width=0.1,linewidth=0.8)+#添加误差线,注意位置，放到最后则这条先不会被箱体覆盖
#         geom_boxplot(aes(fill=group), #绘制箱线图函数
#                      outlier.colour="white",linewidth=0.8)+ 
#         geom_signif(comparisons = list(c("MAF.single","MAF.multi")),#设置需要比较的组
#                     test = wilcox.test, ##计算方法
#                     y_position = c(0.5,0.6,0.7,0.8,0.9,1.0),#图中横线位置设置
#                     tip_length = c(c(0.05,0.05),c(0.05,0.05),c(0.05,0.05)),#横线下方的竖线设置
#                     size=0.8,color="black")
#     }
#   }
# }

{# 独立显著
  {
    lead_BRCA_OV = raw_BRCA_OV[raw_BRCA_OV$is.IndSig_lead!="not",]
    BRCA_cur = BRCA[BRCA$SNP%in%lead_BRCA_OV$SNP,] # 剩下的14个为基因型不一致的复等位基因
    OV_cur = OV[OV$SNP%in%lead_BRCA_OV$SNP,]
    BRCA_OV_cur = BRCA_OV[BRCA_OV$SNP%in%lead_BRCA_OV$SNP,]
    OV_BRCA_cur = OV_BRCA[OV_BRCA$SNP%in%lead_BRCA_OV$SNP,]
    
    colnames(BRCA_cur) = paste0(colnames(BRCA_cur),".BRCA")
    colnames(OV_cur) = paste0(colnames(OV_cur),".OV")
    colnames(BRCA_OV_cur) = paste0(colnames(BRCA_OV_cur),".BRCA_OV")
    colnames(OV_BRCA_cur) = paste0(colnames(OV_BRCA_cur),".OV_BRCA")
    all = merge(BRCA_cur[,c(2,5)],OV_cur[,c(2,5)],by.x = "SNP.BRCA",by.y = "SNP.OV")
    all = merge(all,BRCA_OV_cur[,c(2,5)],by.x = "SNP.BRCA",by.y = "SNP.BRCA_OV")
    all = merge(all,OV_BRCA_cur[,c(2,5)],by.x = "SNP.BRCA",by.y = "SNP.OV_BRCA")
    
    df = all[,2:5]%>%gather(key = 'group',value = 'values') #gather()函数可以把多列数据合并成一列数据
    df$values[df$values>0.5] = 1-df$values[df$values>0.5]
    df$group = factor(df$group,levels = c("MAF.BRCA","MAF.OV","MAF.BRCA_OV","MAF.OV_BRCA"))
    ggplot(df,aes(x=group,y=values))+#指定数据
      stat_boxplot(geom = "errorbar", width=0.1,linewidth=0.8)+#添加误差线,注意位置，放到最后则这条先不会被箱体覆盖
      geom_boxplot(aes(fill=group), #绘制箱线图函数
                   outlier.colour="white",linewidth=0.8)+ 
      geom_signif(comparisons = list(c("MAF.BRCA","MAF.OV"),c("MAF.BRCA","MAF.BRCA_OV"),c("MAF.BRCA","MAF.OV_BRCA"),
                                     c("MAF.OV","MAF.BRCA_OV"),c("MAF.OV","MAF.OV_BRCA"),c("MAF.BRCA_OV","MAF.OV_BRCA")),#设置需要比较的组
                  test = wilcox.test, ##计算方法
                  y_position = c(0.5,0.6,0.7,0.8,0.9,1.0),#图中横线位置设置
                  tip_length = c(c(0.05,0.05),c(0.05,0.05),c(0.05,0.05)),#横线下方的竖线设置
                  size=0.8,color="black")
  }
  {
    single_cur = single[single$SNP%in%lead_BRCA_OV$SNP,]
    multi_cur = multi[multi$SNP%in%lead_BRCA_OV$SNP,]
    
    colnames(single_cur) = paste0(colnames(single_cur),".single")
    colnames(multi_cur) = paste0(colnames(multi_cur),".multi")
    all = merge(single_cur[,c(2,5)],multi_cur[,c(2,5)],by.x = "SNP.single",by.y = "SNP.multi")
    
    df = all[,2:3]%>%gather(key = 'group',value = 'values') #gather()函数可以把多列数据合并成一列数据
    df$values[df$values>0.5] = 1-df$values[df$values>0.5]
    df$group = factor(df$group,levels = c("MAF.single","MAF.multi"))
    ggplot(df,aes(x=group,y=values))+#指定数据
      stat_boxplot(geom = "errorbar", width=0.1,linewidth=0.8)+#添加误差线,注意位置，放到最后则这条先不会被箱体覆盖
      geom_boxplot(aes(fill=group), #绘制箱线图函数
                   outlier.colour="white",linewidth=0.8)+ 
      geom_signif(comparisons = list(c("MAF.single","MAF.multi")),#设置需要比较的组
                  test = wilcox.test, ##计算方法
                  y_position = c(0.5,0.6,0.7,0.8,0.9,1.0),#图中横线位置设置
                  tip_length = c(c(0.05,0.05),c(0.05,0.05),c(0.05,0.05)),#横线下方的竖线设置
                  size=0.8,color="black")
  }
}

