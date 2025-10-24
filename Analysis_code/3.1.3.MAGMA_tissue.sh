# library(org.Hs.eg.db)
# # FUMA 下载的表达量，用的是ENSG id
# ENSG = read_tsv("/home/yanyq/share_genetics/data/MAGMA/gtex_v8_ts_avg_log2TPM.txt",col_names = T)
# trans= select(org.Hs.eg.db,keys=ENSG$GENE,columns = c("ENTREZID"), keytype="ENSEMBL")
# trans=trans[!is.na(trans$ENTREZID),]
# # MAGMA下载的基因位置
# # 用的是entrez id
# MAGMA_gene = read_tsv("/home/yanyq/share_genetics/data/MAGMA/NCBI37.3/NCBI37.3.gene.loc",col_names = F)
# trans = trans[trans$ENTREZID%in%as.character(MAGMA_gene$X1),] # 存在多对多，保留magmaGene中的id
# colnames(trans)[1] = "GENE"
# ENSG = merge(ENSG,trans,by = "GENE")
# ENSG$GENE = ENSG$ENTREZID
# which(duplicated(ENSG$GENE))
# length(which(duplicated(ENSG$GENE)))
# ENSG = ENSG[!duplicated(ENSG$GENE),]
# write_tsv(ENSG[,-57],"/home/yanyq/share_genetics/data/MAGMA/gtex_v8_ts_avg_log2TPM.txt_withENTREZ")

# ENSG = read_tsv("/home/yanyq/share_genetics/data/MAGMA/gtex_v8_ts_general_avg_log2TPM.txt",col_names = T)
# trans= select(org.Hs.eg.db,keys=ENSG$GENE,columns = c("ENTREZID"), keytype="ENSEMBL")
# trans=trans[!is.na(trans$ENTREZID),]
# # MAGMA下载的基因位置
# # 用的是entrez id
# MAGMA_gene = read_tsv("/home/yanyq/share_genetics/data/MAGMA/NCBI37.3/NCBI37.3.gene.loc",col_names = F)
# trans = trans[trans$ENTREZID%in%as.character(MAGMA_gene$X1),] # 存在多对多，保留magmaGene中的id
# colnames(trans)[1] = "GENE"
# ENSG = merge(ENSG,trans,by = "GENE")
# ENSG$GENE = ENSG$ENTREZID
# which(duplicated(ENSG$GENE))
# length(which(duplicated(ENSG$GENE)))
# ENSG = ENSG[!duplicated(ENSG$GENE),]
# write_tsv(ENSG[,-33],"/home/yanyq/share_genetics/data/MAGMA/gtex_v8_ts_general_avg_log2TPM.txt_withENTREZ")

i=0
window="10_1.5"
while read line
do
   echo $i
   echo $line
   magma --gene-results /home/yanyq/share_genetics/result/MAGMA/asso/${line}_10_1.5.genes.raw --gene-covar /home/yanyq/share_genetics/data/MAGMA/gtex_v8_ts_avg_log2TPM.txt_withENTREZ --model direction-covar=greater condition-hide=Average --out /home/yanyq/share_genetics/result/MAGMA/gene_property/tissue_54/$line
   magma --gene-results /home/yanyq/share_genetics/result/MAGMA/asso/${line}_10_1.5.genes.raw --gene-covar /home/yanyq/share_genetics/data/MAGMA/gtex_v8_ts_general_avg_log2TPM.txt_withENTREZ --model direction-covar=greater condition-hide=Average --out /home/yanyq/share_genetics/result/MAGMA/gene_property/tissue_30/$line
   let i++
done < /home/yanyq/share_genetics/result/PLACO_file_all