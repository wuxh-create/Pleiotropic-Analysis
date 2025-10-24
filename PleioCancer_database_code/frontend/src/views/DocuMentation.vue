<template>
  <div style="width: 1750px; margin: 0 auto; display: flex;">
    <div class="left-container" style="height: 300px;width: 175px; position: fixed;">
      <el-menu :default-active="activeMenu">
        <el-menu-item index="1" @click="scrollTo('menu_intro')">Introduction</el-menu-item>
        <el-menu-item index="2" @click="scrollTo('menu_collect')">Data collection</el-menu-item>
        <el-menu-item index="3" @click="scrollTo('menu_process')">Data process</el-menu-item>
        <el-menu-item index="4" @click="scrollTo('menu_statistics')">Data Statistics</el-menu-item>
        <el-menu-item index="5" @click="scrollTo('menu_usage')">Database usage</el-menu-item>
      </el-menu>
    </div>
    <div style="padding-left: 20px; margin-left: 200px;flex: 1;box-sizing: border-box; overflow-y: auto;">
      <h1 class="main-title">PleioCancer</h1>
      <h2 class="sub-title" style="text-align: center;">A database for exploring pleiotropic associations of 37 cancers with SNPs, methylations, genes and proteins</h2>
      <section class="section">
        <h2 class="sub-title" id="menu_intro">Introduction</h2>
        <p class="content">
          Genome-wide association studies (GWAS) have identified numerous cancer risk loci. However, due to limitations in statistical power, these studies can only partially explain heritability. Research suggests that pleiotropy may play a crucial role in shaping the genetic architecture of complex diseases. Pleiotropy refers to the effect of a single gene or variation on multiple phenotypic traits, including horizontal and vertical pleiotropy. Horizontal pleiotropy typically arises when a mutation or gene exerts distinct effects across different cell populations, leading to associations between different diseases. Alternatively, a single molecule may exist in multiple forms and engage in various regulatory processes, resulting in diverse outcomes. Vertical pleiotropy occurs when a causal relationship exists between two phenotypes, with genetic variation influencing one trait and subsequently affecting another. Pleiotropy analysis can help elucidate the genetic overlap between cancers, thereby aiding in the discovery of novel risk loci, offering new insights into carcinogenic pathways, and facilitating the development of targeted therapeutic strategies.
          <br>
          <br>
          In this study, we have developed a database to explore pleiotropic associations between 37 cancer types and SNPs, methylations, genes, and proteins. We compiled GWAS summary statistics for 37 cancer types, along with cis-meQTL, cis-eQTL, and cis-pQTL data. Using the R package 'PLACO', we identified 75,243 pleiotropic SNPs across cancer pairs based on GWAS summary statistics and 4,272 pleiotropic genes using MAGMA software. Additionally, we identified 5,428 methylations, 1,726 genes, and 229 proteins that are causally associated with cancers using SMR software, based on QTL and GWAS data.  
        </p>
        <h2 class="sub-title" id="menu_collect">Data collection</h2>
        <p class="content">
          1. GWAS summary data
        </p>
          <div style="display: flex; justify-content: center; align-items: center;">
            <el-table :data="gwasinfo" border style="margin: 10px 0; text-align: center; width: 80%;border: 1px solid #e9e9eb;"
            :header-cell-style="{ background: '#ecf5ff', color: '#337ecc' }"
            @sort-change="handleSort_gwasinfo">
              <el-table-column label="Cancer" prop="cancer" align="center" sortable="custom" width="470px" />
              <el-table-column label="Number of case" prop="n_case" align="center" sortable="custom" />
              <el-table-column label="Number of control" prop="n_control" align="center" sortable="custom" />
              <el-table-column label="Number of total" prop="n_total" align="center" sortable="custom" />
              <el-table-column label="Source" prop="source" align="center" sortable="custom" >
                <template #default="{ row }">
                  <a :href="getSourceLink(row.source)" class="link-style">{{ row.source }}</a>
                </template>
              </el-table-column>
            </el-table>
          </div>
        <p class="content">
          2. cis-QTL summary data
          <br>
          A cis quantitative trait locus (QTL) is defined as a significant association (P &lt; 5 &times; 10<sup>&#8722;8</sup>) between an SNP and molecular traits (such as methylation, gene expression, protein levels), with a SNP-molecular distance of less than 1 Mb.
          <br><br>
          The cis-meQTL data were obtained from the <a href="https://yanglab.westlake.edu.cn/software/smr/#mQTLsummarydata" class="link-style">
            YangLab website</a>. These data represent a meta-analysis of the BSGS (n = 614) and LBC (n = 1,366) datasets from peripheral blood 
            <a href="https://www.nature.com/articles/s41467-018-03371-0" class="link-style">(Wu et al. 2018 Nat Commun)</a>.
            The cis-eQTL data were retrieved from the <a href="https://eqtlgen.org/cis-eqtls.html" class="link-style">eQTLGene</a> database, 
            which includes 37 datasets comprising a total of 31,684 individuals.
            The cis-pQTL data for 1723 proteins were derived from a study involving 36,000 Icelandic individuals <a href="https://www.nature.com/articles/s41586-023-06563-x" class="link-style">(Eldjarn et al. 2023 Nature)</a>. 
            The summary of these data are available at <a href="https://www.decode.com/summarydata/" class="link-style">https://www.decode.com/summarydata/</a>.
        </p>
        <h2 class="sub-title" id="menu_process">Data process</h2>
        <p>1. Quality control</p>
        <ul class="content">
          <li>All SNPs were mapped to the hg19 reference genome;</li>
          <li>rsIDs were annotated using the dbSNP156 release according to SNP location;</li>
          <li>SNPs without rsID or with duplicate rsID were excluded;</li>
          <li>SNPs in high linkage disequilibrium regions (the major histocompatibility complex region, chr6:25-35 Mb) were excluded;</li>
          <li>SNPs located on heterosomes were excluded;</li>
          <li>SNPs with a minor allele frequency (MAF) &lt; 0.01 were excluded.</li>
        </ul>
        <p class="content">
          2. Statistical analysis
          <br>
          We first performed pleiotropic analysis under the composite null hypothesis (PLACO) to identify pleiotropic SNPs across cancer pairs 
          based on GWAS summary statistics. SNPs with P &lt; 5 &times; 10<sup>&#8722;8</sup> were considered significant pleiotropic variants. 
          <a href="https://fuma.ctglab.nl/" class="link-style">FUMA</a> was used to characterize pleiotropic loci by merging LD blocks (r<sup>2</sup> &ge; 0.1) within 250 kb.
          We then applied MAGMA to aggregate a set of SNP-level associations based on PLACO results into a single gene-level association signal 
          (10 kb upstream to 1.5 kb downstream). Genes that overlapped with the pleiotropic loci and with a false discovery rate (FDR) &lt; 0.05 were considered significant genes. 
          For pleiotropic genes, we conducted a Bayesian colocalization analysis using R package 'coloc'. 
          We also used the SMR software with parameters '--diff-freq-prop 0.2 --smr-multi --ld-multi-snp 0.01' to identify causal sites based on cis-QTL and GWAS data, using the 1000 Genomes Phase 3 European-ancestry genotypes as a reference panel.
        </p>
        <h2 class="sub-title" id="menu_statistics">Data Statistics</h2>
        <p class="content">
          1. Number of pleiotropic SNPs (top left) and genes (bottom right) across cancer pairs
        </p>
        <div style="display: flex; justify-content: center; align-items: center;"><div id="chart_pleioHeat" ref="chart_pleioHeat" style="width: 1200px; height: 950px;"></div></div>
        <p class="content">
          2. Number of causal sites associated with cancers
        </p>
        <div style="display: flex; justify-content: center; align-items: center;">
          <el-table :data="causal_num" border style="margin: 10px 0; text-align: center; width: 80%;border: 1px solid #e9e9eb;"
            :header-cell-style="{ background: '#ecf5ff', color: '#337ecc' }"
            @sort-change="handleSort_causal_num">
              <el-table-column label="Cancer" prop="cancer" align="center" sortable="custom" width="470px" />
              <el-table-column label="Number of methylation" prop="num_methy" align="center" sortable="custom" />
              <el-table-column label="Number of gene" prop="num_gene" align="center" sortable="custom" />
              <el-table-column label="Number of protein" prop="num_protein" align="center" sortable="custom" />
          </el-table>
        </div>
        
        <h2 class="sub-title" id="menu_usage">Database usage</h2>
        <br>
        <el-row>
          <el-col :span="12">
            <div style="display: flex; flex-direction: column; justify-content: center; align-items: center;">
              <img :src="help_home" style = "width: 90%;" />
              <p class="content" style="color: #409EFF; font-weight: bold">Home page</p>
            </div>
          </el-col>
          <el-col :span="12" style="display: flex; align-items: center; justify-content: center;">
            <div style="display: flex; flex-direction: column; justify-content: center; align-items: center;">
              <img :src="help_aggregate_search" style = "width: 90%;" />
              <p class="content" style="color: #409EFF; font-weight: bold">Aggregate search</p>
            </div>
          </el-col>
        </el-row>
        
        <br>
        <el-row>
          <el-col :span="12" style="display: flex; align-items: center; justify-content: center;">
            <div style="display: flex; flex-direction: column; justify-content: center; align-items: center;">
              <img :src="help_pleio_snp_top" style = "width: 90%;" />
              <p class="content" style="color: #409EFF; font-weight: bold">Pleiotropic sites (top)</p>
            </div>
          </el-col>
          <el-col :span="12" style="display: flex; align-items: center; justify-content: center;">
            <div style="display: flex; flex-direction: column; justify-content: center; align-items: center;">
              <img :src="help_causal_top" style = "width: 90%;" />
              <p class="content" style="color: #409EFF; font-weight: bold">Causal sites (top)</p>
            </div>
          </el-col>
        </el-row>

        <br>
        <el-row>
          <el-col :span="12" style="display: flex; align-items: center; justify-content: center;">
            <div style="display: flex; flex-direction: column; justify-content: center; align-items: center;">
              <img :src="help_pleio_snp_bottom" style = "width: 90%;" />
              <p class="content" style="color: #409EFF; font-weight: bold">Pleiotropic sites (bottom)</p>
            </div>
          </el-col>
          <el-col :span="12" style="display: flex; align-items: center; justify-content: center;">
            <div style="display: flex; flex-direction: column; justify-content: center; align-items: center;">
              <img :src="help_causal_bottom" style = "width: 90%;" />
              <p class="content" style="color: #409EFF; font-weight: bold">Causal sites (bottom)</p>
            </div>
          </el-col>
        </el-row>
        
        <br>
        <div style="display: flex; flex-direction: column; justify-content: center; align-items: center;">
          <img :src="help_network" style = "width: 60%;" />
          <p class="content" style="color: #409EFF; font-weight: bold">Network graph</p>
        </div>

      </section>
    </div>
    
  </div>
</template>
  
<script> 
import * as echarts from "echarts";
import { markRaw } from "vue";
const pleio_snp_gene = [[0, 0, 0], [1, 0, 74], [2, 0, 0], [3, 0, 0], [4, 0, 0], [5, 0, 21], [6, 0, 0], [7, 0, 0], [8, 0, 60], [9, 0, 0], [10, 0, 0], [11, 0, 0], [12, 0, 0], [13, 0, 0], [14, 0, 0], [15, 0, 0], [16, 0, 0], [17, 0, 1], [18, 0, 0], [19, 0, 0], [20, 0, 0], [21, 0, 0], [22, 0, 0], [23, 0, 0], [24, 0, 0], [25, 0, 0], [26, 0, 0], [27, 0, 30], [28, 0, 0], [29, 0, 67], [30, 0, 15], [31, 0, 0], [32, 0, 0], [33, 0, 0], [34, 0, 1], [35, 0, 3], [36, 0, 0], 
[0, 1, 3], [1, 1, 0], [2, 1, 60], [3, 1, 106], [4, 1, 58], [5, 1, 2352], [6, 1, 124], [7, 1, 143], [8, 1, 804], [9, 1, 22], [10, 1, 322], [11, 1, 76], [12, 1, 21], [13, 1, 266], [14, 1, 412], [15, 1, 16], [16, 1, 315], [17, 1, 504], [18, 1, 112], [19, 1, 42], [20, 1, 177], [21, 1, 241], [22, 1, 19], [23, 1, 25], [24, 1, 50], [25, 1, 31], [26, 1, 74], [27, 1, 344], [28, 1, 222], [29, 1, 2652], [30, 1, 1763], [31, 1, 434], [32, 1, 1513], [33, 1, 60], [34, 1, 76], [35, 1, 325], [36, 1, 11], 
[0, 2, 0], [1, 2, 7], [2, 2, 0], [3, 2, 8], [4, 2, 14], [5, 2, 240], [6, 2, 48], [7, 2, 16], [8, 2, 80], [9, 2, 0], [10, 2, 5], [11, 2, 1], [12, 2, 0], [13, 2, 9], [14, 2, 5], [15, 2, 0], [16, 2, 2], [17, 2, 100], [18, 2, 6], [19, 2, 0], [20, 2, 0], [21, 2, 7], [22, 2, 0], [23, 2, 0], [24, 2, 0], [25, 2, 0], [26, 2, 0], [27, 2, 43], [28, 2, 63], [29, 2, 220], [30, 2, 412], [31, 2, 0], [32, 2, 14], [33, 2, 104], [34, 2, 0], [35, 2, 59], [36, 2, 0], 
[0, 3, 0], [1, 3, 6], [2, 3, 1], [3, 3, 0], [4, 3, 0], [5, 3, 62], [6, 3, 2], [7, 3, 0], [8, 3, 104], [9, 3, 0], [10, 3, 8], [11, 3, 0], [12, 3, 0], [13, 3, 0], [14, 3, 0], [15, 3, 0], [16, 3, 0], [17, 3, 10], [18, 3, 0], [19, 3, 0], [20, 3, 0], [21, 3, 1], [22, 3, 0], [23, 3, 0], [24, 3, 0], [25, 3, 0], [26, 3, 0], [27, 3, 16], [28, 3, 2], [29, 3, 67], [30, 3, 40], [31, 3, 0], [32, 3, 34], [33, 3, 0], [34, 3, 0], [35, 3, 17], [36, 3, 0], 
[0, 4, 0], [1, 4, 22], [2, 4, 3], [3, 4, 0], [4, 4, 0], [5, 4, 508], [6, 4, 0], [7, 4, 0], [8, 4, 140], [9, 4, 0], [10, 4, 7], [11, 4, 0], [12, 4, 0], [13, 4, 0], [14, 4, 4], [15, 4, 0], [16, 4, 20], [17, 4, 11], [18, 4, 15], [19, 4, 0], [20, 4, 1], [21, 4, 0], [22, 4, 0], [23, 4, 6], [24, 4, 5], [25, 4, 0], [26, 4, 0], [27, 4, 258], [28, 4, 34], [29, 4, 404], [30, 4, 233], [31, 4, 0], [32, 4, 1], [33, 4, 0], [34, 4, 0], [35, 4, 259], [36, 4, 0], 
[0, 5, 7], [1, 5, 143], [2, 5, 20], [3, 5, 5], [4, 5, 23], [5, 5, 0], [6, 5, 291], [7, 5, 11], [8, 5, 1185], [9, 5, 49], [10, 5, 681], [11, 5, 108], [12, 5, 41], [13, 5, 53], [14, 5, 192], [15, 5, 28], [16, 5, 149], [17, 5, 201], [18, 5, 186], [19, 5, 149], [20, 5, 54], [21, 5, 355], [22, 5, 67], [23, 5, 13], [24, 5, 322], [25, 5, 127], [26, 5, 25], [27, 5, 4500], [28, 5, 112], [29, 5, 7177], [30, 5, 593], [31, 5, 242], [32, 5, 447], [33, 5, 226], [34, 5, 120], [35, 5, 369], [36, 5, 44], 
[0, 6, 0], [1, 6, 8], [2, 6, 2], [3, 6, 0], [4, 6, 0], [5, 6, 28], [6, 6, 0], [7, 6, 0], [8, 6, 199], [9, 6, 0], [10, 6, 9], [11, 6, 81], [12, 6, 0], [13, 6, 0], [14, 6, 0], [15, 6, 15], [16, 6, 2], [17, 6, 29], [18, 6, 46], [19, 6, 0], [20, 6, 4], [21, 6, 1], [22, 6, 0], [23, 6, 0], [24, 6, 0], [25, 6, 1], [26, 6, 0], [27, 6, 3064], [28, 6, 59], [29, 6, 468], [30, 6, 59], [31, 6, 1], [32, 6, 6], [33, 6, 0], [34, 6, 7], [35, 6, 31], [36, 6, 0], 
[0, 7, 0], [1, 7, 7], [2, 7, 0], [3, 7, 0], [4, 7, 0], [5, 7, 6], [6, 7, 0], [7, 7, 0], [8, 7, 85], [9, 7, 0], [10, 7, 0], [11, 7, 0], [12, 7, 0], [13, 7, 0], [14, 7, 0], [15, 7, 0], [16, 7, 0], [17, 7, 8], [18, 7, 0], [19, 7, 0], [20, 7, 0], [21, 7, 0], [22, 7, 0], [23, 7, 0], [24, 7, 0], [25, 7, 0], [26, 7, 0], [27, 7, 70], [28, 7, 19], [29, 7, 47], [30, 7, 19], [31, 7, 0], [32, 7, 54], [33, 7, 0], [34, 7, 0], [35, 7, 7], [36, 7, 0], 
[0, 8, 1], [1, 8, 110], [2, 8, 5], [3, 8, 10], [4, 8, 13], [5, 8, 70], [6, 8, 16], [7, 8, 0], [8, 8, 0], [9, 8, 80], [10, 8, 384], [11, 8, 468], [12, 8, 9], [13, 8, 40], [14, 8, 64], [15, 8, 24], [16, 8, 55], [17, 8, 340], [18, 8, 77], [19, 8, 33], [20, 8, 11], [21, 8, 129], [22, 8, 115], [23, 8, 3], [24, 8, 103], [25, 8, 67], [26, 8, 105], [27, 8, 2885], [28, 8, 32], [29, 8, 2608], [30, 8, 330], [31, 8, 154], [32, 8, 249], [33, 8, 66], [34, 8, 49], [35, 8, 125], [36, 8, 27], 
[0, 9, 0], [1, 9, 9], [2, 9, 0], [3, 9, 0], [4, 9, 0], [5, 9, 2], [6, 9, 0], [7, 9, 0], [8, 9, 0], [9, 9, 0], [10, 9, 12], [11, 9, 0], [12, 9, 0], [13, 9, 0], [14, 9, 0], [15, 9, 0], [16, 9, 0], [17, 9, 8], [18, 9, 4], [19, 9, 0], [20, 9, 0], [21, 9, 0], [22, 9, 0], [23, 9, 0], [24, 9, 0], [25, 9, 0], [26, 9, 0], [27, 9, 125], [28, 9, 1], [29, 9, 217], [30, 9, 146], [31, 9, 0], [32, 9, 85], [33, 9, 0], [34, 9, 0], [35, 9, 0], [36, 9, 0], 
[0, 10, 0], [1, 10, 17], [2, 10, 1], [3, 10, 2], [4, 10, 5], [5, 10, 30], [6, 10, 0], [7, 10, 0], [8, 10, 32], [9, 10, 0], [10, 10, 0], [11, 10, 15], [12, 10, 0], [13, 10, 0], [14, 10, 1], [15, 10, 1], [16, 10, 17], [17, 10, 31], [18, 10, 3], [19, 10, 5], [20, 10, 0], [21, 10, 4], [22, 10, 0], [23, 10, 0], [24, 10, 0], [25, 10, 0], [26, 10, 0], [27, 10, 227], [28, 10, 63], [29, 10, 797], [30, 10, 94], [31, 10, 0], [32, 10, 139], [33, 10, 2], [34, 10, 24], [35, 10, 13], [36, 10, 0], 
[0, 11, 0], [1, 11, 10], [2, 11, 1], [3, 11, 0], [4, 11, 0], [5, 11, 10], [6, 11, 0], [7, 11, 0], [8, 11, 17], [9, 11, 0], [10, 11, 1], [11, 11, 0], [12, 11, 0], [13, 11, 20], [14, 11, 0], [15, 11, 0], [16, 11, 0], [17, 11, 5], [18, 11, 2], [19, 11, 0], [20, 11, 0], [21, 11, 0], [22, 11, 0], [23, 11, 0], [24, 11, 0], [25, 11, 0], [26, 11, 0], [27, 11, 17], [28, 11, 16], [29, 11, 454], [30, 11, 55], [31, 11, 0], [32, 11, 12], [33, 11, 0], [34, 11, 7], [35, 11, 7], [36, 11, 0], 
[0, 12, 0], [1, 12, 12], [2, 12, 0], [3, 12, 0], [4, 12, 0], [5, 12, 2], [6, 12, 0], [7, 12, 0], [8, 12, 2], [9, 12, 0], [10, 12, 0], [11, 12, 0], [12, 12, 0], [13, 12, 0], [14, 12, 4], [15, 12, 0], [16, 12, 0], [17, 12, 2], [18, 12, 1], [19, 12, 0], [20, 12, 0], [21, 12, 0], [22, 12, 2], [23, 12, 0], [24, 12, 0], [25, 12, 0], [26, 12, 0], [27, 12, 2], [28, 12, 27], [29, 12, 139], [30, 12, 112], [31, 12, 0], [32, 12, 144], [33, 12, 1], [34, 12, 0], [35, 12, 0], [36, 12, 0], 
[0, 13, 0], [1, 13, 18], [2, 13, 1], [3, 13, 0], [4, 13, 0], [5, 13, 8], [6, 13, 0], [7, 13, 0], [8, 13, 12], [9, 13, 0], [10, 13, 0], [11, 13, 0], [12, 13, 0], [13, 13, 0], [14, 13, 2], [15, 13, 0], [16, 13, 3], [17, 13, 6], [18, 13, 0], [19, 13, 0], [20, 13, 0], [21, 13, 0], [22, 13, 0], [23, 13, 0], [24, 13, 0], [25, 13, 0], [26, 13, 0], [27, 13, 66], [28, 13, 2], [29, 13, 130], [30, 13, 318], [31, 13, 0], [32, 13, 236], [33, 13, 1], [34, 13, 1], [35, 13, 17], [36, 13, 0], 
[0, 14, 0], [1, 14, 18], [2, 14, 2], [3, 14, 0], [4, 14, 0], [5, 14, 14], [6, 14, 0], [7, 14, 0], [8, 14, 7], [9, 14, 0], [10, 14, 0], [11, 14, 0], [12, 14, 1], [13, 14, 0], [14, 14, 0], [15, 14, 8], [16, 14, 17], [17, 14, 6], [18, 14, 0], [19, 14, 0], [20, 14, 11], [21, 14, 162], [22, 14, 0], [23, 14, 33], [24, 14, 0], [25, 14, 0], [26, 14, 14], [27, 14, 7], [28, 14, 1], [29, 14, 220], [30, 14, 49], [31, 14, 1], [32, 14, 27], [33, 14, 0], [34, 14, 0], [35, 14, 19], [36, 14, 9], 
[0, 15, 0], [1, 15, 9], [2, 15, 0], [3, 15, 0], [4, 15, 0], [5, 15, 9], [6, 15, 0], [7, 15, 0], [8, 15, 1], [9, 15, 0], [10, 15, 0], [11, 15, 0], [12, 15, 0], [13, 15, 0], [14, 15, 1], [15, 15, 0], [16, 15, 0], [17, 15, 1], [18, 15, 1], [19, 15, 0], [20, 15, 0], [21, 15, 2], [22, 15, 0], [23, 15, 0], [24, 15, 0], [25, 15, 0], [26, 15, 0], [27, 15, 3], [28, 15, 0], [29, 15, 197], [30, 15, 102], [31, 15, 0], [32, 15, 20], [33, 15, 0], [34, 15, 0], [35, 15, 23], [36, 15, 0], 
[0, 16, 0], [1, 16, 15], [2, 16, 0], [3, 16, 0], [4, 16, 3], [5, 16, 13], [6, 16, 0], [7, 16, 0], [8, 16, 3], [9, 16, 0], [10, 16, 1], [11, 16, 0], [12, 16, 0], [13, 16, 0], [14, 16, 0], [15, 16, 0], [16, 16, 0], [17, 16, 27], [18, 16, 1], [19, 16, 0], [20, 16, 0], [21, 16, 0], [22, 16, 0], [23, 16, 7], [24, 16, 0], [25, 16, 0], [26, 16, 0], [27, 16, 1], [28, 16, 31], [29, 16, 480], [30, 16, 21], [31, 16, 0], [32, 16, 33], [33, 16, 0], [34, 16, 0], [35, 16, 116], [36, 16, 0], 
[0, 17, 1], [1, 17, 29], [2, 17, 6], [3, 17, 2], [4, 17, 2], [5, 17, 35], [6, 17, 2], [7, 17, 1], [8, 17, 17], [9, 17, 1], [10, 17, 1], [11, 17, 2], [12, 17, 1], [13, 17, 1], [14, 17, 1], [15, 17, 0], [16, 17, 2], [17, 17, 0], [18, 17, 12], [19, 17, 0], [20, 17, 4], [21, 17, 5], [22, 17, 95], [23, 17, 5], [24, 17, 16], [25, 17, 1], [26, 17, 4], [27, 17, 2776], [28, 17, 19], [29, 17, 648], [30, 17, 75], [31, 17, 6], [32, 17, 20], [33, 17, 1], [34, 17, 8], [35, 17, 51], [36, 17, 2], 
[0, 18, 0], [1, 18, 2], [2, 18, 1], [3, 18, 0], [4, 18, 5], [5, 18, 21], [6, 18, 2], [7, 18, 0], [8, 18, 10], [9, 18, 0], [10, 18, 0], [11, 18, 0], [12, 18, 0], [13, 18, 0], [14, 18, 0], [15, 18, 0], [16, 18, 0], [17, 18, 1], [18, 18, 0], [19, 18, 0], [20, 18, 0], [21, 18, 0], [22, 18, 10], [23, 18, 1], [24, 18, 0], [25, 18, 0], [26, 18, 15], [27, 18, 10], [28, 18, 50], [29, 18, 233], [30, 18, 55], [31, 18, 0], [32, 18, 9], [33, 18, 0], [34, 18, 0], [35, 18, 43], [36, 18, 0], 
[0, 19, 0], [1, 19, 6], [2, 19, 0], [3, 19, 0], [4, 19, 0], [5, 19, 5], [6, 19, 0], [7, 19, 0], [8, 19, 2], [9, 19, 0], [10, 19, 0], [11, 19, 0], [12, 19, 0], [13, 19, 0], [14, 19, 0], [15, 19, 0], [16, 19, 0], [17, 19, 0], [18, 19, 0], [19, 19, 0], [20, 19, 0], [21, 19, 0], [22, 19, 0], [23, 19, 0], [24, 19, 0], [25, 19, 0], [26, 19, 0], [27, 19, 0], [28, 19, 0], [29, 19, 37], [30, 19, 9], [31, 19, 0], [32, 19, 7], [33, 19, 0], [34, 19, 0], [35, 19, 0], [36, 19, 0], 
[0, 20, 0], [1, 20, 30], [2, 20, 0], [3, 20, 0], [4, 20, 1], [5, 20, 1], [6, 20, 1], [7, 20, 0], [8, 20, 1], [9, 20, 0], [10, 20, 0], [11, 20, 0], [12, 20, 0], [13, 20, 0], [14, 20, 0], [15, 20, 0], [16, 20, 0], [17, 20, 2], [18, 20, 0], [19, 20, 0], [20, 20, 0], [21, 20, 0], [22, 20, 0], [23, 20, 0], [24, 20, 0], [25, 20, 0], [26, 20, 0], [27, 20, 0], [28, 20, 27], [29, 20, 60], [30, 20, 51], [31, 20, 0], [32, 20, 13], [33, 20, 0], [34, 20, 0], [35, 20, 3], [36, 20, 0], 
[0, 21, 0], [1, 21, 13], [2, 21, 1], [3, 21, 1], [4, 21, 0], [5, 21, 29], [6, 21, 0], [7, 21, 0], [8, 21, 10], [9, 21, 0], [10, 21, 1], [11, 21, 0], [12, 21, 0], [13, 21, 0], [14, 21, 14], [15, 21, 0], [16, 21, 0], [17, 21, 1], [18, 21, 0], [19, 21, 0], [20, 21, 0], [21, 21, 0], [22, 21, 0], [23, 21, 10], [24, 21, 0], [25, 21, 0], [26, 21, 1], [27, 21, 2538], [28, 21, 0], [29, 21, 113], [30, 21, 48], [31, 21, 0], [32, 21, 48], [33, 21, 0], [34, 21, 0], [35, 21, 22], [36, 21, 0], 
[0, 22, 0], [1, 22, 2], [2, 22, 0], [3, 22, 0], [4, 22, 0], [5, 22, 22], [6, 22, 0], [7, 22, 0], [8, 22, 5], [9, 22, 0], [10, 22, 0], [11, 22, 0], [12, 22, 0], [13, 22, 0], [14, 22, 0], [15, 22, 0], [16, 22, 0], [17, 22, 8], [18, 22, 1], [19, 22, 0], [20, 22, 0], [21, 22, 0], [22, 22, 0], [23, 22, 0], [24, 22, 0], [25, 22, 0], [26, 22, 0], [27, 22, 7], [28, 22, 12], [29, 22, 56], [30, 22, 39], [31, 22, 0], [32, 22, 8], [33, 22, 0], [34, 22, 2], [35, 22, 30], [36, 22, 0], 
[0, 23, 0], [1, 23, 2], [2, 23, 0], [3, 23, 0], [4, 23, 1], [5, 23, 0], [6, 23, 0], [7, 23, 0], [8, 23, 1], [9, 23, 0], [10, 23, 0], [11, 23, 0], [12, 23, 0], [13, 23, 0], [14, 23, 1], [15, 23, 0], [16, 23, 1], [17, 23, 2], [18, 23, 0], [19, 23, 0], [20, 23, 0], [21, 23, 0], [22, 23, 0], [23, 23, 0], [24, 23, 0], [25, 23, 0], [26, 23, 77], [27, 23, 0], [28, 23, 0], [29, 23, 126], [30, 23, 61], [31, 23, 0], [32, 23, 47], [33, 23, 0], [34, 23, 0], [35, 23, 37], [36, 23, 0], 
[0, 24, 0], [1, 24, 24], [2, 24, 0], [3, 24, 0], [4, 24, 0], [5, 24, 9], [6, 24, 0], [7, 24, 0], [8, 24, 7], [9, 24, 0], [10, 24, 0], [11, 24, 0], [12, 24, 0], [13, 24, 0], [14, 24, 0], [15, 24, 0], [16, 24, 0], [17, 24, 1], [18, 24, 0], [19, 24, 0], [20, 24, 0], [21, 24, 0], [22, 24, 0], [23, 24, 0], [24, 24, 0], [25, 24, 2], [26, 24, 0], [27, 24, 9], [28, 24, 0], [29, 24, 610], [30, 24, 1], [31, 24, 0], [32, 24, 0], [33, 24, 0], [34, 24, 0], [35, 24, 17], [36, 24, 0], 
[0, 25, 0], [1, 25, 1], [2, 25, 0], [3, 25, 0], [4, 25, 0], [5, 25, 3], [6, 25, 0], [7, 25, 0], [8, 25, 0], [9, 25, 0], [10, 25, 0], [11, 25, 0], [12, 25, 0], [13, 25, 0], [14, 25, 0], [15, 25, 0], [16, 25, 0], [17, 25, 0], [18, 25, 0], [19, 25, 0], [20, 25, 0], [21, 25, 0], [22, 25, 0], [23, 25, 0], [24, 25, 0], [25, 25, 0], [26, 25, 0], [27, 25, 73], [28, 25, 10], [29, 25, 321], [30, 25, 145], [31, 25, 0], [32, 25, 89], [33, 25, 0], [34, 25, 0], [35, 25, 12], [36, 25, 0], 
[0, 26, 0], [1, 26, 13], [2, 26, 0], [3, 26, 0], [4, 26, 0], [5, 26, 5], [6, 26, 0], [7, 26, 0], [8, 26, 4], [9, 26, 0], [10, 26, 0], [11, 26, 0], [12, 26, 0], [13, 26, 0], [14, 26, 0], [15, 26, 0], [16, 26, 0], [17, 26, 1], [18, 26, 0], [19, 26, 0], [20, 26, 0], [21, 26, 0], [22, 26, 0], [23, 26, 0], [24, 26, 0], [25, 26, 0], [26, 26, 0], [27, 26, 9], [28, 26, 0], [29, 26, 269], [30, 26, 36], [31, 26, 0], [32, 26, 29], [33, 26, 2], [34, 26, 0], [35, 26, 3], [36, 26, 0], 
[0, 27, 4], [1, 27, 21], [2, 27, 2], [3, 27, 3], [4, 27, 12], [5, 27, 57], [6, 27, 26], [7, 27, 13], [8, 27, 17], [9, 27, 2], [10, 27, 11], [11, 27, 1], [12, 27, 0], [13, 27, 7], [14, 27, 8], [15, 27, 0], [16, 27, 1], [17, 27, 25], [18, 27, 2], [19, 27, 0], [20, 27, 0], [21, 27, 14], [22, 27, 3], [23, 27, 0], [24, 27, 1], [25, 27, 0], [26, 27, 0], [27, 27, 0], [28, 27, 56], [29, 27, 3363], [30, 27, 2783], [31, 27, 88], [32, 27, 263], [33, 27, 51], [34, 27, 1], [35, 27, 46], [36, 27, 0], 
[0, 28, 0], [1, 28, 12], [2, 28, 3], [3, 28, 0], [4, 28, 1], [5, 28, 7], [6, 28, 2], [7, 28, 2], [8, 28, 4], [9, 28, 0], [10, 28, 3], [11, 28, 2], [12, 28, 1], [13, 28, 0], [14, 28, 1], [15, 28, 0], [16, 28, 0], [17, 28, 2], [18, 28, 2], [19, 28, 0], [20, 28, 2], [21, 28, 0], [22, 28, 2], [23, 28, 0], [24, 28, 0], [25, 28, 0], [26, 28, 0], [27, 28, 1], [28, 28, 0], [29, 28, 409], [30, 28, 69], [31, 28, 0], [32, 28, 1], [33, 28, 65], [34, 28, 0], [35, 28, 68], [36, 28, 0], 
[0, 29, 15], [1, 29, 225], [2, 29, 34], [3, 29, 17], [4, 29, 47], [5, 29, 365], [6, 29, 31], [7, 29, 11], [8, 29, 164], [9, 29, 24], [10, 29, 58], [11, 29, 24], [12, 29, 30], [13, 29, 25], [14, 29, 17], [15, 29, 32], [16, 29, 32], [17, 29, 90], [18, 29, 51], [19, 29, 18], [20, 29, 9], [21, 29, 16], [22, 29, 11], [23, 29, 12], [24, 29, 42], [25, 29, 18], [26, 29, 14], [27, 29, 83], [28, 29, 30], [29, 29, 0], [30, 29, 499], [31, 29, 142], [32, 29, 520], [33, 29, 166], [34, 29, 100], [35, 29, 770], [36, 29, 37], 
[0, 30, 2], [1, 30, 74], [2, 30, 7], [3, 30, 8], [4, 30, 14], [5, 30, 49], [6, 30, 6], [7, 30, 4], [8, 30, 31], [9, 30, 12], [10, 30, 6], [11, 30, 11], [12, 30, 19], [13, 30, 16], [14, 30, 18], [15, 30, 3], [16, 30, 5], [17, 30, 10], [18, 30, 4], [19, 30, 7], [20, 30, 7], [21, 30, 18], [22, 30, 2], [23, 30, 4], [24, 30, 0], [25, 30, 3], [26, 30, 9], [27, 30, 24], [28, 30, 3], [29, 30, 100], [30, 30, 0], [31, 30, 5], [32, 30, 1465], [33, 30, 85], [34, 30, 19], [35, 30, 256], [36, 30, 32], 
[0, 31, 0], [1, 31, 18], [2, 31, 0], [3, 31, 0], [4, 31, 0], [5, 31, 4], [6, 31, 0], [7, 31, 0], [8, 31, 15], [9, 31, 0], [10, 31, 0], [11, 31, 0], [12, 31, 0], [13, 31, 0], [14, 31, 0], [15, 31, 0], [16, 31, 0], [17, 31, 13], [18, 31, 0], [19, 31, 0], [20, 31, 0], [21, 31, 0], [22, 31, 0], [23, 31, 0], [24, 31, 0], [25, 31, 0], [26, 31, 0], [27, 31, 0], [28, 31, 0], [29, 31, 9], [30, 31, 2], [31, 31, 0], [32, 31, 12], [33, 31, 0], [34, 31, 0], [35, 31, 21], [36, 31, 0], 
[0, 32, 0], [1, 32, 54], [2, 32, 1], [3, 32, 5], [4, 32, 6], [5, 32, 25], [6, 32, 2], [7, 32, 2], [8, 32, 31], [9, 32, 6], [10, 32, 1], [11, 32, 4], [12, 32, 10], [13, 32, 12], [14, 32, 11], [15, 32, 4], [16, 32, 7], [17, 32, 7], [18, 32, 0], [19, 32, 0], [20, 32, 7], [21, 32, 13], [22, 32, 0], [23, 32, 5], [24, 32, 0], [25, 32, 1], [26, 32, 9], [27, 32, 25], [28, 32, 0], [29, 32, 81], [30, 32, 34], [31, 32, 5], [32, 32, 0], [33, 32, 76], [34, 32, 12], [35, 32, 16], [36, 32, 14], 
[0, 33, 0], [1, 33, 20], [2, 33, 6], [3, 33, 0], [4, 33, 0], [5, 33, 30], [6, 33, 0], [7, 33, 0], [8, 33, 2], [9, 33, 0], [10, 33, 0], [11, 33, 0], [12, 33, 0], [13, 33, 0], [14, 33, 0], [15, 33, 0], [16, 33, 0], [17, 33, 0], [18, 33, 0], [19, 33, 0], [20, 33, 0], [21, 33, 0], [22, 33, 0], [23, 33, 0], [24, 33, 0], [25, 33, 0], [26, 33, 2], [27, 33, 1], [28, 33, 6], [29, 33, 33], [30, 33, 1], [31, 33, 0], [32, 33, 1], [33, 33, 0], [34, 33, 1], [35, 33, 14], [36, 33, 0], 
[0, 34, 0], [1, 34, 3], [2, 34, 0], [3, 34, 0], [4, 34, 0], [5, 34, 11], [6, 34, 0], [7, 34, 0], [8, 34, 1], [9, 34, 0], [10, 34, 2], [11, 34, 0], [12, 34, 0], [13, 34, 0], [14, 34, 0], [15, 34, 0], [16, 34, 0], [17, 34, 3], [18, 34, 0], [19, 34, 0], [20, 34, 0], [21, 34, 0], [22, 34, 0], [23, 34, 0], [24, 34, 0], [25, 34, 0], [26, 34, 0], [27, 34, 0], [28, 34, 0], [29, 34, 15], [30, 34, 2], [31, 34, 0], [32, 34, 0], [33, 34, 1], [34, 34, 0], [35, 34, 8], [36, 34, 6], 
[0, 35, 1], [1, 35, 15], [2, 35, 1], [3, 35, 3], [4, 35, 17], [5, 35, 17], [6, 35, 2], [7, 35, 0], [8, 35, 25], [9, 35, 0], [10, 35, 1], [11, 35, 2], [12, 35, 0], [13, 35, 1], [14, 35, 2], [15, 35, 0], [16, 35, 1], [17, 35, 16], [18, 35, 1], [19, 35, 0], [20, 35, 0], [21, 35, 3], [22, 35, 2], [23, 35, 1], [24, 35, 0], [25, 35, 0], [26, 35, 0], [27, 35, 3], [28, 35, 3], [29, 35, 54], [30, 35, 14], [31, 35, 3], [32, 35, 0], [33, 35, 1], [34, 35, 0], [35, 35, 0], [36, 35, 0], 
[0, 36, 0], [1, 36, 0], [2, 36, 0], [3, 36, 0], [4, 36, 0], [5, 36, 6], [6, 36, 0], [7, 36, 0], [8, 36, 4], [9, 36, 0], [10, 36, 0], [11, 36, 0], [12, 36, 0], [13, 36, 0], [14, 36, 1], [15, 36, 0], [16, 36, 0], [17, 36, 1], [18, 36, 0], [19, 36, 0], [20, 36, 0], [21, 36, 0], [22, 36, 0], [23, 36, 0], [24, 36, 0], [25, 36, 0], [26, 36, 0], [27, 36, 0], [28, 36, 0], [29, 36, 11], [30, 36, 8], [31, 36, 0], [32, 36, 0], [33, 36, 0], [34, 36, 1], [35, 36, 0], [36, 36, 0]]
.map(function (item) {
    return [item[1], item[0], item[2] || '-'];
});
export default {
  data() {
    return {
      chart_pleioHeat: null,
      activeMenu: '1',
      pleio_snp_gene,
      cancerList: ["Acute myeloid leukaemia", "Basal cell carcinoma", "Bladder cancer", "Brain glioblastoma and astrocytoma",
                  "Brain meningioma", "Breast cancer", "Cervical cancer", "Chronic myeloid leukaemia", "Colorectal cancer", "Diffuse large B-cell lymphoma",
                  "Endometrial cancer", "Esophageal cancer", "Gastrointestinal stromal tumor and sarcoma", "Head and neck cancer", "Hepatocellular carcinoma",                                               
                  "Hodgkins lymphoma", "Kidney cancer, except renal pelvis", "Lung cancer", "Lymphocytic leukemia", 
                  "Malignant neoplasm of bone and articular cartilage", "Malignant neoplasm of eye and adnexa",
                  "Malignant neoplasm of intrahepatic ducts, biliary tract and gallbladder", "Mantle cell lymphoma", "Marginal zone B-cell lymphoma",
                  "Mesothelioma", "Multiple myeloma", "Myelodysplastic syndrome", "Ovarian cancer", "Pancreatic cancer", "Prostate cancer", "Skin melanoma",
                  "Small intestine cancer", "Squamous cell carcinoma", "Stomach cancer", "Testicular cancer", "Thyroid cancer", "Vulvar cancer"],
      n_case: [244,20506,2193,341,1316,106278,6563,115,78473,1050,12906,4112,259,2281,500,429,2372,29266,852,224,221,1207,
              210,202,356,623,206,25509, 1626, 122188,3194,525,3531,1423,426,1907,202],
      n_control: [314192, 314193, 314193, 314193, 313392,  91477, 410350, 314192, 107143, 314193, 108979,  17159, 314146, 314193,
                  314193, 455847, 314193,6450, 410350, 314193, 314193, 314193, 314193, 314193, 314193, 314185, 314096,  40941, 314193, 604640,
                  314193, 314193, 314193,314193, 131266, 314193, 182927],
      n_total: [314436, 334699, 316386, 314534, 314708, 197755, 416913, 314307, 185616, 315243, 121885, 21271, 314405, 316474,
                314693, 456276, 316565,85716, 411202,314417, 314414, 315400, 314403, 314395, 314549, 314808, 314302,  66450, 315819, 726828, 
                317387, 314718, 317724,315616, 131692, 316100, 183129],
      source: ['FinnGen','FinnGen','FinnGen','FinnGen','FinnGen','PMID: 32424353','PMID: 32887889','FinnGen','PMID: 36539618','FinnGen',
      'PMID: 30093612','PMID: 27527254','FinnGen','FinnGen','FinnGen','PMID: 34737426','FinnGen','PMID: 28604730','PMID: 32887889',
      'FinnGen','FinnGen','FinnGen','FinnGen','FinnGen','FinnGen','FinnGen','FinnGen','PMID: 28346442','FinnGen',
      'PMID: 37945903','FinnGen','FinnGen','FinnGen','FinnGen','FinnGen','FinnGen','FinnGen'],

      causal_num_cancer: ["Basal cell carcinoma", "Brain meningioma", "Breast cancer", "Cervical cancer", "Colorectal cancer", "Endometrial cancer",
          "Esophageal cancer", "Head and neck cancer", "Hepatocellular carcinoma", "Kidney cancer, except renal pelvis", "Lung cancer",
          "Lymphocytic leukemia", "Malignant neoplasm of intrahepatic ducts, biliary tract and gallbladder", "Ovarian cancer", 
          "Pancreatic cancer", "Prostate cancer", "Skin melanoma", "Squamous cell carcinoma", "Stomach cancer", "Thyroid cancer"],
      num_methy: [480, 0, 1171, 16, 787, 9, 12, 1, 0, 2, 92, 11, 0, 80, 22, 2615, 72, 44, 4, 10],
      num_gene: [152, 3, 449, 1, 253, 3, 0, 0, 2, 2, 8, 1, 1, 11, 0, 801, 14, 12, 6, 7],
      num_protein: [28, 0, 59, 0, 21, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 116, 1, 1, 0, 1],
      help_home: require('@/assets/help_home.png'),
      help_aggregate_search: require('@/assets/help_aggregate_search.png'),
      help_pleio_snp_top: require('@/assets/help_pleio_snp_top.png'),
      help_pleio_snp_bottom: require('@/assets/help_pleio_snp_bottom.png'),
      help_causal_top: require('@/assets/help_causal_top.png'),
      help_causal_bottom: require('@/assets/help_causal_bottom.png'),
      help_network: require('@/assets/help_network.png'),
    };
  },
  computed: {
    gwasinfo() {
      return this.cancerList.map((cancer, index) => ({
        cancer,
        n_case: this.n_case[index],
        n_control: this.n_control[index],
        n_total: this.n_total[index],
        source: this.source[index],
      }));
    },
    causal_num() {
      return this.causal_num_cancer.map((cancer, index) => ({
        cancer,
        num_methy: this.num_methy[index],
        num_gene: this.num_gene[index],
        num_protein: this.num_protein[index],
      }));
    }
  },
  mounted() {
    this.plot_placo_snp_gene();
  },
  methods: {
    scrollTo(sectionId) {
      const section = document.getElementById(sectionId);
      if (section) {
        section.scrollIntoView({ behavior: 'smooth' });
      }
    },
    getSourceLink(source) {
      if (source === 'FinnGen') {
        return 'https://r10.finngen.fi/';
      } else if (source.startsWith('PMID')) {
        const pmid = source.replace('PMID: ', '');
        return `https://pubmed.ncbi.nlm.nih.gov/${pmid}/`;
      }
      return '#'; // 默认返回一个空链接
    },
    handleSort(data, column) {
      const compare = (a, b) => {
        const valueA = a[column.prop];
        const valueB = b[column.prop];

        // 判断数据类型
        if (typeof valueA === 'number' && typeof valueB === 'number') {
          return column.order === 'ascending' ? valueA - valueB : valueB - valueA;
        } else {
          // 字符串或其他类型排序（忽略大小写）
          return column.order === 'ascending'
            ? valueA.toString().localeCompare(valueB.toString())
            : valueB.toString().localeCompare(valueA.toString());
        }
      };
      
      return data.sort(compare);
    },
    handleSort_gwasinfo(column) {
      this.gwasinfo = this.handleSort(this.gwasinfo, column);
    },
    handleSort_causal_num(column) {
      this.causal_num = this.handleSort(this.causal_num, column);
    },
    plot_placo_snp_gene() {

      this.chart_pleioHeat = markRaw(echarts.init(this.$refs.chart_pleioHeat, null, { renderer: 'svg' }));
      const cancerlist = this.cancerList;
      const option = {
        tooltip: {
          position: 'bottom',
          trigger: 'item',
          formatter: function (params) {
              // 获取横纵坐标值
            let x = params.data[0];  // 纵坐标值
            let y = params.data[1];  // 横坐标值

            // 获取其他数据
            let cancer1 = cancerlist[params.data[0]];  // cancer1
            let cancer2 = cancerlist[params.data[1]];  // cancer2
            let pleiotropicData = params.data[2];  // pleiotropic SNP or Gene

            // 判断x与y的大小关系，显示不同的tooltip内容
            if (pleiotropicData > 0){
              if (x < y) {
                // 如果横坐标大于纵坐标，显示SNP
                return `Cancer1: ${cancer1}<br/>
                Cancer2: ${cancer2}<br/>
                Number of pleiotropic SNP: ${pleiotropicData}`;
              } else {
                // 如果横坐标小于纵坐标，显示Gene
                return `Cancer1: ${cancer1}<br/>
                Cancer2: ${cancer2}<br/>
                Number of pleiotropic gene: ${pleiotropicData}`;
              }
            }
            
          }
        },
        grid: {
          height: '65%',
          left: '35%',
          top: '2%',
        },
        xAxis: {
          type: 'category',
          data: this.cancerList,
          axisLabel: { rotate: 45, interval: 0 },
          splitArea: {
            show: false
          }
        },
        yAxis: {
          type: 'category',
          data: this.cancerList,
          splitArea: {
            show: false
          },
          // axisLabel: { rotate: 45, interval: 0 },
        },
        visualMap: {
          min: 0,
          max: 100,
          calculable: true,
          orient: 'vertical',
          left: '90%',
          top: '2%',
        },
        series: [
          {
            type: 'heatmap',
            data: this.pleio_snp_gene,
            label: {
              show: false
            },
          }
        ]
      };

      this.chart_pleioHeat.setOption(option);
    },
  }
};
</script>
  
<style scoped>
.document {
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
}

.main-title {
  text-align: center;
  font-size: 2em;
  margin-bottom: 20px;
  color: #409EFF;
}

.section {
  margin-bottom: 30px;
}

.sub-title {
  font-size: 1.5em;
  margin-bottom: 10px;
  color: #409EFF;
}
  
.content {
  font-size: 1.1em;
  line-height: 1.6;
}

.link-style {
  color: #409EFF;           /* 默认字体颜色为红色 */
  text-decoration: none; /* 默认没有下划线 */
}
.link-style:hover {
  text-decoration: underline; /* 鼠标悬停时显示下划线 */
}

.link-style:active {
  color: #409EFF; /* 点击时字体颜色不变 */
}
</style>