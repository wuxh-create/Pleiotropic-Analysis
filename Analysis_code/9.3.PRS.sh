# https://zhuanlan.zhihu.com/p/401122336
# clump
plink --bfile /home/yanyq/share_genetics/data/MAGMA/g1000_eur/g1000_eur \
      --clump-p1 1 \
      --clump-r2 0.1 \
      --clump-kb 250 \
      --clump /home/yanyq/share_genetics/result/PLACO/PLACO_BRCA-OV.gz \
      --clump-snp-field snpid \
      --clump-field p.placo \
      --out /home/yanyq/share_genetics/result/PRS/BRCA-OV
      
echo "0.001 0 0.001" > /home/yanyq/share_genetics/result/PRS/range_list 
echo "0.05 0 0.05" >> /home/yanyq/share_genetics/result/PRS/range_list
echo "0.1 0 0.1" >> /home/yanyq/share_genetics/result/PRS/range_list
echo "0.2 0 0.2" >> /home/yanyq/share_genetics/result/PRS/range_list
echo "0.3 0 0.3" >> /home/yanyq/share_genetics/result/PRS/range_list
echo "0.4 0 0.4" >> /home/yanyq/share_genetics/result/PRS/range_list
echo "0.5 0 0.5" >> /home/yanyq/share_genetics/result/PRS/range_list

awk 'NR!=1{print $3}' /home/yanyq/share_genetics/result/PRS/BRCA-OV.clumped > /home/yanyq/share_genetics/result/PRS/BRCA-OV.valid.snp
# awk '{print $1,$6}' /home/yanyq/share_genetics/result/PLACO/PLACO_BRCA-OV.gz > /home/yanyq/share_genetics/result/PRS/BRCA-OV.SNP.pvalue
f = read_tsv("/home/yanyq/share_genetics/result/PLACO/PLACO_BRCA-OV.gz")
f = f[,c(1,6)]
write_tsv(f,"/home/yanyq/share_genetics/result/PRS/BRCA-OV.SNP.pvalue")

f = read_tsv("/home/yanyq/share_genetics/data/GWAS/overlap/BRCA-OV.gz")
f$beta.BRCA = log(f$or.BRCA)
f$beta.OV = log(f$or.OV)
write_tsv(f,"/home/yanyq/share_genetics/result/PRS/BRCA-OV_beta")

# 构建BRCA中的PRS模型
plink --bfile /home/yanyq/share_genetics/data/MAGMA/g1000_eur/g1000_eur \
      --score /home/yanyq/share_genetics/result/PRS/BRCA-OV_beta 1 4 20 header \
      --q-score-range /home/yanyq/share_genetics/result/PRS/range_list /home/yanyq/share_genetics/result/PRS/BRCA-OV.SNP.pvalue \
      --extract /home/yanyq/share_genetics/result/PRS/BRCA-OV.valid.snp \
      --out /home/yanyq/share_genetics/result/PRS/BRCA-OV.PRS