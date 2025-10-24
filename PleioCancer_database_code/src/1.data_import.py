import pymongo
import pandas as pd
import json
import numpy as np
from pymongo import MongoClient
from urllib.parse import quote_plus
import csv


# myclient = pymongo.MongoClient(host = "127.0.0.1", port = 27017, username = "yyq", password = "yqx2913196,",authSource = "PLACO") # authorSource指定登录的数据库，默认为admin
# myclient.list_database_names()
# db = myclient.PLACO # 或client['PLACO']



username = quote_plus('yyq')
password = quote_plus('yqx2913196,')

# 创建MongoClient实例并提供认证信息
client = MongoClient(f'mongodb://{username}:{password}@127.0.0.1:30000/PLACO', authSource='PLACO', authMechanism='SCRAM-SHA-1')
db = client['PLACO']  # 数据库名

# 检查 MongoDB 中已有的集合名称，防止重名
existing_collections = db.list_collection_names()
print(existing_collections)



def format_scientific(number): # 科学计数法，json会任意保留小数点位数
    if abs(number) < 0.0005:
        return '{:.2e}'.format(number)
    else:
        return '%.3f'% number

#####################
## 多效SNP
#####################
my_data = pd.read_csv("/home/yanyq/PleioCancer/data/all_placo", sep = "\t")
my_data["alleles"] = my_data["a1"] + "/" + my_data["a2"]
my_data["or.trait1"] = my_data["or.trait1"].apply(format_scientific)
my_data["se.trait1"] = my_data["se.trait1"].apply(format_scientific)
my_data["pval.trait1"] = my_data["pval.trait1"].apply(format_scientific)
my_data["EURaf.trait1"] = my_data["EURaf.trait1"].apply(format_scientific)
my_data["zscore.trait1"] = my_data["zscore.trait1"].apply(format_scientific)
my_data["or.trait2"] = my_data["or.trait2"].apply(format_scientific)
my_data["se.trait2"] = my_data["se.trait2"].apply(format_scientific)
my_data["pval.trait2"] = my_data["pval.trait2"].apply(format_scientific)
my_data["EURaf.trait2"] = my_data["EURaf.trait2"].apply(format_scientific)
my_data["zscore.trait2"] = my_data["zscore.trait2"].apply(format_scientific)
my_data["T.placo"] = my_data["T.placo"].apply(format_scientific)
my_data["p.placo"] = my_data["p.placo"].apply(format_scientific)
# my_data["log10P"] = my_data["log10P"].apply(format_scientific)

my_data["log10P"] = my_data["log10P"].replace([np.inf, -np.inf], 300)  # 先处理无穷值
my_data["log10P"] = my_data["log10P"].apply(format_scientific)

my_data.drop(columns=['zscore.trait2'], inplace=True)
my_data.drop(columns=['zscore.trait1'], inplace=True)
my_data_json = my_data.T.to_json() # 数据框转置转json
db.pleiotropicSNP.drop()
table = db['pleiotropicSNP'] # 在PLACO数据库中创建名为pleiotropicSNP的数据表
db.list_collection_names()
table.insert_many(json.loads(my_data_json).values()) # 将数据导入数据表
db.list_collection_names()

