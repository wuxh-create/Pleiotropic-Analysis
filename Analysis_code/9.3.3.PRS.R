library(bigreadr)
library(readr)

PLACO = fread2("/home/yanyq/share_genetics/result/PLACO/all_DEG_surv_GDSCDrug_eQTLGen_DEG_lead_enhancer_MAGMA_SMR")
PLACO = PLACO[PLACO$traits == "BRCA-OV",]
PLACO$beta.trait1 = log(PLACO$or.trait1)
PLACO$beta.trait2 = log(PLACO$or.trait2)

# 将所有的a1都转为次等位基因
AF5 = PLACO$EURaf.trait1>0.5
a1 = PLACO$a1[AF5]
PLACO$a1[AF5] = PLACO$a2[AF5]
PLACO$a2[AF5] = a1
PLACO$or.trait1[AF5] = exp(-log(PLACO$or.trait1[AF5]))
PLACO$EURaf.trait1[AF5] = 1-PLACO$EURaf.trait1[AF5]
PLACO$zscore.trait1[AF5] = -PLACO$zscore.trait1[AF5]
PLACO$beta.trait1[AF5] = -PLACO$beta.trait1[AF5]
PLACO$or.trait2[AF5] = exp(-log(PLACO$or.trait2[AF5]))
PLACO$EURaf.trait2[AF5] = 1-PLACO$EURaf.trait2[AF5]
PLACO$zscore.trait2[AF5] = -PLACO$zscore.trait2[AF5]
PLACO$beta.trait2[AF5] = -PLACO$beta.trait2[AF5]

{# UKB与多效SNP overlap
  # 用beta.OV计算BRCA的PRS
  # 4400个uniqueID
  breast = data.table::fread(file="/home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/BRCA_all.vcf", skip="CHROM\tPOS",stringsAsFactors=FALSE, data.table=FALSE)#
  breast_OV = data.table::fread(file="/home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/BRCA_OV_all.vcf", skip="CHROM\tPOS",stringsAsFactors=FALSE, data.table=FALSE)#
  tmp = breast$ID!=breast_OV$ID|breast$REF!=breast_OV$REF|breast$ALT!=breast_OV$ALT
  tmp_REF = breast_OV$REF[tmp]
  breast_OV$REF[tmp] = breast_OV$ALT[tmp]
  breast_OV$ALT[tmp] = tmp_REF
  which(breast$ID!=breast_OV$ID|breast$REF!=breast_OV$REF|breast$ALT!=breast_OV$ALT)
  
  # breast:10-17426; OV:17427:17497
  breast = cbind(breast,breast_OV[,10:ncol(breast_OV)])
  breast$ID = do.call(rbind, str_split(breast$ID,":"))[,1]
  nonSNP = PLACO[!PLACO$snpid%in%breast$ID,]
  
  # breast:32-17448; OV:17449:17519
  PLACO_breast = merge(PLACO, breast, by.x = "snpid", by.y = "ID")
  which(colnames(PLACO_breast)[95:17582]!=colnames(breast)[10:17497])
  unharmonized = PLACO_breast$a1==PLACO_breast$REF&PLACO_breast$a2==PLACO_breast$ALT# 12个
  
  # {
  #   tt = paste0(PLACO_breast$snpid,":",PLACO_breast$a2.BRCA,":",PLACO_breast$a1.BRCA)
  #   tt[unharmonized] = paste0(PLACO_breast$snpid[unharmonized],":",PLACO_breast$a1.BRCA[unharmonized],":",PLACO_breast$a2.BRCA[unharmonized])
  #   write_tsv(as.data.frame(tt),"/home/yanyq/share_genetics/result/PLACO/sigUnique_SNP/sig_BRCA-OV", col_names = F)
  #   write_tsv(PLACO_breast[,1:23],"/home/yanyq/share_genetics/result/PRS/BRCA-OV_beta")
  # }
  
  PLACO_breast_unharm = PLACO_breast[unharmonized,]
  # 复等位基因，14个
  errorSNP = (PLACO_breast$a1!=PLACO_breast$ALT|PLACO_breast$a2!=PLACO_breast$REF)&(!unharmonized)
  PLACO_breast = PLACO_breast[(!unharmonized)&(!errorSNP),]
  # PLACO_breast_unharm$REF = PLACO_breast_unharm$a2.BRCA
  # PLACO_breast_unharm$ALT = PLACO_breast_unharm$a1.BRCA
  # for(i in 1:nrow(PLACO_breast_unharm)){
  #   tmp = PLACO_breast_unharm[i,32:ncol(PLACO_breast_unharm)]
  #   t00 = (tmp=="0/0")
  #   t01 = (tmp=="0/1")
  #   t10 = (tmp=="1/0")
  #   t11 = (tmp=="1/1")
  #   tmp[t00] = "1/1"
  #   tmp[t01] = "1/0"
  #   tmp[t10] = "0/1"
  #   tmp[t11] = "0/0"
  #   PLACO_breast_unharm[i,32:ncol(PLACO_breast_unharm)] = tmp
  # }
  # 改变的PLACO的a1、a2，基因型的ref、alt没改变，所以基因型不用做调整
  for(i in 1:nrow(PLACO_breast_unharm)){
    a1 = PLACO_breast_unharm$a1[i]
    PLACO_breast_unharm$a1[i] = PLACO_breast_unharm$a2[i]
    PLACO_breast_unharm$a2[i] = a1
    PLACO_breast_unharm$or.trait1[i] = exp(-log(PLACO_breast_unharm$or.trait1[i]))
    PLACO_breast_unharm$EURaf.trait1[i] = 1-PLACO_breast_unharm$EURaf.trait1[i]
    PLACO_breast_unharm$zscore.trait1[i] = -PLACO_breast_unharm$zscore.trait1[i]
    PLACO_breast_unharm$beta.trait1[i] = -PLACO_breast_unharm$beta.trait1[i]
    PLACO_breast_unharm$or.trait2[i] = exp(-log(PLACO_breast_unharm$or.trait2[i]))
    PLACO_breast_unharm$EURaf.trait2[i] = 1-PLACO_breast_unharm$EURaf.trait2[i]
    PLACO_breast_unharm$zscore.trait2[i] = -PLACO_breast_unharm$zscore.trait2[i]
    PLACO_breast_unharm$beta.trait2[i] = -PLACO_breast_unharm$beta.trait2[i]
  }
  PLACO_breast = rbind(PLACO_breast,PLACO_breast_unharm)
  which(PLACO_breast$a1.BRCA!=PLACO_breast$ALT|PLACO_breast$a2.BRCA!=PLACO_breast$REF)
}

