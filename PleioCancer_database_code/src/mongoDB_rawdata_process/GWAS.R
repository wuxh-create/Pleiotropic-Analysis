library(readr)
library(vroom)
library(GenomicRanges)
# 提取SMR_eQTL/meQTL/pQTL上下游1MB 的GWAS，PLACO上下游1MB、多效基因上的SNP
SMR_eQTL = as.data.frame(read_tsv("/home/yanyq/cogenetics/result/smr_multiSNP_0.01/eQTLGen/all_cancer_fdr_0.05_withSymbol.msmr"))
SMR_meQTL = as.data.frame(read_tsv("/home/yanyq/cogenetics/result/smr_multiSNP_0.01/meQTL/all_cancer_fdr_0.05_withSymbol.msmr"))
SMR_pQTL = as.data.frame(read_tsv("/home/yanyq/cogenetics/result/smr_multiSNP_0.01/pQTL/all_cancer_fdr_0.05_withSymbol.msmr"))
all_PLACO = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/PLACO/all"))
all_PLACO = all_PLACO[!(grepl("CORP",all_PLACO$trait1)|grepl("CORP",all_PLACO$trait2)),]

SMR_eQTL = SMR_eQTL[,c("ProbeChr","Probe_bp","cancer")]
SMR_meQTL = SMR_meQTL[,c("ProbeChr","Probe_bp","cancer")]
SMR_pQTL = SMR_pQTL[,c("ProbeChr","Probe_bp","cancer")]
all_PLACO_trait1 = all_PLACO[,c("hg19chr", "bp","trait1")]
all_PLACO_trait2 = all_PLACO[,c("hg19chr", "bp","trait2")]
colnames(all_PLACO_trait1) = c("ProbeChr","Probe_bp","cancer")
colnames(all_PLACO_trait2) = c("ProbeChr","Probe_bp","cancer")

all_pos = rbind(SMR_eQTL,SMR_meQTL)
all_pos = rbind(all_pos,SMR_pQTL)
all_pos = rbind(all_pos,all_PLACO_trait1)
all_pos = rbind(all_pos,all_PLACO_trait2)

all_pos = unique(all_pos)
all_pos$start = ifelse((all_pos$Probe_bp-1000000)>0,(all_pos$Probe_bp-1000000),1)
all_pos$end = all_pos$Probe_bp+1000000
setwd("/home/yanyq/share_genetics/data/GWAS/processed/")
gwas = list()
abbrev = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/english_abbrev"))
for(trait in unique(all_pos$cancer)){
  print(trait)
  f = as.data.frame(vroom(paste0(trait,".gz")))
  
  tmp_pos = all_pos[all_pos$cancer==trait,]
  tmp_pos = as(paste0(tmp_pos$ProbeChr,":",tmp_pos$start,"-",tmp_pos$end),"GRanges")
  f_GR = as(paste0(f$hg19chr,":",f$bp), "GRanges")

  ov = findOverlaps(tmp_pos,f_GR)
  gwas[[trait]] = f[unique(ov@to),]
  gwas[[trait]]$cancer = trait
  gwas[[trait]]$name = abbrev$name[abbrev$abbrev==trait]
  write_tsv(gwas[[trait]],paste0("~/database/flask_vue/data/tmp/",trait,".gz"))
}
gwas = do.call(rbind,gwas)
gwas$beta = log(gwas$or)
write_tsv(gwas, "~/database/flask_vue/data/GWAS")

gwas = as.data.frame(read_tsv("~/database/flask_vue/data/GWAS"))
gwas$sig = ifelse(gwas$pval<5e-8,"Yes","No")
write_tsv(gwas, "~/database/flask_vue/data/GWAS")

# Acute myeloid leukaemia
# Basal cell carcinoma
# SLC45A2
# 5:33943221-33994780
gwas = as.data.frame(read_tsv("~/database/flask_vue/data/GWAS"))
gwas$name[gwas$name=="Endometrioid Cancer"] = "Endometrial cancer"
write_tsv(gwas, "~/database/flask_vue/data/GWAS")

tmp = gwas[gwas$name=="Acute myeloid leukaemia"&gwas$hg19chr==5&gwas$bp<=33994780&gwas$bp>=33943221,]
