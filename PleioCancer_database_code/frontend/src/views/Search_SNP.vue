<template>
  <div style="margin: 10px 0"></div>
  <div class="container">
    <div class="container-menu" >
      <el-menu :default-active="activeMenu">
        <el-menu-item index="1" @click="scrollTo('menu_pleioSNP')">Pleiotropic SNP</el-menu-item>
        <el-menu-item index="2" @click="scrollTo('menu_meQTL')">meQTL</el-menu-item>
        <el-menu-item index="3" @click="scrollTo('menu_eQTL')">eQTL</el-menu-item>
        <el-menu-item index="4" @click="scrollTo('menu_pQTL')">pQTL</el-menu-item>
        <el-button type="primary" style="margin-left:20px;margin-top: 50px;" @click="plotNetwork">
          Plot network
        </el-button>
      </el-menu>
    </div>
    <div class="container-content">
      <el-collapse v-model="activeNames">
        <el-collapse-item id="menu_pleioSNP" title="Pleiotropic SNP" name="1">
          <div style="width:98%;margin:0 auto;margin-top: 20px;">
            <el-tabs v-model="active_tabs_pleioSNP">
              <el-tab-pane label="Table" name="first">
                <el-row :gutter="0">
                  <el-col :span="20">
                    <el-pagination
                      center
                      background
                      layout="prev, pager, next, total, jumper"
                      :page-size="pagesize_pleioSNP"
                      :total="pleioSNP.length"
                      :current-page="currpage_pleioSNP"
                      @current-change="handleCurrentChange_pleioSNP"
                      @size-change="handleSizeChange_pleioSNP"
                    >
                    </el-pagination>
                  </el-col>
                  <el-col :span="4" style="display: flex; justify-content: flex-end; align-items: center;">
                    <el-button @click="download_pleioSNP" type="primary" plain style="width: 100px;">Download</el-button>
                  </el-col>
                </el-row>
                
                <el-table
                  :data="pleioSNP.slice((currpage_pleioSNP - 1) * pagesize_pleioSNP, currpage_pleioSNP * pagesize_pleioSNP)"
                  border
                  style="margin: 10px 0; text-align: center; width: 100%; max-width: 2000px"
                  :header-cell-style="{ background: '#ecf5ff', color: '#337ecc' }"
                  v-loading="loading"
                  @sort-change="handleSort_pleioSNP"
                  :row-class-name="rowClassName"
                >

                  <el-table-column prop="cancer1" label="Cancer 1" min-width="120px" align="center" sortable="custom" />
                  <el-table-column prop="cancer2" label="Cancer 2" min-width="120px" align="center" sortable="custom" />
                  
                  <el-table-column prop="snpid" label="SNP" min-width="120px" align="center" />
                  <el-table-column label="SNP position" min-width="120px" align="center">
                    <template v-slot="slotProps">
                      {{ slotProps.row.hg19chr }}:{{ slotProps.row.bp }}
                    </template>
                  </el-table-column>
                  <el-table-column prop="alleles" align="center"  width="120 px">
                    <template v-slot:header>
                    <span>EA/OA</span>
                    <el-tooltip
                        content="Effect allele/Other allele"
                        placement="top-start"
                        effect="light"
                    >
                        <el-icon class="icon">
                            <QuestionFilled />
                        </el-icon>
                    </el-tooltip>
                    </template>
                  </el-table-column>
                  <el-table-column prop="T.placo" label="PLACO_T" min-width="120px" align="center" sortable="custom" />
                  <el-table-column prop="p.placo" label="PLACO_P" min-width="120px" align="center" sortable="custom" />
                  
                  <el-table-column prop="or.trait1" label="OR_cancer1" min-width="120px" align="center" sortable="custom"/>
                  <el-table-column prop="se.trait1" label="SE_cancer1" min-width="120px" align="center" sortable="custom"/>
                  <el-table-column prop="pval.trait1" label="P_cancer1" min-width="120px" align="center" sortable="custom"/>
                  <el-table-column prop="EURaf.trait1" min-width="120px" align="center" sortable="custom">
                    <template v-slot:header>
                    <span>EAF_cancer1</span>
                    <el-tooltip
                        content="Effect allele frequency"
                        placement="top-start"
                        effect="light"
                    >
                        <el-icon class="icon">
                            <QuestionFilled />
                        </el-icon>
                    </el-tooltip>
                    </template>
                  </el-table-column>

                  <el-table-column prop="or.trait2" label="OR_cancer2" min-width="120px" align="center" sortable="custom"/>
                  <el-table-column prop="se.trait2" label="SE_cancer2" min-width="120px" align="center" sortable="custom"/>
                  <el-table-column prop="pval.trait2" label="P_cancer2" min-width="120px" align="center" sortable="custom"/>
                  <el-table-column prop="EURaf.trait2" min-width="120px" align="center" sortable="custom" >
                    <template v-slot:header>
                    <span>EAF_cancer2</span>
                    <el-tooltip
                        content="Effect allele frequency"
                        placement="top-start"
                        effect="light"
                    >
                        <el-icon class="icon">
                            <QuestionFilled />
                        </el-icon>
                    </el-tooltip>
                    </template>
                  </el-table-column>
                </el-table>
              </el-tab-pane>
              <el-tab-pane label="Heatmap" name="second">
                <div style="display: flex; justify-content: center; align-items: center; width: 100%; height: 750px;">
                  <div id="chart_pleioSNP" ref="chart_pleioSNP" style="width: 750px; height: 750px;"></div>
                </div>
              </el-tab-pane>
            </el-tabs>
          </div>
        </el-collapse-item>
        <el-collapse-item id="menu_meQTL" title="meQTL" name="2">
          <div style="width:98%;margin:0 auto;margin-top: 20px;">
            <el-tabs v-model="active_tabs_meQTL">
              <el-tab-pane label="Table" name="first">
                <el-row :gutter="0">
                  <el-col :span="20">
                    <el-pagination
                      center
                      background
                      layout="prev, pager, next, total, jumper"
                      :page-size="pagesize_meQTL"
                      :total="meQTL.length"
                      :current-page="currpage_meQTL"
                      @current-change="handleCurrentChange_meQTL"
                      @size-change="handleSizeChange_meQTL"
                    >
                    </el-pagination>
                  </el-col>
                  <el-col :span="4" style="display: flex; justify-content: flex-end; align-items: center;">
                    <el-button @click="download_meqtl" type="primary" plain style="width: 100px;">Download</el-button>
                  </el-col>
                </el-row>
                <el-table
                  :data="meQTL.slice((currpage_meQTL - 1) * pagesize_meQTL, currpage_meQTL * pagesize_meQTL)"
                  border
                  style="margin: 10px 0; text-align: center; width: 100%; max-width: 2000px"
                  :header-cell-style="{ background: '#ecf5ff', color: '#337ecc' }"
                  v-loading="loading"
                  @sort-change="handleSort_meQTL"
                  :row-class-name="rowClassName"
                >
              
                  <el-table-column prop="SNP" label="SNP" min-width="120px" align="center" />
                  <el-table-column label="SNP position" min-width="120px" align="center">
                    <template v-slot="slotProps">
                      {{ slotProps.row.Chr }}:{{ slotProps.row.BP }}
                    </template>
                  </el-table-column>
                  <el-table-column align="center"  width="120 px">
                    <template v-slot:header>
                    <span>EA/OA</span>
                    <el-tooltip
                        content="Effect allele/Other allele"
                        placement="top-start"
                        effect="light"
                    >
                        <el-icon class="icon">
                            <QuestionFilled />
                        </el-icon>
                    </el-tooltip>
                    </template>
                    <template v-slot="slotProps">
                      {{ slotProps.row.A1 }}/{{ slotProps.row.A2 }}
                    </template>
                  </el-table-column>
                  <el-table-column prop="Freq" min-width="120px" align="center">
                    <template v-slot:header>
                    <span>EAF</span>
                    <el-tooltip
                        content="Effect allele frequency"
                        placement="top-start"
                        effect="light"
                    >
                        <el-icon class="icon">
                            <QuestionFilled />
                        </el-icon>
                    </el-tooltip>
                    </template>
                  </el-table-column>
                  <el-table-column prop="Probe" label="Methylation" min-width="120px" align="center" sortable="custom" />
                  <el-table-column label="Methylation position" min-width="120px" align="center">
                    <template v-slot="slotProps">
                      {{ slotProps.row.Probe_Chr }}:{{ slotProps.row.Probe_bp }}
                    </template>
                  </el-table-column>
                  <el-table-column prop="b" label="Beta" min-width="120px" align="center" sortable="custom" />
                  <el-table-column prop="SE" label="SE" min-width="120px" align="center" sortable="custom" />
                  <el-table-column prop="p" label="P" min-width="120px" align="center" sortable="custom" />
                </el-table>
              </el-tab-pane>
              <el-tab-pane label="Heatmap" name="second">
                <div style="display: flex; justify-content: center; align-items: center; width: 100%; height: 300px;">
                  <div id="chart_meqtl" ref="chart_meqtl" style="width: 750px; height: 300px;"></div>
                </div>
              </el-tab-pane>
            </el-tabs>
          </div>
        </el-collapse-item>
        <el-collapse-item id="menu_eQTL" title="eQTL" name="3">
          <div style="width:98%;margin:0 auto;margin-top: 20px;">
            <el-tabs v-model="active_tabs_eQTL">
              <el-tab-pane label="Table" name="first">
                <el-row :gutter="0">
                  <el-col :span="20">
                    <el-pagination
                      center
                      background
                      layout="prev, pager, next, total, jumper"
                      :page-size="pagesize_eQTL"
                      :total="eQTL.length"
                      :current-page="currpage_eQTL"
                      @current-change="handleCurrentChange_eQTL"
                      @size-change="handleSizeChange_eQTL"
                    >
                    </el-pagination>
                  </el-col>
                  <el-col :span="4" style="display: flex; justify-content: flex-end; align-items: center;">
                    <el-button @click="download_eqtl" type="primary" plain style="width: 100px;">Download</el-button>
                  </el-col>
                </el-row>
                
                <el-table
                  :data="eQTL.slice((currpage_eQTL - 1) * pagesize_eQTL, currpage_eQTL * pagesize_eQTL)"
                  border
                  style="margin: 10px 0; text-align: center; width: 100%; max-width: 2000px"
                  :header-cell-style="{ background: '#ecf5ff', color: '#337ecc' }"
                  v-loading="loading"
                  @sort-change="handleSort_eQTL"
                  :row-class-name="rowClassName"
                >

                  <el-table-column prop="SNP" label="SNP" min-width="120px" align="center" />
                  <el-table-column label="SNP position" min-width="120px" align="center">
                    <template v-slot="slotProps">
                      {{ slotProps.row.SNPChr }}:{{ slotProps.row.SNPPos }}
                    </template>
                  </el-table-column>
                  <el-table-column align="center"  width="120 px">
                    <template v-slot:header>
                    <span>EA/OA</span>
                    <el-tooltip
                        content="Effect allele/Other allele"
                        placement="top-start"
                        effect="light"
                    >
                        <el-icon class="icon">
                            <QuestionFilled />
                        </el-icon>
                    </el-tooltip>
                    </template>
                    <template v-slot="slotProps">
                      {{ slotProps.row.AssessedAllele }}/{{ slotProps.row.OtherAllele }}
                    </template>
                  </el-table-column>
                  <el-table-column prop="GeneSymbol" label="Gene" min-width="120px" align="center" sortable="custom" />
                  <el-table-column label="Gene position" min-width="120px" align="center">
                    <template v-slot="slotProps">
                      {{ slotProps.row.GeneChr }}:{{ slotProps.row.GenePos }}
                    </template>
                  </el-table-column>
                  <el-table-column prop="Zscore" label="Z-score" min-width="120px" align="center" sortable="custom" />
                  <el-table-column prop="Pvalue" label="P" min-width="120px" align="center" sortable="custom" />
                  <el-table-column prop="FDR" label="FDR" min-width="120px" align="center" sortable="custom" />
                </el-table>
              </el-tab-pane>
              <el-tab-pane label="Heatmap" name="second">
                <div style="display: flex; justify-content: center; align-items: center; width: 100%; height: 300px;">
                  <div id="chart_eqtl" ref="chart_eqtl" style="width: 750px; height: 300px;"></div>
                </div>
              </el-tab-pane>
            </el-tabs>
          </div>
        </el-collapse-item>
        <el-collapse-item id="menu_pQTL" title="pQTL" name="4">
          <div style="width:98%;margin:0 auto;margin-top: 20px;">
            <el-tabs v-model="active_tabs_pQTL">
              <el-tab-pane label="Table" name="first">
                <el-row :gutter="0">
                  <el-col :span="20">
                    <el-pagination
                      center
                      background
                      layout="prev, pager, next, total, jumper"
                      :page-size="pagesize_pQTL"
                      :total="pQTL.length"
                      :current-page="currpage_pQTL"
                      @current-change="handleCurrentChange_pQTL"
                      @size-change="handleSizeChange_pQTL"
                    >
                    </el-pagination>
                  </el-col>
                  <el-col :span="4" style="display: flex; justify-content: flex-end; align-items: center;">
                    <el-button @click="download_pqtl" type="primary" plain style="width: 100px;">Download</el-button>
                  </el-col>
                </el-row>
                
                <el-table
                  :data="pQTL.slice((currpage_pQTL - 1) * pagesize_pQTL, currpage_pQTL * pagesize_pQTL)"
                  border
                  style="margin: 10px 0; text-align: center; width: 100%; max-width: 2000px"
                  :header-cell-style="{ background: '#ecf5ff', color: '#337ecc' }"
                  v-loading="loading"
                  @sort-change="handleSort_pQTL"
                  :row-class-name="rowClassName"
                >

                  <el-table-column prop="SNP" label="SNP" min-width="120px" align="center" />
                  <el-table-column label="SNP position" min-width="120px" align="center">
                    <template v-slot="slotProps">
                      {{ slotProps.row.Chr }}:{{ slotProps.row.BP }}
                    </template>
                  </el-table-column>
                  <el-table-column align="center"  width="120 px">
                    <template v-slot:header>
                    <span>EA/OA</span>
                    <el-tooltip
                        content="Effect allele/Other allele"
                        placement="top-start"
                        effect="light"
                    >
                        <el-icon class="icon">
                            <QuestionFilled />
                        </el-icon>
                    </el-tooltip>
                    </template>
                    <template v-slot="slotProps">
                      {{ slotProps.row.A1 }}/{{ slotProps.row.A2 }}
                    </template>
                  </el-table-column>
                  <el-table-column prop="Freq" min-width="120px" align="center">
                    <template v-slot:header>
                    <span>EAF</span>
                    <el-tooltip
                        content="Effect allele frequency"
                        placement="top-start"
                        effect="light"
                    >
                        <el-icon class="icon">
                            <QuestionFilled />
                        </el-icon>
                    </el-tooltip>
                    </template>
                  </el-table-column>
                  <el-table-column prop="Gene" label="Protein" min-width="120px" align="center" sortable="custom" />
                  <el-table-column label="Protein position" min-width="120px" align="center">
                    <template v-slot="slotProps">
                      {{ slotProps.row.Probe_Chr }}:{{ slotProps.row.Probe_bp }}
                    </template>
                  </el-table-column>
                  <el-table-column prop="b" label="Beta" min-width="120px" align="center" sortable="custom" />
                  <el-table-column prop="SE" label="SE" min-width="120px" align="center" sortable="custom" />
                  <el-table-column prop="p" label="P" min-width="120px" align="center" sortable="custom" />
                </el-table>
              </el-tab-pane>
              <el-tab-pane label="Heatmap" name="second">
                <div style="display: flex; justify-content: center; align-items: center; width: 100%; height: 300px;">
                  <div id="chart_pqtl" ref="chart_pqtl" style="width: 750px; height: 300px;"></div>
                </div>
              </el-tab-pane>
            </el-tabs>

          </div>
        </el-collapse-item>
      </el-collapse>
    </div>
  </div>
