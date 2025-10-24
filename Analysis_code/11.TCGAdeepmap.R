# 找TCGA DEEPMAP前10%的基因
# head -n 1 /home/yanyq/share_genetics/data/TCGAdeepmap.csv | sed 's/,/\n/g' > /home/yanyq/share_genetics/data/TCGAdeepmap_sample
library(readr)
TCGAdeepmap_sample = read.table("/home/yanyq/share_genetics/data/TCGAdeepmap_sample")
TCGAdeepmap_sample$V1 = gsub("[.]","-",TCGAdeepmap_sample$V1)
TCGAdeepmap_sample$`Case ID` = substr(TCGAdeepmap_sample$V1,1,12)
TCGAdeepmap_sample$type = substr(TCGAdeepmap_sample$V1,14,16)

sample_info = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/TCGA/samples_tumor_normal"))
TCGAdeepmap_sample =  dplyr::left_join(TCGAdeepmap_sample, unique(sample_info[,c("Case ID", "Project ID")]), by = "Case ID")
TCGAdeepmap_sample[is.na(TCGAdeepmap_sample$`Project ID`)&(TCGAdeepmap_sample$type%in%c("01","03")),]
{
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-19-1787"] = "TCGA-GBM"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-CV-A6K0"] = "TCGA-HNSC"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2967"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-VD-A8KA"] = "TCGA-UVM"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-EW-A1PC"] = "TCGA-BRCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-XY-A8S3"] = "TCGA-TGCT"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-DW-7963"] = "TCGA-KIRP"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-BH-A0C7"] = "TCGA-BRCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-CI-6619"] = "TCGA-READ"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2896"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-55-7913"] = "TCGA-LUAD"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-EJ-7218"] = "TCGA-PRAD"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2841"] = "TCGA-GBM"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-23-1029"] = "TCGA-OV"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-23-1026"] = "TCGA-OV"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-14-0790"] = "TCGA-GBM"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2978"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2981"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2985"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-K4-A3WU"] = "TCGA-BLCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-24-0970"] = "TCGA-OV"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2954"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-D8-A1JG"] = "TCGA-BRCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-FG-7638"] = "TCGA-LGG"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2949"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-26-5136"] = "TCGA-GBM"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AO-A03M"] = "TCGA-BRCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-YL-A8SQ"] = "TCGA-PRAD"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2988"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-HC-7817"] = "TCGA-PRAD"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-BH-A0C1"] = "TCGA-BRCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-13-0884"] = "TCGA-OV"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-TS-A7OU"] = "TCGA-MESO"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2904"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-R6-A8W5"] = "TCGA-ESCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-GR-A4D9"] = "TCGA-DLBC"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2838"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2811"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-FG-5962"] = "TCGA-LGG"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-UT-A88C"] = "TCGA-MESO"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2833"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2816"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2868"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-UT-A88G"] = "TCGA-MESO"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-HT-7884"] = "TCGA-LGG"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-09-2056"] = "TCGA-OV"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AC-A3QQ"] = "TCGA-BRCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-HT-7477"] = "TCGA-LGG"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2972"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-CG-4474"] = "TCGA-STAD"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-FG-A4MU"] = "TCGA-LGG"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-13-0908"] = "TCGA-OV"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-R6-A6DQ"] = "TCGA-ESCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-09-1668"] = "TCGA-OV"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-R6-A6Y2"] = "TCGA-ESCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-YL-A8SJ"] = "TCGA-PRAD"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-W2-A7H5"] = "TCGA-PCPG"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-CS-4938"] = "TCGA-LGG"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2920"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-23-1114"] = "TCGA-OV"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-09-1659"] = "TCGA-OV"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-77-A5GB"] = "TCGA-LUSC"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-EJ-7325"] = "TCGA-PRAD"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-61-1917"] = "TCGA-OV"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-ZR-A9CJ"] = "TCGA-ESCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-77-A5G7"] = "TCGA-LUSC"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AO-A03U"] = "TCGA-BRCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-R6-A6XQ"] = "TCGA-ESCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-R6-A6Y0"] = "TCGA-ESCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-09-1659"] = "TCGA-OV"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-77-A5GB"] = "TCGA-LUSC"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-EJ-7325"] = "TCGA-PRAD"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-61-1917"] = "TCGA-OV"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-ZR-A9CJ"] = "TCGA-ESCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-77-A5G7"] = "TCGA-LUSC"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AO-A03U"] = "TCGA-BRCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-R6-A6XQ"] = "TCGA-ESCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-R6-A6Y0"] = "TCGA-ESCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-09-1665"] = "TCGA-OV"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-CV-A6JO"] = "TCGA-HNSC"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-09-1661"] = "TCGA-OV"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AO-A03N"] = "TCGA-BRCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-55-7284"] = "TCGA-LUAD"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-FY-A3I5"] = "TCGA-THCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2879"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-DK-A6AW"] = "TCGA-BLCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2999"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-C5-A1BF"] = "TCGA-CESC"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-CG-4449"] = "TCGA-STAD"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-YL-A8SR"] = "TCGA-PRAD"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-K4-A4AB"] = "TCGA-BLCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-YL-A8SH"] = "TCGA-PRAD"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-R5-A7ZE"] = "TCGA-STAD"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2837"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-C5-A3HD"] = "TCGA-CESC"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-HT-7873"] = "TCGA-LGG"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-UT-A88D"] = "TCGA-MESO"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-CI-6623"] = "TCGA-READ"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2803"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2990"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-C5-A1BQ"] = "TCGA-CESC"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2854"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-W2-A7HA"] = "TCGA-PCPG"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-R6-A8W8"] = "TCGA-ESCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-09-2044"] = "TCGA-OV"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-3005"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-09-1667"] = "TCGA-OV"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-61-1736"] = "TCGA-OV"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2824"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-68-7757"] = "TCGA-LUSC"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-UT-A88E"] = "TCGA-MESO"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-EJ-7312"] = "TCGA-PRAD"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-77-A5G8"] = "TCGA-LUSC"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-C5-A1BK"] = "TCGA-CESC"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-CK-4948"] = "TCGA-COAD"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-12-1597"] = "TCGA-GBM"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-13-0900"] = "TCGA-OV"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-28-1747"] = "TCGA-GBM"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2977"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2969"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2848"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-06-0649"] = "TCGA-GBM"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AZ-4682"] = "TCGA-COAD"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-B5-A1MS"] = "TCGA-UCEC"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-ET-A3BQ"] = "TCGA-THCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-FG-8189"] = "TCGA-LGG"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-BC-4072"] = "TCGA-LIHC"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-B8-4146"] = "TCGA-KIRC"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-VD-A8K7"] = "TCGA-UVM"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-YL-A8SL"] = "TCGA-PRAD"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-C5-A1BE"] = "TCGA-CESC"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-FG-7641"] = "TCGA-LGG"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2903"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-BR-4362"] = "TCGA-STAD"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-23-1021"] = "TCGA-OV"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2860"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-76-4928"] = "TCGA-GBM"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-EJ-7318"] = "TCGA-PRAD"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-QK-A8Z9"] = "TCGA-HNSC"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-CJ-4642"] = "TCGA-KIRC"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2952"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-VD-AA8S"] = "TCGA-UVM"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-C5-A1BI"] = "TCGA-CESC"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-FG-5965"] = "TCGA-LGG"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-13-0893"] = "TCGA-OV"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-YL-A8SP"] = "TCGA-PRAD"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-C5-A1BN"] = "TCGA-CESC"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-13-0901"] = "TCGA-OV"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2855"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2979"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-B6-A1KC"] = "TCGA-BRCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-EX-A1H6"] = "TCGA-CESC"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-ET-A2N3"] = "TCGA-THCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-R6-A6L6"] = "TCGA-ESCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-76-4926"] = "TCGA-GBM"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-3006"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-14-0781"] = "TCGA-GBM"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-BH-A0E9"] = "TCGA-BRCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2887"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-CI-6624"] = "TCGA-READ"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-DO-A2HM"] = "TCGA-THCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-BA-4077"] = "TCGA-HNSC"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-R6-A6DN"] = "TCGA-ESCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2832"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-67-4679"] = "TCGA-LUAD"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-V5-A7RC"] = "TCGA-ESCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2993"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-VQ-A8E7"] = "TCGA-STAD"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AQ-A04H"] = "TCGA-BRCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-GV-A3QK"] = "TCGA-BLCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-16-1045"] = "TCGA-GBM"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-13-0905"] = "TCGA-OV"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-E7-A97Q"] = "TCGA-BLCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-BA-6868"] = "TCGA-HNSC"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-HT-8015"] = "TCGA-LGG"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AQ-A04L"] = "TCGA-BRCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-EW-A3E8"] = "TCGA-BRCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-B8-4153"] = "TCGA-KIRC"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-CG-4472"] = "TCGA-STAD"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-DE-A0Y3"] = "TCGA-THCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2964"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-R6-A6XG"] = "TCGA-ESCA"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-DX-A3LY"] = "TCGA-SARC"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-AB-2845"] = "TCGA-LAML"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-YL-A8SO"] = "TCGA-PRAD"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-YL-A8SK"] = "TCGA-PRAD"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-09-2053"] = "TCGA-OV"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-HC-8264"] = "TCGA-PRAD"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-BC-4073"] = "TCGA-LIHC"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-CK-4947"] = "TCGA-COAD"
  TCGAdeepmap_sample$`Project ID`[TCGAdeepmap_sample$`Case ID`=="TCGA-67-4679"] = "TCGA-LUAD"  
}
TCGAdeepmap_sample[is.na(TCGAdeepmap_sample$`Project ID`)&(TCGAdeepmap_sample$type%in%c("01","03")),]
write_tsv(TCGAdeepmap_sample, "~/share_genetics/result/TCGAdeepmap/TCGAdeepmap_sample_project")

