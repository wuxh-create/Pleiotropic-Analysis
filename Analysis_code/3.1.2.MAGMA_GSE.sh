i=0
window="10_1.5"
while read line
do
   echo $i
   echo $line
   magma --set-annot "/home/yanyq/data/msigdb.v7.4.entrez.gmt" --gene-results /home/yanyq/share_genetics/result/MAGMA/asso/${line}_10_1.5.genes.raw --out /home/yanyq/share_genetics/result/MAGMA/gse/${line}_10_1.5
   let i++
done < /home/yanyq/share_genetics/result/PLACO_file_all