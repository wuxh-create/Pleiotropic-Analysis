from flask import Blueprint, jsonify, request
from db import mydb  # 从 db.py 导入 mydb
import time

searchregion_bp = Blueprint("searchregion", __name__)

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
@searchregion_bp.route("/search_region", methods = ["GET"])
def search_region():
    snp_cancer_pleio = []
    gene_cancer_pleio = []
    gene_cancer = []
    protein_cancer = []
    methy_cancer = []
    if request.method == "GET":
        region = request.args.get("searchRegion")
        if region:
            region = region.replace("-",":").split(":")
            region = [ int(x) for x in region ]

            snp_cancer_pleio = list(snp_cancer_db.find({"hg19chr":region[0], "bp":{'$gte': region[1], '$lte': region[2]}},{"_id":0}))
            gene_cancer_pleio = list(pleiotropicGene.find({"CHR": region[0], "START":{'$gte': region[1]},"STOP":{'$lte': region[2]}},{"_id":0}))
            gene_cancer = list(smr_eqtl.find({"ProbeChr": region[0], "Probe_bp": {"$gte": region[1], "$lte": region[2]},"sig":"Yes"},{"_id":0}))
            protein_cancer = list(smr_pqtl.find({"ProbeChr": region[0], "Probe_bp": {"$gte": region[1], "$lte": region[2]},"sig":"Yes"},{"_id":0}))
            methy_cancer = list(smr_meqtl.find({"ProbeChr": region[0], "Probe_bp": {"$gte": region[1], "$lte": region[2]},"sig":"Yes"},{"_id":0}))

    return {"pleioSNP":snp_cancer_pleio, "pleioGene":gene_cancer_pleio,  
            "smr_eQTL":gene_cancer, "smr_pQTL":protein_cancer,"smr_meQTL":methy_cancer}
