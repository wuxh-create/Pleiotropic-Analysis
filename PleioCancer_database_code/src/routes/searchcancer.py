from flask import Blueprint, jsonify, request
from db import mydb  # 从 db.py 导入 mydb
import time

searchcancer_bp = Blueprint("searchcancer", __name__)

snp_cancer_db = mydb['pleiotropicSNP']
pleiotropicGene = mydb["pleiotropicGene"]
GWAS = mydb["GWAS"]
snp_gene_db = mydb['eQTL']
snp_methy_db = mydb['meQTL']
snp_protein_db = mydb['pQTL']
smr_meqtl_eqtl = mydb["SMR_meQTL_eQTL"]
smr_eqtl = mydb["SMR_eQTL"]

smr_meqtl = mydb["SMR_meQTL"]
smr_pqtl = mydb["SMR_pQTL"]

# 关系图 { "cancerType": [ "Breast", "Prostate" ], "gene": "CSK\nTLR1\nMetazoa_SRP", "protein": "CSK\nTLR1\nMetazoa_SRP", "methy": "cg20801110\ncg13055199", "snp": "rs2290574\nrs4833096\nrs1053732" }
@searchcancer_bp.route("/search_cancer", methods = ["GET"])
def search_cancer():
    snp_cancer_pleio = []
    gene_cancer_pleio = []
    gene_cancer = []
    protein_cancer = []
    methy_cancer = []
    if request.method == "GET":
        cancer = request.args.get("searchCancer")
        if cancer:
            snp_cancer_pleio = list(snp_cancer_db.find({"$or": [{"cancer1": cancer}, {"cancer2": cancer}]},{"_id":0}))
            gene_cancer_pleio = list(pleiotropicGene.find({"$or": [{"cancer1": cancer}, {"cancer2": cancer}]},{"_id":0}))
            gene_cancer = list(smr_eqtl.find({"cancer": cancer, "sig":"Yes"},{"_id":0}))
            protein_cancer = list(smr_pqtl.find({"cancer": cancer, "sig":"Yes"},{"_id":0}))
            methy_cancer = list(smr_meqtl.find({"cancer": cancer, "sig":"Yes"},{"_id":0}))

    return {"pleioSNP":snp_cancer_pleio, "pleioGene":gene_cancer_pleio,  
            "smr_eQTL":gene_cancer, "smr_pQTL":protein_cancer,"smr_meQTL":methy_cancer}
