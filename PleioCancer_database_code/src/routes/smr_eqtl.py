from flask import Blueprint, jsonify, request
from db import mydb  # 从 db.py 导入 mydb

smr_eqtl_bp = Blueprint("smr_eqtl", __name__)

SMR_eQTL = mydb["SMR_eQTL"]
eQTL = mydb["eQTL"]
GWAS = mydb["GWAS"]

@smr_eqtl_bp.route("/SMR_eQTL", methods=["GET", "POST"])
def smr_eQTL():
    listx = []
    if request.is_json:
        filterForm = request.get_json()
        cancerType = filterForm['cancerType']
        searchRegion = filterForm['searchRegion']
        searchGene = filterForm['searchGene']

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
            
            if searchGene:  # 如果基因参数不为空
                query['symbol'] = searchGene

            # 如果没有任何参数，则查询所有记录
            if not query:
                query = {}  # 查询所有记录
            
            query['sig'] = "Yes"
            # 执行MongoDB查询
            for x in SMR_eQTL.find(query, {"_id": 0}):
                listx.append(x)
        else:
            return "errorID"

    else:
        for x in SMR_eQTL.find({"sig": "Yes"}, {"_id": 0}):
            listx.append(x)
    return jsonify(listx)

@smr_eqtl_bp.route("/SMR_eQTL_fig", methods=["GET", "POST"])
def smr_eQTL_fig():
    if request.is_json:
        data_frontEnd = request.get_json()
        gene = data_frontEnd["gene"]
        cancer = data_frontEnd["cancer"]

        eQTL_result = list(eQTL.find({"GeneSymbol": gene}, {"_id": 0}))
        eQTL_result_notsig = [x for x in eQTL_result if float(x['Pvalue']) >= 5e-8]
        eQTL_result_sig = [x for x in eQTL_result if float(x['Pvalue']) < 5e-8]

        gene_start = eQTL_result[1]["GenePos"] - 1000000
        gene_end = eQTL_result[1]["GenePos"] + 1000000
        GWAS_result = list(GWAS.find(
            {"cancer": cancer, "hg19chr": eQTL_result[1]["GeneChr"], "bp": {"$gte": gene_start, "$lte": gene_end}},
            {"_id": 0}
        ))
        GWAS_result_notsig = [x for x in GWAS_result if float(x['pval']) >= 5e-8]
        GWAS_result_sig = [x for x in GWAS_result if float(x['pval']) < 5e-8]

        SMR_result = list(SMR_eQTL.find(
            {"cancer": cancer, "ProbeChr": eQTL_result[1]["GeneChr"], "Probe_bp": {"$gte": gene_start, "$lte": gene_end}},
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

        for qtl in eQTL_result:
            snp = qtl['SNP']
            if snp not in snpid_dict:
                continue

            gwas = snpid_dict[snp]
            # 检查 gwas['se'] 是否为 0，避免除以零
            if float(gwas['se']) == 0:
                continue
            gwas_zscore = float(gwas['beta'])/float(gwas['se'])
            qtl_zscore = float(qtl['Zscore'])

            match = is_match(gwas['a1'], gwas['a2'], qtl['AssessedAllele'], qtl['OtherAllele'])
            reverse_match = is_reverse_match(gwas['a1'], gwas['a2'], qtl['AssessedAllele'], qtl['OtherAllele'])

            if match or reverse_match:
                flip = reverse_match
                merged_entry = {
                    'SNP': qtl['SNP'],
                    'Chr': qtl["SNPChr"],
                    'BP': qtl['SNPPos'],
                    'A1': qtl['AssessedAllele'],
                    'A2': qtl['OtherAllele'],
                    'qtl_zscore': qtl_zscore,
                    'qtl_p': qtl['Pvalue'],
                    'gwas_EAF': 1 - float(gwas['EURaf']) if flip else float(gwas['EURaf']),
                    'gwas_zscore': -gwas_zscore if flip else gwas_zscore,
                    'gwas_p': gwas['pval']
                }
                merged_results.append(merged_entry)

        return jsonify({"eQTL_result_sig": eQTL_result_sig, "eQTL_result_notsig": eQTL_result_notsig, 
                        "GWAS_result_sig": GWAS_result_sig, "GWAS_result_notsig": GWAS_result_notsig, 
                        "SMR_result_sig":SMR_result_sig, "SMR_result_notsig":SMR_result_notsig, 
                        "merged_result":merged_results,
                        "gene_start": gene_start,
                        "gene_end": gene_end})
