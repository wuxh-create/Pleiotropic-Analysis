#/bin/bash
# Munge Data

munge_sumstats.py \
--sumstats /home/yanyq/share_genetics/data/GWAS/processed/AN \
--N 72517 \
--out /home/yanyq/share_genetics/result/ldsc/munge/AN \
--merge-alleles /home/yanyq/share_genetics/data/reference/w_hm3.noMHC.snplist

munge_sumstats.py \
--sumstats /home/yanyq/share_genetics/data/GWAS/processed/GORD \
--N 456327 \
--out /home/yanyq/share_genetics/result/ldsc/munge/GORD \
--merge-alleles /home/yanyq/share_genetics/data/reference/w_hm3.noMHC.snplist

munge_sumstats.py \
--sumstats /home/yanyq/share_genetics/data/GWAS/processed/IBS \
--N 486601 \
--out /home/yanyq/share_genetics/result/ldsc/munge/IBS \
--merge-alleles /home/yanyq/share_genetics/data/reference/w_hm3.noMHC.snplist

munge_sumstats.py \
--sumstats /home/yanyq/share_genetics/data/GWAS/processed/IBD \
--N 456327 \
--out /home/yanyq/share_genetics/result/ldsc/munge/IBS \
--merge-alleles /home/yanyq/share_genetics/data/reference/w_hm3.noMHC.snplist

munge_sumstats.py \
--sumstats /home/yanyq/share_genetics/data/GWAS/processed/PUD \
--N 456327 \
--out /home/yanyq/share_genetics/result/ldsc/munge/PUD \
--merge-alleles /home/yanyq/share_genetics/data/reference/w_hm3.noMHC.snplist
