# THCA-HAUS6
{
  # bash 
  # smr --bfile /home/yanyq/share_genetics/data/MAGMA/g1000_eur/g1000_eur --gwas-summary /home/yanyq/cogenetics/data/smr_input/THCA --beqtl-summary /home/yanyq/cogenetics/data/eQTL/eQTLGen/cis-eQTLs-full_eQTLGen_AF_incl_nr_formatted_20191212.new.txt_besd-dense --out /home/yanyq/cogenetics/result/plot/eQTL/THCA --plot --probe  ENSG00000147874 --probe-wind 500 --gene-list  ~/cogenetics/data/glist-hg19
  source("/home/yanyq/software/smr-1.3.1-linux-x86_64/plot/plot_SMR.r") 
  library(readr)
  library(dplyr)
  SMRData = ReadSMRData("/home/yanyq/cogenetics/result/plot/plot/eQTL/THCA.ENSG00000147874.txt")
  msmr = as.data.frame(read_tsv("/home/yanyq/cogenetics/result/smr_multiSNP_0.01/eQTLGen/THCA.msmr"))
  msmr = msmr[!is.na(msmr$p_SMR_multi),]
  msmr$fdr = p.adjust(msmr$p_SMR_multi, method = "BH")
  msmr[msmr$probeID=="ENSG00000147874","fdr"]
  
  msmr = msmr[msmr$probeID%in%SMRData$SMR$V1,]
  colnames(msmr)[1] = "V1"
  smr = SMRData$SMR
  smr = left_join(smr,msmr,by = "V1")
  symbol = as.data.frame(read_tsv("~/cogenetics/data/eQTL/eQTLGen/cis-eQTLs-full_eQTLGen_AF_incl_nr_formatted_20191212.new.txt_besd-dense.epi_symbol"))
  colnames(symbol)[2] = "V1"
  smr = left_join(smr, symbol[,c(2,5)],by = "V1")
  smr$V1 = smr$X5
  smr$V4 = smr$X5
  smr$V8 = smr$fdr
  smr$V9 = smr$p_HEIDI
  SMRData$SMR = smr[,1:9]
  
  eQTL = SMRData$eQTL
  colnames(symbol)[2] = colnames(eQTL)[1]
  eQTL = left_join(eQTL, symbol[,c(2,5)],by = "prbname")
  eQTL$prbname = eQTL$X5
  SMRData$eQTL = eQTL[,1:5]
  
  SMRData$probeID = "HAUS6"
  pdf("/home/yanyq/share_genetics/artical/plot/smr_thca_haus6.pdf", height = 8,width = 8)
  SMRLocusPlot(data=SMRData, smr_thresh=0.05,heidi_thresh = 1, plotWindow=500, max_anno_probe=16)
  dev.off()
}
# PRAD-HAUS6
{
  # bash 
  # smr --bfile /home/yanyq/share_genetics/data/MAGMA/g1000_eur/g1000_eur --gwas-summary /home/yanyq/cogenetics/data/smr_input/PRAD --beqtl-summary /home/yanyq/cogenetics/data/eQTL/eQTLGen/cis-eQTLs-full_eQTLGen_AF_incl_nr_formatted_20191212.new.txt_besd-dense --out /home/yanyq/cogenetics/result/plot/eQTL/PRAD --plot --probe  ENSG00000147874 --probe-wind 500 --gene-list  ~/cogenetics/data/glist-hg19
  source("/home/yanyq/software/smr-1.3.1-linux-x86_64/plot/plot_SMR.r") 
  library(readr)
  library(dplyr)
  SMRData = ReadSMRData("/home/yanyq/cogenetics/result/plot/eQTL/plot/PRAD.ENSG00000147874.txt")
  msmr = as.data.frame(read_tsv("/home/yanyq/cogenetics/result/smr_multiSNP_0.01/eQTLGen/THCA.msmr"))
  msmr = msmr[!is.na(msmr$p_SMR_multi),]
  msmr$fdr = p.adjust(msmr$p_SMR_multi, method = "BH")

  msmr = msmr[msmr$probeID%in%SMRData$SMR$V1,]
  colnames(msmr)[1] = "V1"
  smr = SMRData$SMR
  smr = left_join(smr,msmr,by = "V1")
  symbol = as.data.frame(read_tsv("~/cogenetics/data/eQTL/eQTLGen/cis-eQTLs-full_eQTLGen_AF_incl_nr_formatted_20191212.new.txt_besd-dense.epi_symbol"))
  colnames(symbol)[2] = "V1"
  smr = left_join(smr, symbol[,c(2,5)],by = "V1")
  smr$V1 = smr$X5
  smr$V4 = smr$X5
  smr$V8 = smr$fdr
  smr$V9 = smr$p_HEIDI
  SMRData$SMR = smr[,1:9]
  
  eQTL = SMRData$eQTL
  colnames(symbol)[2] = colnames(eQTL)[1]
  eQTL = left_join(eQTL, symbol[,c(2,5)],by = "prbname")
  eQTL$prbname = eQTL$X5
  SMRData$eQTL = eQTL[,1:5]
  
  SMRData$probeID = "HAUS6"
  SMRLocusPlot(data=SMRData, smr_thresh=0.05,heidi_thresh = 1, plotWindow=500, max_anno_probe=16)
}