#####################
# 多效基因
#####################
# my_data = pd.read_csv("/home/yanyq/PleioCancer/data/placo_gene", sep = "\t")
# my_data["fdr.PLACO"] = my_data["fdr.PLACO"].apply(format_scientific)
# my_data["fdr.trait1"] = my_data["fdr.trait1"].apply(format_scientific)
# my_data["fdr.trait2"] = my_data["fdr.trait2"].apply(format_scientific)
# my_data["PP.H0.abf"] = my_data["PP.H0.abf"].apply(format_scientific)
# my_data["PP.H1.abf"] = my_data["PP.H1.abf"].apply(format_scientific)
# my_data["PP.H2.abf"] = my_data["PP.H2.abf"].apply(format_scientific)
# my_data["PP.H3.abf"] = my_data["PP.H3.abf"].apply(format_scientific)
# my_data["PP.H4.abf"] = my_data["PP.H4.abf"].apply(format_scientific)
# my_data["SNP.PP.H4"] = my_data["SNP.PP.H4"].apply(format_scientific)
# my_data["log10FDR"] = my_data["log10FDR"].apply(format_scientific)
# my_data = my_data[['CHR', 'START', 'STOP', 'NSNPS', 'fdr.PLACO', 'fdr.trait1', 'fdr.trait2', 'SYMBOL','X5',
#                    'PP.H0.abf', 'PP.H1.abf', 'PP.H2.abf','PP.H3.abf', 'PP.H4.abf', 'snp', 'SNP.PP.H4', 'cancer1', 'cancer2','log10FDR']]
# db.pleiotropicGene.drop()
# table = db['pleiotropicGene'] # 在PLACO数据库中创建名为pleiotropicSNP的数据表
# db.list_collection_names()
# my_data_json = my_data.T.to_json() # 数据框转置转json
# table.insert_many(json.loads(my_data_json).values()) # 将数据导入数据表
# table.create_index("SYMBOL")
# db.list_collection_names()

#####################
## 多效SNP上下游1MB
#####################
my_data = pd.read_csv("/home/yanyq/PleioCancer/data/placo_1MB", sep = "\t")
my_data["p.placo"] = my_data["p.placo"].apply(format_scientific)
# my_data["log10P"] = my_data["log10P"].apply(format_scientific)


my_data["log10P"] = my_data["log10P"].replace([np.inf, -np.inf], 300)  # 先处理无穷值
my_data["log10P"] = my_data["log10P"].apply(format_scientific)

my_data_json = my_data.T.to_json() # 数据框转置转json
db.pleio1MB.drop()
table = db['pleio1MB'] # 在PLACO数据库中创建名为pleiotropicSNP的数据表
db.list_collection_names()
table.insert_many(json.loads(my_data_json).values()) # 将数据导入数据表
table.create_index([("cancer1", pymongo.ASCENDING), ("cancer2", pymongo.ASCENDING), ("snpid", pymongo.ASCENDING)])
db.list_collection_names()

#####################
## SMR位点
#####################
# eQTL_SMR
# my_data = pd.read_csv("/home/yanyq/PleioCancer/data/SMR_eQTL", sep = "\t")
# my_data["SNP_position"] = my_data["topSNP_chr"].astype("str") + ":" + my_data["topSNP_bp"].astype("str")
# # my_data["Gene_position"] = my_data["ProbeChr"].astype("str") + ":" + my_data["Probe_bp"].astype("str")
# my_data["alleles"] = my_data["A1"] + "/" + my_data["A2"]
# my_data["p_GWAS"] = my_data["p_GWAS"].apply(format_scientific)
# my_data["p_eQTL"] = my_data["p_eQTL"].apply(format_scientific)
# my_data["p_SMR"] = my_data["p_SMR"].apply(format_scientific)
# my_data["p_SMR_multi"] = my_data["p_SMR_multi"].apply(format_scientific)
# my_data["p_HEIDI"] = my_data["p_HEIDI"].apply(format_scientific)
# my_data["fdr"] = my_data["fdr"].apply(format_scientific)
# my_data["Freq"] = my_data["Freq"].apply(format_scientific)
# my_data["b_GWAS"] = my_data["b_GWAS"].astype("float").apply(format_scientific)
# my_data["b_SMR"] = my_data["b_SMR"].astype("float").apply(format_scientific)
# my_data["b_eQTL"] = my_data["b_eQTL"].astype("float").apply(format_scientific)
# my_data["se_GWAS"] = my_data["se_GWAS"].apply(format_scientific)
# my_data["se_SMR"] = my_data["se_SMR"].apply(format_scientific)
# my_data["se_eQTL"] = my_data["se_eQTL"].apply(format_scientific)
# # my_data = my_data[[ 'topSNP', 'Freq', 'b_GWAS', 'se_GWAS', 'p_GWAS','b_eQTL', 'se_eQTL', 'p_eQTL', 'b_SMR', 'se_SMR',  'p_HEIDI',  'fdr','symbol', 'name', 'SNP_position','ProbeChr','Probe_bp', 'alleles','sig','log10FDR']]
# my_data = my_data[['ProbeChr','Probe_bp', 'topSNP',  'Freq', 'b_GWAS', 'se_GWAS', 'p_GWAS','b_eQTL', 'se_eQTL', 'p_eQTL', 'b_SMR', 'se_SMR', 'p_SMR','p_SMR_multi', 'p_HEIDI', 'nsnp_HEIDI',  'fdr', 'symbol', 'name', 'log10FDR', 'sig', 'SNP_position', 'alleles']]
# my_data = my_data.rename(columns={'name': 'cancer'})
# my_data_json = my_data.T.to_json()
# db.SMR_eQTL.drop()
# table = db['SMR_eQTL']
# table.insert_many(json.loads(my_data_json).values()) # 将数据导入数据表
# table.create_index("sig")
# table.create_index([("cancer", pymongo.ASCENDING), ("ProbeChr", pymongo.ASCENDING), ("Probe_bp", pymongo.ASCENDING)])
# db.list_collection_names()

