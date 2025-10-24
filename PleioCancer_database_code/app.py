from flask import Flask
from flask_cors import CORS
from db import mydb  # 从 db.py 导入 mydb

from src.routes.pleio_snp import pleio_snp_bp
from src.routes.pleio_fuma import pleio_fuma_bp
from src.routes.smr_eqtl import smr_eqtl_bp
from src.routes.smr_meqtl import smr_meqtl_bp
from src.routes.smr_pqtl import smr_pqtl_bp
from src.routes.network import network_bp
from src.routes.pleio_gene import pleio_gene_bp
from src.routes.searchregion import searchregion_bp
from src.routes.searchcancer import searchcancer_bp
from src.views import views  # 新增：导入views蓝图
import config

app = Flask(__name__)
app.debug = True
app.config.update(DEBUG=True)
app.config.from_object(config)

CORS(app, resources={r'/*': {'origins': '*'}})

# 注册API蓝图
app.register_blueprint(pleio_snp_bp, url_prefix='/api/cancerdb')
app.register_blueprint(pleio_fuma_bp, url_prefix='/api/cancerdb')
app.register_blueprint(pleio_gene_bp, url_prefix='/api/cancerdb')
app.register_blueprint(smr_eqtl_bp, url_prefix='/api/cancerdb')
app.register_blueprint(smr_meqtl_bp, url_prefix='/api/cancerdb')
app.register_blueprint(smr_pqtl_bp, url_prefix='/api/cancerdb')
app.register_blueprint(network_bp, url_prefix='/api/cancerdb')
app.register_blueprint(searchregion_bp, url_prefix='/api/cancerdb')
app.register_blueprint(searchcancer_bp, url_prefix='/api/cancerdb')

# 新增：注册前端页面蓝图（不加url_prefix，直接在根路径下）
app.register_blueprint(views)

if __name__ == '__main__':
    app.run(debug=True, use_reloader=True)