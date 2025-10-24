# 从GWAS catalog下载了所有top的关联（GWAS catalog检索性状得到的表格给的也是top关联，非top的只有summary数据里有）
# 下载时间：2024.7.25
# 点击了MAPPED_TRAIT_URI里所有的连接，筛选cancer or benign分类下的性状
library(readr)
library(tidyverse)
top_asso = as.data.frame(read_tsv("/home/yanyq/data/gwas_catalog_v1.0.2-associations/gwas_catalog_v1.0.2-associations_e112_r2024-07-08.tsv"))
top_asso$row_num = 1:nrow(top_asso)
top_asso_num = top_asso[, c("row_num","MAPPED_TRAIT_URI")]
# 拆分逗号分割的列，获取所有本体的链接
top_asso_num =  top_asso_num %>%
  separate_rows(MAPPED_TRAIT_URI, sep = ", ")
write_tsv(as.data.frame(unique(top_asso_num$MAPPED_TRAIT_URI)), "/home/yanyq/data/gwas_catalog_v1.0.2-associations/gwas_catalog_v1.0.2_ontology_URI", col_names = F)
# 筛选后的cancer ontology
cancer_ontology = as.data.frame(read.table("/home/yanyq/data/gwas_catalog_v1.0.2-associations/gwas_catalog_v1.0.2-cancer_or_benign_ontology.txt", header = F))
# C: cancer; H: hematopoietic and lymphoid system neoplasm; S: nervous system disease; U: neoplasm，不确定恶性还是良性; N: 非癌（息肉、纤维化、肝硬化）

top_asso_cancer = top_asso_num[top_asso_num$MAPPED_TRAIT_URI%in%cancer_ontology$V1[cancer_ontology$V2!="N"],]
top_asso_cancer = top_asso[unique(top_asso_cancer$row_num),]
write_tsv(top_asso_cancer, "/home/yanyq/data/gwas_catalog_v1.0.2-associations/gwas_catalog_v1.0.2-cancer.txt")

