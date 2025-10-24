# 提取SMR上下游1MB的结果，包括显著和不显著的结果
library(readr)
library(GenomicRanges)
{ # eQTL
  SMR_eQTL_all = as.data.frame(read_tsv("/home/yanyq/cogenetics/result/smr_multiSNP_0.01/eQTLGen/all_cancer.msmr"))
  SMR_eQTL_sig = SMR_eQTL_all[(SMR_eQTL_all$fdr<0.05)&(SMR_eQTL_all$p_HEIDI>0.01)&!is.na(SMR_eQTL_all$p_HEIDI),]
  
  # 显著SNP上下游区间
  SMR_eQTL_sig$start = ifelse(SMR_eQTL_sig$Probe_bp<1000000,1,SMR_eQTL_sig$Probe_bp-1000000)
  SMR_eQTL_sig$end = SMR_eQTL_sig$Probe_bp+1000000
  
  SMR_eQTL_need = list()
  for(i in unique(SMR_eQTL_sig$cancer)){
    SMR_eQTL_all_tmp = SMR_eQTL_all[SMR_eQTL_all$cancer==i,]
    SMR_eQTL_sig_tmp = SMR_eQTL_sig[SMR_eQTL_sig$cancer==i,]
    SMR_eQTL_all_tmp_GR = as(paste0(SMR_eQTL_all_tmp$ProbeChr,":",SMR_eQTL_all_tmp$Probe_bp), "GRanges")
    SMR_eQTL_sig_tmp_GR = as(paste0(SMR_eQTL_sig_tmp$ProbeChr,":",SMR_eQTL_sig_tmp$start,"-",SMR_eQTL_sig_tmp$end), "GRanges")
    ov = findOverlaps(SMR_eQTL_sig_tmp_GR, SMR_eQTL_all_tmp_GR)
    SMR_eQTL_need[[i]] = unique(SMR_eQTL_all_tmp[ov@to,])
  }
  SMR_eQTL_need = do.call(rbind, SMR_eQTL_need)
  
  # 注释symbol和癌症全称
  gene_symbol = as.data.frame(read_tsv("/home/yanyq/cogenetics/data/eQTL/eQTLGen/cis-eQTLs-full_eQTLGen_AF_incl_nr_formatted_20191212.new.txt_besd-dense.epi_symbol"))
  colnames(gene_symbol)[c(2,5)] = c("probeID","symbol")
  SMR_eQTL_need = dplyr::left_join(SMR_eQTL_need, gene_symbol[,c(2,5)], by = "probeID")
  which(is.na(SMR_eQTL_need$symbol))
  abbrev = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/english_abbrev"))
  colnames(abbrev)[2] = "cancer"
  SMR_eQTL_need = dplyr::left_join(SMR_eQTL_need, abbrev, by = "cancer")
  SMR_eQTL_need$log10FDR = -log10(SMR_eQTL_need$fdr)
  which(is.na(SMR_eQTL_need$name))
  
  # 注释显著的SMR
  SMR_eQTL_need$sig = "No"
  SMR_eQTL_need$sig[SMR_eQTL_need$fdr<0.05&!is.na(SMR_eQTL_need$p_HEIDI)&SMR_eQTL_need$p_HEIDI>0.01] = "Yes"
  table(SMR_eQTL_need$sig) # 1726
  write_tsv(SMR_eQTL_need,"/home/yanyq/database/flask_vue/data/SMR_eQTL")
  SMR_eQTL_need = as.data.frame(read_tsv("/home/yanyq/database/flask_vue/data/SMR_eQTL"))
  SMR_eQTL_need$name[SMR_eQTL_need$name=="Endometrioid Cancer"] = "Endometrial cancer"
  write_tsv(SMR_eQTL_need,"/home/yanyq/database/flask_vue/data/SMR_eQTL")
  
}
{ # meQTL
  SMR_meQTL_all = as.data.frame(read_tsv("/home/yanyq/cogenetics/result/smr_multiSNP_0.01/meQTL/all_cancer.msmr"))
  SMR_meQTL_sig = SMR_meQTL_all[(SMR_meQTL_all$fdr<0.05)&(SMR_meQTL_all$p_HEIDI>0.01)&!is.na(SMR_meQTL_all$p_HEIDI),] # 5428
  
  # 显著SNP上下游区间
  SMR_meQTL_sig$start = ifelse(SMR_meQTL_sig$Probe_bp<1000000,1,SMR_meQTL_sig$Probe_bp-1000000)
  SMR_meQTL_sig$end = SMR_meQTL_sig$Probe_bp+1000000
  
  SMR_meQTL_need = list()
  for(i in unique(SMR_meQTL_sig$cancer)){
    SMR_meQTL_all_tmp = SMR_meQTL_all[SMR_meQTL_all$cancer==i,]
    SMR_meQTL_sig_tmp = SMR_meQTL_sig[SMR_meQTL_sig$cancer==i,]
    SMR_meQTL_all_tmp_GR = as(paste0(SMR_meQTL_all_tmp$ProbeChr,":",SMR_meQTL_all_tmp$Probe_bp), "GRanges")
    SMR_meQTL_sig_tmp_GR = as(paste0(SMR_meQTL_sig_tmp$ProbeChr,":",SMR_meQTL_sig_tmp$start,"-",SMR_meQTL_sig_tmp$end), "GRanges")
    ov = findOverlaps(SMR_meQTL_sig_tmp_GR, SMR_meQTL_all_tmp_GR)
    SMR_meQTL_need[[i]] = unique(SMR_meQTL_all_tmp[ov@to,])
  }
  SMR_meQTL_need = do.call(rbind, SMR_meQTL_need)
  
  {
    # 注释甲基化探针
    methy = as.data.frame(read_csv("/home/yanyq/data/humanmethylation450_15017482_v1-2.csv"))
    colnames(methy) = methy[7,]
    methy = methy[-(1:7),]
    which(methy$IlmnID!=methy$Name)
    tmp1 = methy[,c("IlmnID","UCSC_RefGene_Name")]
    tmp2 = methy[,c("Name","UCSC_RefGene_Name")]
    colnames(tmp1) = c("probeID","Gene")
    colnames(tmp2) = c("probeID","Gene")
    SMR_meQTL_need = dplyr::left_join(SMR_meQTL_need[,-3], unique(rbind(tmp1,tmp2)), by = "probeID")
    
    # 处理列中的重复项
    SMR_meQTL_need$Gene <- sapply(SMR_meQTL_need$Gene, function(x) {
      if (!is.na(x)) {
        # 用分号分割并去重，然后再合并成一个字符串
        unique_genes <- unique(unlist(strsplit(x, ";")))
        paste(unique_genes, collapse = ";")
      } else {
        NA
      }
    })
    length(which(is.na(SMR_meQTL_need$Gene)))
  }
  abbrev = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/english_abbrev"))
  colnames(abbrev)[2] = "cancer"
  SMR_meQTL_need = dplyr::left_join(SMR_meQTL_need, abbrev, by = "cancer")
  SMR_meQTL_need$log10FDR = -log10(SMR_meQTL_need$fdr)
  which(is.na(SMR_meQTL_need$name))
  
  # 注释显著的SMR
  SMR_meQTL_need$sig = "No"
  SMR_meQTL_need$sig[SMR_meQTL_need$fdr<0.05&!is.na(SMR_meQTL_need$p_HEIDI)&SMR_meQTL_need$p_HEIDI>0.01] = "Yes"
  table(SMR_meQTL_need$sig) # 5428
  write_tsv(SMR_meQTL_need,"/home/yanyq/database/flask_vue/data/SMR_meQTL")
  
  SMR_meQTL_need = as.data.frame(read_tsv("/home/yanyq/database/flask_vue/data/SMR_meQTL"))
  SMR_meQTL_need$name[SMR_meQTL_need$name=="Endometrioid Cancer"] = "Endometrial cancer"
  write_tsv(SMR_meQTL_need,"/home/yanyq/database/flask_vue/data/SMR_meQTL")
  
}