# meQTL_SMR
# my_data = pd.read_csv("/home/yanyq/PleioCancer/data/SMR_meQTL", sep = "\t")
# my_data.columns
# my_data["SNP_position"] = my_data["topSNP_chr"].astype("str") + ":" + my_data["topSNP_bp"].astype("str")
# # my_data["methylation_position"] = my_data["ProbeChr"].astype("str") + ":" + my_data["Probe_bp"].astype("str")
# my_data["alleles"] = my_data["A1"] + "/" + my_data["A2"]
# my_data["p_GWAS"] = my_data["p_GWAS"].apply(format_scientific)
# my_data["p_eQTL"] = my_data["p_eQTL"].apply(format_scientific)
# my_data["p_SMR"] = my_data["p_SMR"].apply(format_scientific)
# my_data["p_SMR_multi"] = my_data["p_SMR_multi"].apply(format_scientific)
# my_data["p_HEIDI"] = my_data["p_HEIDI"].apply(format_scientific)
# my_data["fdr"] = my_data["fdr"].apply(format_scientific)
# my_data["Freq"] = my_data["Freq"].apply(format_scientific)
# my_data["b_GWAS"] = my_data["b_GWAS"].astype("float").apply(format_scientific)
# my_data["b_SMR"] = my_data["b_SMR"].astype("float").apply(format_scientific)
# my_data["b_eQTL"] = my_data["b_eQTL"].astype("float").apply(format_scientific)
# my_data["se_GWAS"] = my_data["se_GWAS"].apply(format_scientific)
# my_data["se_SMR"] = my_data["se_SMR"].apply(format_scientific)
# my_data["se_eQTL"] = my_data["se_eQTL"].apply(format_scientific)
# # my_data = my_data[[ 'probeID','topSNP', 'Freq', 'b_GWAS', 'se_GWAS', 'p_GWAS','b_eQTL', 'se_eQTL', 'p_eQTL', 'b_SMR', 'se_SMR',  'p_HEIDI',  'fdr','Gene', 'name', 'SNP_position','ProbeChr','Probe_bp', 'alleles','sig','log10FDR']]
# my_data = my_data[['probeID','ProbeChr','Probe_bp', 'topSNP',  'Freq', 'b_GWAS', 'se_GWAS', 'p_GWAS','b_eQTL', 'se_eQTL', 'p_eQTL', 'b_SMR', 'se_SMR', 'p_SMR','p_SMR_multi', 'p_HEIDI', 'nsnp_HEIDI',  'fdr', 'Gene', 'name', 'log10FDR', 'sig', 'SNP_position', 'alleles']]
# my_data = my_data.rename(columns={'name': 'cancer'})
# my_data_json = my_data.T.to_json()
# db.SMR_meQTL.drop()
# table = db['SMR_meQTL']
# table.insert_many(json.loads(my_data_json).values()) # 将数据导入数据表
# table.create_index("sig")
# table.create_index([("cancer", pymongo.ASCENDING), ("ProbeChr", pymongo.ASCENDING), ("Probe_bp", pymongo.ASCENDING)])
# db.list_collection_names()

