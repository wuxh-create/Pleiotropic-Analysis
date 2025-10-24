go = fread("/home/yanyq/share_genetics/result/gse/go/result/all_res")
magma = fread("/home/yanyq/share_genetics/result/MAGMA/asso_merge_fdr_0.05/all")

magma_go = list()
for(i in 1:nrow(go)){
  traits = go$traits[i]
  genes = as.numeric(unlist(strsplit(go$core_enrichment[i],"/")))
  tmp_magma = magma[magma$trait==traits,]
  if(nrow(tmp_magma[tmp_magma$GENE%in%genes,])>0){
    magma_go[[i]] = tmp_magma[tmp_magma$GENE%in%genes,]
    magma_go[[i]]$GO_ID = go$ID[i]
    magma_go[[i]]$GO_pathway = go$Description[i]
  }
}
magma_go = do.call(rbind,magma_go)
magma_go$flag = paste0(magma_go$GENE,":",magma_go$trait)
for(i in unique(magma_go$flag)){
  tmp  = magma_go[magma_go$flag==i,]
  if((nrow(unique(tmp[,-c(20,21)]))==1)&nrow(tmp)==2){
    magma_go$GO_ID[magma_go$flag==i] = paste0(tmp$GO_ID[1],"/",tmp$GO_ID[2])
    magma_go$GO_pathway[magma_go$flag==i] = paste0(tmp$GO_pathway[1],"/",tmp$GO_pathway[2])
  }
  if((nrow(unique(tmp[,-c(20,21)]))==1)&nrow(tmp)>2){
    tmp_ID = paste0(tmp$GO_ID[1],"/",tmp$GO_ID[2])
    tmp_pathway = paste0(tmp$GO_pathway[1],"/",tmp$GO_pathway[2])
    for(j in 3:nrow(tmp)){
      tmp_ID = paste0(tmp_ID,"/",tmp$GO_ID[j])
      tmp_pathway = paste0(tmp_pathway,"/",tmp$GO_pathway[j])
    }
    magma_go$GO_ID[magma_go$flag==i] = tmp_ID
    magma_go$GO_pathway[magma_go$flag==i] = tmp_pathway
  }
  
}

write_tsv(unique(magma_go),"/home/yanyq/share_genetics/result/magma_go_overlap")