{ # pQTL
  SMR_pQTL_all = as.data.frame(read_tsv("/home/yanyq/cogenetics/result/smr_multiSNP_0.01/pQTL/all_cancer.msmr"))
  SMR_pQTL_sig = SMR_pQTL_all[(SMR_pQTL_all$fdr<0.05)&(SMR_pQTL_all$p_HEIDI>0.01)&!is.na(SMR_pQTL_all$p_HEIDI),] # 229
  
  # 显著SNP上下游区间
  SMR_pQTL_sig$start = ifelse(SMR_pQTL_sig$Probe_bp<1000000,1,SMR_pQTL_sig$Probe_bp-1000000)
  SMR_pQTL_sig$end = SMR_pQTL_sig$Probe_bp+1000000
  
  SMR_pQTL_need = list()
  for(i in unique(SMR_pQTL_sig$cancer)){
    SMR_pQTL_all_tmp = SMR_pQTL_all[SMR_pQTL_all$cancer==i,]
    SMR_pQTL_sig_tmp = SMR_pQTL_sig[SMR_pQTL_sig$cancer==i,]
    SMR_pQTL_all_tmp_GR = as(paste0(SMR_pQTL_all_tmp$ProbeChr,":",SMR_pQTL_all_tmp$Probe_bp), "GRanges")
    SMR_pQTL_sig_tmp_GR = as(paste0(SMR_pQTL_sig_tmp$ProbeChr,":",SMR_pQTL_sig_tmp$start,"-",SMR_pQTL_sig_tmp$end), "GRanges")
    ov = findOverlaps(SMR_pQTL_sig_tmp_GR, SMR_pQTL_all_tmp_GR)
    SMR_pQTL_need[[i]] = unique(SMR_pQTL_all_tmp[ov@to,])
  }
  SMR_pQTL_need = do.call(rbind, SMR_pQTL_need)
  
  pQTL = as.data.frame(read_tsv("/home/yanyq/cogenetics/data/pQTL/pQTL_raw.txt"))
  pQTL = tidyr::separate(pQTL, "pQTL ID prot", into = c("I1","I2","I3","I4"), sep = "_")
  pQTL$probeID = paste0(pQTL$I1,"_",pQTL$I2)
  SMR_pQTL_need = dplyr::left_join(SMR_pQTL_need,unique(pQTL[,c("probeID","shortname prot")]), by = "probeID")
  abbrev = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/english_abbrev"))
  colnames(abbrev)[2] = "cancer"
  SMR_pQTL_need = dplyr::left_join(SMR_pQTL_need, abbrev, by = "cancer")
  SMR_pQTL_need$log10FDR = -log10(SMR_pQTL_need$fdr)
  which(is.na(SMR_pQTL_need$name))
  
  # 注释显著的SMR
  SMR_pQTL_need$sig = "No"
  SMR_pQTL_need$sig[SMR_pQTL_need$fdr<0.05&!is.na(SMR_pQTL_need$p_HEIDI)&SMR_pQTL_need$p_HEIDI>0.01] = "Yes"
  table(SMR_pQTL_need$sig) # 229
  write_tsv(SMR_pQTL_need,"/home/yanyq/database/flask_vue/data/SMR_pQTL")
  # 
  # SMR_pQTL_need = as.data.frame(read_tsv("/home/yanyq/database/flask_vue/data/SMR_pQTL"))
  # SMR_pQTL_need$name[SMR_pQTL_need$name=="Endometrioid Cancer"] = "Endometrial cancer"
  # write_tsv(SMR_pQTL_need,"/home/yanyq/database/flask_vue/data/SMR_pQTL")
}
# 统计数目
{
  SMR_eQTL_need = as.data.frame(read_tsv("/home/yanyq/database/flask_vue/data/SMR_eQTL"))
  SMR_eQTL_need = SMR_eQTL_need[SMR_eQTL_need$sig=="Yes",]
  tmp = as.data.frame(table(SMR_eQTL_need$name))
  SMR_meQTL_need = as.data.frame(read_tsv("/home/yanyq/database/flask_vue/data/SMR_meQTL"))
  SMR_meQTL_need = SMR_meQTL_need[SMR_meQTL_need$sig=="Yes",]
  tmp2 = as.data.frame(table(SMR_meQTL_need$name))
  SMR_pQTL_need = as.data.frame(read_tsv("/home/yanyq/database/flask_vue/data/SMR_pQTL"))
  SMR_pQTL_need = SMR_pQTL_need[SMR_pQTL_need$sig=="Yes",]
  tmp3 = as.data.frame(table(SMR_pQTL_need$name))
  
  tmp$Var1 = as.character(tmp$Var1)
  tmp2$Var1 = as.character(tmp2$Var1)
  tmp3$Var1 = as.character(tmp3$Var1)
  
  all = merge(tmp,tmp2,by = "Var1", all = T)
  all = merge(all,tmp3,by = "Var1", all = T)
  
  all$Var1
  all$Freq.x
  all$Freq.y
  all$Freq
}