#!/bin/bashs
for i in `seq 22`;do python3 /home/yanyq/software/mixer/precimed/mixer.py ld --lib /home/yanyq/software/mixer/src/build/lib/libbgmg.so --bfile /home/yanyq/share_genetics/data/MAGMA/g1000_eur/chr/chr$i --out /home/yanyq/share_genetics/data/MAGMA/g1000_eur/chr/mixer/chr$i.run4.ld --r2min 0.05 --ldscore-r2min 0.05 --ld-window-kb 30000;done


for trait in ("BLCA" "BRCA" "HNSC" "kidney" "lung" "OV" "PAAD" "PRAD" "SKCM" "UCEC")
do
    python3 /home/yanyq/software/mixer/precimed/mixer.py fit1 \
      --trait1-file /home/yanyq/share_genetics/data/GWAS/mixer_input/$trait.gz \
      --out /home/yanyq/share_genetics/result/mixer/fit1/$trait.fit.rep${SLURM_ARRAY_TASK_ID} \
      --bim-file /home/yanyq/share_genetics/data/MAGMA/g1000_eur/chr/chr@.bim --ld-file /home/yanyq/share_genetics/data/MAGMA/g1000_eur/chr/mixer/chr@.run4.ld \
      --lib /home/yanyq/software/mixer/src/build/lib/libbgmg.so --threads 20

    python3 /home/yanyq/software/mixer/precimed/mixer.py test1 \
      --trait1-file /home/yanyq/share_genetics/data/GWAS/mixer_input/$trait.gz \
      --load-params-file /home/yanyq/share_genetics/result/mixer/fit1/$trait.fit.rep${SLURM_ARRAY_TASK_ID}.json \
      --out /home/yanyq/share_genetics/result/mixer/test1/$trait.test.rep${SLURM_ARRAY_TASK_ID} \
      --lib --lib /home/yanyq/software/mixer/src/build/lib/libbgmg.so --threads 20 \
      --bim-file /home/yanyq/share_genetics/data/MAGMA/g1000_eur/chr/chr@.bim --ld-file /home/yanyq/share_genetics/data/MAGMA/g1000_eur/chr/mixer/chr@.run4.ld
done

trait=("BLCA" "BRCA" "HNSC" "kidney" "lung" "OV" "PAAD" "PRAD" "SKCM" "UCEC")
for i in {0..8}
do
        j=$(($i+1))
        while [ $j -lt 10 ]
        do
                python3 /home/yanyq/software/mixer/precimed/mixer.py fit2 \
                    --trait1-file /home/yanyq/share_genetics/data/GWAS/mixer_input/${trait[i]}.gz \
                    --trait2-file /home/yanyq/share_genetics/data/GWAS/mixer_input/${trait[j]}.gz \
                    --trait1-params-file /home/yanyq/share_genetics/result/mixer/fit1/${trait[i]}.fit.rep${SLURM_ARRAY_TASK_ID}.json \
                    --trait2-params-file /home/yanyq/share_genetics/result/mixer/fit1/${trait[j]}.fit.rep${SLURM_ARRAY_TASK_ID}.json \
                    --out /home/yanyq/share_genetics/result/mixer/fit2/${trait[i]}-${trait[j]}.fit.rep${SLURM_ARRAY_TASK_ID} \
                    --lib /home/yanyq/software/mixer/src/build/lib/libbgmg.so --threads 20 \
                    --bim-file /home/yanyq/share_genetics/data/MAGMA/g1000_eur/chr/chr@.bim --ld-file /home/yanyq/share_genetics/data/MAGMA/g1000_eur/chr/mixer/chr@.run4.ld
                
                python3 /home/yanyq/software/mixer/precimed/mixer.py test2 \
                    --trait1-file /home/yanyq/share_genetics/data/GWAS/mixer_input/${trait[i]}.gz \
                    --trait2-file /home/yanyq/share_genetics/data/GWAS/mixer_input/${trait[j]}.gz \
                    --load-params-file /home/yanyq/share_genetics/result/mixer/fit2/${trait[i]}-${trait[j]}.fit.rep${SLURM_ARRAY_TASK_ID}.json \
                    --out /home/yanyq/share_genetics/result/mixer/test2/${trait[i]}-${trait[j]}.test.rep${SLURM_ARRAY_TASK_ID} \
                    --lib /home/yanyq/software/mixer/src/build/lib/libbgmg.so --threads 20 \
                    --bim-file /home/yanyq/share_genetics/data/MAGMA/g1000_eur/chr/chr@.bim --ld-file /home/yanyq/share_genetics/data/MAGMA/g1000_eur/chr/mixer/chr@.run4.ld
                
                python3 /home/yanyq/software/mixer/precimed/mixer_figures.py combine \
                    --json /home/yanyq/share_genetics/result/mixer/fit2/${trait[i]}-${trait[j]}.fit.rep${SLURM_ARRAY_TASK_ID}.json \
                    --out /home/yanyq/share_genetics/result/mixer/combine/${trait[i]}-${trait[j]}.fit
                python3 /home/yanyq/software/mixer/precimed/mixer_figures.py combine \
                    --json /home/yanyq/share_genetics/result/mixer/test2/${trait[i]}-${trait[j]}.test.rep${SLURM_ARRAY_TASK_ID}.json \
                    --out /home/yanyq/share_genetics/result/mixer/combine/${trait[i]}-${trait[j]}.test
                python3 /home/yanyq/software/mixer/precimed/mixer_figures.py two \
                    --json-fit /home/yanyq/share_genetics/result/mixer/combine/${trait[i]}-${trait[j]}.fit.json \
                    --json-test /home/yanyq/share_genetics/result/mixer/combine/${trait[i]}-${trait[j]}.test.json \
                    --out /home/yanyq/share_genetics/result/mixer/two/${trait[i]}-${trait[j]} --statistic mean std

                let j++
        done
done

