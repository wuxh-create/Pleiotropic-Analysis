from flask import Blueprint, jsonify, request
from db import mydb

smr_pqtl_bp = Blueprint("smr_pqtl", __name__)

SMR_pQTL = mydb["SMR_pQTL"]
pQTL = mydb["pQTL"]
GWAS = mydb["GWAS"]

@smr_pqtl_bp.route("/SMR_pQTL", methods=["GET", "POST"])
def smr_pQTL():
    listx = []
    if request.is_json:
        filterForm = request.get_json()
        cancerType = filterForm['cancerType']
        searchRegion = filterForm['searchRegion']
        searchProtein = filterForm['searchProtein']

        # 检查输入框数据的格式，判断是否合法：chr:100-200
        searchRegion = searchRegion.replace("-",":").split(":") # 将1:100-200，转为[1,100,200]

        if filterForm['searchRegion']=="" or (len(searchRegion)==3 and all(searchRegion) and int(searchRegion[1])<int(searchRegion[2])):
            # 构建查询条件字典
            query = {}
            
            if len(cancerType)!=0:  # 如果癌症类型参数不为空
                query['cancer'] = {'$in': cancerType}
            
            if len(searchRegion)==3:
                chr_number = int(searchRegion[0])  # 获取染色体号
                start_position = int(searchRegion[1])  # 获取起始位置
                end_position = int(searchRegion[2])  # 获取结束位置
                
                # 构建基于染色体和位置范围的查询条件
                query['ProbeChr'] = chr_number
                query['Probe_bp'] = {'$gte': start_position, '$lte': end_position}
            
            if searchProtein:  # 如果基因参数不为空
                query['Gene'] = searchProtein

            # 如果没有任何参数，则查询所有记录
            if not query:
                query = {}  # 查询所有记录
            
            query['sig'] = "Yes"

            # 执行MongoDB查询
            for x in SMR_pQTL.find(query, {"_id": 0}):
                listx.append(x)
    
        else:
            return "errorID"
    else:
        for x in SMR_pQTL.find({"sig":"Yes"}, {"_id": 0}):
            listx.append(x)
    return jsonify(listx)

@smr_pqtl_bp.route("/SMR_pQTL_fig", methods=["GET", "POST"])
def smr_pQTL_fig():
    if request.is_json:
        data_frontEnd = request.get_json()
        protein = data_frontEnd["protein"]
        cancer = data_frontEnd["cancer"]

        pQTL_result = list(pQTL.find({"Probe": protein}, {"_id": 0}))
        pQTL_result_notsig = [x for x in pQTL_result if float(x['p']) >= 5e-8]
        pQTL_result_sig = [x for x in pQTL_result if float(x['p']) < 5e-8]
   
        protein_start = pQTL_result[1]["Probe_bp"] - 1000000
        protein_end = pQTL_result[1]["Probe_bp"] + 1000000
        GWAS_result = list(GWAS.find(
            {"cancer": cancer, "hg19chr": pQTL_result[1]["Probe_Chr"], "bp": {"$gte": protein_start, "$lte": protein_end}},
            {"_id": 0}
        ))
        GWAS_result_notsig = [x for x in GWAS_result if float(x['pval']) >= 5e-8]
        GWAS_result_sig = [x for x in GWAS_result if float(x['pval']) < 5e-8]

        SMR_result = list(SMR_pQTL.find(
            {"cancer": cancer, "ProbeChr": pQTL_result[1]["Probe_Chr"], "Probe_bp": {"$gte": protein_start, "$lte": protein_end}},
            {"_id": 0}
        ))
        SMR_result_notsig = [x for x in SMR_result if x['sig'] == "No"]
        SMR_result_sig = [x for x in SMR_result if x['sig'] == "Yes"]


        # 创建一个字典来将 SNP 和 snpid 关联起来
        snpid_dict = {entry['snpid']: entry for entry in GWAS_result}

        # 定义反向互补碱基对的集合
        complementary_pairs = {("A", "T"), ("T", "A"), ("C", "G"), ("G", "C")}
        # 反向互补碱基映射
        flip_dict = {"A": "T", "T": "A", "G": "C", "C": "G"}
        # 定义匹配和反向匹配逻辑
        def is_match(a1, a2, b1, b2, freq_diff=0):
            return ((a1, a2) == (b1, b2) or (b1, b2) == (flip_dict[a1], flip_dict[a2])) and abs(freq_diff) < 0.2

        def is_reverse_match(a1, a2, b1, b2, freq_diff=0):
            return ((a1, a2) == (b2, b1) or (b1, b2) == (flip_dict[a2], flip_dict[a1])) and abs(freq_diff) > 0.2

        # 合并数据
        merged_results = []

        for qtl in pQTL_result:
            snp = qtl['SNP']
            if snp not in snpid_dict:
                continue

            gwas = snpid_dict[snp]
            # 检查 gwas['se'] 是否为 0，避免除以零
            if float(gwas['se']) == 0:
                continue
            gwas_zscore = float(gwas['beta'])/float(gwas['se'])
            qtl_zscore = float(qtl['b'])/float(qtl['SE'])

            freq_diff = float(qtl['Freq']) - float(gwas['EURaf'])

            match = is_match(gwas['a1'], gwas['a2'], qtl['A1'], qtl['A2'], freq_diff)
            reverse_match = is_reverse_match(gwas['a1'], gwas['a2'], qtl['A1'], qtl['A2'], freq_diff)

            if match or reverse_match:
                flip = reverse_match
                merged_entry = {
                    'SNP': qtl['SNP'],
                    'Chr': qtl["Chr"],
                    'BP': qtl['BP'],
                    'A1': qtl['A1'],
                    'A2': qtl['A2'],
                    'qtl_EAF': qtl['Freq'],
                    'qtl_b': qtl['b'],
                    'qtl_se': qtl['SE'],
                    'qtl_p': qtl['p'],
                    'qtl_zscore': qtl_zscore,
                    'gwas_EAF': 1 - float(gwas['EURaf']) if flip else float(gwas['EURaf']),
                    'gwas_b': -float(gwas['beta']) if flip else float(gwas['beta']),
                    'gwas_se': gwas['se'],
                    'gwas_p': gwas['pval'],
                    'gwas_zscore': -gwas_zscore if flip else gwas_zscore
                }
                merged_results.append(merged_entry)
                
        return jsonify({"pQTL_result_sig": pQTL_result_sig, "pQTL_result_notsig": pQTL_result_notsig, 
                        "GWAS_result_sig": GWAS_result_sig, "GWAS_result_notsig": GWAS_result_notsig, 
                        "SMR_result_sig":SMR_result_sig, "SMR_result_notsig":SMR_result_notsig, 
                        "merged_result":merged_results,
                        "protein_start": protein_start,
                        "protein_end": protein_end})