# pQTL_SMR
# my_data = pd.read_csv("/home/yanyq/PleioCancer/data/SMR_pQTL", sep = "\t")
# my_data.columns
# my_data["SNP_position"] = my_data["topSNP_chr"].astype("str") + ":" + my_data["topSNP_bp"].astype("str")
# # my_data["methylation_position"] = my_data["ProbeChr"].astype("str") + ":" + my_data["Probe_bp"].astype("str")
# my_data["alleles"] = my_data["A1"] + "/" + my_data["A2"]
# my_data["p_GWAS"] = my_data["p_GWAS"].apply(format_scientific)
# my_data["p_eQTL"] = my_data["p_eQTL"].apply(format_scientific)
# my_data["p_SMR"] = my_data["p_SMR"].apply(format_scientific)
# my_data["p_SMR_multi"] = my_data["p_SMR_multi"].apply(format_scientific)
# my_data["p_HEIDI"] = my_data["p_HEIDI"].apply(format_scientific)
# my_data["fdr"] = my_data["fdr"].apply(format_scientific)
# my_data["Freq"] = my_data["Freq"].apply(format_scientific)
# my_data["b_GWAS"] = my_data["b_GWAS"].astype("float").apply(format_scientific)
# my_data["b_SMR"] = my_data["b_SMR"].astype("float").apply(format_scientific)
# my_data["b_eQTL"] = my_data["b_eQTL"].astype("float").apply(format_scientific)
# my_data["se_GWAS"] = my_data["se_GWAS"].apply(format_scientific)
# my_data["se_SMR"] = my_data["se_SMR"].apply(format_scientific)
# my_data["se_eQTL"] = my_data["se_eQTL"].apply(format_scientific)
# # my_data = my_data[[ 'probeID','topSNP', 'Freq', 'b_GWAS', 'se_GWAS', 'p_GWAS','b_eQTL', 'se_eQTL', 'p_eQTL', 'b_SMR', 'se_SMR',  'p_HEIDI',  'fdr','Gene', 'name', 'SNP_position','ProbeChr','Probe_bp', 'alleles','sig','log10FDR']]
# my_data = my_data[['probeID','ProbeChr','Probe_bp', 'topSNP',  'Freq', 'b_GWAS', 'se_GWAS', 'p_GWAS','b_eQTL', 'se_eQTL', 'p_eQTL', 'b_SMR', 'se_SMR', 'p_SMR','p_SMR_multi', 'p_HEIDI', 'nsnp_HEIDI',  'fdr', 'Gene', 'name', 'log10FDR', 'sig', 'SNP_position', 'alleles']]
# my_data = my_data.rename(columns={'name': 'cancer'})
# my_data_json = my_data.T.to_json()
# db.SMR_pQTL.drop()
# table = db['SMR_pQTL']
# table.insert_many(json.loads(my_data_json).values()) # 将数据导入数据表
# table.create_index("sig")
# table.create_index([("cancer", pymongo.ASCENDING), ("ProbeChr", pymongo.ASCENDING), ("Probe_bp", pymongo.ASCENDING)])
# db.list_collection_names()

