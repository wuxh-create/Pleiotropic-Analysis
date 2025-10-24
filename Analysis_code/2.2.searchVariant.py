# litvar检索PLACO显著的SNP

import json
import pandas as pd
import requests
import bs4
from bs4 import BeautifulSoup
import os
headers = { # 开发者工具 → network → request header → user-agent
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36 Edg/116.0.1938.62"
} # 把爬虫伪装成正常浏览器

traits = ["BLCA","BRCA",	"HNSC",	"kidney",	"lung",	"OV",	'PAAD',	"PRAD",	'SKCM',	"UCEC"]
for trait1 in traits:
    for trait2 in traits:
        file_path = "/home/yanyq/share_genetics/result/PLACO/sig_"+trait1+"-"+trait2
        if os.path.exists(file_path):
            sig_PLACO = pd.read_table(file_path, sep = "\t")
            variants = sig_PLACO['snpid']
            df = pd.DataFrame(columns=["pmids","pmcids","pmids_count"])
            for i in variants:
                try:
                    response = requests.get("https://www.ncbi.nlm.nih.gov/research/litvar2-api/variant/get/litvar%40"+i+"%23%23/publications", headers=headers) # 必须输入http协议
                    if response.ok:
                        print(i)
                        html = json.loads(response.text)
                        tmp_df = pd.DataFrame([html])
                        tmp_df.index = [i]
                        df = pd.concat([df,tmp_df])
                    else:
                        print("请求失败: "+trait1+"-"+trait2+"-"+i)         
                except:
                    print("error: "+ trait1+"-"+trait2+"-"+i)
            df.to_csv("/home/yanyq/share_genetics/result/PLACO/search_variant/"+trait1+"-"+trait2,sep="\t")