{
  PLACO_breast_012 = PLACO_breast
  PLACO_breast_012[PLACO_breast=="0/0"] = 0
  PLACO_breast_012[PLACO_breast=="0/1"] = 1
  PLACO_breast_012[PLACO_breast=="1/0"] = 1
  PLACO_breast_012[PLACO_breast=="1/1"] = 2
  PLACO_breast_012[PLACO_breast=="./."] = NA
  PLACO_breast_PRS = PLACO_breast_012
  for(i in 95:ncol(PLACO_breast_PRS)){
    PLACO_breast_PRS[,i] = PLACO_breast_PRS$beta.trait2*as.numeric(PLACO_breast_PRS[,i])
  }
  write_tsv(PLACO_breast_PRS, "/home/yanyq/share_genetics/result/PRS/BRCAthenOV.PRS")
  PLACO_breast_PRS_sum = colSums(PLACO_breast_PRS[,95:ncol(PLACO_breast_PRS)], na.rm = T)
  PLACO_breast_PRS_sum = as.data.frame(PLACO_breast_PRS_sum)
  # PLACO_breast_OV_PRS_sum = as.data.frame(PLACO_breast_PRS_sum[rownames(PLACO_breast_PRS_sum)%in%colnames(breast_OV)[10:80],])
  # PLACO_breast_PRS_sum = as.data.frame(PLACO_breast_PRS_sum[!(rownames(PLACO_breast_PRS_sum)%in%colnames(breast_OV)[10:80]),])
  PLACO_breast_PRS_sum$outcome = "BRCA"
  PLACO_breast_PRS_sum$outcome[rownames(PLACO_breast_PRS_sum)%in%colnames(breast_OV)[10:80]] = "BRCA to OV"
  colnames(PLACO_breast_PRS_sum)[1] = "PRS"
  PLACO_breast_PRS_sum$sample_ID = rownames(PLACO_breast_PRS_sum)
  write_tsv(PLACO_breast_PRS_sum[,c(3,2,1)],"/home/yanyq/share_genetics/result/PRS/BRCAthenOV.PRS.plot", col_names = F)
}

