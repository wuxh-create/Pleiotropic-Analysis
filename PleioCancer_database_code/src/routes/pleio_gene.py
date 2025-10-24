from flask import Blueprint, jsonify, request
from db import mydb  # 从 db.py 导入 mydb
import time

pleio_gene_bp = Blueprint("pleio_gene", __name__)
eQTL = mydb["eQTL"]
pQTL = mydb["pQTL"]
smr_eqtl = mydb["SMR_eQTL"]
smr_pqtl = mydb["SMR_pQTL"]
smr_meqtl_eqtl = mydb["SMR_meQTL_eQTL"]
pleiotropicGene = mydb["pleiotropicGene"]
GWAS = mydb["GWAS"]

@pleio_gene_bp.route("/pleio_gene", methods=["GET", "POST"])
def pleio_gene():
    listx = []
    if request.is_json:
        # 获取前端传来的检索条件
        filterForm = request.get_json()
        cancer = filterForm["cancerType"]
        print(cancer)
        if(len(cancer)>=1):
            cancer.sort()
        gene = filterForm["searchGenes"]
        region = filterForm["searchRegion"]

        # 检查输入框数据的格式，判断是否合法：以rs开头或者chr:100-200
        region = region.replace("-",":").split(":") # 1:100-200，转为[1,100,200]
        if filterForm["searchRegion"] and (len(region)!=3 or ('' in region) or int(region[1])>int(region[2])):
            return "errorID"
        else:
            query = {}

            if len(cancer) == 1:
                # 单个值时，匹配 cancer1 或 cancer2
                query = {
                    "$or": [
                        {"cancer1": cancer[0]},
                        {"cancer2": cancer[0]}
                    ]
                }
            if len(cancer) > 1:
                # 多个值时，生成所有组合，确保 cancer1 < cancer2
                combinations = []
                for i in range(len(cancer)):
                    for j in range(i + 1, len(cancer)):
                        combinations.append({
                            "cancer1": cancer[i],
                            "cancer2": cancer[j]
                        })

                query = {"$or": combinations}
            
            if gene:
                query['SYMBOL'] = gene

            if len(region)==3:
                region = [ int(x) for x in region ]
                region_query = {
                    "CHR": region[0],
                    "$or": [
                        {
                            "START": {"$lte": region[2]},
                            "STOP": {"$gte": region[1]}
                        }
                    ]
                }
                query.update(region_query)

            # 如果没有任何参数，则查询所有记录
            if not query:
                query = {}  # 查询所有记录
            
            for x in pleiotropicGene.find(query, {"_id": 0}):
                listx.append(x)

    if request.method == "GET":
        gene = request.args.get("searchGene")
        if gene:
            listx_pleioGene = []
            listx_eQTL = []
            listx_smr_eQTL = []            
            listx_smr_pQTL = []
            listx_smr_meQTL_eqtl = []
            listx_pQTL = []
            listx_pleioGene = list(pleiotropicGene.find({"SYMBOL": gene,},{"_id": 0}))
            # listx_eQTL = list(eQTL.find({"GeneSymbol": gene,"PLACO":True}, {"_id": 0}))
            # listx_pQTL = list(pQTL.find({"Gene": gene,"PLACO":True},{"_id": 0}))
            listx_eQTL = list(eQTL.find({"GeneSymbol": gene,}, {"_id": 0}))
            listx_pQTL = list(pQTL.find({"Gene": gene,},{"_id": 0}))

            listx_smr_eQTL = list(smr_eqtl.find({"symbol": gene,"sig": "Yes"},{"_id": 0}))
            listx_smr_pQTL = list(smr_pqtl.find({"Gene": gene,"sig": "Yes"},{"_id": 0}))
            listx_smr_meQTL_eqtl = list(smr_meqtl_eqtl.find({"symbol": gene},{"_id": 0}))
            if len(listx_pleioGene)>0 or len(listx_smr_eQTL)>0 or len(listx_smr_pQTL)>0:
                return {"pleioGene":listx_pleioGene, "eQTL":listx_eQTL,"pQTL":listx_pQTL , "smr_eQTL":listx_smr_eQTL, "smr_pQTL":listx_smr_pQTL,"smr_meQTL_eQTL":listx_smr_meQTL_eqtl}
            else:
                return {"pleioGene":[], "eQTL":[], "smr_eQTL":[],"smr_meQTL_eQTL":[]}
        else:
            listx = list(pleiotropicGene.find({},{"_id": 0}))
    return jsonify(listx)