TCGAdeepmap_sample = as.data.frame(read_tsv("~/share_genetics/result/TCGAdeepmap/TCGAdeepmap_sample_project"))
TCGAdeepmap_sample$`Project ID`[is.na(TCGAdeepmap_sample$`Project ID`)] = "filtered"
TCGAdeepmap = as.data.frame(bigreadr::fread2("/home/yanyq/share_genetics/data/TCGAdeepmap.csv"))
colnames(TCGAdeepmap) = gsub("[.]", "-", colnames(TCGAdeepmap))
project = unique(TCGAdeepmap_sample$`Project ID`)
project = project[project!="filtered"]

all_means_after_3SD = list()
all_means_before_3SD = list()
for(i in project){
  tmp = TCGAdeepmap[,TCGAdeepmap_sample$`Project ID`==i] # 提取对应癌症的评分
  rownames(tmp) = TCGAdeepmap$Gene
  means_before_3SD = rowMeans(tmp) # 计算平均分
  
  SD = apply(tmp, 1, sd)
  means_after_3SD = apply(tmp, 1, function(x, mean_val, std_val) {
    x[abs(x - mean_val) > 3 * std_val] = NA  # 将超过三个标准差的样本设置为NA
    mean(as.numeric(x), na.rm=T) # 计算平均值
  }, mean_val = means_before_3SD, std_val = SD)
  
  means_after_3SD = as.data.frame(means_after_3SD)
  colnames(means_after_3SD) = i
  all_means_after_3SD[[i]] = means_after_3SD
  means_before_3SD = as.data.frame(means_before_3SD)
  colnames(means_before_3SD) = i
  all_means_before_3SD[[i]] = means_before_3SD
}

