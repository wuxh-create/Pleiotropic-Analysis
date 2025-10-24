from flask import Blueprint, jsonify, request
from db import mydb  # 从 db.py 导入 mydb
import time

network_bp = Blueprint("network", __name__)

snp_cancer_db = mydb['pleiotropicSNP']
GWAS = mydb["GWAS"]
snp_gene_db = mydb['eQTL']
snp_methy_db = mydb['meQTL']
snp_protein_db = mydb['pQTL']
smr_meqtl_eqtl = mydb["SMR_meQTL_eQTL"]
smr_eqtl = mydb["SMR_eQTL"]
pleiotropicGene = mydb["pleiotropicGene"]
smr_meqtl = mydb["SMR_meQTL"]
smr_pqtl = mydb["SMR_pQTL"]

# 关系图 { "cancerType": [ "Breast", "Prostate" ], "gene": "CSK\nTLR1\nMetazoa_SRP", "protein": "CSK\nTLR1\nMetazoa_SRP", "methy": "cg20801110\ncg13055199", "snp": "rs2290574\nrs4833096\nrs1053732" }
@network_bp.route("/network", methods = ["GET", "POST"])
def network():
    # 获取前端传来的检索条件
    filterForm = request.get_json()
    # cancer:this.cancerType, gene: this.textarea_gene, methy: this.textarea_methy,snp:this.textarea_SNP
    # 前端输入的例子
    # filterForm = { "cancerType": [ "Breast", "Prostate" ], "gene": "CSK\nTLR1\nMetazoa_SRP", "protein": "CSK\nTLR1\nMetazoa_SRP", "methy": "cg20801110\ncg13055199\ncg13560058", "snp": "rs2290574\nrs4833096\nrs3184504" }    
    cancer = filterForm["cancer"]
    gene = filterForm["gene"]
    methy =  filterForm["methy"]
    snp = filterForm["snp"]

    gene = gene.split("\n") if gene else []
    methy = methy.split("\n") if methy else []
    snp = snp.split("\n") if snp else []

    # 判断是否全为空
    # 判断是否全为空
    if not (gene or methy or snp or cancer):
        return "input null"

    start = time.time()
    node_snp = set(snp)
    node_methy = set(methy)
    node_gene = set(gene)
    node_protein = set(gene)
    node_cancer = set(cancer)

    snp_cancer_pleio = []
    gene_cancer_pleio = []
    snp_gene = []
    snp_methy = []
    snp_protein = []
    methy_gene = []
    gene_cancer = []
    protein_cancer = []
    methy_cancer = []
    snp_cancer_gwas = []

    if snp:
        snp_cancer_pleio = list(snp_cancer_db.find({"snpid":{"$in": snp}},{"_id":0}))
        snp_cancer_gwas = list(GWAS.find({"snpid":{"$in": snp}, "sig": "Yes"},{"_id":0}))
        snp_gene = list(snp_gene_db.find({"SNP":{"$in": snp}, "sig": "Yes"},{"_id":0})) # eQTL存的是smr和placo显著基因的结果，不需要做PLACO筛选        
        snp_methy = list(snp_methy_db.find({"SNP":{"$in": snp}, "sig": "Yes"},{"_id":0}))
        snp_protein = list(snp_protein_db.find({"SNP":{"$in": snp}, "sig": "Yes"},{"_id":0}))
        for record in snp_cancer_pleio:
            node_cancer.add(record['cancer1'])
            node_cancer.add(record['cancer2'])
        for record in snp_cancer_gwas:
            node_cancer.add(record['cancer'])
        for record in snp_gene:
            node_gene.add(record['GeneSymbol'])
        for record in snp_methy:
            node_methy.add(record['Probe'])
        for record in snp_protein:
            node_protein.add(record['Gene'])

    print("snp"+ str(time.time() - start))
    if gene:
        snp_gene = list(snp_gene_db.find({"GeneSymbol":{"$in": gene}, "sig": "Yes"},{"_id":0}))
        methy_gene = list(smr_meqtl_eqtl.find({"symbol": {"$in": gene}},{"_id": 0}))
        gene_cancer = list(smr_eqtl.find({"symbol": {"$in": gene},"sig": "Yes"},{"_id": 0}))
        gene_cancer_pleio = list(pleiotropicGene.find({"SYMBOL": {"$in": gene}},{"_id": 0}))
        protein_cancer = list(smr_pqtl.find({"Gene": {"$in": gene},"sig": "Yes"},{"_id": 0}))

        for record in snp_gene:
            node_snp.add(record['SNP'])
        for record in methy_gene:
            node_methy.add(record['Expo_ID'])
        for record in gene_cancer:
            node_cancer.add(record['cancer'])
        for record in gene_cancer_pleio:
            node_cancer.add(record['cancer1'])
            node_cancer.add(record['cancer2'])
        for record in protein_cancer:
            node_cancer.add(record['cancer'])
    print("gene"+ str(time.time() - start))
 
    if methy:
        snp_methy = list(snp_methy_db.find({"Probe":{"$in": methy}, "sig": "Yes"},{"_id":0}))
        methy_gene = list(smr_meqtl_eqtl.find({"Expo_ID": {"$in": methy}},{"_id": 0}))
        methy_cancer = list(smr_meqtl.find({"probeID": {"$in": methy},"sig": "Yes"},{"_id": 0}))

        for record in snp_methy:
            node_snp.add(record['SNP'])
        for record in methy_gene:
            node_gene.add(record['symbol'])
        for record in methy_cancer:
            node_cancer.add(record['cancer'])
    print("methy"+ str(time.time() - start))
   
    if cancer:
        snp_cancer_pleio = list(snp_cancer_db.find(
            {"$or": [{"cancer1": {"$in": cancer}}, {"cancer2": {"$in": cancer}}]},
            {"_id": 0}
        ))
        snp_cancer_gwas = list(GWAS.find({"cancer":{"$in": cancer}, "sig": "Yes"},{"_id":0}))
        gene_cancer = list(smr_eqtl.find({"cancer": {"$in": cancer},"sig": "Yes"},{"_id": 0}))
        gene_cancer_pleio = list(pleiotropicGene.find(
            {"$or": [{"cancer1": {"$in": cancer}}, {"cancer2": {"$in": cancer}}]},
            {"_id": 0}
        ))
        protein_cancer = list(smr_pqtl.find({"cancer": {"$in": cancer},"sig": "Yes"},{"_id": 0}))
        methy_cancer = list(smr_meqtl.find({"cancer": {"$in": cancer},"sig": "Yes"},{"_id": 0}))

        for record in snp_cancer_pleio:
            node_snp.add(record['snpid'])
        for record in snp_cancer_gwas:
            node_snp.add(record['snpid'])
        for record in gene_cancer_pleio:
            node_gene.add(record['SYMBOL'])
        for record in gene_cancer:
            node_gene.add(record['symbol'])
        for record in methy_cancer:
            node_methy.add(record['probeID'])
        for record in protein_cancer:
            node_protein.add(record['Gene'])
    print("cancer"+ str(time.time() - start))

    snp = list(node_snp)
    methy = list(node_methy)
    gene = list(node_gene)
    protein = list(node_protein)
    cancer = list(node_cancer)

    if len(methy) > 0 and len(snp)>0:
        snp_methy = list(snp_methy_db.find({"SNP":{"$in": snp},"Probe": {"$in": methy}, "sig": "Yes"},{"_id":0}))
    print("snp-methy"+ str(time.time() - start))
    if len(gene) > 0 and len(snp)>0:
        snp_gene = list(snp_gene_db.find({"SNP":{"$in": snp},"GeneSymbol":{"$in": gene}, "sig": "Yes"},{"_id":0})) 
    print("snp-gene"+ str(time.time() - start))
    if len(protein) > 0 and len(snp)>0:
        snp_protein = list(snp_protein_db.find({"SNP":{"$in": snp},"Gene": {"$in": protein}, "sig": "Yes"},{"_id":0}))
    print("snp-protein"+ str(time.time() - start))
    if len(cancer)>0 and len(snp)>0:
        snp_cancer_pleio = list(snp_cancer_db.find({"snpid":{"$in": snp},
                                                    "$or": [{"cancer1": {"$in": cancer}}, {"cancer2": {"$in": cancer}}]},
                                                   {"_id": 0}))
        snp_cancer_gwas = list(GWAS.find({"snpid":{"$in": snp},"cancer": {"$in": cancer},"sig":"Yes"},{"_id":0}))
    print("snp-cancer"+ str(time.time() - start))
    if len(cancer)>0 and len(gene)>0:
        gene_cancer = list(smr_eqtl.find({"symbol": {"$in": gene}, "cancer": {"$in": cancer}, "sig": "Yes"},{"_id": 0}))
    print("gene-cancer"+ str(time.time() - start))
    if len(cancer)>0 and len(protein)>0:
        protein_cancer = list(smr_pqtl.find({"Gene": {"$in": protein}, "cancer": {"$in": cancer}, "sig": "Yes"},{"_id": 0}))
    print("protein-cancer"+ str(time.time() - start))
    if len(cancer)>0 and len(methy)>0:
        methy_cancer = list(smr_meqtl.find({"probeID": {"$in": methy}, "cancer": {"$in": cancer}, "sig": "Yes"},{"_id": 0}))            
    print("methy-cancer"+ str(time.time() - start))
    if len(methy) > 0 and len(gene)>0:
        methy_gene = list(smr_meqtl_eqtl.find({"Expo_ID": {"$in": methy}, "symbol": {"$in": gene}, "sig": "Yes"},{"_id": 0}))
    print("gene-methy"+ str(time.time() - start))
    return {"pleioSNP":snp_cancer_pleio, "pleioGene":gene_cancer_pleio, "eQTL":snp_gene, "meQTL":snp_methy, "pQTL":snp_protein, 
            "smr_meQTL_eQTL":methy_gene, "smr_eQTL":gene_cancer, "smr_pQTL":protein_cancer,"GWAS":snp_cancer_gwas, "smr_meQTL":methy_cancer}