{# SNP筛选
  top_asso_cancer = as.data.frame(read_tsv("/home/yanyq/data/gwas_catalog_v1.0.2-associations/gwas_catalog_v1.0.2-cancer.txt"))
  top_asso_cancer = top_asso_cancer[!is.na(top_asso_cancer$CHR_ID),]
  # ID 为9;9;9;9;9;9;9;9;9;9;9;9;9;9;9，一行包含了多个SNP
  top_asso_cancer = top_asso_cancer[!grepl(";", top_asso_cancer$CHR_ID),]
  # 上位性
  top_asso_cancer = top_asso_cancer[!grepl("x", top_asso_cancer$CHR_ID),]
  top_asso_cancer = top_asso_cancer[top_asso_cancer$CHR_ID!="X",]
  top_asso_cancer$CHR_ID = as.numeric(top_asso_cancer$CHR_ID) 
  top_asso_cancer$CHR_POS = as.numeric(top_asso_cancer$CHR_POS)
  # # 注释癌症类型
  # top_asso_cancer$trait = NA
  # top_asso_cancer$trait[grep("breast", top_asso_cancer$`DISEASE/TRAIT`)] = "BRCA"
  # top_asso_cancer$trait[grep("Breast", top_asso_cancer$`DISEASE/TRAIT`)] = "BRCA"
  # top_asso_cancer$trait[grep("Acute myeloid leukemia", top_asso_cancer$`DISEASE/TRAIT`)] = "AML"
  # top_asso_cancer$trait[grep("Esophageal", top_asso_cancer$`DISEASE/TRAIT`)] = "ESCA"  
  # top_asso_cancer$trait[grep("esophageal", top_asso_cancer$`DISEASE/TRAIT`)] = "ESCA"  
  # 
  # top_asso_cancer$trait[grep("Bladder", top_asso_cancer$`DISEASE/TRAIT`)] = "BLCA" 
  # bladder 
  # top_asso_cancer$trait[grep("prostate", top_asso_cancer$`DISEASE/TRAIT`)] = "PRAD" 
  # top_asso_cancer$trait[grep("Colorectal", top_asso_cancer$`DISEASE/TRAIT`)] = "CRC"
  # top_asso_cancer$trait[grep("Colon", top_asso_cancer$`DISEASE/TRAIT`)] = "CRC"
  # top_asso_cancer$trait[grep("colon", top_asso_cancer$`DISEASE/TRAIT`)] = "CRC"
  #  
  # top_asso_cancer$trait[grep("Cervical", top_asso_cancer$`DISEASE/TRAIT`)] = "CESC"
  # top_asso_cancer$trait[grep("lung", top_asso_cancer$`DISEASE/TRAIT`)] = "lung"
  # top_asso_cancer$trait[grep("Lung", top_asso_cancer$`DISEASE/TRAIT`)] = "lung"
  # top_asso_cancer$trait[grep("Endometrial", top_asso_cancer$`DISEASE/TRAIT`)] = "UCEC" 
  # top_asso_cancer$trait[grep("Kidney", top_asso_cancer$`DISEASE/TRAIT`)] = "kidney"
  # top_asso_cancer$trait[grep("renal", top_asso_cancer$`DISEASE/TRAIT`)] = "kidney" 
  # top_asso_cancer$trait[grep("Renal", top_asso_cancer$`DISEASE/TRAIT`)] = "kidney" 
  # top_asso_cancer$trait[grep("Prostate", top_asso_cancer$`DISEASE/TRAIT`)] = "PRAD" 
  # top_asso_cancer$trait[grep("Basal cell carcinoma", top_asso_cancer$`DISEASE/TRAIT`)] = "BCC" 
  # top_asso_cancer$trait[grep("Melanoma", top_asso_cancer$`DISEASE/TRAIT`)] = "SKCM" 
  # top_asso_cancer$trait[grep("ovarian", top_asso_cancer$`DISEASE/TRAIT`)] = "OV"
  # top_asso_cancer$trait[grep("Ovarian", top_asso_cancer$`DISEASE/TRAIT`)] = "OV"
  # top_asso_cancer$trait[grep("Pancreatic", top_asso_cancer$`DISEASE/TRAIT`)] = "PAAD" 
  # top_asso_cancer$trait[grep("Gastric", top_asso_cancer$`DISEASE/TRAIT`)] = "STAD" 
  # top_asso_cancer$trait[grep("Thyroid", top_asso_cancer$`DISEASE/TRAIT`)] = "THCA" 
  # top_asso_cancer$trait[grep("Testicular", top_asso_cancer$`DISEASE/TRAIT`)] = "TEST" 
  # top_asso_cancer$trait[grep("Glioblastoma", top_asso_cancer$`DISEASE/TRAIT`)] = "BGA" 
  # top_asso_cancer$trait[grep("Multiple myeloma", top_asso_cancer$`DISEASE/TRAIT`)] = "MM" 
  # top_asso_cancer$trait[grep("Diffuse large B cell lymphoma", top_asso_cancer$`DISEASE/TRAIT`)] = "DLBC" 
  # 
  #   
  #   
  # tmp = as.data.frame(table(top_asso_cancer$`DISEASE/TRAIT`[is.na(top_asso_cancer$trait)]))
  # tmp$Var1[grep("bladder",tmp$Var1)]
}

cancer_SNP = unique(top_asso_cancer[,c("SNPS", "CHR_ID", "CHR_POS", "REGION")])

# # GWASlab注释
# #######################gwaslab
# cancer_SNP_tmp = cancer_SNP[,1:3]
# cancer_SNP_tmp[,2:3] = NA
# colnames(cancer_SNP_tmp) = c("SNP","chr","pos")
# write_tsv(cancer_SNP_tmp, "/home/yanyq/data/gwas_catalog_v1.0.2-associations/gwas_catalog_v1.0.2-cancerSNP_beforeGL.txt")
# import gwaslab as gl
# mysumstats = gl.Sumstats("/home/yanyq/data/gwas_catalog_v1.0.2-associations/gwas_catalog_v1.0.2-cancerSNP_beforeGL.txt", snpid="SNP",chrom = "chr",pos = "pos")
# mysumstats.data['rsID'] = mysumstats.data['SNPID']
# mysumstats.data['CHR'] = mysumstats.data['CHR'].astype('Int64')
# mysumstats.data['POS'] = mysumstats.data['POS'].astype('Int64')
# mysumstats.data['CHR'].dtypes
# mysumstats.data['POS'].dtypes
# mysumstats.rsid_to_chrpos2(path="/home/yanyq/software/rsidmap/dbsnp/GCF_000001405.25.gz.rsID_CHR_POS_groups_20000000.h5")
# mysumstats.data.to_csv("/home/yanyq/data/gwas_catalog_v1.0.2-associations/gwas_catalog_v1.0.2-cancerSNP_afterGL.txt",header = True, index = False, sep = "\t")
# ##############################
all_PLACO = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer_MAGMA_SMR"))
PLACO_SNP = unique(all_PLACO[,c("snpid", "hg19chr", "bp")])
lead_PLACO_SNP = PLACO_SNP[PLACO_SNP$snpid%in%cancer_SNP$SNPS,]
write_tsv(lead_PLACO_SNP, "/home/yanyq/share_genetics/result/PLACO/all_lead_GWAS_cancer_SNP")