{
  # 用beta.OV计算BRCA的PRS
  # 4400个uniqueID
  OV = data.table::fread(file="/home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/OV_all.vcf", skip="CHROM\tPOS",stringsAsFactors=FALSE, data.table=FALSE)#
  OV_breast = data.table::fread(file="/home/yanyq/share_genetics/data/UKB_multi_cancer/genotype/OV_BRCA_all.vcf", skip="CHROM\tPOS",stringsAsFactors=FALSE, data.table=FALSE)#
  tmp = OV$ID!=OV_breast$ID|OV$REF!=OV_breast$REF|OV$ALT!=OV_breast$ALT
  tmp_REF = OV_breast$REF[tmp]
  OV_breast$REF[tmp] = OV_breast$ALT[tmp]
  OV_breast$ALT[tmp] = tmp_REF
  which(OV$ID!=OV_breast$ID|OV$REF!=OV_breast$REF|OV$ALT!=OV_breast$ALT)
  
  # OV:10-1179; breast:1180:1224
  OV = cbind(OV,OV_breast[,10:ncol(OV_breast)])
  OV$ID = do.call(rbind, str_split(OV$ID,":"))[,1]
  nonSNP = PLACO[!PLACO$snpid%in%OV$ID,]
  
  # OV:32-1201; breast:1202:1246
  PLACO_OV = merge(PLACO, OV, by.x = "snpid", by.y = "ID")
  which(colnames(PLACO_OV)[95:1309]!=colnames(OV)[10:1224])
  unharmonized = PLACO_OV$a1==PLACO_OV$REF&PLACO_OV$a2==PLACO_OV$ALT# 20个
  PLACO_OV_unharm = PLACO_OV[unharmonized,]
  # 复等位基因，14个
  errorSNP = (PLACO_OV$a1!=PLACO_OV$ALT|PLACO_OV$a2!=PLACO_OV$REF)&(!unharmonized)
  PLACO_OV = PLACO_OV[(!unharmonized)&(!errorSNP),]
  
  for(i in 1:nrow(PLACO_OV_unharm)){
    a1 = PLACO_OV_unharm$a1[i]
    PLACO_OV_unharm$a1[i] = PLACO_OV_unharm$a2[i]
    PLACO_OV_unharm$a2[i] = a1
    PLACO_OV_unharm$or.trait1[i] = exp(-log(PLACO_OV_unharm$or.trait1[i]))
    PLACO_OV_unharm$EURaf.trait1[i] = 1-PLACO_OV_unharm$EURaf.trait1[i]
    PLACO_OV_unharm$zscore.trait1[i] = -PLACO_OV_unharm$zscore.trait1[i]
    PLACO_OV_unharm$beta.trait1[i] = -PLACO_OV_unharm$beta.trait1[i]
    PLACO_OV_unharm$or.trait2[i] = exp(-log(PLACO_OV_unharm$or.trait2[i]))
    PLACO_OV_unharm$EURaf.trait2[i] = 1-PLACO_OV_unharm$EURaf.trait2[i]
    PLACO_OV_unharm$zscore.trait2[i] = -PLACO_OV_unharm$zscore.trait2[i]
    PLACO_OV_unharm$beta.trait2[i] = -PLACO_OV_unharm$beta.trait2[i]
  }
}
{
  PLACO_OV_012 = PLACO_OV
  PLACO_OV_012[PLACO_OV=="0/0"] = 0
  PLACO_OV_012[PLACO_OV=="0/1"] = 1
  PLACO_OV_012[PLACO_OV=="1/0"] = 1
  PLACO_OV_012[PLACO_OV=="1/1"] = 2
  PLACO_OV_012[PLACO_OV=="./."] = NA
  PLACO_OV_PRS = PLACO_OV_012
  for(i in 95:ncol(PLACO_OV_PRS)){
    PLACO_OV_PRS[,i] = PLACO_OV_PRS$beta.trait1*as.numeric(PLACO_OV_PRS[,i])
  }
  write_tsv(PLACO_OV_PRS, "/home/yanyq/share_genetics/result/PRS/OVthenBRCA.PRS")
  PLACO_OV_PRS_sum = colSums(PLACO_OV_PRS[,95:ncol(PLACO_OV_PRS)], na.rm = T)
  PLACO_OV_PRS_sum = as.data.frame(PLACO_OV_PRS_sum)
  PLACO_OV_PRS_sum$outcome = "OV"
  PLACO_OV_PRS_sum$outcome[rownames(PLACO_OV_PRS_sum)%in%colnames(OV_breast)[10:80]] = "OV to BRCA"
  colnames(PLACO_OV_PRS_sum)[1] = "PRS"
  PLACO_OV_PRS_sum$sample_ID = rownames(PLACO_OV_PRS_sum)
  write_tsv(PLACO_OV_PRS_sum[,c(3,2,1)],"/home/yanyq/share_genetics/result/PRS/OVthenBRCA.PRS.plot", col_names = F)
}