# meQTL_eQTL_SMR
# my_data = pd.read_csv("/home/yanyq/PleioCancer/data/all_chr_fdr_0.05_withsymbol.msmr", sep = "\t")
# my_data.columns
# my_data["SNP_position"] = my_data["topSNP_chr"].astype("str") + ":" + my_data["topSNP_bp"].astype("str")
# my_data["alleles"] = my_data["A1"] + "/" + my_data["A2"]
# my_data["Freq"] = my_data["Freq"].apply(format_scientific)
# my_data["b_Outco"] = my_data["b_Outco"].apply(format_scientific)
# my_data["se_Outco"] = my_data["se_Outco"].apply(format_scientific)
# my_data["p_Outco"] = my_data["p_Outco"].apply(format_scientific)
# my_data["p_HEIDI"] = my_data["p_HEIDI"].apply(format_scientific)
# my_data["b_Expo"] = my_data["b_Expo"].apply(format_scientific)
# my_data["se_Expo"] = my_data["se_Expo"].astype("float").apply(format_scientific)
# my_data["p_Expo"] = my_data["p_Expo"].astype("float").apply(format_scientific)
# my_data["b_SMR"] = my_data["b_SMR"].astype("float").apply(format_scientific)
# my_data["se_SMR"] = my_data["se_SMR"].apply(format_scientific)
# my_data["p_SMR_multi"] = my_data["p_SMR_multi"].apply(format_scientific)
# my_data["p_SMR"] = my_data["p_SMR"].apply(format_scientific)
# my_data["fdr"] = my_data["fdr"].apply(format_scientific)
# my_data = my_data[['Expo_ID','Expo_Chr','Expo_bp', 'symbol','Outco_Chr','Outco_bp','topSNP','SNP_position', 'alleles',  'Freq', 'b_Outco', 'se_Outco', 'p_Outco', 'b_Expo', 'se_Expo','p_Expo', 'b_SMR', 'se_SMR', 'p_SMR','p_SMR_multi', 'p_HEIDI', 'nsnp_HEIDI',  'fdr']]
# my_data_json = my_data.T.to_json()
# db.SMR_meQTL_eQTL.drop()
# table = db['SMR_meQTL_eQTL']
# table.insert_many(json.loads(my_data_json).values()) # 将数据导入数据表
# db.list_collection_names()

#####################
## SNP和cancer的关联
#####################
my_data = pd.read_csv("/home/yanyq/PleioCancer/data/GWAS", sep = "\t")
# my_data['log10P'] = abs(np.log10(my_data["pval"]))

my_data['log10P'] = abs(np.log10(my_data["pval"].clip(lower=1e-300)))
my_data["pval"] = my_data["pval"].apply(format_scientific)
my_data["beta"] = my_data["beta"].apply(format_scientific)
my_data["se"] = my_data["se"].apply(format_scientific)
my_data = my_data.drop(columns="cancer")
my_data = my_data.rename(columns={'name': 'cancer'})
my_data_json = my_data.T.to_json()
db.GWAS.drop()
table = db['GWAS']
table.insert_many(json.loads(my_data_json).values()) # 将数据导入数据表
table.create_index("cancer")
table.create_index("hg19chr")
table.create_index("snpid")
table.create_index("sig")
table.create_index([("cancer", pymongo.ASCENDING), ("hg19chr", pymongo.ASCENDING), ("bp", pymongo.ASCENDING)])
table.create_index([("snpid", pymongo.ASCENDING), ("cancer", pymongo.ASCENDING)])
table.create_index([("hg19chr", pymongo.ASCENDING), ("bp", pymongo.ASCENDING)])
db.list_collection_names()

