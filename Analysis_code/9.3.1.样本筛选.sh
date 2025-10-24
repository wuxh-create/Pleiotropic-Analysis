# 提取仅患乳腺癌和卵巢癌个体的表型
# 218.199.69.19
# sort -n /home/luohh/Yanyq/01.mpcSampleExtract/singleCancer.breast.sample > /home/yanyq/share_genetics/data/UKB_multi_cancer/01.mpcSampleExtract/singleCancer.breast.sample.sorted
# sort -n /home/luohh/Yanyq/01.mpcSampleExtract/singleCancer.ovary.sample > /home/yanyq/share_genetics/data/UKB_multi_cancer/01.mpcSampleExtract/singleCancer.ovary.sample.sorted
# # sort排序可能出现错误
# sed '1d' /home/luohh/UKB50wData/01.Download/04.PhenotypeData/ukb670790.txt | sort -t $'\t' -k 2 > /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/tmp
# join -1 1 -2 2 /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/tmp_sample /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/tmp > /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/singleCancer.breast
# join -1 1 -2 2 /home/luohh/Yanyq/01.mpcSampleExtract/singleCancer.ovary.sample /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/tmp > /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/singleCancer.ovary
# 提取sample所在的行号
cut -f 2 /home/luohh/UKB50wData/01.Download/04.PhenotypeData/ukb670790.txt > /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/tmp
while read line
do
    grep -n $line /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/tmp >> /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/singleCancer.breast.sample_line
done < /home/luohh/Yanyq/01.mpcSampleExtract/singleCancer.breast.sample
while read line
do
    grep -n $line /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/tmp >> /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/singleCancer.ovary.sample_line
done < /home/luohh/Yanyq/01.mpcSampleExtract/singleCancer.ovary.sample
while read line
do
    grep -n $line /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/tmp >> /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/nonCancer.filtered.white.sample_line
