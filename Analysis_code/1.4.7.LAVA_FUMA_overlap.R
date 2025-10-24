setwd("/home/yanyq/share_genetics/result/FUMA/")
library(readr)
library(GenomicRanges)
library(dplyr)

LAVA = as.data.frame(read_tsv("/home/yanyq/share_genetics/result/LAVA/all_uni_filtered_bivar"))
LAVA$FDR = p.adjust(LAVA$p, method = "BH")
# LAVA = LAVA[LAVA$p<0.05,]
LAVA = LAVA[LAVA$FDR<0.05,]
LAVA$pair = paste0(LAVA$phen1, "-", LAVA$phen2)
LAVA$FUMA_loci_num = NA
LAVA$FUMA_loci = NA

all_FUMA = list()
for(traits in unique(LAVA$pair)){
  if(file.exists(traits)){
    FUMA = as.data.frame(read.table(paste0(traits,"/GenomicRiskLoci.txt"), header = T))
    cur_LAVA = LAVA[LAVA$pair==traits,]
    
    FUMA_GR = as(paste0(FUMA$chr, ":", FUMA$start, "-", FUMA$end), "GRanges")
    cur_LAVA_GR = as(paste0(cur_LAVA$chr, ":", cur_LAVA$start, "-", cur_LAVA$stop), "GRanges")
    overlap = findOverlaps(cur_LAVA_GR, FUMA_GR)
    if(length(overlap)>0){
      overlap = data.frame(from = overlap@from, to = overlap@to,
                           LAVA_loci = paste0(cur_LAVA$chr[overlap@from], ":", cur_LAVA$start[overlap@from], "-", cur_LAVA$stop[overlap@from]),
                           FUMA_loci = paste0(FUMA$chr[overlap@to], ":", FUMA$start[overlap@to], "-", FUMA$end[overlap@to]))
      overlap_from = overlap %>% group_by(from) %>% summarise(to = paste(to, collapse = ","), FUMA_loci = paste(FUMA_loci, collapse = ","))
      overlap_to = overlap %>% group_by(to) %>% summarise(from = paste(from, collapse = ","), LAVA_loci = paste(LAVA_loci, collapse = ","))
      
      cur_LAVA$FUMA_loci_num[overlap_from$from] = overlap_from$to
      cur_LAVA$FUMA_loci[overlap_from$from] = overlap_from$FUMA_loci
      LAVA[LAVA$pair==traits,] = cur_LAVA
      
      FUMA$LAVA_loci_num = NA
      FUMA$LAVA_loci = NA
      FUMA$LAVA_loci_num[overlap_to$to] = overlap_to$from
      FUMA$LAVA_loci[overlap_to$to] = overlap_to$LAVA_loci
      all_FUMA[[traits]] = FUMA
    }
  }
}
all_FUMA = do.call(rbind, all_FUMA)
