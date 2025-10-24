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
"AML" "BCC" "BGC" "BM" "CESC" "CORP" "DLBC" "EYAD" "HL" "LL" "MCL" "MM" "MZBL" "SCC" "TEST" "BAC" "BGA" "CML" "CRC" "ESCA" "GSS" "LIHC" "MESO" "MS" "SI" "STAD" "THCA" "VULVA"