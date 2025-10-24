#!/bin/bash

# 仅包含常染色体
# hg19千人基因组下载链接:http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/
# hg19千人基因组fasta下载链接http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/human_g1k_v37.fasta.gz
# 提取EUR样本ID
awk '$3=="EUR"{print $1}' ~/data/1000Genomes/integrated_call_samples_v3.20130502.ALL.panel > ~/data/1000Genomes/EUR.sample

# process
for chr in {1..22}
do
   bcftools view -S ~/data/1000Genomes/EUR.sample ~/data/1000Genomes/ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz | \ # 提取欧洲人群
      bcftools norm -m-any --check-ref w -f ~/data/1000Genomes/human_g1k_v37.fasta | \ # 标准化ref
      bcftools annotate -x ID,INFO -I +'%CHROM:%POS:%REF:%ALT' | \ # ID注释，原文件没有SNPID
      bcftools norm --rm-dup both | \ # 去重
      bcftools +fill-tags -Oz  -- -t AF  \ # 新增AF列，等位基因频率
      > ~/data/1000Genomes/EUR/EUR.chr"${chr}".split_norm_af.vcf.gz
   tabix -p vcf EUR.chr"${chr}".split_norm_af.vcf.gz
   echo "/home/yanyq/data/1000Genomes/EUR/EUR.chr"${chr}".split_norm_af.vcf.gz" >> ~/data/1000Genomes/EUR/concat_list.txt 
done

# merge
bcftools concat -a -d both -f ~/data/1000Genomes/hg19/concat_list.txt -Ob | bcftools sort -Oz  > ~/data/1000Genomes/hg19/EUR.ALL.split_norm_af.1kgp3v5.hg19.vcf.gz # 合并所有的染色体
tabix -p vcf ~/data/1000Genomes/EUR/EUR.ALL.split_norm_af.1kgp3v5.hg19.vcf.gz

cp ~/data/1000Genomes/EUR/EUR.ALL.split_norm_af.1kgp3v5.hg19.vcf.gz ~/data/1000Genomes/EUR/bak_EUR.ALL.split_norm_af.1kgp3v5.hg19.vcf.gz

# 生成bfile
plink --vcf ~/data/1000Genomes/EUR/ACGT_EUR.ALL.split_norm_af.1kgp3v5.hg19.vcf.gz --make-bed --out ~/data/1000Genomes/EUR/bfile/ACGT_EUR.ALL
