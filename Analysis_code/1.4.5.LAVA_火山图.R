# 绘制LAVA结果的火山图: https://doi.org/10.1101/2024.05.20.24307614
library(ggplot2)
library(readr)
library(GenomicRanges)
setwd("/home/yanyq/share_genetics/result/LAVA/")
# # 给LAVA的locus注释成1p36.33格式
# loc = as.data.frame(read.table("/home/yanyq/software/LAVA/support_data/blocks_s2500_m25_f1_w200.GRCh37_hg19.locfile", header = T))
# loc_gr = as(paste0(loc$CHR,":",loc$START,"-",loc$STOP),"GRanges")
# chrname = as.data.frame(read_tsv("/home/yanyq/data/cytoBand_hg19.txt.gz", col_names = F))
# chrname$X1 = gsub("chr","",chrname$X1)
# chrname_gr = as(paste0(chrname$X1,":",chrname$X2,"-",chrname$X3),"GRanges")
# overlap = findOverlaps(loc_gr, chrname_gr, type = "within")
# length(overlap@from)
# length(unique(overlap@from))
# loc$chrname = NA
# loc$chrname[overlap@from] = chrname$X4[overlap@to]
# # 一对多的情况，选择overlap长度更大的注释
# overlap = findOverlaps(loc_gr, chrname_gr)
# dup = overlap@from[duplicated(overlap@from)]
# length(dup)
# length(unique(dup))
traits = c("AML","BAC","BCC","BGA","BGC","BLCA","BM","BRCA","CESC","CML","CORP",
           "CRC","DLBC","ESCA","EYAD","GSS","HL","HNSC","kidney","LIHC","LL",
           "lung","MCL","MESO","MM","MS","MZBL","OV","PAAD","PRAD","SCC","SI",
           "SKCM","STAD","TEST","THCA","UCEC","VULVA")

for(trait1 in traits){
  for(trait2 in traits){
    file_name = paste0(trait1,"-",trait2,".bivar.lava")
    if(file.exists(file_name)){
      f = as.data.frame(read.table(file_name, header = T))
      f = f[!is.na(f$rho),]
      f$FDR = p.adjust(f$p, method = "BH")
      # 判断是否显著，以及相关性的正负
      f$color = ifelse(f$FDR<0.05,ifelse(f$rho>0,"#ff4757", "#546de5"),"#d2dae2")
      
      ###绘图——基础火山图###
      pdf(paste0("volcano/", trait1, "-", trait2, ".pdf"), height = 5, width = 5)
      g = ggplot(f, aes(x =rho, y=-log10(FDR), color=color)) + #x、y轴取值限制，颜色根据"Sig"
        geom_point(alpha=0.65, size=2) +  #点的透明度、大小
        scale_color_identity() + xlim(c(-1, 1)) +  #调整点的颜色和x轴的取值范围
        geom_hline(yintercept = -log10(0.05), lty=4,col="black",lwd=0.5) + 
        geom_vline(xintercept = 0, lty=4,col="black",lwd=0.5) + # lty线型，lwd粗细
        labs(x="rho", #~表示空格
             y=expression(-log[10]~FDR))+
        ggtitle(paste0(trait1," & ", trait2)) + #标题
        theme_bw() +
        theme(plot.title = element_text(hjust = 0.5, size = 12),
              legend.position="none",
              panel.grid.major = element_blank(), # 去除主网格线
              panel.grid.minor = element_blank(),  # 去除次网格线
              panel.background = element_blank(),
              axis.text = element_text(size = 10, colour = "black"),
              axis.title = element_text(size = 12))
        
      print(g)
      dev.off()
    }
  }
}
