import pymongo
import pandas as pd
import json
import numpy as np

myclient = pymongo.MongoClient(host = "127.0.0.1", port = 27017, username = "yyq", password = "yqx2913196,",authSource = "PLACO") # authorSource指定登录的数据库，默认为admin
myclient.list_database_names()
db = myclient.PLACO # 或client['PLACO']

def format_scientific(number): # 科学计数法，json会任意保留小数点位数
    if abs(number) < 0.0005:
        return '{:.2e}'.format(number)
    else:
        return '%.3f'% number

#####################
## PLACO 显著位点
#####################
my_data = pd.read_csv("/home/yanyq/database/flask_vue/data/all_sig_placo", sep = "\t")

# my_data = my_data.round({"T": 3}) # 在前端保留位数，否则转为json自动去除末尾的0
def format_scientific(number): # 科学计数法，json会任意保留小数点位数
    return '{:.2e}'.format(number)
my_data["P"] = my_data["P"].apply(format_scientific)

# double_precision = 3
my_data_json = my_data.T.to_json() # 数据框转置转json
db.pleiotropicSNP.drop()
table = db['pleiotropicSNP'] # 在PLACO数据库中创建名为pleiotropicSNP的数据表
db.list_collection_names()
table.insert_many(json.loads(my_data_json).values()) # 将数据导入数据表
db.list_collection_names()
# table.create_index({"trait_pairs":1}) # 创建索引，加快查询速度

# SNP和cancer的关联
# CORP没有SMR基因，所以不需要过滤
# 合并缩写和英文名
# f = as.data.frame(read_tsv("/home/yanyq/database/flask_vue/data/SMR_Gene_GWAS"))
# f = f[f$cancer!="CORP",]
# abbrev = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/english_abbrev"))
# colnames(abbrev)[2] = "cancer"
# f = dplyr::left_join(f,abbrev, by = "cancer")
# which(is.na(f$name))
# write_tsv(f,"/home/yanyq/database/flask_vue/data/SMR_Gene_GWAS")
my_data = pd.read_csv("/home/yanyq/database/flask_vue/data/SMR_Gene_GWAS", sep = "\t")
my_data['log10P'] = abs(np.log10(my_data["pval"]))
my_data["pval"] = my_data["pval"].apply(format_scientific)
my_data["beta"] = my_data["beta"].apply(format_scientific)
my_data["se"] = my_data["se"].apply(format_scientific)
my_data_json = my_data.T.to_json()
db.SMR_Gene_GWAS.drop()
table = db['SMR_Gene_GWAS']
table.insert_many(json.loads(my_data_json).values()) # 将数据导入数据表
table.create_index("cancer")
table.create_index("hg19chr")
db.list_collection_names()

# db.SNP_cancer.drop()
# table = db['SNP_cancer']
# table.insert_many(json.loads(my_data_json).values()) # 将数据导入数据表
# db.list_collection_names()
#####################
## QTL位点
#####################
# eQTL
my_data = pd.read_csv("/home/yanyq/share_genetics/data/eQTL/eQTLGen/mongodb_eQTL_SMRGene_and_PLACOSNP", sep = "\t")
# my_data = my_data[my_data["GeneSymbol"].isin(['ZBTB48', 'PLEKHM2'])]
my_data['log10P'] = abs(np.log10(my_data["Pvalue"]))
my_data["Pvalue"] = my_data["Pvalue"].apply(format_scientific)
my_data_json = my_data.T.to_json()
db.eQTL.drop()
table = db['eQTL']
table.insert_many(json.loads(my_data_json).values()) # 将数据导入数据表
table.create_index("GeneSymbol")
table.create_index("SNP")
table.create_index("PLACO")
db.list_collection_names()

