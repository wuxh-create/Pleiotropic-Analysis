setwd("/home/yanyq/share_genetics/data/TCGA/expression")
library(vroom)
library(readr)
library(dplyr)
library(data.table)
files = list.files()
files = files[!files%in%c("gdc_sample_sheet.2024-05-27.tsv","gdc_manifest_expression.2024-05-27.txt", "tt.sh", "tt")]
samples = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/TCGA/expression/gdc_sample_sheet.2024-05-27.tsv"))
files[!files%in%samples$`File ID`]
samples$`File ID`[!samples$`File ID`%in%files]
samples$file_path = paste0(samples$`File ID`,"/",samples$`File Name`)
# tmp = samples
# tmp$V1 = "wc -l"
# write_tsv(tmp[,c("V1", "file_path")],"tt.sh", col_names = F)

# 筛选癌症样本
tmp1 = samples[grep("01A",samples$`Sample ID`),]
tmp2 = samples[grep("03A",samples$`Sample ID`),]
samples = rbind(tmp1,tmp2)

# # 重复样本
# dup = samples[samples$`Sample ID`%in%samples$`Sample ID`[duplicated(samples$`Sample ID`)],]
# which(table(dup$`Sample ID`)!=2) # 只有两个重复样本
# # 判断两个样本之间表达量是否存在显著差异
# expression_diff = data.frame(sample = unique(dup$`Sample ID`), p = numeric(length = length(unique(dup$`Sample ID`))))
# for(sample_id in unique(dup$`Sample ID`)) {
#   tmp_samples = samples[samples$`Sample ID`==sample_id,]
#   if(nrow(tmp_samples)==2){
#     tmp1 = as.data.frame(fread(tmp_samples$file_path[1]))
#     tmp2 = as.data.frame(fread(tmp_samples$file_path[2]))
#     tmp1 = tmp1$fpkm_unstranded[-(1:4)]
#     tmp2 = tmp2$fpkm_unstranded[-(1:4)]
#     tmp = t.test(tmp1, tmp2, paired = TRUE)
#     expression_diff$p[expression_diff$sample==sample_id] = tmp$p.value
#   }else{
#     print(sample_id)
#   }
# }

# 对于重复样本任意选择一个样本
samples = samples[!duplicated(samples$`Sample ID`),]
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