cancer_SNP = split(cancer_SNP, cancer_SNP$CHR_ID)
PLACO_SNP = PLACO_SNP[!(PLACO_SNP$snpid%in%cancer_SNP$SNPS),]
colnames(PLACO_SNP) = c("SNPS","CHR_ID","CHR_POS")
PLACO_SNP = split(PLACO_SNP, PLACO_SNP$CHR_ID)

library(LDlinkR)
library(pbmcapply)
# 计算多效SNP和GWAS catalog中的SNP的LD
# 寻找需要计算LD的SNP对，后面并行计算
{
  calculate_LD <- function(A_chr, B_chr, max_distance = 500000) {
    results <- list()
    for (i in 1:nrow(A_chr)) {
      for (j in 1:nrow(B_chr)) {
        if (A_chr$CHR_ID[i] == B_chr$CHR_ID[j]) {
          distance <- abs(A_chr$CHR_POS[i] - B_chr$CHR_POS[j])
          if (distance <= max_distance) {
            result = data.frame(PLACO = A_chr$SNPS[i], cancer = B_chr$SNPS[j])
            results <- c(results, list(result))
          }
        }
      }
    }
    results = do.call(rbind, results)
    return(results)
  }
  
  # 初始化结果和错误列表
  LD_results <- list()
  
  # 对每个染色体进行计算
  for (chr in 1:22) {
    print(chr)
    LD_results[[chr]] <- calculate_LD(PLACO_SNP[[chr]], cancer_SNP[[chr]])
  }
  LD_results = do.call(rbind, LD_results)
  write_tsv(LD_results,"/home/yanyq/share_genetics/result/GWAS_catalog/to_calculate_LDpair")
  
  ######################上面只计算了多效SNP和GWAS catalog中癌症SNP的LD
  # 还需计算多效SNP中显著和不显著之间的LD
  all_PLACO = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer_MAGMA_SMR"))
  write_tsv(as.data.frame(unique(all_PLACO$snpid)),"/home/yanyq/share_genetics/result/GWAS_catalog/to_calculate_LD_plinkinput", col_names = F)
  # plink --bfile /home/yanyq/share_genetics/data/MAGMA/g1000_eur/g1000_eur --extract /home/yanyq/share_genetics/result/GWAS_catalog/to_calculate_LD_plinkinput --r2 --ld-window-kb 500 --ld-window-r2 0.5 --ld-snp-list /home/yanyq/share_genetics/result/GWAS_catalog/to_calculate_LD_plinkinput --out /home/yanyq/share_genetics/result/GWAS_catalog/PLACO_LD_0.5
  PLACO_SNP_sig = unique(all_PLACO[all_PLACO$sig_GWAS!=0,c("snpid", "hg19chr", "bp")])
  PLACO_SNP_not = unique(all_PLACO[(all_PLACO$sig_GWAS==0)&(!all_PLACO$snpid%in%PLACO_SNP_sig$snpid),c("snpid", "hg19chr", "bp")])
  colnames(PLACO_SNP_sig) = c("SNPS","CHR_ID","CHR_POS")
  PLACO_SNP_sig = split(PLACO_SNP_sig, PLACO_SNP_sig$CHR_ID)
  colnames(PLACO_SNP_not) = c("SNPS","CHR_ID","CHR_POS")
  PLACO_SNP_not = split(PLACO_SNP_not, PLACO_SNP_not$CHR_ID)
  # 初始化结果和错误列表
  LD_results <- list()
  
  # 对每个染色体进行计算
  for (chr in 1:22) {
    print(chr)
    LD_results[[chr]] <- calculate_LD(PLACO_SNP_not[[chr]], PLACO_SNP_sig[[chr]])
  }
  LD_results = do.call(rbind, LD_results)
  lead_PLACO_SNP = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/PLACO/all_lead_GWAS_cancer_SNP"))
  LD_results = LD_results[!LD_results$cancer%in%lead_PLACO_SNP$snpid,] # 之前计算过了
  LD_results = LD_results[!LD_results$PLACO%in%lead_PLACO_SNP$snpid,] # 在gwascatalog中显著的，不需要计算LD
  write_tsv(LD_results,"/home/yanyq/share_genetics/result/GWAS_catalog/to_calculate_LDpair_PLACOwithin")
  
}