done < /home/luohh/UKB50wMultiPcancer/01.data/02.phenoData/nonCancer.filtered.white.sample
rm /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/tmp
# 根据行号提取sample
head -n 1 /home/luohh/UKB50wData/01.Download/04.PhenotypeData/ukb670790.txt > /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/singleCancer.breast.pheno
while read line
do
    num=(${line//:/ })
    sed -n ''"${num[0]}"'p' /home/luohh/UKB50wData/01.Download/04.PhenotypeData/ukb670790.txt >> /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/singleCancer.breast.pheno
done < /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/singleCancer.breast.sample_line
head -n 1 /home/luohh/UKB50wData/01.Download/04.PhenotypeData/ukb670790.txt > /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/singleCancer.ovary.pheno
while read line
do
    num=(${line//:/ })
    sed -n ''"${num[0]}"'p' /home/luohh/UKB50wData/01.Download/04.PhenotypeData/ukb670790.txt >> /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/singleCancer.ovary.pheno
done < /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/singleCancer.ovary.sample_line
head -n 1 /home/luohh/UKB50wData/01.Download/04.PhenotypeData/ukb670790.txt > /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/nonCancer.filtered.white.pheno
while read line
do
    num=(${line//:/ })
    sed -n ''"${num[0]}"'p' /home/luohh/UKB50wData/01.Download/04.PhenotypeData/ukb670790.txt >> /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/nonCancer.filtered.white.pheno
done < /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/nonCancer.filtered.white.sample_line
# # 提取到122981行后中断了
# sed '1,122981d' nonCancer.filtered.white.sample_line > nonCancer

# for i in {1..211}
# do
# head -n ${i}000 nonCancer | tail -n 1000 > nonCancer.${i}000
# sed 's/1000/'"${i}000"'/g' nonCancer.1000.sh > nonCancer.${i}000.sh
# echo 'nohup ./nonCancer.'"${i}"000'.sh >& nonCancer.'"${i}"000'.log &' >> ttt
# done
# tail -n 871 nonCancer > nonCancer.211871
# sed 's/1000/211871/g' nonCancer.1000.sh > nonCancer.211871.sh
# echo 'nohup ./nonCancer.211871.sh >& nonCancer.211871.log &' >> ttt


# 获取字段对应的列
# 招聘年龄【21022】9832:21022-0.0
# 性别【22001】Genetic sex	Genotyping process and sample QC；9992:22001-0.0
# BMI【21001】Body mass index (BMI)	Body size measures；9784:21001-0.0、9785:21001-1.0、9786:21001-2.0、9787:21001-3.0
# 吸烟【20116】Smoking status：never、previous、current；8876:20116-0.0、8877:20116-1.0、8878:20116-2.0、8879:20116-3.0
# 饮酒【20117】Alcohol drinker status：never、previous、current；8880:20117-0.0、8881:20117-1.0、8882:20117-2.0、8883:20117-3.0
head -n 1 "/home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/singleCancer.breast.pheno" | xargs -n1 | grep -n 21022
head -n 1 "/home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/singleCancer.breast.pheno" | xargs -n1 | grep -n 22001
head -n 1 "/home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/singleCancer.breast.pheno" | xargs -n1 | grep -n 21001
head -n 1 "/home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/singleCancer.breast.pheno" | xargs -n1 | grep -n 20116
head -n 1 "/home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/singleCancer.breast.pheno" | xargs -n1 | grep -n 20117
head -n 1 /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/singleCancer.breast.pheno | cut -f 1,8880-8883,8876-8879,9784-9787,9832,9992 > /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/singleCancer.breast.pheno.filtered
sed '1d' /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/singleCancer.breast.pheno | cut -f 2,8881-8884,8877-8880,9785-9788,9833,9993 >> /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/singleCancer.breast.pheno.filtered
head -n 1 /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/singleCancer.ovary.pheno | cut -f 1,8880-8883,8876-8879,9784-9787,9832,9992 > /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/singleCancer.ovary.pheno.filtered
sed '1d' /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/singleCancer.ovary.pheno | cut -f 2,8881-8884,8877-8880,9785-9788,9833,9993 >> /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/singleCancer.ovary.pheno.filtered
head -n 1 /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/nonCancer.filtered.white.pheno | cut -f 1,8880-8883,8876-8879,9784-9787,9832,9992 > /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/nonCancer.filtered.white.pheno.filtered
sed '1d' /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/nonCancer.filtered.white.pheno | cut -f 2,8881-8884,8877-8880,9785-9788,9833,9993 >> /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/nonCancer.filtered.white.pheno.filtered

# 提取患多原发癌的个体
# 提取sample所在的行号
f = read_tsv("/home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/tmp",col_names = F)
breast_ovary = read_tsv("/home/luohh/Yanyq/01.mpcSampleExtract/breastThenOvary.sample",col_names = F)
ovary_breast = read_tsv("/home/luohh/Yanyq/01.mpcSampleExtract/ovaryThenBreast.sample",col_names = F)
breast_line = as.data.frame(which(f$X1%in%breast_ovary$X1))
ovary_line = as.data.frame(which(f$X1%in%ovary_breast$X1))
breast_sample = as.data.frame(f$X1[f$X1%in%breast_ovary$X1])
ovary_sample = as.data.frame(f$X1[f$X1%in%ovary_breast$X1])
write_tsv(as.data.frame(paste0(breast_line[,1],":",breast_sample[,1])),"/home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/breastThenOvary.sample_line", col_names = F)
write_tsv(as.data.frame(paste0(ovary_line[,1],":",ovary_sample[,1])),"/home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/ovaryThenBreast.sample_line", col_names = F)
# 根据行号提取sample
head -n 1 /home/luohh/UKB50wData/01.Download/04.PhenotypeData/ukb670790.txt > /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/breastThenOvary.pheno
while read line
do
    num=(${line//:/ })
    sed -n ''"${num[0]}"'p' /home/luohh/UKB50wData/01.Download/04.PhenotypeData/ukb670790.txt >> /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/breastThenOvary.pheno
done < /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/breastThenOvary.sample_line
head -n 1 /home/luohh/UKB50wData/01.Download/04.PhenotypeData/ukb670790.txt > /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/ovaryThenBreast.pheno
while read line
do
    num=(${line//:/ })
    sed -n ''"${num[0]}"'p' /home/luohh/UKB50wData/01.Download/04.PhenotypeData/ukb670790.txt >> /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/ovaryThenBreast.pheno
done < /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/ovaryThenBreast.sample_line
head -n 1 /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/breastThenOvary.pheno | cut -f 1,8880-8883,8876-8879,9784-9787,9832,9992 > /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/breastThenOvary.pheno.filtered
sed '1d' /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/breastThenOvary.pheno | cut -f 2,8881-8884,8877-8880,9785-9788,9833,9993 >> /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/breastThenOvary.pheno.filtered
head -n 1 /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/ovaryThenBreast.pheno | cut -f 1,8880-8883,8876-8879,9784-9787,9832,9992 > /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/ovaryThenBreast.pheno.filtered
sed '1d' /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/ovaryThenBreast.pheno | cut -f 2,8881-8884,8877-8880,9785-9788,9833,9993 >> /home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/ovaryThenBreast.pheno.filtered

###########################################################
# 提取癌症字段表型
# 获取癌症字段编码
head -n 1 /home/luohh/UKB50wData/01.Download/04.PhenotypeData/ukb670790.disease.txt | sed 's/\t/\n/g' > /home/yanyq/share_genetics/data/UKB_multi_cancer/disease_code
disease_code = read.table("/home/yanyq/share_genetics/data/UKB_multi_cancer/disease_code", header = T)
disease_code$eid = sub("-.*", "", disease_code$eid)
disease_code = unique(disease_code)
disease_code$eid
# "20001": 20001   Cancer code, self-reported
# "20002": Non-cancer illness code, self-reported
# "40001": Underlying (primary) cause of death: ICD10
# "40002": Contributory (secondary) causes of death: ICD10
# "40006": Type of cancer: ICD10
# "40013": Type of cancer: ICD9
# "41201": External causes - ICD10
# "41202": Diagnoses - main ICD10
# "41203": Diagnoses - main ICD9
# "41204": Diagnoses - secondary ICD10
# "41205": Diagnoses - secondary ICD9
# "41270": Diagnoses - ICD10
# "41271": Diagnoses - ICD9

# 癌症相关表型，从第二行开始，第一列为空列，处理一下
cp "/home/luohh/UKB50wData/01.Download/04.PhenotypeData/ukb670790.disease.txt" /home/yanyq/share_genetics/data/UKB_multi_cancer/ukb670790.disease.txt
head -n 1 /home/yanyq/share_genetics/data/UKB_multi_cancer/ukb670790.disease.txt > /home/yanyq/share_genetics/data/UKB_multi_cancer/ukb670790.disease_new.txt
sed '1d' /home/yanyq/share_genetics/data/UKB_multi_cancer/ukb670790.disease.txt | cut -f 2- >> /home/yanyq/share_genetics/data/UKB_multi_cancer/ukb670790.disease_new.txt

# 获取所有疾病的字段编码
# head -n 1 /home/yanyq/share_genetics/data/UKB_multi_cancer/ukb670790.disease_new.txt | sed 's/\t/\n/g' > /home/yanyq/share_genetics/data/UKB_multi_cancer/disease_code_all

# 获取表型文件中癌症字段对应的列
# disease_code_all = read.table("/home/yanyq/share_genetics/data/UKB_multi_cancer/disease_code_all", header = T)
# disease_code = read.table("/home/yanyq/share_genetics/data/UKB_multi_cancer/disease_code", header = T)

raw = read.table("/home/luohh/UKB50wData/02.CancerExtract/02.CancerSeperate/01.SeperateCancer/01.rawData/bladder.sample", header = F)
filtered = read.table("/home/luohh/UKB50wData/02.CancerExtract/02.CancerSeperate/01.SeperateCancer/02.filteredData/bladder.filter.sample", header = F)
multi = read.table("/home/luohh/UKB50wMultiPcancer/01.data/02.phenoData/01.MPC/multiPCancer.sample", header = F)
raw_filtered_diff = setdiff(raw$V1, filtered$V1)

multi_bladder = read.table("/home/luohh/UKB50wMultiPcancer/01.data/02.phenoData/03.SpecificMPC/06.urinaryBladder/urinaryBladder.mpc.sample", header = F)

length(setdiff(filtered$V1, multi$V1))
length(setdiff(filtered$V1, multi_bladder$V1))

f1 = setdiff(filtered$V1, multi$V1)
f2 = setdiff(filtered$V1, multi_bladder$V1)
setdiff(f2,f1)

library(readr)
library(vroom)
multi = read.table("/home/luohh/UKB50wMultiPcancer/01.data/04.sampleData/03.multiPcancer/multiPCancer.sample", header = F)
singles = read.table("/home/luohh/UKB50wMultiPcancer/01.data/04.sampleData/08.singleCancer/singleCacner.filtered.white.sample", header = F)
pheno = read_tsv("/home/yanyq/share_genetics/data/UKB_multi_cancer/ukb670790.disease_new.txt") # 从第二行开始，每行多一列，最后一列全是NA，40006-21.0为ICD10，全为NA，后一列40013-0.0确实为ICD9，所以不影响

# 提取癌症编码40006
# pheno_cancer = pheno[,grep("20001|40006|40013",  colnames(pheno))]
pheno_cancer = pheno[,grep("40006",  colnames(pheno))]
write_tsv(pheno_cancer, "/home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/all_cancer_40006_ICD10")

# cut -f 1 /home/yanyq/share_genetics/data/UKB_multi_cancer/ukb670790.disease_new.txt > /home/yanyq/share_genetics/data/UKB_multi_cancer/sample_eid
eid = read_tsv("/home/yanyq/share_genetics/data/UKB_multi_cancer/sample_eid")
pheno_cancer = read_tsv("/home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/all_cancer_40006_ICD10")
# 去掉最后一位
pheno_cancer_ICD10 = apply(pheno_cancer, 2, function(x) substr(x, 1, 3))
pheno_cancer_ICD10 = as.data.frame(pheno_cancer_ICD10)

# 根据ICD10提取样本
sample_ICD = function(pheno = data.frame(), ICD = character(), eid = c()){
  row_indices = apply(pheno, 1, function(x) any(x == ICD, na.rm = TRUE))
  pheno = pheno[row_indices,]
  pheno$eid = eid[row_indices]
  return(pheno)
}
# 提取C67所在的行，膀胱癌
# row_indices = apply(pheno_cancer_ICD10, 1, function(x) any(x == "C67", na.rm = TRUE))
# pheno_cancer_C67_bladder = pheno_cancer_ICD10[row_indices,]
# pheno_cancer_C67_bladder$eid = pheno$eid[row_indices]

# 与/home/luohh/UKB50wData/02.CancerExtract/02.CancerSeperate/03.40006Cancer/01.rawData/样本数一致的癌症
{
  # 2091个样本，与luohh一致："/home/luohh/UKB50wData/02.CancerExtract/02.CancerSeperate/03.40006Cancer/01.rawData/kidney.sample"
  pheno_cancer_C64_kidney = sample_ICD(pheno = pheno_cancer_ICD10, ICD = "C64", eid = eid$eid)
  tmp = read_tsv("/home/luohh/UKB50wData/02.CancerExtract/02.CancerSeperate/03.40006Cancer/01.rawData/kidney.sample", col_names = F)
  which(!pheno_cancer_C64_kidney$eid%in%tmp$X1)
  
  # 1453个样本，与luohh一致：pancreatic.sample
  pheno_cancer_C25_PAAD = sample_ICD(pheno = pheno_cancer_ICD10, ICD = "C25", eid = eid$eid)
  tmp = read_tsv("/home/luohh/UKB50wData/02.CancerExtract/02.CancerSeperate/03.40006Cancer/01.rawData/pancreatic.sample", col_names = F)
  which(!pheno_cancer_C25_PAAD$eid%in%tmp$X1)
  
  # 840个样本，与luohh一致：thyroid.sample
  pheno_cancer_C73_THCA = sample_ICD(pheno = pheno_cancer_ICD10, ICD = "C73", eid = eid$eid)
  tmp = read_tsv("/home/luohh/UKB50wData/02.CancerExtract/02.CancerSeperate/03.40006Cancer/01.rawData/thyroid.sample",col_names = F)
  which(!pheno_cancer_C73_THCA$eid%in%tmp$X1)
  
  # 959个样本，与luohh一致：brain.sample
  pheno_cancer_C71_BGA = sample_ICD(pheno = pheno_cancer_ICD10, ICD = "C71", eid = eid$eid)
  tmp = read_tsv("/home/luohh/UKB50wData/02.CancerExtract/02.CancerSeperate/03.40006Cancer/01.rawData/brain.sample", col_names = F) 
  which(!pheno_cancer_C71_BGA$eid%in%tmp$X1)
  
  # 24个样本，与luohh一致：meningeal.sample
  pheno_cancer_C70_BM = sample_ICD(pheno = pheno_cancer_ICD10, ICD = "C70", eid = eid$eid)
  tmp = read_tsv("/home/luohh/UKB50wData/02.CancerExtract/02.CancerSeperate/03.40006Cancer/01.rawData/meningeal.sample", col_names = F) 
  which(!pheno_cancer_C70_BM$eid%in%tmp$X1)
  
  # 2530个样本，与luohh一致：uterine.sample
  pheno_cancer_C54_CORP = sample_ICD(pheno = pheno_cancer_ICD10, ICD = "C54", eid = eid$eid)
  tmp = read_tsv("/home/luohh/UKB50wData/02.CancerExtract/02.CancerSeperate/03.40006Cancer/01.rawData/uterine.sample", col_names = F) 
  which(!pheno_cancer_C54_CORP$eid%in%tmp$X1)
  
  # 458个样本，与luohh一致：mesothelioma.sample
  pheno_cancer_C45_MESO = sample_ICD(pheno = pheno_cancer_ICD10, ICD = "C45", eid = eid$eid)
  tmp = read_tsv("/home/luohh/UKB50wData/02.CancerExtract/02.CancerSeperate/03.40006Cancer/01.rawData/mesothelioma.sample", col_names = F) 
  which(!pheno_cancer_C45_MESO$eid%in%tmp$X1)
  
  # 347个样本，与luohh一致：smallBowel.sample
  pheno_cancer_C17_SI = sample_ICD(pheno = pheno_cancer_ICD10, ICD = "C17", eid = eid$eid)
  tmp = read_tsv("/home/luohh/UKB50wData/02.CancerExtract/02.CancerSeperate/03.40006Cancer/01.rawData/smallBowel.sample", col_names = F) 
  which(!pheno_cancer_C17_SI$eid%in%tmp$X1)
  
  # 586个样本，与luohh一致：testicular.sample
  pheno_cancer_C62_TEST = sample_ICD(pheno = pheno_cancer_ICD10, ICD = "C62", eid = eid$eid)
  tmp = read_tsv("/home/luohh/UKB50wData/02.CancerExtract/02.CancerSeperate/03.40006Cancer/01.rawData/testicular.sample", col_names = F) 
  which(!pheno_cancer_C62_TEST$eid%in%tmp$X1)
}
# 包含原位癌样本的癌症，这里去掉
{
  # 3273个样本，1419个D09原位癌，这里去掉后，剩1854个恶性肿瘤
  pheno_cancer_C67_bladder = sample_ICD(pheno = pheno_cancer_ICD10, ICD = "C67", eid = eid$eid)
  tmp = read_tsv("/home/luohh/UKB50wData/02.CancerExtract/02.CancerSeperate/03.40006Cancer/01.rawData/bladder.sample", col_names = F)
  tmp = pheno_cancer_ICD10[eid$eid%in%tmp$X1&!(eid$eid%in%pheno_cancer_C67_bladder$eid),]
  sample_ICD(pheno = tmp, ICD = "C67", eid = eid$eid[eid$eid%in%tmp$X1&!(eid$eid%in%pheno_cancer_C67_bladder$eid)])
  
  
  # 939个样本，12个D09原位癌，这里去掉后，剩927个恶性肿瘤
  pheno_cancer_C16_STAD = sample_ICD(pheno = pheno_cancer_ICD10, ICD = "C16", eid = eid$eid)
  tmp = read_tsv("/home/luohh/UKB50wData/02.CancerExtract/02.CancerSeperate/03.40006Cancer/01.rawData/stomach.sample", col_names = F)
  tmp = pheno_cancer_ICD10[eid$eid%in%tmp$X1&!(eid$eid%in%pheno_cancer_C16_STAD$eid),]
  sample_ICD(pheno = tmp, ICD = "C16", eid = eid$eid[eid$eid%in%tmp$X1&!(eid$eid%in%pheno_cancer_C16_STAD$eid)])
  
  
  # 221个样本，11个D09原位癌，这里去掉后，剩210个恶性肿瘤
  pheno_cancer_C69_EYAD = sample_ICD(pheno = pheno_cancer_ICD10, ICD = "C69", eid = eid$eid)
  tmp = read_tsv("/home/luohh/UKB50wData/02.CancerExtract/02.CancerSeperate/03.40006Cancer/01.rawData/eyeAndAdnexa.sample", col_names = F) 
  tmp = pheno_cancer_ICD10[eid$eid%in%tmp$X1&!(eid$eid%in%pheno_cancer_C69_EYAD$eid),]
  sample_ICD(pheno = tmp, ICD = "C69", eid = eid$eid[eid$eid%in%tmp$X1&!(eid$eid%in%pheno_cancer_C69_EYAD$eid)])
  
  
  # 377个样本，157个D09原位癌，这里去掉后，剩220个恶性肿瘤：vulva.sample
  pheno_cancer_C51_VULVA = sample_ICD(pheno = pheno_cancer_ICD10, ICD = "C51", eid = eid$eid)
  tmp = read_tsv("/home/luohh/UKB50wData/02.CancerExtract/02.CancerSeperate/03.40006Cancer/01.rawData/vulva.sample", col_names = F) 
  tmp = pheno_cancer_ICD10[eid$eid%in%tmp$X1&!(eid$eid%in%pheno_cancer_C51_VULVA$eid),]
  sample_ICD(pheno = tmp, ICD = "C51", eid = eid$eid[eid$eid%in%tmp$X1&!(eid$eid%in%pheno_cancer_C51_VULVA$eid)])
}
{
  setwd("/home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/")
  write_tsv(pheno_cancer_C16_STAD,"STAD")
  write_tsv(pheno_cancer_C17_SI,"SI")
  write_tsv(pheno_cancer_C25_PAAD,"PAAD")
  write_tsv(pheno_cancer_C45_MESO,"MESO")
  write_tsv(pheno_cancer_C51_VULVA,"VULVA")
  write_tsv(pheno_cancer_C54_CORP,"CORP")
  write_tsv(pheno_cancer_C62_TEST,"TEST")
  write_tsv(pheno_cancer_C64_kidney,"kidney")
  write_tsv(pheno_cancer_C67_bladder,"BLCA")
  write_tsv(pheno_cancer_C69_EYAD,"EYAD")
  write_tsv(pheno_cancer_C70_BM,"BM")
  write_tsv(pheno_cancer_C71_BGA,"BGA")
  write_tsv(pheno_cancer_C73_THCA,"THCA")
}
