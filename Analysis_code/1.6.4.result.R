# 整理局部遗传相关性结果
library(readr)
library(GenomicRanges)
library(dplyr)
library(vroom)
setwd("/home/yanyq/share_genetics/result/SUPERGNOVA/")
local_cor = list()
for(i in list.files()){
  local_cor[[i]] = as.data.frame(read.table(i, header = T))
  local_cor[[i]] = local_cor[[i]][!is.na(local_cor[[i]]$corr),]
  local_cor[[i]]$traits = i
  local_cor[[i]]$FDR = p.adjust(local_cor[[i]]$p,method = "BH")
}
local_cor = do.call(rbind, local_cor)
write_tsv(local_cor, "/home/yanyq/share_genetics/result/SUPERGNOVA/all")
local_cor = local_cor[local_cor$FDR<0.05,]
local_cor = local_cor[!is.na(local_cor$corr),]
write_tsv(local_cor, "/home/yanyq/share_genetics/result/SUPERGNOVA/all_fdr0.05")

# ################Estimation of the proportion of correlated regions
# # https://link.springer.com/article/10.1186/s13059-021-02478-w#Sec9
# # 要用所有的区域算，不能过滤掉corr为NA的区域
# library(ashr)
# local_cor =as.data.frame(read_tsv("/home/yanyq/share_genetics/result/SUPERGNOVA/all"))
# local_cor_percent = data.frame(traits = unique(local_cor$traits), percent = NA, loci_num = NA)
# for(i in 1:nrow(local_cor_percent)){
#   tmp_local_cor = local_cor[local_cor$traits==local_cor_percent$traits[i],]
#   tmp = ash(betahat = tmp_local_cor$rho,
#             sebetahat = sqrt(tmp_local_cor$var),
#             mixcompdist = "halfnormal")
#   local_cor_percent$percent[i] = sum(1-tmp$result$lfsr)/nrow(tmp_local_cor)
#   tmp_local_cor = tmp_local_cor[tmp_local_cor$FDR<0.05,]
#   tmp_local_cor = tmp_local_cor[!is.na(tmp_local_cor$corr),]
#   local_cor_percent$loci_num[i] = nrow(tmp_local_cor)
# }
# write_tsv(local_cor_percent,"/home/yanyq/share_genetics/result/SUPERGNOVA/all_percent")
################################ 多效SNP富集在局部遗传相关性区域内的情况
all_PLACO = read_tsv("/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer_MAGMA_SMR_GWASCatalog_cancer_separate")
all_PLACO$local_cor_region = NA
local_cor = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/SUPERGNOVA/all_fdr0.05"))
local_cor$region = paste0(local_cor$chr,":",local_cor$start,"-",local_cor$end)
fisher_matrix_all = list()
fisher_result = list()
cal_traits = unique(local_cor$traits)
cal_traits = cal_traits[!cal_traits%in%names(fisher_matrix_all)]
for(i in cal_traits){
  tmp_local_cor = local_cor[local_cor$traits==i,]
  tmp_local_gr = as(tmp_local_cor$region, "GRanges")
  
  tmp_all_PLACO = all_PLACO[all_PLACO$traits==i,]
  
  all_SNP = as.data.frame(vroom(paste0("/home/yanyq/share_genetics/data/GWAS/overlap/", i, ".gz"))) # 共有的SNP
  SNP_not_PLACO = all_SNP[!all_SNP$snpid%in%tmp_all_PLACO$snpid,] # 非多效SNP
  SNP_not_PLACO_gr = as(paste0(SNP_not_PLACO[,2],":",SNP_not_PLACO[,3]), "GRanges")
  
  tmp_overlaps = findOverlaps(SNP_not_PLACO_gr,tmp_local_gr)
  not_in = length(unique(tmp_overlaps@from)) # 非多效SNP在有遗传相关性区域内的
  not_out = nrow(SNP_not_PLACO)-not_in # 非多效SNP在有遗传相关性区域外的
  
  if(nrow(tmp_all_PLACO)>0){
    tmp_PLACO_gr = as(paste0(tmp_all_PLACO$hg19chr,":",tmp_all_PLACO$bp), "GRanges")
    tmp_overlaps = findOverlaps(tmp_PLACO_gr,tmp_local_gr)
    PLACO_in = length(unique(tmp_overlaps@from)) # 多效SNP在有遗传相关性区域内的
    PLACO_out = nrow(tmp_all_PLACO)-PLACO_in # 多效SNP在有遗传相关性区域外的
  }else{
    PLACO_in = 0
    PLACO_out = 0
  }
  fisher_matrix = matrix(c(PLACO_in,PLACO_out,not_in,not_out),ncol = 2, nrow = 2)
  fisher_matrix_all[[i]] = as.data.frame(fisher_matrix)
  colnames(fisher_matrix_all[[i]]) = c("PLACO_SNP_num","not_num")
  rownames(fisher_matrix_all[[i]]) = c("in_local_cor_region","not_in")
  if(sum(fisher_matrix)==nrow(all_SNP)){
    fisher_result[[i]] = fisher.test(fisher_matrix)
  }else{
    print(i)
  }
}
save(fisher_matrix_all, fisher_result, file = "/home/yanyq/share_genetics/result/PLACO_local_fisher.Rda")

