#!/bin/bash
trait_path="/home/yanyq/share_genetics/data/GWAS/SUPERGNOVA"
traits1=("BLCA" "BRCA" "HNSC" "kidney" "lung" "OV" "PAAD" "PRAD" "SKCM" "UCEC")
traits2=("BGC" "CRC" "DLBC" "ESCA" "STAD" "THCA")
traits3=("AML" "BAC" "BCC" "BGA" "BM" "CESC" "CML" "CORP" "EYAD" "GSS" "HL" "LIHC" "LL" "MCL" "MESO" "MM" "MS" "MZBL" "SCC" "SI" "TEST" "VULVA")

for i in {0..8}
do
    trait1=${traits1[i]}
    echo $trait1
    N1=$(zcat $trait_path/$trait1.gz | head -n 2 | cut -f 5 | tail -n 1)
    j=$(($i+1))
    while [ $j -lt 10 ]
    do
        trait2=${traits1[j]}
        N2=$(zcat $trait_path/$trait2.gz | head -n 2 | cut -f 5 | tail -n 1)
        echo 'python3 /home/yanyq/software/SUPERGNOVA/supergnova.py '$trait_path'/'$trait1'.gz '$trait_path'/'$trait2'.gz --N1 '$N1' --N2 '$N2' --bfile /home/yanyq/software/SUPERGNOVA/data/bfiles/eur_chr@_SNPmaf5 --partition /home/yanyq/software/SUPERGNOVA/data/partition/eur_chr@.bed --out /home/yanyq/share_genetics/result/SUPERGNOVA/'${trait1}'-'${trait2}' --thread 5' > /home/yanyq/share_genetics/pipeline/code/1.6.3.SUPERGNOVA_run/${trait1}-${trait2}.sh
        echo 'nohup bash /home/yanyq/share_genetics/pipeline/code/1.6.3.SUPERGNOVA_run/'${trait1}'-'${trait2}'.sh >& /home/yanyq/share_genetics/pipeline/code/log/1.6.3.SUPERGNOVA_run/'${trait1}'-'${trait2}'.log &' >> /home/yanyq/share_genetics/pipeline/code/1.6.3.SUPERGNOVA_run/all_run.sh
        let j++
    done
done

for i in {0..4}
do
    trait1=${traits2[i]}
    echo $trait1
    N1=$(zcat $trait_path/$trait1.gz | head -n 2 | cut -f 5 | tail -n 1)
    j=$(($i+1))
    while [ $j -lt 6 ]
    do
        trait2=${traits2[j]}
        N2=$(zcat $trait_path/$trait2.gz | head -n 2 | cut -f 5 | tail -n 1)
        echo 'python3 /home/yanyq/software/SUPERGNOVA/supergnova.py '$trait_path'/'$trait1'.gz '$trait_path'/'$trait2'.gz --N1 '$N1' --N2 '$N2' --bfile /home/yanyq/software/SUPERGNOVA/data/bfiles/eur_chr@_SNPmaf5 --partition /home/yanyq/software/SUPERGNOVA/data/partition/eur_chr@.bed --out /home/yanyq/share_genetics/result/SUPERGNOVA/'${trait1}'-'${trait2}' --thread 5' > /home/yanyq/share_genetics/pipeline/code/1.6.3.SUPERGNOVA_run/${trait1}-${trait2}.sh
        echo 'nohup bash /home/yanyq/share_genetics/pipeline/code/1.6.3.SUPERGNOVA_run/'${trait1}'-'${trait2}'.sh >& /home/yanyq/share_genetics/pipeline/code/log/1.6.3.SUPERGNOVA_run/'${trait1}'-'${trait2}'.log &' >> /home/yanyq/share_genetics/pipeline/code/1.6.3.SUPERGNOVA_run/all_run.sh
        let j++
    done
done

for i in {0..20}
do
    trait1=${traits3[i]}
    echo $trait1
    N1=$(zcat $trait_path/$trait1.gz | head -n 2 | cut -f 5 | tail -n 1)
    j=$(($i+1))
    while [ $j -lt 22 ]
    do
        trait2=${traits3[j]}
        N2=$(zcat $trait_path/$trait2.gz | head -n 2 | cut -f 5 | tail -n 1)
        echo 'python3 /home/yanyq/software/SUPERGNOVA/supergnova.py '$trait_path'/'$trait1'.gz '$trait_path'/'$trait2'.gz --N1 '$N1' --N2 '$N2' --bfile /home/yanyq/software/SUPERGNOVA/data/bfiles/eur_chr@_SNPmaf5 --partition /home/yanyq/software/SUPERGNOVA/data/partition/eur_chr@.bed --out /home/yanyq/share_genetics/result/SUPERGNOVA/'${trait1}'-'${trait2}' --thread 5' > /home/yanyq/share_genetics/pipeline/code/1.6.3.SUPERGNOVA_run/${trait1}-${trait2}.sh
        echo 'nohup bash /home/yanyq/share_genetics/pipeline/code/1.6.3.SUPERGNOVA_run/'${trait1}'-'${trait2}'.sh >& /home/yanyq/share_genetics/pipeline/code/log/1.6.3.SUPERGNOVA_run/'${trait1}'-'${trait2}'.log &' >> /home/yanyq/share_genetics/pipeline/code/1.6.3.SUPERGNOVA_run/all_run.sh
        let j++
    done
