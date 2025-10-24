#!/bin/bash
ls ~/share_genetics/result/ldsc/h2 > /home/yanyq/share_genetics/result/ldsc/h2_file
echo -e 'trait\tTotal Observed scale h2\tLambda GC\tMean Chi^2\tIntercept\tRatio' > /home/yanyq/share_genetics/result/ldsc/ldsc_h2
while read line
do
    result=$(tail -n 7 /home/yanyq/share_genetics/result/ldsc/h2/$line | head -n 5 | \
    sed 's/Total Observed scale h2: //g' | sed 's/Lambda GC: //g' | sed 's/Mean Chi^2: //g' | sed 's/Intercept: //g' | sed 's/Ratio: //g' | paste -s -d '\t' | sed 's/\t/\\t/g')
    echo -e ''$line'\t'$result'' >> /home/yanyq/share_genetics/result/ldsc/ldsc_h2
done < /home/yanyq/share_genetics/result/ldsc/h2_file

echo -e 'trait\tTotal Observed scale h2\tLambda GC\tMean Chi^2\tIntercept\tRatio' > /home/yanyq/share_genetics/result/ldsc/ldsc_h2_sampleSize_effect
while read line
do
    result=$(tail -n 7 /home/yanyq/share_genetics/result/ldsc/h2_sampleSize_effect/$line | head -n 5 | \
    sed 's/Total Observed scale h2: //g' | sed 's/Lambda GC: //g' | sed 's/Mean Chi^2: //g' | sed 's/Intercept: //g' | sed 's/Ratio: //g' | paste -s -d '\t' | sed 's/\t/\\t/g')
    echo -e ''$line'\t'$result'' >> /home/yanyq/share_genetics/result/ldsc/ldsc_h2_sampleSize_effect
done < /home/yanyq/share_genetics/result/ldsc/h2_file

echo -e 'trait\tTotal Observed scale h2\tLambda GC\tMean Chi^2\tIntercept\tRatio' > /home/yanyq/share_genetics/result/ldsc/ldsc_h2_sampleSize_effect_4
while read line
do
    result=$(tail -n 7 /home/yanyq/share_genetics/result/ldsc/h2_sampleSize_effect_4/$line | head -n 5 | \
    sed 's/Total Observed scale h2: //g' | sed 's/Lambda GC: //g' | sed 's/Mean Chi^2: //g' | sed 's/Intercept: //g' | sed 's/Ratio: //g' | paste -s -d '\t' | sed 's/\t/\\t/g')
    echo -e ''$line'\t'$result'' >> /home/yanyq/share_genetics/result/ldsc/ldsc_h2_sampleSize_effect_4
done < /home/yanyq/share_genetics/result/ldsc/h2_file