</template>

<script>
import axios from "axios";
//导入nprogress加载进度条包即样式
import NProgress from 'nprogress'
import 'nprogress/nprogress.css'
import * as echarts from "echarts";
import { markRaw } from "vue";

//为axios添加拦截器
//在request拦截器中，展示进度条 NProgress.start()
axios.interceptors.request.use(config =>{
  // console.log(config);
  NProgress.start();
  config.headers.Authorization = window.sessionStorage.getItem('token');
  return config;//最后必须返回config
})
//在response拦截器中，隐藏进度条 NProgress.done()
axios.interceptors.response.use(config =>{
  // console.log(config);
  NProgress.done();
  return config;//最后必须返回config
})

export default {
  name: "SearchPleiotropySNP",
  data() {
    return {
      pleioSNP: [],
      meQTL: [],
      eQTL:[],
      pQTL: [],
      snp: this.$route.query.snp,   // 从URL中获取查询参数snp
      error: null,                   // 错误信息

      // 表格
      pagesize_pleioSNP: 10,
      currpage_pleioSNP: 1,
      pagesize_meQTL: 10,
      currpage_meQTL: 1,
      pagesize_eQTL: 10,
      currpage_eQTL: 1,
      pagesize_pQTL: 10,
      currpage_pQTL: 1,
      loading: false,
      

      // 当前选中的菜单项
      activeMenu: '1',
      
      // 当前显示的表格
      activeTab: 1,
      activeNames: ['1','2','3','4'],
      active_tabs_pleioSNP: 'first',
      active_tabs_meQTL: 'first',
      active_tabs_eQTL: 'first',
      active_tabs_pQTL: 'first',

      chart_meqtl: null,
      chart_pleioSNP: null,
      chart_eqtl: null,
      chart_pqtl: null,
    };
  },

  created() {
    // 获取查询参数并请求数据
    this.fetchData(this.snp);
  },

  methods: {
    scrollTo(sectionId) {
      const section = document.getElementById(sectionId);
      if (section) {
        section.scrollIntoView({ behavior: 'smooth' });
      }
    },
    handleCurrentChange_pleioSNP(cpage) {
      this.currpage_pleioSNP= cpage;
    },
    handleSizeChange_pleioSNP(psize) {
      this.pagesize_pleioSNP = psize;
    },
    handleCurrentChange_eQTL(cpage) {
      this.currpage_eQTL = cpage;
    },
    handleSizeChange_eQTL(psize) {
      this.pagesize_eQTL = psize;
    },
    handleCurrentChange_meQTL(cpage) {
      this.currpage_meQTL = cpage;
    },
    handleSizeChange_meQTL(psize) {
      this.pagesize_meQTL = psize;
    },
    handleCurrentChange_pQTL(cpage) {
      this.currpage_pQTL = cpage;
    },
    handleSizeChange_pQTL(psize) {
      this.pagesize_pQTL = psize;
    },
    // 通用排序函数
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

    handleSort_pleioSNP(column) {
      this.pleioSNP = this.handleSort(this.pleioSNP, column);
    },
    handleSort_eQTL(column) {
      this.eQTL = this.handleSort(this.eQTL, column);
    },
    handleSort_meQTL(column) {
      this.meQTL = this.handleSort(this.meQTL, column);
    },
    handleSort_pQTL(column) {
      this.pQTL = this.handleSort(this.pQTL, column);
    },

    downloadTable(data, columnMap, filename) {
      // 1. 获取展示的列的标题
      const headers = Object.keys(columnMap);  // 使用列名作为 CSV 的头

      // 2. 构造导出的数据，根据列映射处理每一行
      const tableData = data.map(row => {
        return headers.map(col => {
          const column = columnMap[col];
          return typeof column === 'function' ? column(row) : row[column];  // 处理函数和普通字段
        });
      });

      // 3. 创建CSV内容
      let csvContent = '';
      csvContent += headers.join(',') + '\n';  // 头部以逗号分隔

      // 4. 添加数据行
      tableData.forEach(row => {
        csvContent += row.join(',') + '\n';  // 行内数据以逗号分隔
      });

      // 5. 创建blob对象并触发下载
      const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
      const url = URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.setAttribute('href', url);
      link.setAttribute('download', filename);
      link.style.visibility = 'hidden';
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    },
    
    download_pleioSNP() {
      const columnMap = {   
        'Cancer 1': 'cancer1',
        'Cancer 2': 'cancer2',
        'SNP': 'snpid',
        'SNP position': (row) => `${row.hg19chr}:${row.bp}`,
        "EA/OA": 'alleles',

        "PLACO_T":'T.placo',
        "PLACO_P":'p.placo',

        "OR_cancer1":'or.trait1',
        "SE_cancer1":'se.trait1',
        "P_cancer1":'pval.trait1',
        "EAF_cancer1":'EURaf.trait1',

        "OR_cancer2":'or.trait2',
        "SE_cancer2":'se.trait2',
        "P_cancer2":'pval.trait2',
        "EAF_cancer2":'EURaf.trait2',
      };

      this.downloadTable(this.pleioSNP, columnMap, 'Pleiotropic_SNP_FDR0.05.csv');
    },
    download_meqtl() {
      const columnMap = { 
        'SNP': 'SNP',
        'SNP position': (row) => `${row.Chr}:${row.BP}`,
        "EA/OA": (row) => `${row.A1}:${row.A2}`,
        "EAF":'Freq',
        "Methylation":'Probe',
        "Methylation position":(row) => `${row.Probe_Chr}:${row.Probe_bp}`,
        "Beta":'b',
        "SE":'SE',
        "P":'p',
      };

      this.downloadTable(this.meQTL, columnMap, 'meQTL_P5e-8.csv');
    },
    download_eqtl() {
      const columnMap = {
        'SNP': 'SNP',
        'SNP position': (row) => `${row.SNPChr}:${row.SNPPos}`,
        'EA/OA': (row) => `${row.AssessedAllele}/${row.OtherAllele}`,
        'Gene': 'GeneSymbol',
        'Gene position': (row) => `${row.GeneChr}:${row.GenePos}`,
        "Z-score": 'Zscore',
        "P": "Pvalue",
        "FDR": "FDR",
      };

      this.downloadTable(this.eQTL, columnMap, 'eQTL_P5e-8.csv');
    },
    download_pqtl() {
      const columnMap = { 
        'SNP': 'SNP',
        'SNP position': (row) => `${row.Chr}:${row.BP}`,
        "EA/OA": (row) => `${row.A1}:${row.A2}`,
        "EAF":'Freq',
        "Protein":'Gene',
        "Protein position":(row) => `${row.Probe_Chr}:${row.Probe_bp}`,
        "Beta":'b',
        "SE":'SE',
        "P":'p',
      };

      this.downloadTable(this.pQTL, columnMap, 'pQTL_P5e-8.csv');
    },

    fetchData() {
      if (!this.snp) return;  // 如果没有提供snp参数，直接返回

      this.loading = true;
      this.error = null;

      axios.get("/api/cancerdb/pleio_snp",{params: { searchSNPs: this.snp },})
        .then((res) => {
          this.pleioSNP = res.data.pleioSNP;
          this.eQTL = res.data.eQTL;
          this.meQTL = res.data.meQTL;
          this.pQTL = res.data.pQTL;
          this.loading = false; 

          const areAllListsEmpty = [this.pleioSNP, this.eQTL, this.meQTL, this.pQTL].every(list => Array.isArray(list) && list.length === 0);
          if (areAllListsEmpty) {
            // 如果后端返回的数据长度为0，则弹出窗口提示用户
            this.$alert("Sorry, this SNP is not a pleiotropic SNP related to any cancers in our results.", "No results", {
              confirmButtonText: "OK",
            });
          } else {
            if(this.pleioSNP.length > 0) {
              this.plot_pleioSNP(this.pleioSNP);
            };
            if(this.meQTL.length > 0) {
              this.plot_meqtl(this.meQTL);
            };
            if(this.eQTL.length > 0) {
              this.plot_eqtl(this.eQTL);
            };
            if(this.pQTL.length > 0) {
              this.plot_pqtl(this.pQTL);
            };
          };
        })
        .catch((err) => {console.log(err)})
    },

    plot_pleioSNP(data) {
      // 获取所有cancer1和cancer2的唯一值
      const cancer1List = [...new Set(data.map(item => item.cancer1))];
      const cancer2List = [...new Set(data.map(item => item.cancer2))];

      // 创建数据矩阵
      const matrix = [];
      cancer1List.forEach(cancer1 => {
        const row = [];
        cancer2List.forEach(cancer2 => {
          // 找到对应cancer1和cancer2的log10FDR
          const item = data.find(d => d.cancer1 === cancer1 && d.cancer2 === cancer2);
          row.push(item ? item.log10P : null); // 如果没有数据，填充null
        });
        matrix.push(row);
      });

      // 使用非响应式实例化，否则拖动范围时报错https://blog.csdn.net/weixin_50508597/article/details/123552563
      this.chart_pleioSNP = markRaw(echarts.init(this.$refs.chart_pleioSNP,null, { renderer : 'svg' })); // 渲染为svg，防止放大模糊
      const option = {
        title: {
          text: "P value based on pleiotropy analysis",
          left: 'center',  // 标题位置：left, right, center
          top: 0,  // 标题距离顶部的距离
          textStyle: {
            fontSize: 14,  // 设置标题字体大小
            fontWeight: 'bold',  // 设置标题字体粗细
          },
        },
        textStyle: {
          fontSize: 12,  // 设置所有字体的大小
        },
        tooltip: {
          position: 'bottom',
          formatter: function (params) {
            return `<b>Cancer1:</b> ${cancer1List[params.data[0]]}<br/>
                    <b>Cancer2:</b> ${cancer2List[params.data[1]]}<br/>
                    <b>-log10P:</b> ${params.data[2]}<br/>`;
          }
        },
        grid: {
          left:200,
          // top: '20%',
          height: '50%'
        },
        xAxis: {
          type: 'category',
          data: cancer1List,
          name: 'Cancer1',
          nameGap: 5,
          axisLabel: {
            rotate: 45, // 控制坐标标签旋转角度
            interval: 0,  // 确保所有标签都显示
          },
          splitArea: {
            show: false, // 不显示网格背景，背景有颜色，会视觉干扰
          }
        },
        yAxis: {
          type: 'category',
          data: cancer2List,
          name: 'Cancer2',
          nameGap: 5,
          axisLabel: {
            interval: 0,  // 确保所有标签都显示
          },
          splitArea: {
            show: false,
          }
        },
        visualMap: {
          min: 0,
          max: Math.max(...data.map(d => d.log10P)),
          calculable: true,
          orient: 'vertical',
          left: '680',
          top: '0',
          inRange: {
            color: ['#FFFFFF', "rgb(191,68,76)"]
          }
        },
        series: [{
          name: 'log10P',
          type: 'heatmap',
          data: [],
          label: {
            show: false,
          },
          itemStyle: {
            normal: {
              borderColor: '#fff',
              borderWidth: 1
            }
          }
        }]
      };

      // 填充数据
      const seriesData = [];
      for (let i = 0; i < matrix.length; i++) {
        for (let j = 0; j < matrix[i].length; j++) {
          seriesData.push([i, j, matrix[i][j]]);
        }
      }

      option.series[0].data = seriesData;
      this.chart_pleioSNP.setOption(option)
    },
    plot_meqtl(data) {
      this.chart_meqtl = markRaw(echarts.init(this.$refs.chart_meqtl, null, { renderer: 'svg' }));

      // 提取热图数据
      data.sort((a, b) => a.b - b.b);
      const values = data.map(item => item.b);  // 热图值
      const methy = data.map(item => item.Probe);  // 横轴数据
      const snp = data[0].SNP;  // 纵轴只有一个symbol

      // 将数据转换为热图需要的二维数组格式
      const heatmapData = methy.map((Probe, index) => {
        return [Probe, 0, values[index]];  // 使用expoId作为横轴，0作为纵轴
      });

      const maxAbsValue = Math.max(...values.map(v => Math.abs(v)));  // 获取绝对值最大的数
      // console.log(heatmapData)
      // 配置项
      const option = {
        title: {
          text: "Association (beta) between SNP and methylation based on meQTL data",
          left: 'center',
          top: 0,
          textStyle: { fontSize: 14, fontWeight: 'bold' }
        },
        tooltip: {
          position: 'right',
          formatter: function (params) {
            const data_tooltip = data[params.dataIndex];
            return `<b>SNP:</b> ${snp}<br/>
                    <b>Methylation:</b> ${data_tooltip.Probe}<br/>
                    <b>Beta:</b> ${params.data[2]}<br/>`;
          }
        },
        grid: {
          left: '10%',
          right: '10%',
          bottom: '10%',
          top: '10%',
        },
        xAxis: {
          type: 'category',
          data: methy,  // 横轴数据
        },
        yAxis: {
          type: 'category',
          data: [snp],  // 纵轴只有一个symbol
        },
        visualMap: {
          min: -maxAbsValue,
          max: maxAbsValue,
          calculable: true,
          orient: 'vertical',
          left: '680',
          top: '10%',
          inRange: {
            color: ['#313695','#FFFFFF','#a50026']
          }
        },
        series: [{
          name: 'Heatmap',
          type: 'heatmap',
          data: heatmapData,  // 热图数据
          label: {
            show: false,
            color: '#fff',
            fontSize: 12,
          },
          emphasis: {
            itemStyle: {
              borderColor: 'white',
              borderWidth: 1
            }
          }
        }]
      };

      this.chart_meqtl.setOption(option);
    },
    plot_eqtl(data) {
      this.chart_eqtl = markRaw(echarts.init(this.$refs.chart_eqtl, null, { renderer: 'svg' }));

      // 提取热图数据
      data.sort((a, b) => a.Zscore - b.Zscore);
      const values = data.map(item => item.Zscore);  // 热图值
      const gene = data.map(item => item.GeneSymbol);  // 横轴数据
      const snp = data[0].SNP;  // 纵轴只有一个symbol

      // 将数据转换为热图需要的二维数组格式
      const heatmapData = gene.map((GeneSymbol, index) => {
        return [GeneSymbol, 0, values[index]];  // 使用expoId作为横轴，0作为纵轴
      });

      const maxAbsValue = Math.max(...values.map(v => Math.abs(v)));  // 获取绝对值最大的数
      // console.log(heatmapData)
      // 配置项
      const option = {
        title: {
          text: "Association (z-score) between SNP and gene based on eQTL data",
          left: 'center',
          top: 0,
          textStyle: { fontSize: 14, fontWeight: 'bold' }
        },
        tooltip: {
          position: 'right',
          formatter: function (params) {
            const data_tooltip = data[params.dataIndex];
            return `<b>SNP:</b> ${snp}<br/>
                    <b>Gene:</b> ${data_tooltip.GeneSymbol}<br/>
                    <b>Z-score:</b> ${params.data[2]}<br/>`;
          }
        },
        grid: {
          left: '10%',
          right: '10%',
          bottom: '10%',
          top: '10%',
        },
        xAxis: {
          type: 'category',
          data: gene,  // 横轴数据
        },
        yAxis: {
          type: 'category',
          data: [snp],  // 纵轴只有一个symbol
        },
        visualMap: {
          min: -maxAbsValue,
          max: maxAbsValue,
          calculable: true,
          orient: 'vertical',
          left: '680',
          top: '10%',
          inRange: {
            color: ['#313695','#FFFFFF','#a50026']
          }
        },
        series: [{
          name: 'Heatmap',
          type: 'heatmap',
          data: heatmapData,  // 热图数据
          label: {
            show: false,
            color: '#fff',
            fontSize: 12,
          },
          emphasis: {
            itemStyle: {
              borderColor: 'white',
              borderWidth: 1
            }
          }
        }]
      };

      this.chart_eqtl.setOption(option);
    },
    plot_pqtl(data) {
      this.chart_pqtl = markRaw(echarts.init(this.$refs.chart_pqtl, null, { renderer: 'svg' }));

      // 提取热图数据
      data.sort((a, b) => a.b - b.b);
      const values = data.map(item => item.b);  // 热图值
      const protein = data.map(item => item.Probe);  // 横轴数据
      const snp = data[0].SNP;  // 纵轴只有一个symbol

      // 将数据转换为热图需要的二维数组格式
      const heatmapData = protein.map((Probe, index) => {
        return [Probe, 0, values[index]];  // 使用expoId作为横轴，0作为纵轴
      });

      const maxAbsValue = Math.max(...values.map(v => Math.abs(v)));  // 获取绝对值最大的数
      // console.log(heatmapData)
      // 配置项
      const option = {
        title: {
          text: "Association (beta) between SNP and protein based on pQTL data",
          left: 'center',
          top: 0,
          textStyle: { fontSize: 14, fontWeight: 'bold' }
        },
        tooltip: {
          position: 'right',
          formatter: function (params) {
            const data_tooltip = data[params.dataIndex];
            return `<b>SNP:</b> ${snp}<br/>
                    <b>Protein:</b> ${data_tooltip.Gene}<br/>
                    <b>Beta:</b> ${params.data[2]}<br/>`;
          }
        },
        grid: {
          left: '10%',
          right: '10%',
          bottom: '10%',
          top: '10%',
        },
        xAxis: {
          type: 'category',
          data: protein,  // 横轴数据
          axisLabel: {
            formatter: function (index) {
              const cur_gene = data.find(d => d.Probe === index);
              return cur_gene.Gene;
            },
          },
        },
        yAxis: {
          type: 'category',
          data: [snp],  // 纵轴只有一个symbol
        },
        visualMap: {
          min: -maxAbsValue,
          max: maxAbsValue,
          calculable: true,
          orient: 'vertical',
          left: '680',
          top: '10%',
          inRange: {
            color: ['#313695','#FFFFFF','#a50026']
          }
        },
        series: [{
          name: 'Heatmap',
          type: 'heatmap',
          data: heatmapData,  // 热图数据
          label: {
            show: false,
            color: '#fff',
            fontSize: 12,
          },
          emphasis: {
            itemStyle: {
              borderColor: 'white',
              borderWidth: 1
            }
          }
        }]
      };

      this.chart_pqtl.setOption(option);
    },
    plotNetwork() {
      // 将数据存储到 sessionStorage 或 localStorage
      sessionStorage.setItem('pleioSNP', JSON.stringify(this.pleioSNP));
      sessionStorage.setItem('eQTL', JSON.stringify(this.eQTL));
      sessionStorage.setItem('meQTL', JSON.stringify(this.meQTL));
      sessionStorage.setItem('pQTL', JSON.stringify(this.pQTL));

      // 跳转到 B 页面，保持路由不变
      this.$router.replace({
        path: '/cancerdb/network'  // 这里不传递任何参数
      });
    },
  },
}
</script>
  