#####################################独立显著SNP
lead_PLACO_breast_PRS = PLACO_breast_PRS[PLACO_breast_PRS$snpid%in%PLACO$snpid[PLACO$is.IndSig_lead!="not"],]
PLACO_breast_PRS_sum = colSums(lead_PLACO_breast_PRS[,95:ncol(lead_PLACO_breast_PRS)], na.rm = T)
PLACO_breast_PRS_sum = as.data.frame(PLACO_breast_PRS_sum)
PLACO_breast_PRS_sum$outcome = "BRCA"
PLACO_breast_PRS_sum$outcome[rownames(PLACO_breast_PRS_sum)%in%colnames(breast_OV)[10:80]] = "BRCA to OV"
colnames(PLACO_breast_PRS_sum)[1] = "PRS"
PLACO_breast_PRS_sum$sample_ID = rownames(PLACO_breast_PRS_sum)
write_tsv(PLACO_breast_PRS_sum[,c(3,2,1)],"/home/yanyq/share_genetics/result/PRS/BRCAthenOV.PRS.independent.plot", col_names = F)

lead_PLACO_OV_PRS = PLACO_OV_PRS[PLACO_OV_PRS$snpid%in%PLACO$snpid[PLACO$is.IndSig_lead!="not"],]
PLACO_OV_PRS_sum = colSums(lead_PLACO_OV_PRS[,95:ncol(lead_PLACO_OV_PRS)], na.rm = T)
PLACO_OV_PRS_sum = as.data.frame(PLACO_OV_PRS_sum)
PLACO_OV_PRS_sum$outcome = "OV"
PLACO_OV_PRS_sum$outcome[rownames(PLACO_OV_PRS_sum)%in%colnames(OV_breast)[10:80]] = "OV to BRCA"
colnames(PLACO_OV_PRS_sum)[1] = "PRS"
PLACO_OV_PRS_sum$sample_ID = rownames(PLACO_OV_PRS_sum)
write_tsv(PLACO_OV_PRS_sum[,c(3,2,1)],"/home/yanyq/share_genetics/result/PRS/OVthenBRCA.PRS.independent.plot", col_names = F)

#####################################lead SNP
lead_PLACO_breast_PRS = PLACO_breast_PRS[PLACO_breast_PRS$snpid%in%PLACO$snpid[PLACO$is.IndSig_lead=="leadSNP"],]
PLACO_breast_PRS_sum = colSums(lead_PLACO_breast_PRS[,95:ncol(lead_PLACO_breast_PRS)], na.rm = T)
PLACO_breast_PRS_sum = as.data.frame(PLACO_breast_PRS_sum)
PLACO_breast_PRS_sum$outcome = "BRCA"
PLACO_breast_PRS_sum$outcome[rownames(PLACO_breast_PRS_sum)%in%colnames(breast_OV)[10:80]] = "BRCA to OV"
colnames(PLACO_breast_PRS_sum)[1] = "PRS"
PLACO_breast_PRS_sum$sample_ID = rownames(PLACO_breast_PRS_sum)
write_tsv(PLACO_breast_PRS_sum[,c(3,2,1)],"/home/yanyq/share_genetics/result/PRS/BRCAthenOV.PRS.lead.plot", col_names = F)

lead_PLACO_OV_PRS = PLACO_OV_PRS[PLACO_OV_PRS$snpid%in%PLACO$snpid[PLACO$is.IndSig_lead=="leadSNP"],]
PLACO_OV_PRS_sum = colSums(lead_PLACO_OV_PRS[,95:ncol(lead_PLACO_OV_PRS)], na.rm = T)
PLACO_OV_PRS_sum = as.data.frame(PLACO_OV_PRS_sum)
PLACO_OV_PRS_sum$outcome = "OV"
PLACO_OV_PRS_sum$outcome[rownames(PLACO_OV_PRS_sum)%in%colnames(OV_breast)[10:80]] = "OV to BRCA"
colnames(PLACO_OV_PRS_sum)[1] = "PRS"
PLACO_OV_PRS_sum$sample_ID = rownames(PLACO_OV_PRS_sum)
write_tsv(PLACO_OV_PRS_sum[,c(3,2,1)],"/home/yanyq/share_genetics/result/PRS/OVthenBRCA.PRS.lead.plot", col_names = F)
