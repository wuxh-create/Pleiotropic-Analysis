#!/bin/bash
python3  ./code/rsidmap_v2.py --build hg19 --chr_col chr.iCOGs --pos_col Position.iCOGs --ref_col Baseline.Meta --alt_col Effect.Meta --file_gwas /home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/icogs_onco_gwas_meta_overall_breast_cancer_summary_level_statistics.txt  --file_out /home/yanyq/share_genetics/data/GWAS/rsidmap/BRCA
python3  ./code/rsidmap_v2.py --build hg19 --chr_col chromosome --pos_col base_pair_location --ref_col other_allele --alt_col effect_allele --file_gwas /home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/lung --file_out /home/yanyq/share_genetics/data/GWAS/rsidmap/lung
python3  ./code/rsidmap_v2.py --build hg19 --chr_col chromosome --pos_col base_pair_location --ref_col other_allele --alt_col effect_allele --file_gwas /home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/PRAD --file_out /home/yanyq/share_genetics/data/GWAS/rsidmap/PRAD
python3  ./code/rsidmap_v2.py --build hg19 --chr_col chromosome --pos_col base_pair_location --ref_col other_allele --alt_col effect_allele --file_gwas /home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/UCEC.tsv.gz --file_out /home/yanyq/share_genetics/data/GWAS/rsidmap/UCEC
python3  ./code/rsidmap_v2.py --build hg19 --chr_col chromosome --pos_col base_pair_location --ref_col other_allele --alt_col effect_allele --file_gwas /home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/CRC.tsv.gz --file_out /home/yanyq/share_genetics/data/GWAS/rsidmap/CRC
python3  ./code/rsidmap_v2.py --build hg19 --chr_col chromosome --pos_col base_pair_location --ref_col other_allele --alt_col effect_allele --file_gwas /home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/ESCA.gz --file_out /home/yanyq/share_genetics/data/GWAS/rsidmap/ESCA
python3  ./code/rsidmap_v2.py --build hg19 --chr_col chromosome --pos_col base_pair_location --ref_col other_allele --alt_col effect_allele --file_gwas /home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/CESC.tsv.gz --file_out /home/yanyq/share_genetics/data/GWAS/rsidmap/CESC
python3  ./code/rsidmap_v2.py --build hg19 --chr_col chromosome --pos_col base_pair_location --ref_col other_allele --alt_col effect_allele --file_gwas /home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/LL.gz --file_out /home/yanyq/share_genetics/data/GWAS/rsidmap/LL
# python3  ./code/rsidmap_v2.py --build hg19 --chr_col chromosome --pos_col base_pair_location --ref_col other_allele --alt_col effect_allele --file_gwas /home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/BCC.gz --file_out /home/yanyq/share_genetics/data/GWAS/rsidmap/BCC
# python3  ./code/rsidmap_v2.py --build hg19 --chr_col chromosome --pos_col base_pair_location --ref_col other_allele --alt_col effect_allele --file_gwas /home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/SCC.gz --file_out /home/yanyq/share_genetics/data/GWAS/rsidmap/SCC
python3  ./code/rsidmap_v2.py --build hg19 --chr_col chromosome --pos_col base_pair_location --ref_col other_allele --alt_col effect_allele --file_gwas /home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/HL.gz --file_out /home/yanyq/share_genetics/data/GWAS/rsidmap/HL

OV_files = list.files("/home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/")
OV_files = OV_files[grep("Summary_chr",OV_files)]
OV_files = OV_files[OV_files!="Summary_chr23.txt"]
f = fread(paste0("/home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/",OV_files[1]))
for(i in 2:length(OV_files)){
  tmp = fread(paste0("/home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/", OV_files[i]))
  f = rbind(f,tmp)
}
f = f[,c(3,4,5,6,7,9,10,12)]
f = f[!((f$Chromosome==6)&(f$Position>25000000&f$Position<35000000)),] # 去除主要组织相容性复合体区域
f = f[f$EAF<0.99&f$EAF>0.01,]
f = f[f$Effect%in%c("A","C","G","T")&f$Baseline%in%c("A","C","G","T"),]
write_tsv(f,"/home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/OV.gz")
python3  ./code/rsidmap_v2.py --build hg19 --chr_col Chromosome --pos_col Position --ref_col Baseline --alt_col Effect --file_gwas /home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/OV.gz  --file_out /home/yanyq/share_genetics/data/GWAS/rsidmap/OV