@pleio_gene_bp.route("/pleio_gene_fig", methods=["POST"])
def pleio_gene_fig():
    if request.is_json:
        data_frontEnd = request.get_json()
        snp_chr = data_frontEnd["chr"]
        snp_start = data_frontEnd["start"]
        snp_end = data_frontEnd["stop"]
        cancer1 = data_frontEnd["cancer1"]
        cancer2 = data_frontEnd["cancer2"]

        start_time = time.time()
        GWAS_result_cancer1 = list(GWAS.find(
            {"cancer": cancer1, "hg19chr": snp_chr, "bp": {"$gte": snp_start, "$lte": snp_end}},
            {"_id": 0}
        ))
        GWAS_result_cancer1_notsig = [x for x in GWAS_result_cancer1 if float(x['pval']) >= 5e-8]
        GWAS_result_cancer1_sig = [x for x in GWAS_result_cancer1 if float(x['pval']) < 5e-8]

        GWAS_result_cancer2 = list(GWAS.find(
            {"cancer": cancer2, "hg19chr": snp_chr, "bp": {"$gte": snp_start, "$lte": snp_end}},
            {"_id": 0}
        ))
        GWAS_result_cancer2_notsig = [x for x in GWAS_result_cancer2 if float(x['pval']) >= 5e-8]
        GWAS_result_cancer2_sig = [x for x in GWAS_result_cancer2 if float(x['pval']) < 5e-8]

        # 创建一个字典来将 SNP 和 snpid 关联起来
        snpid_dict = {entry['snpid']: entry for entry in GWAS_result_cancer2}

        
        # 反向互补碱基映射
        flip_dict = {"A": "T", "T": "A", "G": "C", "C": "G"}
        # 定义匹配和反向匹配逻辑
        def is_match(a1, a2, b1, b2, freq_diff=0):
            return ((a1, a2) == (b1, b2) or (b1, b2) == (flip_dict[a1], flip_dict[a2])) and abs(freq_diff) < 0.2

        def is_reverse_match(a1, a2, b1, b2, freq_diff=0):
            return ((a1, a2) == (b2, b1) or (b1, b2) == (flip_dict[a2], flip_dict[a1])) and abs(freq_diff) > 0.2

        # 合并数据
        merged_results = []

        for gwas1 in GWAS_result_cancer1:
            snp = gwas1['snpid']
            if snp not in snpid_dict:
                continue

            gwas2 = snpid_dict[snp]
            
            gwas1_zscore = float(gwas1['beta'])/float(gwas1['se'])
            gwas2_zscore = float(gwas2['beta'])/float(gwas2['se'])

            match = is_match(gwas2['a1'], gwas2['a2'], gwas1['a1'], gwas1['a2'])
            reverse_match = is_reverse_match(gwas2['a1'], gwas2['a2'], gwas1['a1'], gwas1['a2'])

            if match or reverse_match:
                flip = reverse_match
                merged_entry = {
                    'SNP': gwas1['snpid'],
                    'Chr': gwas1["hg19chr"],
                    'BP': gwas1['bp'],
                    'A1': gwas1['a1'],
                    'A2': gwas1['a2'],
                    'gwas1_EAF': gwas1['EURaf'],
                    'gwas1_beta': gwas1['beta'],
                    'gwas1_se': gwas1['se'],
                    'gwas1_zscore': gwas1_zscore,
                    'gwas1_p': gwas1['pval'],
                    'gwas2_EAF': 1 - float(gwas2['EURaf']) if flip else float(gwas2['EURaf']),
                    'gwas2_beta': -float(gwas2['beta']) if flip else float(gwas2['beta']),
                    'gwas2_se': gwas2['se'],
                    'gwas2_zscore': -gwas2_zscore if flip else gwas2_zscore,
                    'gwas2_p': gwas2['pval']
                }
                merged_results.append(merged_entry)
        print(time.time()-start_time)


        return jsonify({"GWAS1_result_sig": GWAS_result_cancer1_sig, "GWAS1_result_notsig": GWAS_result_cancer1_notsig, 
                        "GWAS2_result_sig": GWAS_result_cancer2_sig, "GWAS2_result_notsig": GWAS_result_cancer2_notsig, 
                        "merged_result":merged_results})