load("/home/yanyq/share_genetics/result/PLACO_local_fisher.Rda")
fisher_matrix_all = do.call(rbind, fisher_matrix_all)
fisher_matrix_all$trait = sub("\\..*$", "", rownames(fisher_matrix_all))
fisher_matrix_all$local_cor = sub("^[^.]*\\.","",rownames(fisher_matrix_all))
fisher_result_df = list()
for(i in names(fisher_result)){
  fisher_result_df[[i]] = data.frame(p.value = fisher_result[[i]]$p.value,
                                     conf.int_up = fisher_result[[i]]$conf.int[1],
                                     conf.int_down = fisher_result[[i]]$conf.int[2],
                                     estimate = fisher_result[[i]]$estimate,
                                     null.value = fisher_result[[i]]$null.value,
                                     alternative = fisher_result[[i]]$alternative,
                                     method = fisher_result[[i]]$method,
                                     data.name = fisher_result[[i]]$data.name,
                                     trait = i)
  
}
fisher_result_df = do.call(rbind,fisher_result_df)
fisher_result_df = as.data.frame(fisher_result_df)
fisher_matrix_all = dplyr::left_join(fisher_matrix_all, fisher_result_df, by = "trait")
nrow(fisher_matrix_all) # 294
nrow(fisher_matrix_all[fisher_matrix_all$p.value<0.05,])# 120
write_tsv(fisher_matrix_all,"/home/yanyq/share_genetics/result/PLACO_local_fisher.matrix")

################################ 多效SNP富集在局部遗传相关性区域内(P<0.05)的情况
all_PLACO = read_tsv("/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer_MAGMA_SMR_GWASCatalog_cancer_separate")
all_PLACO$local_cor_region = NA
local_cor = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/SUPERGNOVA/all")) # 1638867
local_cor = local_cor[local_cor$p<0.05,] # 26259
local_cor$region = paste0(local_cor$chr,":",local_cor$start,"-",local_cor$end)
fisher_matrix_all = list()
fisher_result = list()
# cal_traits = unique(local_cor$traits) # 703
cal_traits = unique(all_PLACO$traits)
cal_traits = cal_traits[!cal_traits%in%names(fisher_matrix_all)]
library(parallel)
library(GenomicRanges)
library(vroom)
# 定义并行函数
process_traits <- function(i) {
  tmp_local_cor <- local_cor[local_cor$traits == i,]
  tmp_local_gr <- as(tmp_local_cor$region, "GRanges")
  
  tmp_all_PLACO <- all_PLACO[all_PLACO$traits == i,]
  
  all_SNP <- as.data.frame(vroom(paste0("/home/yanyq/share_genetics/data/GWAS/overlap/", i, ".gz")))  # 共有的SNP
  SNP_not_PLACO <- all_SNP[!all_SNP$snpid %in% tmp_all_PLACO$snpid,]  # 非多效SNP
  SNP_not_PLACO_gr <- as(paste0(SNP_not_PLACO[,2], ":", SNP_not_PLACO[,3]), "GRanges")
  
  tmp_overlaps <- findOverlaps(SNP_not_PLACO_gr, tmp_local_gr)
  not_in <- length(unique(tmp_overlaps@from))  # 非多效SNP在有遗传相关性区域内的
  not_out <- nrow(SNP_not_PLACO) - not_in  # 非多效SNP在有遗传相关性区域外的
  
  if (nrow(tmp_all_PLACO) > 0) {
    tmp_PLACO_gr <- as(paste0(tmp_all_PLACO$hg19chr, ":", tmp_all_PLACO$bp), "GRanges")
    tmp_overlaps <- findOverlaps(tmp_PLACO_gr, tmp_local_gr)
    PLACO_in <- length(unique(tmp_overlaps@from))  # 多效SNP在有遗传相关性区域内的
    PLACO_out <- nrow(tmp_all_PLACO) - PLACO_in  # 多效SNP在有遗传相关性区域外的
  } else {
    PLACO_in <- 0
    PLACO_out <- 0
  }
  
  fisher_matrix <- matrix(c(PLACO_in, PLACO_out, not_in, not_out), ncol = 2, nrow = 2)
  fisher_matrix_df <- as.data.frame(fisher_matrix)
  colnames(fisher_matrix_df) <- c("PLACO_SNP_num", "not_num")
  rownames(fisher_matrix_df) <- c("in_local_cor_region", "not_in")
  
  if (sum(fisher_matrix) == nrow(all_SNP)) {
    fisher_result <- fisher.test(fisher_matrix)
  } else {
    print(i)
    fisher_result <- NULL
  }
  
  return(list(fisher_matrix = fisher_matrix_df, fisher_result = fisher_result, trait = i))
}