# finngen
{
  setwd("~/share_genetics/data/GWAS/GWAS_summary_raw")
  library(vroom)
  library(readr)
  traits = c("AML","BILIARY_GALLBLADDER","BONE_CARTILAGE","CML","CORPUS_UTERI",
             "EYE_ADNEXA","GASTRINT_STROM","GBM_ASTROCYTOMA","HEPATOCELLU_CARC",
             "MANTLE_CELL_LYMPHOMA","MARGINAL_ZONE_LYMPHOMA","MENINGIOMA","MESOTHELIOMA",
             "MULT_MYELOMA","MYELODYSP_SYNDR","SMALL_INTESTINE","TESTIS","VULVA")
  f_name = paste0("finngen_R10_C3_", traits[1], "_EXALLC.gz")
  f = as.data.frame(vroom(f_name))
  f$ID = paste0(f$`#chrom`,":", f$pos,":", f$ref, ":",f$alt)
  f = f[,c("#chrom", "pos", "ref", "alt", "rsids", "ID")]
  for(i in traits[-1]){
    print(i)
    f_name = paste0("finngen_R10_C3_", i, "_EXALLC.gz")
    tmp = as.data.frame(vroom(f_name))
    tmp$ID = paste0(tmp$`#chrom`,":", tmp$pos,":", tmp$ref, ":",tmp$alt)
    tmp = tmp[!tmp$ID%in%f$ID,]
    tmp = tmp[,c("#chrom", "pos", "ref", "alt", "rsids", "ID")]
    f = rbind(f,tmp)
  }
  write_tsv(f,"~/share_genetics/data/GWAS/GWAS_summary_raw/finngen_SNP_loc_hg38")
  {#BCC、SCC
    f = as.data.frame(vroom("/home/yanyq/share_genetics/data/GWAS/rsidmap/finngen_SNP_loc_hg38"))
    tmp = as.data.frame(vroom("/home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/finngen_R10_C3_SQUOMOUS_CELL_CARCINOMA_SKIN_EXALLC.gz"))
    tmp$ID = paste0(tmp$`#chrom`,":", tmp$pos,":", tmp$ref, ":",tmp$alt)
    tmp = tmp[tmp$ref%in%c("A","C","G","T")&tmp$alt%in%c("A","C","G","T"),]
    t1 = tmp[!tmp$ID%in%f$ID,c("#chrom", "pos", "ref", "alt", "rsids", "ID")] # 102个
    tmp = as.data.frame(vroom("/home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/finngen_R10_C3_BASAL_CELL_CARCINOMA_EXALLC.gz"))
    tmp$ID = paste0(tmp$`#chrom`,":", tmp$pos,":", tmp$ref, ":",tmp$alt)
    tmp = tmp[tmp$ref%in%c("A","C","G","T")&tmp$alt%in%c("A","C","G","T"),]
    t2 = tmp[!tmp$ID%in%f$ID,c("#chrom", "pos", "ref", "alt", "rsids", "ID")] # 542
    write_tsv(rbind(t1,t2),"/home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/finngen_SNP_loc_hg38_BCC_SCC_rest")
  }
}
python3  ./code/rsidmap_v2.py --build hg38 --chr_col "#chrom" --pos_col pos --ref_col  ref --alt_col alt --file_gwas /home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/finngen_SNP_loc_hg38  --file_out /home/yanyq/share_genetics/data/GWAS/rsidmap/finngen_SNP_loc_hg38
python3  ./code/rsidmap_v2.py --build hg38 --chr_col "#chrom" --pos_col pos --ref_col  ref --alt_col alt --file_gwas /home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/finngen_SNP_loc_hg38_BCC_SCC_rest  --file_out /home/yanyq/share_genetics/data/GWAS/rsidmap/finngen_SNP_loc_hg38_BCC_SCC_rest
sed '1d' /home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/finngen_SNP_loc_hg38_BCC_SCC_rest >> /home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/finngen_SNP_loc_hg38
sed '1d' /home/yanyq/share_genetics/data/GWAS/rsidmap/finngen_SNP_loc_hg38_BCC_SCC_rest >> /home/yanyq/share_genetics/data/GWAS/rsidmap/finngen_SNP_loc_hg38
{
  library(vroom)
  library(readr)
  library(dplyr)
  traits = data.frame(full_name = c("AML","BONE_CARTILAGE","CML","CORPUS_UTERI",
                                    "EYE_ADNEXA","GASTRINT_STROM","GBM_ASTROCYTOMA","HEPATOCELLU_CARC",
                                    "MANTLE_CELL_LYMPHOMA","MARGINAL_ZONE_LYMPHOMA","MENINGIOMA","MESOTHELIOMA",
                                    "MULT_MYELOMA","MYELODYSP_SYNDR","SMALL_INTESTINE","TESTIS","VULVA",
                                    "BASAL_CELL_CARCINOMA","SQUOMOUS_CELL_CARCINOMA_SKIN"),
                      abbrev = c("AML","BAC","CML","CORP","EYAD","GSS","BGA","LIHC",
                                 "MCL","MZBL","BM","MESO","MM","MS","SI","TEST","VULVA","BCC","SCC"))
  SNPs = as.data.frame(vroom("/home/yanyq/share_genetics/data/GWAS/rsidmap/finngen_SNP_loc_hg38"))
  SNPs = SNPs[!duplicated(SNPs$ID),]
  for(i in 1:nrow(traits)){
    f_name = paste0("~/share_genetics/data/GWAS/GWAS_summary_raw/finngen_R10_C3_", traits$full_name[i], "_EXALLC.gz")
    f = as.data.frame(vroom(f_name))
    tmp_row = nrow(f)
    f$ID = paste0(f$`#chrom`,":", f$pos,":", f$ref, ":",f$alt)
    f = left_join(f, SNPs[,c(6,7)], by = "ID")
    if(nrow(f)==tmp_row){
      write_tsv(f[,-which(colnames(f)=="ID")],paste0("~/share_genetics/data/GWAS/rsidmap/", traits$abbrev[i], ".gz"))
    }
  }
}