#####################
## eQTL
#####################
my_data = pd.read_csv("/home/yanyq/PleioCancer/data/ciseQTL_filtered_by_SMRgene_and_PLACO_156", sep = "\t")
# my_data = my_data[my_data["GeneSymbol"].isin(['ZBTB48', 'PLEKHM2'])]
# my_data['log10P'] = abs(np.log10(my_data["Pvalue"]))
my_data['log10P'] = abs(np.log10(my_data["Pvalue"].clip(lower=1e-300)))
my_data["Pvalue"] = my_data["Pvalue"].apply(format_scientific)
my_data["FDR"] = my_data["FDR"].apply(format_scientific)
my_data["Zscore"] = my_data["Zscore"].apply(format_scientific)
my_data.columns
my_data = my_data[['Gene','Pvalue', 'SNP', 'SNPChr', 'SNPPos', 'AssessedAllele', 'OtherAllele','Zscore', 'GeneSymbol', 'GeneChr', 'GenePos',  'FDR',  'PLACO', 'log10P','sig']]
my_data_json = my_data.T.to_json()
db.eQTL.drop()
table = db['eQTL']
table.insert_many(json.loads(my_data_json).values()) # 将数据导入数据表
table.create_index([("SNPChr", pymongo.ASCENDING), ("SNPPos", pymongo.ASCENDING)])
table.create_index([("GeneChr", pymongo.ASCENDING), ("GenePos", pymongo.ASCENDING)])
table.create_index([("SNP", pymongo.ASCENDING), ("GeneSymbol", pymongo.ASCENDING)])
table.create_index("GeneSymbol")
table.create_index("SNP")
table.create_index("PLACO")
table.create_index("sig")
db.list_collection_names()

#####################
## meQTL
#####################
my_data = pd.read_csv("/home/yanyq/PleioCancer/data/cismeQTL_filtered_by_SMRmethy_and_PLACO", sep = "\t")
my_data['log10P'] = abs(np.log10(my_data["p"]))
my_data["Freq"] = my_data["Freq"].apply(format_scientific)
my_data["b"] = my_data["b"].apply(format_scientific)
my_data["SE"] = my_data["SE"].apply(format_scientific)
my_data["p"] = my_data["p"].apply(format_scientific)
my_data.columns
my_data = my_data[['p', 'SNP', 'Chr', 'BP', 'A1', 'A2','Freq', 'Probe', 'Probe_Chr', 'Probe_bp',  'PLACO', 'log10P','b','SE','sig']]
my_data_json = my_data.T.to_json()
db.meQTL.drop()
table = db['meQTL']
table.insert_many(json.loads(my_data_json).values()) # 将数据导入数据表
table.create_index("Probe")
table.create_index("SNP")
table.create_index("PLACO")
table.create_index("sig")
table.create_index([("SNP", pymongo.ASCENDING), ("Probe", pymongo.ASCENDING)])
db.list_collection_names()

#####################
## pQTL
#####################
my_data = pd.read_csv("/home/yanyq/PleioCancer/data/cispQTL_filtered_by_SMRprotein_and_PLACO", sep = "\t")
# my_data['log10P'] = abs(np.log10(my_data["p"]))

my_data['log10P'] = abs(np.log10(my_data["p"].clip(lower=1e-300)))

my_data["p"] = my_data["p"].apply(format_scientific)
my_data["Freq"] = my_data["Freq"].apply(format_scientific)
my_data["b"] = my_data["b"].apply(format_scientific)
my_data["SE"] = my_data["SE"].apply(format_scientific)
my_data.columns
my_data_json = my_data.T.to_json()
db.pQTL.drop()
table = db['pQTL']
table.insert_many(json.loads(my_data_json).values()) # 将数据导入数据表
table.create_index("Gene")
table.create_index("SNP")
table.create_index("PLACO")
table.create_index("sig")
table.create_index([("SNP", pymongo.ASCENDING), ("Probe", pymongo.ASCENDING)])
table.create_index([("SNP", pymongo.ASCENDING), ("Gene", pymongo.ASCENDING)])
db.list_collection_names()

#####################
## FUMA
#####################
# my_data = pd.read_csv("/home/yanyq/PleioCancer/data/fuma", sep = "\t")
# my_data["p"] = my_data["p"].apply(format_scientific)
# my_data.columns
# my_data_json = my_data.T.to_json()
# db.fuma.drop()
# table = db['fuma']
# table.insert_many(json.loads(my_data_json).values()) # 将数据导入数据表
# db.list_collection_names()