# meQTL
my_data = pd.read_csv("/home/yanyq/database/flask_vue/data/placo_meQTL_SNP_overlap", sep = "\t")
my_data_json = my_data.T.to_json()
db.meQTL.drop()
table = db['meQTL']
table.insert_many(json.loads(my_data_json).values()) # 将数据导入数据表
db.list_collection_names()
# pQTL
my_data = pd.read_csv("/home/yanyq/database/flask_vue/data/placo_pQTL_SNP_overlap", sep = "\t")
my_data_json = my_data.T.to_json()
db.pQTL.drop()
table = db['pQTL']
table.insert_many(json.loads(my_data_json).values()) # 将数据导入数据表
db.list_collection_names()
#####################
## SMR位点
#####################
# eQTL_SMR
# my_data = pd.read_csv("/home/yanyq/cogenetics/result/smr_eQTL/all_cancer_sig.smr", sep = "\t")
# my_data_json = my_data.T.to_json()
# db.SMR_eQTL.drop()
# table = db['SMR_eQTL']
# table.insert_many(json.loads(my_data_json).values()) # 将数据导入数据表
# db.list_collection_names()
my_data = pd.read_csv("/home/yanyq/cogenetics/result/smr_multiSNP_0.01/eQTLGen/all_cancer_fdr_0.05_withSymbol.msmr", sep = "\t")
my_data["location"] = my_data["topSNP_chr"].astype("str") + ":" + my_data["topSNP_bp"].astype("str")
my_data["alleles"] = my_data["A1"] + "/" + my_data["A2"]
# probeID ProbeChr        Gene    Probe_bp        
# topSNP  topSNP_chr      topSNP_bp       A1      A2      Freq    
# b_GWAS  se_GWAS p_GWAS  b_eQTL  se_eQTL p_eQTL  
# b_SMR   se_SMR  p_SMR
# p_SMR_multi     p_HEIDI nsnp_HEIDI      p_thresh        fdr     cancer
my_data["p_GWAS"] = my_data["p_GWAS"].apply(format_scientific)
my_data["p_eQTL"] = my_data["p_eQTL"].apply(format_scientific)
my_data["p_SMR"] = my_data["p_SMR"].apply(format_scientific)
my_data["p_SMR_multi"] = my_data["p_SMR_multi"].apply(format_scientific)
my_data["p_HEIDI"] = my_data["p_HEIDI"].apply(format_scientific)
my_data["fdr"] = my_data["fdr"].apply(format_scientific)
my_data["Freq"] = my_data["Freq"].apply(format_scientific)
my_data["b_GWAS"] = my_data["b_GWAS"].astype("float").apply(format_scientific)
my_data["b_SMR"] = my_data["b_SMR"].astype("float").apply(format_scientific)
my_data["b_eQTL"] = my_data["b_eQTL"].astype("float").apply(format_scientific)
my_data["se_GWAS"] = my_data["se_GWAS"].apply(format_scientific)
my_data["se_SMR"] = my_data["se_SMR"].apply(format_scientific)
my_data["se_eQTL"] = my_data["se_eQTL"].apply(format_scientific)
my_data_json = my_data.T.to_json()
db.SMR_eQTL.drop()
table = db['SMR_eQTL']
table.insert_many(json.loads(my_data_json).values()) # 将数据导入数据表
db.list_collection_names()
# meQTL_SMR
my_data = pd.read_csv("/home/yanyq/cogenetics/result/smr_meQTL/all_cancer_sig.smr", sep = "\t")
my_data["Probe_bp"] = my_data["Probe_bp"].astype("Int64")
my_data["topSNP_bp"] = my_data["topSNP_bp"].astype("Int64")
my_data["ProbeChr"] = my_data["ProbeChr"].astype("Int64")
my_data["topSNP_chr"] = my_data["topSNP_chr"].astype("Int64")
my_data_json = my_data.T.to_json()
db.SMR_meQTL.drop()
table = db['SMR_meQTL']
table.insert_many(json.loads(my_data_json).values()) # 将数据导入数据表
db.list_collection_names()
# pQTL_SMR
my_data = pd.read_csv("/home/yanyq/cogenetics/result/smr_pQTL/all_cancer_sig.smr", sep = "\t")
my_data_json = my_data.T.to_json()
db.SMR_pQTL.drop()
table = db['SMR_pQTL']
table.insert_many(json.loads(my_data_json).values()) # 将数据导入数据表
db.list_collection_names()
# meQTL_eQTL_SMR
my_data = pd.read_csv("/home/yanyq/cogenetics/result/smr_meQTL_eQTLGen/all_cancer_sig.smr", sep = "\t")
my_data_json = my_data.T.to_json()
db.SMR_meQTL_eQTL.drop()
table = db['SMR_meQTL_eQTL']
table.insert_many(json.loads(my_data_json).values()) # 将数据导入数据表
db.list_collection_names()