<style lang="scss" scoped>
:deep(.el-select__tags-text) {
  color: black;
}
.icon {
  padding: 5px;
}
.search {
  width: 1750px;
  border:1px solid #e9e9eb;
  margin: 0 auto;
  margin-top: +10px;
}
.searchContent{
  padding-left: 80px;
  padding-right: 80px;
}
.searchExample{
  padding-left: 450px;
  padding-right: 450px;
}
.cancerTypeSelect {
  position: relative;
  float: left;
  top: -5px;
  font-size: 20px;
  font-weight: bold;
  color: #337ecc;
}
.rsIDinputBox{
  position: relative;
  float: left;
  top: -5px;
  font-size: 20px;
  font-weight: bold;
  color: #337ecc;
}
.geneInputBox{
  position: relative;
  float: left;
  top: -5px;
  font-size: 20px;
  font-weight: bold;
  color: #337ecc;
}
.el-input {
  height: 40px;
}
.searchButton{
  position: relative;
  top: -5px;
}
.table_display{
  width: 1750px;
  border: 1px solid #e9e9eb;
  margin: 0 auto;
}
.el-row{
  margin: 20px;
}
.el-menu{
  // font-weight: bold;
  font-size: 16px;
}

:deep(.el-collapse-item__header) {
  background-color: #f5f7fa;
  border-bottom: 1px solid #ebeef5;
  font-size: 16px;
  font-weight: bold;
  padding-left: 1%;
  color: #337ecc;
}
.container {
  display: flex;
  width: 1750px;
  height: 850px;
  margin: 0 auto;
}

.container-menu {
  width: 150px;
  position: fixed;
}
.el-menu {
  border-right: 0;
}

.container-content {
  margin-left: 150px;
  flex: 1;
  box-sizing: border-box;
  overflow-y: auto;
  border-left: 1px solid #ebeef5;
}

</style>
  