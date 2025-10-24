#!/bin/bashs
trait=("BLCA" "BRCA" "HNSC" "kidney" "lung" "OV" "PAAD" "PRAD" "SKCM" "UCEC")
for i in {0..8}
do
        j=$(($i+1))
        while [ $j -lt 10 ]
        do
                python3 /home/yanyq/software/mixer/precimed/mixer_figures.py two \
                    --json-fit /home/yanyq/share_genetics/result/mixer/combine/${trait[i]}-${trait[j]}.fit.json \
                    --json-test /home/yanyq/share_genetics/result/mixer/combine/${trait[i]}-${trait[j]}.test.json \
                    --out /home/yanyq/share_genetics/result/mixer/two/${trait[i]}-${trait[j]} --statistic mean std

                let j++
        done
done

