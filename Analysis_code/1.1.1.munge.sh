#!/bin/bash
while read line
do
	array=(${line//\t/})
	munge_sumstats.py \
	--sumstats /home/yanyq/share_genetics/data/GWAS/processed/${array[0]}.gz \
	--N ${array[1]} \
	--out /home/yanyq/share_genetics/result/ldsc/munge/${array[0]} \
	--merge-alleles /home/yanyq/share_genetics/data/reference/w_hm3.noMHC.snplist
done < /home/yanyq/share_genetics/data/sampleSize

#!/bin/bash
while read line
do
        array=(${line//\t/})
        munge_sumstats.py \
        --sumstats /home/yanyq/share_genetics/data/GWAS/processed/${array[0]}.gz \
        --N ${array[1]} \
        --out /home/yanyq/share_genetics/result/ldsc/munge_sampleSize_effect/${array[0]} \
        --merge-alleles /home/yanyq/share_genetics/data/reference/w_hm3.noMHC.snplist
done < /home/yanyq/share_genetics/data/sampleSize_effect

#!/bin/bash
while read line
do
        array=(${line//\t/})
        munge_sumstats.py \
        --sumstats /home/yanyq/share_genetics/data/GWAS/processed/${array[0]}.gz \
        --N ${array[1]} \
        --out /home/yanyq/share_genetics/result/ldsc/munge_sampleSize_effect_4/${array[0]} \
        --merge-alleles /home/yanyq/share_genetics/data/reference/w_hm3.noMHC.snplist
done < /home/yanyq/share_genetics/data/sampleSize_effect_4

