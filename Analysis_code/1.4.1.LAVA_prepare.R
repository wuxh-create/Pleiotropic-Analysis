library(readr)
library(data.table)
setwd("/home/yanyq/share_genetics/data/GWAS/processed/")
samplesize = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/sampleSize",col_names = F))
files = list.files()
# tmp = samplesize$X1[1:10]
# tmp = paste0(tmp,".gz")
# files = files[!files%in%tmp]
for(i in files){
  f = fread(i)
  f$N = samplesize[samplesize$X1==gsub(".gz","",i),2]
  f = f[,c("snpid","a1","a2","N","or","pval")]
  colnames(f) = c("SNP","A1","A2","N","OR","P")
  write_tsv(f,paste0("/home/yanyq/share_genetics/data/GWAS/LAVA/",i))
}

{
  # 最初的10个癌症ldsc用的是绝对样本量
  # 后来的ldsc我们使用有效样本量
  # 除了MCL-BGC、MCL-DLBC、MCL-MESO、MCL-MM、MCL-MS、MCL-MZBL，有效样本量大0.0001
  # 两种方法计算的gcov_int没有区别
  scor = read.table("/home/yanyq/share_genetics/result/ldsc/ldsc_stat",header=T)              # read in
  scor = scor[seq(1,nrow(scor),2),]
  scor = scor[,c("p1","p2","gcov_int")]             # retain key headers
  scor$p1 = gsub("/home/yanyq/share_genetics/result/ldsc/munge_filter/","",gsub(".sumstats.gz","",scor$p1))   # assuming the munged files have format [phenotype]_munge.sumstats.gz
  scor$p2 = gsub("/home/yanyq/share_genetics/result/ldsc/munge_filter/","",gsub(".sumstats.gz","",scor$p2))   # (adapt as necessary)
  row_num = nrow(scor)
  tmp = scor$p1[1:nrow(scor)]
  scor = rbind(scor,scor)
  scor$p1[(row_num+1):nrow(scor)] = scor$p2[(row_num+1):nrow(scor)]
  scor$p2[(row_num+1):nrow(scor)] = tmp
  phen = unique(c(scor$p1,scor$p2))
  tmp = scor[1:length(phen),]
  tmp[,1] = phen
  tmp[,2] = phen
  tmp[,3] = 1
  scor = rbind(scor,tmp)
  
  phen = unique(scor$p1)                  # obtain list of all phenotypes (assuming all combinations have been analysed)
  n = length(phen)
  mat = matrix(NA,n,n)                    # create matrix
  rownames(mat) = colnames(mat) = phen    # set col/rownames
  
  for (i in phen) {
    for (j in phen) {
      mat[i,j] = as.numeric(subset(scor, p1==i & p2==j)$gcov_int)
    }
  }
  
  if (!all(t(mat)==mat)) { mat[lower.tri(mat)] = t(mat)[lower.tri(mat)] }  # sometimes there might be small differences in gcov_int depending on which phenotype was analysed as the outcome / predictor
  mat = round(cov2cor(mat),5)                       # standardise
  write.table(mat, "/home/yanyq/share_genetics/data/GWAS/sample.overlap.txt", quote=F)   # save
}
