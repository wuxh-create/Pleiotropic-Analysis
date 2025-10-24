# ChromeDriver 对应版本下载https://blog.csdn.net/weixin_51238373/article/details/140383863
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from bs4 import BeautifulSoup
import time

# 设置option，加速加载及忽略风险警告
chrome_options = webdriver.ChromeOptions()
chrome_options.add_argument('-ignore-certificate-errors')
chrome_options.add_argument('-ignore -ssl-errors')
# 禁止图片
chrome_options.add_argument('blink-settings=imagesEnabled=false')
chrome_options.add_argument('--disable-images')
# 屏蔽webdriver特征
chrome_options.add_argument("--disable-blink-features")
chrome_options.add_argument("--disable-blink-features=AutomationControlled")
# chrome_options.add_argument('--incognito')  # 无痕模式
# -------------------------------------------------------------------- #

# 设置 ChromeDriver 的路径
chrome_driver_path = 'D:\software\python3.10\chromedriver-win64\chromedriver.exe'

# 创建 Chrome 浏览器对象
service = Service(chrome_driver_path)
driver = webdriver.Chrome(service=service, options=chrome_options)

# /home/yanyq/share_genetics/data/gwas_catalog_ontology_URI
i=0
driver.get("http://www.baidu.com")
page_source = driver.page_source # 用于判断网页是否加载失败
soup_before = BeautifulSoup(page_source, 'html.parser')

with open("C:/Users/Administrator/Desktop/test.txt", 'r', encoding='utf-8') as file, open("C:/Users/Administrator/Desktop/gwas_catalog_ontology_URI_cancer", 'a', encoding='utf-8') as output, open("C:/Users/Administrator/Desktop/gwas_catalog_ontology_URI_notcancer", 'a', encoding='utf-8') as notcancer , open("C:/Users/Administrator/Desktop/gwas_catalog_ontology_URI_failed", 'a', encoding='utf-8') as failed:
    urls = file.readlines()
    for url in urls:
        i=i+1
        print(i)

        url = url.strip()  # 使用 strip() 方法去掉行末的换行符
        print(url)
        driver.get(url)

        # 获取页面源码
        page_source = driver.page_source
        # 使用 BeautifulSoup 解析页面
        soup = BeautifulSoup(page_source, 'html.parser')

        if str(soup) != str(soup_before):
            if "cancer or benign tumor" in str(soup):
                output.write("\n" + url)
            else:
                notcancer.write("\n" + url)
            
            soup_before = soup

        else:
            print("yes")
            failed.write("\n" + url)


        

        # # 关闭浏览器
        # driver.quit()