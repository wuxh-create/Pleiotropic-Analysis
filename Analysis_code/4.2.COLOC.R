# 共定位分析
setwd("~/share_genetics/data/GWAS/processed")
library(readr)
library(data.table)
library(coloc)
# arg = commandArgs(T)
# trait1 = arg[1]
# trait2 = arg[2]
traits = c("AML","BAC","BCC","BGA","BGC","BLCA","BM","BRCA","CESC","CML","CORP",
           "CRC","DLBC","ESCA","EYAD","GSS","HL","HNSC","kidney","LIHC","LL",
           "lung","MCL","MESO","MM","MS","MZBL","OV","PAAD","PRAD","SCC","SI",
           "SKCM","STAD","TEST","THCA","UCEC","VULVA")

sampleSize = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/sampleSize",col_names = F))
for(trait1 in traits){
  for(trait2 in traits){
    if(file.exists(paste0("~/share_genetics/result/FUMA/merge/",trait1,"-",trait2))){
      print(paste0(trait1,"-",trait2))
      result = list()
      best_result = list() # SNP.PP.H4最佳的
      to_coloc = list()
      FUMA_both = as.data.frame(read_tsv(paste0("~/share_genetics/result/FUMA/merge/",trait1,"-",trait2)))
      overlap = as.data.frame(read_tsv(paste0("~/share_genetics/data/GWAS/overlap/",trait1,"-",trait2,".gz")))
      colnames(overlap)[2:3] = c("chr","bp")
      
      for(j in 1:nrow(FUMA_both)){
        to_coloc[[j]] = overlap[overlap$chr==FUMA_both$chr[j]&overlap$bp>=FUMA_both$start[j]&overlap$bp<=FUMA_both$end[j],]
      }
      N_trait1 = sampleSize$X2[sampleSize$X1==trait1]
      N_trait2 = sampleSize$X2[sampleSize$X1==trait2]
      
      for(j in 1:length(to_coloc)){
        to_coloc[[j]] = as.matrix(to_coloc[[j]])
        MAF_trait1 = to_coloc[[j]][,paste0("EURaf.",trait1)]
        MAF_trait2 = to_coloc[[j]][,paste0("EURaf.",trait2)]
          
        
	      tryCatch({
          result[[j]] = coloc.abf(dataset1=list(pvalues=as.numeric(to_coloc[[j]][,paste0("pval.",trait1)]), type="cc",snp=to_coloc[[j]][,"snpid"],beta=log(as.numeric(to_coloc[[j]][,paste0("or.",trait1)])),varbeta=(as.numeric(to_coloc[[j]][,paste0("se.",trait1)]))^2,N=N_trait1, MAF=as.numeric(MAF_trait1)),
                                  dataset2=list(pvalues=as.numeric(to_coloc[[j]][,paste0("pval.",trait2)]), type="cc",snp=to_coloc[[j]][,"snpid"],beta=log(as.numeric(to_coloc[[j]][,paste0("or.",trait2)])),varbeta=(as.numeric(to_coloc[[j]][,paste0("se.",trait2)]))^2,N=N_trait2, MAF=as.numeric(MAF_trait2)))
          tmp_result = result[[j]]$result
          best_result[[j]] = tmp_result[which.max(tmp_result$`SNP.PP.H4`),]
        }, error = function(e) {
          write_rds(to_coloc[[j]],paste0("/home/yanyq/share_genetics/result/coloc/error/",trait1,"-",trait2,"_locus_",j))
        })
      }
      write_rds(result,paste0("/home/yanyq/share_genetics/result/coloc/raw/",trait1,"-",trait2))
      for(j in 1:length(result)){
        if(length(result)!=0){
          if(!is.null(result[[j]])){
            tmp = result[[j]]$summary
            tmp["locus"] = FUMA_both$locus[j]
            tmp["no.locus"] = FUMA_both$GenomicLocus[j]
            result[[j]] = tmp
          }else{
            result[[j]] = as.data.frame(matrix(ncol=8,nrow = 1))
            colnames(result[[j]]) = c("nsnps","PP.H0.abf","PP.H1.abf","PP.H2.abf","PP.H3.abf","PP.H4.abf","locus","no.locus")
            best_result[[j]] = as.data.frame(matrix(ncol=11,nrow = 1))
            colnames(best_result[[j]]) = c("snp","V.df1","z.df1","r.df1","lABF.df1","V.df2","z.df2","r.df2", "lABF.df2", "internal.sum.lABF", "SNP.PP.H4")
          }
        }
      }
      
      best_result = do.call(rbind,best_result)
      result = do.call(rbind,result)
      result = as.data.frame(result)
      for(j in which(is.na(result$locus))){
        result$nsnps[j] = nrow(overlap[(overlap$chr==FUMA_both$chr[j])&(overlap$bp>=FUMA_both$start[j])&(overlap$bp<=FUMA_both$end[j]),])
        result$locus[j] = FUMA_both$locus[j]
        result$no.locus[j] = FUMA_both$GenomicLocus[j]
      }
      write_tsv(cbind(result,best_result),paste0("~/share_genetics/result/coloc/summary/",trait1,"-",trait2))
    }
  }
}

setwd("~/share_genetics/result/coloc/summary")
files = list.files()
coloc_res = list()
for(i in files){
  tmp = fread(i,header = T)
  if(nrow(tmp)>0){
    tmp$traits = i
    coloc_res[[i]] = tmp
  }
}
coloc_res = do.call(rbind,coloc_res)


