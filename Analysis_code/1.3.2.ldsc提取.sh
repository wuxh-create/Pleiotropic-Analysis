#!/bin/bash
ls ~/share_genetics/result/ldsc/ldsc > /home/yanyq/share_genetics/result/ldsc/ldsc_file
while read line
do
	echo $line >> /home/yanyq/share_genetics/result/ldsc/ldsc_intercept
	grep "Intercept"  /home/yanyq/share_genetics/result/ldsc/ldsc/$line >> /home/yanyq/share_genetics/result/ldsc/ldsc_intercept
        tail -n 5 /home/yanyq/share_genetics/result/ldsc/ldsc/$line | head -n 2	>> /home/yanyq/share_genetics/result/ldsc/ldsc_stat
done < /home/yanyq/share_genetics/result/ldsc/ldsc_file

while read line
do
        echo $line >> /home/yanyq/share_genetics/result/ldsc/ldsc_intercept_sampleSize_effect
        grep "Intercept"  /home/yanyq/share_genetics/result/ldsc/ldsc_sampleSize_effect/$line >> /home/yanyq/share_genetics/result/ldsc/ldsc_intercept_sampleSize_effect
	tail -n 5 /home/yanyq/share_genetics/result/ldsc/ldsc_sampleSize_effect/$line | head -n 2  >> /home/yanyq/share_genetics/result/ldsc/ldsc_stat_sampleSize_effect
done < /home/yanyq/share_genetics/result/ldsc/ldsc_file

while read line
do
        echo $line >> /home/yanyq/share_genetics/result/ldsc/ldsc_intercept_sampleSize_effect_4
        grep "Intercept"  /home/yanyq/share_genetics/result/ldsc/ldsc_sampleSize_effect_4/$line >> /home/yanyq/share_genetics/result/ldsc/ldsc_intercept_sampleSize_effect_4
	tail -n 5 /home/yanyq/share_genetics/result/ldsc/ldsc_sampleSize_effect_4/$line | head -n 2  >> /home/yanyq/share_genetics/result/ldsc/ldsc_stat_sampleSize_effect_4
done < /home/yanyq/share_genetics/result/ldsc/ldsc_file
