# FUMA注释的leadSNP数和风险基因座
# Based on the identified independent significant SNPs, independent lead SNPs are 
# defined if they are independent from each other at r 2 < 0.1. 
# Additionally, if LD blocks of independent significant SNPs are closely 
# located to each other (< 250 kb based on the most right and left SNPs from each LD block), 
# they are merged into one genomic locus. 
# Each genomic locus can thus contain multiple independent significant SNPs and lead SNPs.
lead = f
lead$V1[lead$V1!=0] = NA
lead$V2 = lead$V1
for(i in 1:nrow(lead)){
  trait1 = lead$trait1[i]
  trait2 = lead$trait2[i]
  if(file.exists(paste0("/home/yanyq/share_genetics/result/FUMA/",trait1,"-",trait2,"/leadSNPs.txt"))){
    FUMA_both = read_tsv(paste0("/home/yanyq/share_genetics/result/FUMA/",trait1,"-",trait2,"/leadSNPs.txt"))
    lead$V1[i] = nrow(FUMA_both)
    FUMA_both = read_tsv(paste0("/home/yanyq/share_genetics/result/FUMA/",trait1,"-",trait2,"/GenomicRiskLoci.txt"))
    lead$V2[i] = nrow(FUMA_both)
  }
}
which(lead$V1==0&f$V1!=0)
which(lead$V1!=0&f$V1==0)
which(lead$V2==0&f$V1!=0)
which(lead$V2!=0&f$V1==0)
which(lead$trait1!=f$trait1)
which(lead$trait2!=f$trait2)
colnames(lead) = c("num_leadSNP", "trait1", "trait2", "num_loci")
write_tsv(lead[,c(2,3,1,4)], "/home/yanyq/share_genetics/final_result/FUMA/all_leadSNP_AND_loci_num")

# 所有显著的多效位点
f = read.table("/home/yanyq/share_genetics/result/PLACO/sig_num", header = F)
f = f[-704,]
f$V2 = gsub("/home/yanyq/share_genetics/result/PLACO/sig_","",f$V2)
f = f[!grepl("CORP", f$V2),]
f = tidyr::separate(f, col = "V2", into = c("trait1", "trait2"), sep = "-")
f$V1 = f$V1-1
