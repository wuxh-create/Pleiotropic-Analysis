setwd("/home/yanyq/share_genetics/data/TCGA/expression")
library(vroom)
library(readr)
library(dplyr)
library(data.table)
files = list.files()
files = files[!files%in%c("gdc_sample_sheet.2024-05-27.tsv","gdc_manifest_expression.2024-05-27.txt", "tt.sh", "tt")]
which(nchar(files)!=36)
samples = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/TCGA/expression/gdc_sample_sheet.2024-05-27.tsv"))
files[!files%in%samples$`File ID`]
samples$`File ID`[!samples$`File ID`%in%files]
samples$file_path = paste0(samples$`File ID`,"/",samples$`File Name`)

# 保留正常样本，WGCNA的模块需要与分组进行关联，识别癌症重要模块
samples = samples[c(grep("01A",samples$`Sample ID`),grep("03A",samples$`Sample ID`),
                    grep("11A",samples$`Sample ID`)),] # 原发癌/原发性血液来源的癌症-外周血/正常组织
# 10592个样本

# 对于重复样本任意选择一个样本
# 每个project重复样本的情况
table(samples[duplicated(samples$`Sample ID`),"Project ID"])
# TCGA-BLCA TCGA-BRCA TCGA-COAD  TCGA-GBM TCGA-KIRC TCGA-LIHC TCGA-LUAD TCGA-LUSC TCGA-UCEC 
# 3         5        10         1         4         1        11         1         4
samples = samples[!duplicated(samples$`Sample ID`),]
write_tsv(samples,"/home/yanyq/share_genetics/data/TCGA/samples_tumor_normal")
# 保留10552个样本

# 统计每个project case和narmal数目
case_normal_num = as.data.frame(matrix(nrow = length(unique(samples$`Project ID`)), ncol = 3))
colnames(case_normal_num) = c("project", "case", "normal")
case_normal_num$project = unique(samples$`Project ID`)
for(i in 1:nrow(case_normal_num)){
  tmp_samples = samples[samples$`Project ID`==case_normal_num$project[i],]
  case_normal_num$case[i] = table(tmp_samples$`Sample Type`)[1]
  case_normal_num$normal[i] = table(tmp_samples$`Sample Type`)[2]
}
# 去除normal数小于等于5的project
case_normal_num = na.omit(case_normal_num)
case_normal_num = case_normal_num[case_normal_num$normal>5,] # 17个
samples = samples[samples$`Project ID`%in%case_normal_num$project,] # 7721个样本
case_normal_num[case_normal_num$project=="TCGA-KIRP",] = c("kidney",66+529+289,25+72+32)
case_normal_num[case_normal_num$project=="TCGA-LUAD",] = c("lung",513+496,58+51)
case_normal_num[case_normal_num$project=="TCGA-COAD",] = c("CRC",455+163,41+10)
case_normal_num$project = gsub("TCGA-","",case_normal_num$project)
case_normal_num = case_normal_num[!case_normal_num$project%in%c("KIRP","KIRC","KICH","LUAD","LUSC","COAD","READ"),]
case_normal_num$case = as.numeric(case_normal_num$case)
case_normal_num$normal = as.numeric(case_normal_num$normal)
sum(case_normal_num[,2:3])
# 样本数直方图
{
  library(showtext)
  library(stringr)
  
  showtext_auto()
  font_add("SimSun", "/home/yanyq/usr/share/font/simsun.ttc")  # 使用宋体（SimSun）
  
  data = rbind(case_normal_num,case_normal_num)
  data$case[14:26] = data$normal[14:26]
  data$normal[1:13] = "Cancer"
  data$normal[14:26] = "Normal"
  # 绘制直方图
  ggplot(data, aes(x = project, y = case, fill = normal)) +
    geom_bar(stat = "identity", position = "dodge") +
    labs( x = "癌症类型", y = "样本数") +
    theme_minimal() +
    scale_y_continuous(expand = c(0, 0), limits = c(0,1200)) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    scale_fill_manual(values = c("Normal" = "#377EB8", "Cancer" = "#E41A1C"))+theme_bw() +
    theme(panel.grid.major = element_blank(), # 去除主网格线
          panel.grid.minor = element_blank(),  # 去除次网格线
          panel.background = element_blank(),
          axis.text = element_text(size = 15, colour = "black", family = "sans"),
          axis.text.x = element_text(angle = 90, hjust = 1),
          axis.title = element_text(size = 15, family = "SimSun"),
          legend.location = "right",
          legend.title = element_blank(),
          legend.key.size = unit(1, "lines"),
          legend.text = element_text(size = 15, family = "sans"))
  
  
}
  
# 整合表达量
for(project in unique(samples$`Project ID`)){
  tmp_samples = samples[samples$`Project ID`==project,]
  expression = as.data.frame(fread(tmp_samples$file_path[1]))
  expression = expression[,c(1,2,7)]
  # rownames(expression) = expression[,1]
  colnames(expression)[3] = tmp_samples$`Sample ID`[1]
  for(i in 2:nrow(tmp_samples)){
    tmp_expression = as.data.frame(fread(tmp_samples$file_path[i]))
    expression = left_join(expression, tmp_expression[,c("gene_id", "fpkm_unstranded")], by = "gene_id")
    colnames(expression)[i+2] = tmp_samples$`Sample ID`[i]
  }
  write_tsv(expression,paste0("/home/yanyq/share_genetics/data/TCGA/expression_merged/",project))
}