# 使用mclapply并行计算
fisher_results_all <- mclapply(cal_traits, process_traits, mc.cores = 10)
save(fisher_results_all, file = "/home/yanyq/share_genetics/result/PLACO_localP0.05_fisher.Rda")

load("/home/yanyq/share_genetics/result/PLACO_localP0.05_fisher.Rda")
fisher_matrix_all <- lapply(fisher_results_all, function(res) cbind(res$fisher_matrix, res$trait))
fisher_matrix_all = do.call(rbind, fisher_matrix_all)
fisher_matrix_all$local_cor = rownames(fisher_matrix_all)
fisher_result_df = list()
for(i in 1:length(fisher_results_all)){
  fisher_result = fisher_results_all[[i]]$fisher_result
  fisher_result_df[[i]] = data.frame(p.value = fisher_result$p.value,
                                     conf.int_up = fisher_result$conf.int[1],
                                     conf.int_down = fisher_result$conf.int[2],
                                     estimate = fisher_result$estimate,
                                     null.value = fisher_result$null.value,
                                     alternative = fisher_result$alternative,
                                     method = fisher_result$method,
                                     data.name = fisher_result$data.name,
                                     trait = fisher_results_all[[i]]$trait)
  
}
fisher_result_df = as.data.frame(do.call(rbind,fisher_result_df))
colnames(fisher_matrix_all)[3] = "trait"
fisher_matrix_all = dplyr::left_join(fisher_matrix_all, fisher_result_df, by = "trait")
nrow(fisher_matrix_all) # 772
nrow(fisher_matrix_all[fisher_matrix_all$p.value<0.05,])# 466
write_tsv(fisher_matrix_all,"/home/yanyq/share_genetics/result/PLACO_localP0.05_fisher.matrix")

# lead SNP在局部遗传相关性区域的情况
all_PLACO_lead = all_PLACO[all_PLACO$is.IndSig_lead=="leadSNP"&all_PLACO$traits%in%list.files("/home/yanyq/share_genetics/result/SUPERGNOVA/"),]
length(which(is.na(all_PLACO_lead$local_cor_region)))


setwd("/home/yanyq/share_genetics/result/FUMA/")


LAVA = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/LAVA/all_uni_filtered_bivar"))
LAVA$FDR = p.adjust(LAVA$p, method = "BH")
# LAVA = LAVA[LAVA$p<0.05,]
LAVA = LAVA[LAVA$FDR<0.05,]
LAVA$pair = paste0(LAVA$phen1, "-", LAVA$phen2)
LAVA$FUMA_loci_num = NA
LAVA$FUMA_loci = NA

all_FUMA = list()
for(traits in unique(LAVA$pair)){
  if(file.exists(traits)){
    FUMA = as.data.frame(read.table(paste0(traits,"/GenomicRiskLoci.txt"), header = T))
    cur_LAVA = LAVA[LAVA$pair==traits,]
    
    FUMA_GR = as(paste0(FUMA$chr, ":", FUMA$start, "-", FUMA$end), "GRanges")
    cur_LAVA_GR = as(paste0(cur_LAVA$chr, ":", cur_LAVA$start, "-", cur_LAVA$stop), "GRanges")
    overlap = findOverlaps(cur_LAVA_GR, FUMA_GR)
    if(length(overlap)>0){
      overlap = data.frame(from = overlap@from, to = overlap@to,
                           LAVA_loci = paste0(cur_LAVA$chr[overlap@from], ":", cur_LAVA$start[overlap@from], "-", cur_LAVA$stop[overlap@from]),
                           FUMA_loci = paste0(FUMA$chr[overlap@to], ":", FUMA$start[overlap@to], "-", FUMA$end[overlap@to]))
      overlap_from = overlap %>% group_by(from) %>% summarise(to = paste(to, collapse = ","), FUMA_loci = paste(FUMA_loci, collapse = ","))
      overlap_to = overlap %>% group_by(to) %>% summarise(from = paste(from, collapse = ","), LAVA_loci = paste(LAVA_loci, collapse = ","))
      
      cur_LAVA$FUMA_loci_num[overlap_from$from] = overlap_from$to
      cur_LAVA$FUMA_loci[overlap_from$from] = overlap_from$FUMA_loci
      LAVA[LAVA$pair==traits,] = cur_LAVA
      
      FUMA$LAVA_loci_num = NA
      FUMA$LAVA_loci = NA
      FUMA$LAVA_loci_num[overlap_to$to] = overlap_to$from
      FUMA$LAVA_loci[overlap_to$to] = overlap_to$LAVA_loci
      all_FUMA[[traits]] = FUMA
    }
  }
}
all_FUMA = do.call(rbind, all_FUMA)