all_means_after_3SD = do.call(cbind, all_means_after_3SD)
all_means_after_3SD$Gene = rownames(all_means_after_3SD)
all_means_before_3SD = do.call(cbind, all_means_before_3SD)
all_means_before_3SD$Gene = rownames(all_means_before_3SD)
write_tsv(all_means_after_3SD,"~/share_genetics/result/TCGAdeepmap/all_means_after_3SD")
write_tsv(all_means_before_3SD,"~/share_genetics/result/TCGAdeepmap/all_means_before_3SD")

all_means_after_3SD_top200 = list()
all_means_before_3SD_top200 = list()
for(i in 1:ncol(all_means_after_3SD)){
  tmp_after = as.data.frame(rownames(all_means_after_3SD)[order(all_means_after_3SD[,i])][1:200])
  tmp_before = as.data.frame(rownames(all_means_before_3SD)[order(all_means_before_3SD[,i])][1:200])
  colnames(tmp_after) = colnames(all_means_after_3SD)[i]
  colnames(tmp_before) = colnames(all_means_before_3SD)[i]
  all_means_after_3SD_top200[[i]] = tmp_after
  all_means_before_3SD_top200[[i]] = tmp_before
  print(length(intersect(tmp_after[,1],tmp_before[,1])))
}
all_means_after_3SD_top200 = do.call(cbind, all_means_after_3SD_top200)
all_means_before_3SD_top200 = do.call(cbind, all_means_before_3SD_top200)
write_tsv(all_means_after_3SD_top200, "~/share_genetics/result/TCGAdeepmap/all_means_after_3SD_top200")
write_tsv(all_means_before_3SD_top200, "~/share_genetics/result/TCGAdeepmap/all_means_before_3SD_top200")
