#!/bin/bash
sampleSize=(486945	578458	700878	355946	355640	577743	364039 664957	411075	487023 609443 264511 264205 486308 272604 573522 319640	700956	356024	355718	577821	364117	665035	411153	478444	478138	700241	486537	787455	533573	133206	355309	141605	442523	188641	355003	141299	442217	188335	363402	664320	410438	450616	196734	497652)

i=0
while read line
do
   echo ${sampleSize[i]}
   echo $i
   echo $line
   echo 'zcat /home/yanyq/share_genetics/result/PLACO/'"$line"'.gz | cut -f 1,6  > /home/yanyq/share_genetics/result/PLACO/tmp_'"$line"'' > MAGMA_$line.sh
   echo "sed -i '1d' /home/yanyq/share_genetics/result/PLACO/tmp_"$line"" >> MAGMA_$line.sh
   echo "magma --bfile ~/share_genetics/data/MAGMA/g1000_eur/g1000_eur --pval /home/yanyq/share_genetics/result/PLACO/tmp_"$line" N=${sampleSize[i]} --gene-annot ~/share_genetics/result/MAGMA/anno/MAGMA_g1000_eur_500kb.genes.annot --out ~/share_genetics/result/MAGMA/asso/$line" >> MAGMA_$line.sh
   let i++
done < /home/yanyq/share_genetics/result/PLACO_file
