#!/bin/bash
   while read line
   do
      arr=(${line//\t/ })
      magma --bfile ~/share_genetics/data/MAGMA/g1000_eur/g1000_eur_500kb --pval ~/share_genetics/data/MAGMA/PLACO_SNP/${arr[0]} N=${arr[1]} --gene-annot ~/share_genetics/result/MAGMA/anno/MAGMA_g1000_eur.genes.annot --out ~/share_genetics/result/MAGMA/asso/${arr[0]}
   done < ~/share_genetics/data/MAGMA/PLACO_SNP/file_list