{
  {# 分组，每一万个一组
    all_cal_pair = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/GWAS_catalog/to_calculate_LDpair"))
    for(i in 1:38){
      write_tsv(all_cal_pair[((i-1)*10000+1):(i*10000),], paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair/", i))
    }
    i = 39
    write_tsv(all_cal_pair[((i-1)*10000+1):nrow(all_cal_pair),], paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair/", i))
  }
  
  { # 开始计算
    library(readr)
    library(LDlinkR)
    j = 1
    cal_pair = as.data.frame(read_tsv(paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair/", j)))
    results = list()
    errors = list()
    for(i in 1:nrow(cal_pair)){
      result <- tryCatch({
        LDpair(var1 = cal_pair$PLACO[i], var2 = cal_pair$cancer[i], pop = "EUR", token = "0eaa42cc5d9f")
      }, error = function(e) {
        # 打印错误信息并保留错误的SNP对
        message(paste("Error in LDpair for SNPs", cal_pair$PLACO[i], "and", cal_pair$cancer[i], ":", e$message))
        errors <<- c(errors, list(list(snp1 = cal_pair$PLACO[i], snp2 = cal_pair$cancer[i], error = e$message)))
        return(NULL)
      })
      if (!is.null(result)) {
        results <- c(results, list(result))
      }
    }
    
    write_rds(results, paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_res/",j,".rds"))
    write_rds(errors, paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_res/",j,"_errors.rds"))
  }
  
  { # 获取errors
    errors = list()
    for(i in 1:39){
      errors[[i]] = readRDS(paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_res/",i,"_errors.rds"))
      errors[[i]] = do.call(rbind, errors[[i]])
      # results[[i]] = readRDS(paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_res/",i,".rds"))
      # results[[i]] = lapply(results[[i]], function(df) df[, 1:17])
      # results[[i]] = do.call(rbind, results[[i]])
    }
    errors = do.call(rbind, errors)
    errors = as.data.frame(errors)
    errors$snp1 = unlist(errors$snp1)
    errors$snp2 = unlist(errors$snp2)
    errors$error = unlist(errors$error)
    write_tsv(errors, "/home/yanyq/share_genetics/result/GWAS_catalog/to_calculate_LDpair_errors_1")
    # results = do.call(rbind, results)
  }
  
  { # PLACO中的SNP
    {# 分组，每一万个一组
      all_cal_pair = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/GWAS_catalog/to_calculate_LDpair_PLACOwithin"))
      for(i in 1:72){
        write_tsv(all_cal_pair[((i-1)*10000+1):(i*10000),], paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair__PLACOwithin/", i))
      }
      i = 73
      write_tsv(all_cal_pair[((i-1)*10000+1):nrow(all_cal_pair),], paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair__PLACOwithin/", i))
    }
    
    { # 开始计算
      library(readr)
      library(LDlinkR)
      j = 1
      cal_pair = as.data.frame(read_tsv(paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair__PLACOwithin/", j)))
      results = list()
      errors = list()
      for(i in 1:nrow(cal_pair)){
        result <- tryCatch({
          LDpair(var1 = cal_pair$PLACO[i], var2 = cal_pair$cancer[i], pop = "EUR", token = "0eaa42cc5d9f")
        }, error = function(e) {
          # 打印错误信息并保留错误的SNP对
          message(paste("Error in LDpair for SNPs", cal_pair$PLACO[i], "and", cal_pair$cancer[i], ":", e$message))
          errors <<- c(errors, list(list(snp1 = cal_pair$PLACO[i], snp2 = cal_pair$cancer[i], error = e$message)))
          return(NULL)
        })
        if (!is.null(result)) {
          results <- c(results, list(result))
        }
      }
      
      write_rds(results, paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair__PLACOwithin_res/",j,".rds"))
      write_rds(errors, paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair__PLACOwithin_res/",j,"_errors.rds"))
    }
  }
}

{ # 第一次重新计算
  {# 分组，每2000个一组
    for(i in 1:119){
      write_tsv(errors[((i-1)*2000+1):(i*2000),], paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_1/", i))
    }
    i = 120
    write_tsv(errors[((i-1)*2000+1):nrow(errors),], paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_1/", i))
  }
  {
    # 开始计算
    library(readr)
    library(LDlinkR)
    j = 1
    cal_pair = as.data.frame(read_tsv(paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_1/", j)))
    results = list()
    errors = list()
    for(i in 1:nrow(cal_pair)){
      result <- tryCatch({
        LDpair(var1 = cal_pair$snp1[i], var2 = cal_pair$snp2[i], pop = "EUR", token = "0eaa42cc5d9f")
      }, error = function(e) {
        # 打印错误信息并保留错误的SNP对
        message(paste("Error in LDpair for SNPs", cal_pair$snp1[i], "and", cal_pair$snp2[i], ":", e$message))
        errors <<- c(errors, list(list(snp1 = cal_pair$snp1[i], snp2 = cal_pair$snp2[i], error = e$message)))
        return(NULL)
      })
      if (!is.null(result)) {
        results <- c(results, list(result))
      }
    }
    
    write_rds(results, paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_1_res/",j,".rds"))
    write_rds(errors, paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_1_res/",j,"_errors.rds"))
  }
  
  { # 获取errors
    errors = list()
    for(i in 1:120){
      errors[[i]] = readRDS(paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_1_res/",i,"_errors.rds"))
      errors[[i]] = do.call(rbind, errors[[i]])
    }
    errors = do.call(rbind, errors)
    errors = as.data.frame(errors)
    errors$snp1 = unlist(errors$snp1)
    errors$snp2 = unlist(errors$snp2)
    errors$error = unlist(errors$error)
    write_tsv(errors, "/home/yanyq/share_genetics/result/GWAS_catalog/to_calculate_LDpair_errors_2")
    # results = do.call(rbind, results)
  }
}

{
  { # 第二次重新计算
    {# 分组，每1000个一组
      for(i in 1:125){
        write_tsv(errors[((i-1)*1000+1):(i*1000),], paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_2/", i))
      }
      i = 126
      write_tsv(errors[((i-1)*1000+1):nrow(errors),], paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_2/", i))
    }
    
    { # 获取errors
      errors = list()
      for(i in 1:126){
        errors[[i]] = readRDS(paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_2_res/",i,"_errors.rds"))
        errors[[i]] = do.call(rbind, errors[[i]])
      }
      errors = do.call(rbind, errors)
      errors = as.data.frame(errors)
      errors$snp1 = unlist(errors$snp1)
      errors$snp2 = unlist(errors$snp2)
      errors$error = unlist(errors$error)
      write_tsv(errors, "/home/yanyq/share_genetics/result/GWAS_catalog/to_calculate_LDpair_errors_3")
    }
  }
}

{
  { # 第三次重新计算
    {# 分组，每1000个一组
      for(i in 1:70){
        write_tsv(errors[((i-1)*1000+1):(i*1000),], paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_3/", i))
      }
      i = 71
      write_tsv(errors[((i-1)*1000+1):nrow(errors),], paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_3/", i))
    }
    
    { # 获取errors
      errors = list()
      for(i in 1:71){
        errors[[i]] = readRDS(paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_3_res/",i,"_errors.rds"))
        errors[[i]] = do.call(rbind, errors[[i]])
      }
      errors = do.call(rbind, errors)
      errors = as.data.frame(errors)
      errors$snp1 = unlist(errors$snp1)
      errors$snp2 = unlist(errors$snp2)
      errors$error = unlist(errors$error)
      write_tsv(errors, "/home/yanyq/share_genetics/result/GWAS_catalog/to_calculate_LDpair_errors_4")
    }
  }
}

{
  { # 第四次重新计算
    {# 分组，每1000个一组
      for(i in 1:43){
        write_tsv(errors[((i-1)*1000+1):(i*1000),], paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_4/", i))
      }
      i = 44
      write_tsv(errors[((i-1)*1000+1):nrow(errors),], paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_4/", i))
    }

    { # 获取errors
      errors = list()
      for(i in 1:44){
        errors[[i]] = readRDS(paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_4_res/",i,"_errors.rds"))
        errors[[i]] = do.call(rbind, errors[[i]])
      }
      errors = do.call(rbind, errors)
      errors = as.data.frame(errors)
      errors$snp1 = unlist(errors$snp1)
      errors$snp2 = unlist(errors$snp2)
      errors$error = unlist(errors$error)
      write_tsv(errors, "/home/yanyq/share_genetics/result/GWAS_catalog/to_calculate_LDpair_errors_5")
    }
  }
}

{
  { # 第五次重新计算
    {# 分组，每1000个一组
      for(i in 1:31){
        write_tsv(errors[((i-1)*1000+1):(i*1000),], paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_5/", i))
      }
      i = 32
      write_tsv(errors[((i-1)*1000+1):nrow(errors),], paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_5/", i))
    }
    
    { # 获取errors
      errors = list()
      for(i in 1:32){
        errors[[i]] = readRDS(paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_5_res/",i,"_errors.rds"))
        errors[[i]] = do.call(rbind, errors[[i]])
      }
      errors = do.call(rbind, errors)
      errors = as.data.frame(errors)
      errors$snp1 = unlist(errors$snp1)
      errors$snp2 = unlist(errors$snp2)
      errors$error = unlist(errors$error)
      write_tsv(errors, "/home/yanyq/share_genetics/result/GWAS_catalog/to_calculate_LDpair_errors_6")
    }
  }
}

{
  { # 第六次重新计算
    {# 分组，每1000个一组
      for(i in 1:13){
        write_tsv(errors[((i-1)*2000+1):(i*2000),], paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_6/", i))
      }
      i = 14
      write_tsv(errors[((i-1)*2000+1):nrow(errors),], paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_6/", i))
    }
    
    { # 获取errors
      errors = list()
      for(i in 1:14){
        errors[[i]] = readRDS(paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_6_res/",i,"_errors.rds"))
        errors[[i]] = do.call(rbind, errors[[i]])
      }
      errors = do.call(rbind, errors)
      errors = as.data.frame(errors)
      errors$snp1 = unlist(errors$snp1)
      errors$snp2 = unlist(errors$snp2)
      errors$error = unlist(errors$error)
      write_tsv(errors, "/home/yanyq/share_genetics/result/GWAS_catalog/to_calculate_LDpair_errors_7")
    }
  }
}

{
  { # 第七次重新计算
    {# 分组，每1000个一组
      for(i in 1:4){
        write_tsv(errors[((i-1)*5000+1):(i*5000),], paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_7/", i))
      }
      i = 5
      write_tsv(errors[((i-1)*5000+1):nrow(errors),], paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_7/", i))
    }
    
    { # 获取errors
      errors = list()
      for(i in 1:5){
        errors[[i]] = readRDS(paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_7_res/",i,"_errors.rds"))
        errors[[i]] = do.call(rbind, errors[[i]])
      }
      errors = do.call(rbind, errors)
      errors = as.data.frame(errors)
      errors$snp1 = unlist(errors$snp1)
      errors$snp2 = unlist(errors$snp2)
      errors$error = unlist(errors$error)
      write_tsv(errors, "/home/yanyq/share_genetics/result/GWAS_catalog/to_calculate_LDpair_errors_8")
    }
  }
}
{# 第八次重新计算
  # 开始计算
  library(readr)
  library(LDlinkR)
  cal_pair = as.data.frame(read_tsv(paste0("/home/yanyq/share_genetics/result/GWAS_catalog/to_calculate_LDpair_errors_8")))
  cal_pair = cal_pair[!grepl("not in 1000G reference panel", cal_pair$error),]
  results = list()
  errors = list()
  for(i in 1:nrow(cal_pair)){
    result <- tryCatch({
      LDpair(var1 = cal_pair$snp1[i], var2 = cal_pair$snp2[i], pop = "EUR", token = "0eaa42cc5d9f")
    }, error = function(e) {
      # 打印错误信息并保留错误的SNP对
      message(paste("Error in LDpair for SNPs", cal_pair$snp1[i], "and", cal_pair$snp2[i], ":", e$message))
      errors <<- c(errors, list(list(snp1 = cal_pair$snp1[i], snp2 = cal_pair$snp2[i], error = e$message)))
      return(NULL)
    })
    if (!is.null(result)) {
      results <- c(results, list(result))
    }
  }
  write_rds(results, paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_8_res.rds"))
  write_rds(errors, paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_8_res_errors.rds"))
  
  { # 获取errors
    errors = readRDS("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_8_res_errors.rds")
    errors = do.call(rbind, errors)
    errors = as.data.frame(errors)
    errors$snp1 = unlist(errors$snp1)
    errors$snp2 = unlist(errors$snp2)
    errors$error = unlist(errors$error)
    write_tsv(errors, "/home/yanyq/share_genetics/result/GWAS_catalog/to_calculate_LDpair_errors_9")
  }
  # 剩下的error非网络连接问题
}


{
  results = list()
  all_results = list()
  for(i in 1:39){
    results[[i]] = readRDS(paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_res/",i,".rds"))
    results[[i]] = lapply(results[[i]], function(df) df[, 1:17])
    results[[i]] = do.call(rbind, results[[i]])
  }
  all_results[[1]] = do.call(rbind, results)
  results = list()
  for(i in 1:120){
    results[[i]] = readRDS(paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_1_res/",i,".rds"))
    results[[i]] = lapply(results[[i]], function(df) df[, 1:17])
    results[[i]] = do.call(rbind, results[[i]])
  }
  all_results[[2]] = do.call(rbind, results)
  results = list()
  for(i in 1:126){
    results[[i]] = readRDS(paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_2_res/",i,".rds"))
    results[[i]] = lapply(results[[i]], function(df) df[, 1:17])
    results[[i]] = do.call(rbind, results[[i]])
  }
  all_results[[3]] = do.call(rbind, results)
  results = list()
  for(i in 1:71){
    results[[i]] = readRDS(paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_3_res/",i,".rds"))
    results[[i]] = lapply(results[[i]], function(df) df[, 1:17])
    results[[i]] = do.call(rbind, results[[i]])
  }
  all_results[[4]] = do.call(rbind, results)
  results = list()
  for(i in 1:44){
    results[[i]] = readRDS(paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_4_res/",i,".rds"))
    results[[i]] = lapply(results[[i]], function(df) df[, 1:17])
    results[[i]] = do.call(rbind, results[[i]])
  }
  all_results[[5]] = do.call(rbind, results)
  results = list()
  for(i in 1:32){
    results[[i]] = readRDS(paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_5_res/",i,".rds"))
    results[[i]] = lapply(results[[i]], function(df) df[, 1:17])
    results[[i]] = do.call(rbind, results[[i]])
  }
  all_results[[6]] = do.call(rbind, results)
  results = list()
  for(i in 1:14){
    results[[i]] = readRDS(paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_6_res/",i,".rds"))
    results[[i]] = lapply(results[[i]], function(df) df[, 1:17])
    results[[i]] = do.call(rbind, results[[i]])
  }
  all_results[[7]] = do.call(rbind, results)
  results = list()
  for(i in 1:5){
    results[[i]] = readRDS(paste0("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_7_res/",i,".rds"))
    results[[i]] = lapply(results[[i]], function(df) df[, 1:17])
    results[[i]] = do.call(rbind, results[[i]])
  }
  all_results[[8]] = do.call(rbind, results)
  results = readRDS("/home/yanyq/share_genetics/result/GWAS_catalog/LDpair_error_8_res.rds")
  results = lapply(results, function(df) df[, 1:17])
  all_results[[8]] = do.call(rbind, results)

  all_results = do.call(rbind, all_results)
  write_tsv(all_results, "/home/yanyq/share_genetics/result/GWAS_catalog/all_results")
  all_results = all_results[!is.na(all_results$r2),]
  all_results = all_results[all_results$r2>=0.5,]
  write_tsv(all_results,"/home/yanyq/share_genetics/result/GWAS_catalog/all_results_r2_0.5")
}