done

for i in {0..5}
do
    trait1=${traits2[i]}
    echo $trait1
    N1=$(zcat $trait_path/$trait1.gz | head -n 2 | cut -f 5 | tail -n 1)
    for j in {0..9}
    do
        trait2=${traits1[j]}
        N2=$(zcat $trait_path/$trait2.gz | head -n 2 | cut -f 5 | tail -n 1)
        echo 'python3 /home/yanyq/software/SUPERGNOVA/supergnova.py '$trait_path'/'$trait1'.gz '$trait_path'/'$trait2'.gz --N1 '$N1' --N2 '$N2' --bfile /home/yanyq/software/SUPERGNOVA/data/bfiles/eur_chr@_SNPmaf5 --partition /home/yanyq/software/SUPERGNOVA/data/partition/eur_chr@.bed --out /home/yanyq/share_genetics/result/SUPERGNOVA/'${trait1}'-'${trait2}' --thread 5' > /home/yanyq/share_genetics/pipeline/code/1.6.3.SUPERGNOVA_run/${trait1}-${trait2}.sh
        echo 'nohup bash /home/yanyq/share_genetics/pipeline/code/1.6.3.SUPERGNOVA_run/'${trait1}'-'${trait2}'.sh >& /home/yanyq/share_genetics/pipeline/code/log/1.6.3.SUPERGNOVA_run/'${trait1}'-'${trait2}'.log &' >> /home/yanyq/share_genetics/pipeline/code/1.6.3.SUPERGNOVA_run/all_run.sh
    done
done

for i in {0..21}
do
    trait1=${traits3[i]}
    echo $trait1
    N1=$(zcat $trait_path/$trait1.gz | head -n 2 | cut -f 5 | tail -n 1)
    for j in {0..9}
    do
        trait2=${traits1[j]}
        N2=$(zcat $trait_path/$trait2.gz | head -n 2 | cut -f 5 | tail -n 1)
        echo 'python3 /home/yanyq/software/SUPERGNOVA/supergnova.py '$trait_path'/'$trait1'.gz '$trait_path'/'$trait2'.gz --N1 '$N1' --N2 '$N2' --bfile /home/yanyq/software/SUPERGNOVA/data/bfiles/eur_chr@_SNPmaf5 --partition /home/yanyq/software/SUPERGNOVA/data/partition/eur_chr@.bed --out /home/yanyq/share_genetics/result/SUPERGNOVA/'${trait1}'-'${trait2}' --thread 5' > /home/yanyq/share_genetics/pipeline/code/1.6.3.SUPERGNOVA_run/${trait1}-${trait2}.sh
        echo 'nohup bash /home/yanyq/share_genetics/pipeline/code/1.6.3.SUPERGNOVA_run/'${trait1}'-'${trait2}'.sh >& /home/yanyq/share_genetics/pipeline/code/log/1.6.3.SUPERGNOVA_run/'${trait1}'-'${trait2}'.log &' >> /home/yanyq/share_genetics/pipeline/code/1.6.3.SUPERGNOVA_run/all_run.sh
    done
done

for i in {0..21}
do
    trait1=${traits3[i]}
    echo $trait1
    N1=$(zcat $trait_path/$trait1.gz | head -n 2 | cut -f 5 | tail -n 1)
    for j in {0..5}
    do
        trait2=${traits2[j]}
        N2=$(zcat $trait_path/$trait2.gz | head -n 2 | cut -f 5 | tail -n 1)
        echo 'python3 /home/yanyq/software/SUPERGNOVA/supergnova.py '$trait_path'/'$trait1'.gz '$trait_path'/'$trait2'.gz --N1 '$N1' --N2 '$N2' --bfile /home/yanyq/software/SUPERGNOVA/data/bfiles/eur_chr@_SNPmaf5 --partition /home/yanyq/software/SUPERGNOVA/data/partition/eur_chr@.bed --out /home/yanyq/share_genetics/result/SUPERGNOVA/'${trait1}'-'${trait2}' --thread 5' > /home/yanyq/share_genetics/pipeline/code/1.6.3.SUPERGNOVA_run/${trait1}-${trait2}.sh
        echo 'nohup bash /home/yanyq/share_genetics/pipeline/code/1.6.3.SUPERGNOVA_run/'${trait1}'-'${trait2}'.sh >& /home/yanyq/share_genetics/pipeline/code/log/1.6.3.SUPERGNOVA_run/'${trait1}'-'${trait2}'.log &' >> /home/yanyq/share_genetics/pipeline/code/1.6.3.SUPERGNOVA_run/all_run.sh
    done
done