python3  ./code/rsidmap_v2.py --build hg38 --chr_col "#chrom" --pos_col pos --ref_col  ref --alt_col alt --file_gwas /home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/finngen_R10_C3_BLADDER_EXALLC.gz  --file_out /home/yanyq/share_genetics/data/GWAS/rsidmap/BLCA
python3  ./code/rsidmap_v2.py --build hg38 --chr_col "#chrom" --pos_col pos --ref_col  ref --alt_col alt --file_gwas /home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/finngen_R10_C3_HEAD_AND_NECK_EXALLC.gz --file_out /home/yanyq/share_genetics/data/GWAS/rsidmap/HNSC
python3  ./code/rsidmap_v2.py --build hg38 --chr_col "#chrom" --pos_col pos --ref_col  ref --alt_col alt --file_gwas /home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/finngen_R10_C3_KIDNEY_NOTRENALPELVIS_EXALLC.gz --file_out /home/yanyq/share_genetics/data/GWAS/rsidmap/kidney
python3  ./code/rsidmap_v2.py --build hg38 --chr_col "#chrom" --pos_col pos --ref_col  ref --alt_col alt --file_gwas /home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/finngen_R10_C3_MELANOMA_SKIN_EXALLC.gz --file_out /home/yanyq/share_genetics/data/GWAS/rsidmap/SKCM
python3  ./code/rsidmap_v2.py --build hg38 --chr_col "#chrom" --pos_col pos --ref_col  ref --alt_col alt --file_gwas /home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/finngen_R10_C3_PANCREAS_EXALLC.gz --file_out /home/yanyq/share_genetics/data/GWAS/rsidmap/PAAD
python3  ./code/rsidmap_v2.py --build hg38 --chr_col "#chrom" --pos_col pos --ref_col  ref --alt_col alt --file_gwas /home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/finngen_R10_C3_DLBCL_EXALLC.gz --file_out /home/yanyq/share_genetics/data/GWAS/rsidmap/DLBC
python3  ./code/rsidmap_v2.py --build hg38 --chr_col "#chrom" --pos_col pos --ref_col  ref --alt_col alt --file_gwas /home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/finngen_R10_C3_BILIARY_GALLBLADDER_EXALLC.gz --file_out /home/yanyq/share_genetics/data/GWAS/rsidmap/BGC
python3  ./code/rsidmap_v2.py --build hg38 --chr_col "#chrom" --pos_col pos --ref_col  ref --alt_col alt --file_gwas /home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/finngen_R10_C3_STOMACH_EXALLC.gz --file_out /home/yanyq/share_genetics/data/GWAS/rsidmap/STAD
python3  ./code/rsidmap_v2.py --build hg38 --chr_col "#chrom" --pos_col pos --ref_col  ref --alt_col alt --file_gwas /home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/finngen_R10_C3_THYROID_GLAND_EXALLC.gz --file_out /home/yanyq/share_genetics/data/GWAS/rsidmap/THCA
python3  ./code/rsidmap_v2.py --build hg38 --chr_col "#chrom" --pos_col pos --ref_col  ref --alt_col alt --file_gwas /home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/finngen_R10_C3_CORPUS_UTERI_EXALLC.gz --file_out /home/yanyq/share_genetics/data/GWAS/rsidmap/CORC
# python3  ./code/rsidmap_v2.py --build hg38 --chr_col "#chrom" --pos_col pos --ref_col  ref --alt_col alt --file_gwas /home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/finngen_R10_C3_HEPATOCELLU_CARC_EXALLC.gz --file_out /home/yanyq/share_genetics/data/GWAS/rsidmap/LIHC
# python3  ./code/rsidmap_v2.py --build hg38 --chr_col "#chrom" --pos_col pos --ref_col  ref --alt_col alt --file_gwas /home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/finngen_R10_C3_MULT_MYELOMA_EXALLC.gz --file_out /home/yanyq/share_genetics/data/GWAS/rsidmap/MM
# python3  ./code/rsidmap_v2.py --build hg38 --chr_col "#chrom" --pos_col pos --ref_col  ref --alt_col alt --file_gwas /home/yanyq/share_genetics/data/GWAS/GWAS_summary_raw/finngen_R10_C3_TESTIS_EXALLC.gz --file_out /home/yanyq/share_genetics/data/GWAS/rsidmap/TEST


cd /home/yanyq/share_genetics/data/GWAS/rsidmap/
gzip BRCA lung PRAD UCEC OV BLCA HNSC kidney SKCM PAAD CRC DLBC BGC STAD THCA ESCA CESC LL CORC HL