############################################
# MAGMA结果共定位
# 共定位分析
rm(list = ls())
setwd("~/share_genetics/data/GWAS/processed")
library(readr)
library(data.table)
library(coloc)
# arg = commandArgs(T)
# trait1 = arg[1]
# trait2 = arg[2]
traits = c("AML","BAC","BCC","BGA","BGC","BLCA","BM","BRCA","CESC","CML","CORP",
           "CRC","DLBC","ESCA","EYAD","GSS","HL","HNSC","kidney","LIHC","LL",
           "lung","MCL","MESO","MM","MS","MZBL","OV","PAAD","PRAD","SCC","SI",
           "SKCM","STAD","TEST","THCA","UCEC","VULVA")
sampleSize = read.table("/home/yanyq/share_genetics/data/sampleSize",header = F)
for(trait1 in traits){
  for(trait2 in traits){
    if(file.exists(paste0("/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/",trait1,"-",trait2))){
      print(paste0(trait1,"-",trait2))
      result = list()
      best_result = list() # SNP.PP.H4最佳的
      to_coloc = list()
      MAGMA_both = fread(paste0("/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/",trait1,"-",trait2))
      if(nrow(MAGMA_both) > 0){
        overlap = fread(paste0("~/share_genetics/data/GWAS/overlap/",trait1,"-",trait2,".gz"))
        colnames(overlap)[2:3] = c("chr","bp")
        
        for(j in 1:nrow(MAGMA_both)){
          to_coloc[[j]] = overlap[overlap$chr==MAGMA_both$CHR[j]&overlap$bp>=MAGMA_both$START[j]&overlap$bp<=MAGMA_both$STOP[j],]
        }
        N_trait1 = sampleSize$V2[sampleSize$V1==trait1]
        N_trait2 = sampleSize$V2[sampleSize$V1==trait2]
        
        for(j in 1:length(to_coloc)){
          to_coloc[[j]] = as.matrix(to_coloc[[j]])
          MAF_trait1 = to_coloc[[j]][,paste0("EURaf.",trait1)]
          MAF_trait2 = to_coloc[[j]][,paste0("EURaf.",trait2)]
          
          # # 检查是否有beta为0的
          # tmp_or1 = as.numeric(to_coloc[[j]][,paste0("or.",trait1)])
          # tmp_or2 = as.numeric(to_coloc[[j]][,paste0("or.",trait2)])
          dataset1 = list(pvalues=as.numeric(to_coloc[[j]][,paste0("pval.",trait1)]), type="cc",snp=to_coloc[[j]][,"snpid"],beta=log(as.numeric(to_coloc[[j]][,paste0("or.",trait1)])),varbeta=((as.numeric(to_coloc[[j]][,paste0("se.",trait1)]))^2),N=N_trait1, MAF=as.numeric(MAF_trait1))
          dataset2 = list(pvalues=as.numeric(to_coloc[[j]][,paste0("pval.",trait2)]), type="cc",snp=to_coloc[[j]][,"snpid"],beta=log(as.numeric(to_coloc[[j]][,paste0("or.",trait2)])),varbeta=((as.numeric(to_coloc[[j]][,paste0("se.",trait2)]))^2),N=N_trait2, MAF=as.numeric(MAF_trait2))
          tryCatch({
            result[[j]] = coloc.abf(dataset1 = dataset1,
                                    dataset2 = dataset2)
            tmp_result = result[[j]]$result
            best_result[[j]] = tmp_result[which.max(tmp_result$`SNP.PP.H4`),]
          }, error = function(e) {
            write_rds(to_coloc[[j]],paste0("/home/yanyq/share_genetics/result/coloc_MAGMA/error/",trait1,"-",trait2,"_locus_",j))
          })
        }
        write_rds(result,paste0("/home/yanyq/share_genetics/result/coloc_MAGMA/raw/",trait1,"-",trait2))
        for(j in 1:length(result)){
          if(length(result)!=0){
            if(!is.null(result[[j]])){
              tmp = result[[j]]$summary
              tmp["locus"] = MAGMA_both$locus.MAGMA[j]
              tmp["gene"] = MAGMA_both$SYMBOL[j]
              result[[j]] = tmp
            }else{
              result[[j]] = as.data.frame(matrix(ncol=8,nrow = 1))
              colnames(result[[j]]) = c("nsnps","PP.H0.abf","PP.H1.abf","PP.H2.abf","PP.H3.abf","PP.H4.abf","locus", "gene")
              best_result[[j]] = as.data.frame(matrix(ncol=11,nrow = 1))
              colnames(best_result[[j]]) = c("snp","V.df1","z.df1","r.df1","lABF.df1","V.df2","z.df2","r.df2", "lABF.df2", "internal.sum.lABF", "SNP.PP.H4")
            }
          }
        }
        
        best_result = do.call(rbind,best_result)
        result = do.call(rbind,result)
        result = as.data.frame(result)
        for(j in which(is.na(result$locus))){
          result$nsnps[j] = nrow(overlap[(overlap$chr==MAGMA_both$CHR[j])&(overlap$bp>=MAGMA_both$START[j])&(overlap$bp<=MAGMA_both$STOP[j]),])
          result$locus[j] = MAGMA_both$locus.MAGMA[j]
          result$gene[j] = MAGMA_both$SYMBOL[j]
        }
        write_tsv(cbind(result,best_result),paste0("~/share_genetics/result/coloc_MAGMA/summary/",trait1,"-",trait2))
      }
    }
  }
}


setwd("~/share_genetics/result/coloc_MAGMA/summary")
files = list.files()
coloc_MAGMA_res = list()
for(i in files){
  tmp = fread(i,header = T)
  if(nrow(tmp)>0){
    tmp$traits = i
    coloc_MAGMA_res[[i]] = tmp
  }
}
coloc_MAGMA_res = do.call(rbind,coloc_MAGMA_res)
