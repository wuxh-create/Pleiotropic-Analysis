from flask import Blueprint, jsonify, request
from db import mydb  # 从 db.py 导入 mydb
import time

pleio_fuma_bp = Blueprint("pleio_fuma", __name__)

pleiotropicSNP = mydb['pleiotropicSNP']
fuma = mydb["fuma"]
eQTL = mydb['eQTL']
meQTL = mydb['meQTL']
pQTL = mydb['pQTL']
GWAS = mydb["GWAS"]
pleio1MB = mydb["pleio1MB"]

@pleio_fuma_bp.route("/pleio_fuma", methods=["GET", "POST"])
def pleio_fuma():
    listx = []
    if request.is_json:
        # 获取前端传来的检索条件
        filterForm = request.get_json()
        print(filterForm)
        cancer = filterForm["cancerType"]
        if(len(cancer)>=1):
            cancer.sort()
        SNP = filterForm["searchSNPs"]
        region = filterForm["searchRegion"]

        # 检查输入框数据的格式，判断是否合法：以rs开头或者chr:100-200
        if (not SNP.startswith("rs")) and SNP:
            region = SNP
        region = region.replace("-",":").split(":") # 1:100-200，转为[1,100,200]
        print(region)
        if SNP=="" or SNP.startswith("rs") or (len(region)==3 and all(region) and int(region[1])<=int(region[2])) or (len(region)==2 and all(region)):
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
            
            if SNP.startswith("rs"):
                query['snpid'] = {"$regex": SNP}

            if len(region)==3:
                region = [ int(x) for x in region ]
                query['hg19chr'] = region[0]
                query['bp'] = {'$gte': region[1], '$lte': region[2]}

            if len(region)==2:
                region = [ int(x) for x in region ]
                query['hg19chr'] = region[0]
                query['bp'] = region[1]

            
            # 如果没有任何参数，则查询所有记录
            if not query:
                query = {}  # 查询所有记录
            
            for x in pleiotropicSNP.find(query, {"_id": 0}):
                listx.append(x)
        else:
            return "errorID"
    elif request.method == "GET":
        SNP = request.args.get("searchSNPs")
        if SNP:
            listx_pleioSNP = []
            listx_eQTL = []
            listx_meQTL = []
            listx_pQTL = []
            listx_pleioSNP = list(pleiotropicSNP.find({"snpid":SNP},{"_id": 0}))
            # if(len(listx_pleioSNP)>0):
            #     listx_eQTL = list(eQTL.find({"SNP": SNP,"PLACO":True},{"_id": 0}))
            #     listx_meQTL = list(meQTL.find({"SNP": SNP,"PLACO":True},{"_id": 0}))
            #     listx_pQTL = list(pQTL.find({"SNP": SNP,"PLACO":True},{"_id": 0}))
          
            listx_eQTL = list(eQTL.find({"SNP": SNP},{"_id": 0}))
            listx_meQTL = list(meQTL.find({"SNP": SNP},{"_id": 0}))
            listx_pQTL = list(pQTL.find({"SNP": SNP},{"_id": 0}))
            return {"pleioSNP":listx_pleioSNP,"eQTL":listx_eQTL,"meQTL":listx_meQTL,"pQTL":listx_pQTL}
        else:
            for x in fuma.find({},{"_id": 0}):
                listx.append(x)
    return jsonify(listx)

@pleio_fuma_bp.route("/pleio_fuma_fig", methods=["GET", "POST"])
def pleio_fuma_fig():
    if request.is_json:
        data_frontEnd = request.get_json()
        snp_chr = data_frontEnd["chr"]
        snp_start = data_frontEnd["pos"] - 1000000
        snp_end = data_frontEnd["pos"] + 1000000
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
        print(time.time()-start_time)
        snpids_cancer1 = {entry['snpid'] for entry in GWAS_result_cancer1}
        snpids_cancer2 = {entry['snpid'] for entry in GWAS_result_cancer2}
        # 找到交集
        common_snpids = list(snpids_cancer1.intersection(snpids_cancer2))

        # Step 2: 在pleioMB集合中查找这些snpid
        pleio_result = list(pleio1MB.find(
            {"snpid": {"$in": common_snpids},"cancer1": cancer1, "cancer2": cancer2},
            {"_id": 0}
        ))
        print(time.time()-start_time)


        # 创建一个字典来将 SNP 和 snpid 关联起来
        snpid_dict = {entry['snpid']: entry for entry in GWAS_result_cancer2}
        snpid_dict_pleio = {entry['snpid']: entry for entry in pleio_result}
        
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

            if snp in snpid_dict_pleio:
                cur_pleio = snpid_dict_pleio[snp]
            else:
                cur_pleio = {'p.placo':None, 'log10P':None}
            
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
                    'gwas2_p': gwas2['pval'],
                    'placo_p': cur_pleio['p.placo'],
                    'placo_log10P': cur_pleio['log10P']
                }
                merged_results.append(merged_entry)
        print(time.time()-start_time)

        placo_result_notsig = [
            x for x in merged_results if x['placo_p'] is not None and float(x['placo_p']) >= 5e-8
        ]
        placo_result_sig = [
            x for x in merged_results if x['placo_p'] is not None and float(x['placo_p']) < 5e-8
        ]

        return jsonify({"GWAS1_result_sig": GWAS_result_cancer1_sig, "GWAS1_result_notsig": GWAS_result_cancer1_notsig, 
                        "GWAS2_result_sig": GWAS_result_cancer2_sig, "GWAS2_result_notsig": GWAS_result_cancer2_notsig, 
                        "placo_result_sig":placo_result_sig, "placo_result_notsig":placo_result_notsig, 
                        "merged_result":merged_results})
