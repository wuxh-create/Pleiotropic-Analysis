<template>
  <div style="margin: 10px 0"></div>
  <div class="container">
    <div class="container-menu" >
      <el-menu :default-active="activeMenu" :default-openeds="['2']">
        <el-menu-item index="1" @click="scrollTo('menu_meQTL')">meQTL</el-menu-item>
        <el-menu-item index="2" @click="scrollTo('menu_smr_meQTL')">Causal methylation</el-menu-item>
        <el-button type="primary" style="margin-left:20px;margin-top: 50px;" @click="plotNetwork">
          Plot network
        </el-button>
      </el-menu>
    </div>
    <div class="container-content">
      <el-collapse v-model="activeNames">
        <el-collapse-item id="menu_meQTL" title="meQTL" name="1">
          <div style="width:98%;margin:0 auto;margin-top: 20px;">
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
              <el-table-column prop="PLACO" label="Pleiotropic SNP" min-width="120px" align="center" sortable="custom" :formatter="formatBoolean" />
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
          </div>
        </el-collapse-item>
        <el-collapse-item id="menu_smr_meQTL" title="Causal methylation" name="3">
          <div style="width:98%;margin:0 auto;margin-top: 20px;">
            <el-tabs v-model="active_tabs_smr_meQTL">
              <el-tab-pane label="Table" name="first">
                <el-row :gutter="0">
                  <el-col :span="20">
                    <el-pagination
                      center
                      background
                      layout="prev, pager, next, total, jumper"
                      :page-size="pagesize_smr_meQTL"
                      :total="smr_meQTL.length"
                      :current-page="currpage_smr_meQTL"
                      @current-change="handleCurrentChange_smr_meQTL"
                      @size-change="handleSizeChange_smr_meQTL"
                    >
                    </el-pagination>
                  </el-col>
                  <el-col :span="4" style="display: flex; justify-content: flex-end; align-items: center;">
                    <el-button @click="download_smr_meqtl" type="primary" plain style="width: 100px;">Download</el-button>
                  </el-col>
                </el-row>
                <el-table
                  :data="smr_meQTL.slice((currpage_smr_meQTL - 1) * pagesize_smr_meQTL, currpage_smr_meQTL * pagesize_smr_meQTL)"
                  border
                  style="margin: 10px 0; text-align: center; width: 100%; max-width: 2000px"
                  :header-cell-style="{ background: '#ecf5ff', color: '#337ecc' }"
                  v-loading="loading"
                  @sort-change="handleSort_smr_meQTL"
                  :row-class-name="rowClassName"
                >
                  <el-table-column prop="probeID" label="Methylation" min-width="120px" align="center" />
                  <el-table-column label="Methylation position" min-width="120px" align="center">
                    <template v-slot="slotProps">
                      {{ slotProps.row.ProbeChr }}:{{ slotProps.row.Probe_bp }}
                    </template>
                  </el-table-column>
                  <el-table-column prop="cancer" label="Cancer" min-width="120px" align="center"  sortable="custom" />
                  
                  <el-table-column prop="b_SMR" label="SMR_beta" min-width="120px" align="center" sortable="custom"/>
                  <el-table-column prop="se_SMR" label="SMR_SE" min-width="120px" align="center" sortable="custom"/>
                  <el-table-column prop="p_SMR" label="SMR_P" min-width="120px" align="center" sortable="custom"/>
                  <el-table-column prop="p_SMR_multi" label="SMR_P_multi" min-width="120px" align="center" sortable="custom"/>
                  <el-table-column prop="fdr" label="SMR_FDR" min-width="120px" align="center" sortable="custom"/>
                  <el-table-column prop="p_HEIDI" label="HEIDI_P" min-width="120px" align="center" sortable="custom"/>
                  <el-table-column prop="nsnp_HEIDI" label="HEIDI_nsnp" min-width="120px" align="center" sortable="custom"/>
                
                  <!-- topSNP  topSNP_chr      topSNP_bp       A1      A2      Freq -->
                  <el-table-column prop="topSNP" label="Top SNP" min-width="120px" align="center"  sortable="custom">
                    <template v-slot="scope">
                      <a :href="'http://localhost:8081/cancerdb/search_pleio_snp?snp=' + scope.row.topSNP" target="_blank" class="link-snpid">
                        {{ scope.row.topSNP }}
                      </a>
                    </template>
                  </el-table-column>
                  <el-table-column prop="SNP_position" label="SNP position" min-width="120px" align="center"  sortable="custom" />
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
                  <el-table-column prop="Freq" min-width="120px" align="center" sortable="custom">
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

                  <!-- b_eQTL  se_eQTL p_eQTL -->
                  <el-table-column prop="b_eQTL" label="eQTL_beta" min-width="120px" align="center" sortable="custom"/>
                  <el-table-column prop="se_eQTL" label="eQTL_SE" min-width="120px" align="center" sortable="custom"/>
                  <el-table-column prop="p_eQTL" label="eQTL_P" min-width="120px" align="center" sortable="custom"/>

                  <!-- b_GWAS  se_GWAS p_GWAS -->
                  <el-table-column prop="b_GWAS" label="GWAS_beta" min-width="120px" align="center" sortable="custom"/>
                  <el-table-column prop="se_GWAS" label="GWAS_SE" min-width="120px" align="center" sortable="custom"/>
                  <el-table-column prop="p_GWAS" label="GWAS_P" min-width="120px" align="center" sortable="custom"/>
                  
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
  console.log(config);
  NProgress.start();
  config.headers.Authorization = window.sessionStorage.getItem('token');
  return config;//最后必须返回config
})
//在response拦截器中，隐藏进度条 NProgress.done()
axios.interceptors.response.use(config =>{
  console.log(config);
  NProgress.done();
  return config;//最后必须返回config
})

export default {
  name: "SearchCausalMethy",
  data() {
    return {
      meQTL: [],
      smr_meQTL: [],
      smr_meQTL_eQTL:[],
      methy: this.$route.query.methy,   
      error: null,                   // 错误信息

      // 表格
      pagesize_meQTL: 10,
      currpage_meQTL: 1,
      pagesize_smr_meQTL: 10,
      currpage_smr_meQTL: 1,
      pagesize_smr_meQTL_eQTL: 10,
      currpage_smr_meQTL_eQTL: 1,
      loading: false,
      
      // 当前选中的菜单项
      activeMenu: '1',
      
      // 当前显示的表格
      activeTab: 1,
      activeNames: ['1','2','3'],

      //显示表格还是heatmap
      active_tabs_smr_meQTL:'first',
      active_tabs_smr_meQTL_eQTL: 'first',

      chart_smr_meqtl_eqtl: null,
      chart_eqtl: null,

    };
  },

  created() {
    // 获取查询参数并请求数据
    this.fetchData(this.methy);
  },

  methods: {
    formatBoolean(row, column, cellValue) {
      return cellValue ? 'True' : 'False';
    },
    scrollTo(sectionId) {
      const section = document.getElementById(sectionId);
      if (section) {
        section.scrollIntoView({ behavior: 'smooth' });
      }
    },
    handleCurrentChange_meQTL(cpage) {
      this.currpage_meQTL = cpage;
    },
    handleSizeChange_meQTL(psize) {
      this.pagesize_meQTL = psize;
    },
    handleCurrentChange_smr_meQTL_eQTL(cpage) {
      this.currpage_smr_meQTL_eQTL = cpage;
    },
    handleSizeChange_smr_meQTL_eQTL(psize) {
      this.pagesize_smr_meQTL_eQTL = psize;
    },
    handleCurrentChange_smr_meQTL(cpage) {
      this.currpage_smr_meQTL = cpage;
    },
    handleSizeChange_smr_meQTL(psize) {
      this.pagesize_smr_meQTL = psize;
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

    handleSort_meQTL(column) {
      this.meQTL = this.handleSort(this.meQTL, column);
    },
    handleSort_smr_meQTL_eQTL(column) {
      this.smr_meQTL_eQTL = this.handleSort(this.smr_meQTL_eQTL, column);
    },
    handleSort_smr_meQTL(column) {
      this.smr_meQTL = this.handleSort(this.smr_meQTL, column);
    },

    // 通用下载函数
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
    download_smr_meqtl_eqtl() {
      const columnMap = {
        'Methylation': 'Expo_ID',
        'Methylation position': (row) => `${row.Expo_Chr}:${row.Expo_bp}`,
        'Gene': 'symbol',
        'Gene position': (row) => `${row.Outco_Chr}:${row.Outco_bp}`,

        SMR_beta: 'b_SMR',
        SMR_SE: 'se_SMR',
        SMR_P: 'p_SMR',
        SMR_P_multi: 'p_SMR_multi',
        SMR_FDR: 'fdr',
        HEIDI_P: 'p_HEIDI',
        HEIDI_nsnp: 'nsnp_HEIDI',

        "Top SNP": 'topSNP',
        'SNP position': 'SNP_position',
        "EA/OA": 'alleles',
        EAF: 'Freq',
        meQTL_beta: 'b_Expo',
        meQTL_SE: 'se_Expo',
        meQTL_P: 'p_Expo',
        eQTL_beta: 'b_Outco',
        eQTL_SE: 'se_Outco',
        eQTL_P: 'p_Outco'
      };

      this.downloadTable(this.smr_meQTL_eQTL, columnMap, 'SMR_meQTL-eQTL_FDR0.05.csv');
    },
    download_smr_meqtl() {
      const columnMap = {
        Methylation: 'probeID',
        'Methylation position': (row) => `${row.ProbeChr}:${row.Probe_bp}`,
        Cancer: 'cancer',

        SMR_beta: 'b_SMR',
        SMR_SE: 'se_SMR',
        SMR_P: 'p_SMR',
        SMR_P_multi: 'p_SMR_multi',
        SMR_FDR: 'fdr',
        HEIDI_P: 'p_HEIDI',
        HEIDI_nsnp: 'nsnp_HEIDI',

        "Top SNP": 'topSNP',
        'SNP position': 'SNP_position',
        "EA/OA": 'alleles',
        EAF: 'Freq',
        meQTL_beta: 'b_eQTL',
        meQTL_SE: 'se_eQTL',
        meQTL_P: 'p_eQTL',
        GWAS_beta: 'b_GWAS',
        GWAS_SE: 'se_GWAS',
        GWAS_P: 'p_GWAS'
        
      };

      this.downloadTable(this.smr_meQTL, columnMap, 'SMR_meQTL_FDR0.05.csv');
    },

    fetchData() {
      if (!this.methy) return;  // 如果没有提供snp参数，直接返回

      this.loading = true;
      this.error = null;

      axios.get("/api/cancerdb/SMR_meQTL",{params: { searchMethy: this.methy },})
        .then((res) => {
          this.meQTL = res.data.meQTL;
          this.smr_meQTL_eQTL = res.data.smr_meQTL_eQTL;
          this.smr_meQTL = res.data.smr_meQTL;
          this.loading = false; 
          const areAllListsEmpty = [this.meQTL, this.smr_meQTL_eQTL, this.smr_meQTL].every(list => Array.isArray(list) && list.length === 0);
          if (areAllListsEmpty) {
            // 如果后端返回的数据长度为0，则弹出窗口提示用户
            this.$alert("Sorry, this methylation is not a causal site related to any cancers in our results.", "No results", {
              confirmButtonText: "OK",
            });
          } else {
            if(this.smr_meQTL_eQTL.length > 0) {
              this.plot_smr_meqlt_eqtl(this.smr_meQTL_eQTL);
            };
            if(this.smr_meQTL.length > 0) {
              this.plot_smr_meqtl(this.smr_meQTL);
            };
          };
        })
        .catch((err) => {console.log(err)})
    },

    plot_smr_meqlt_eqtl(data) {
      this.chart_meqtl_eqtl = markRaw(echarts.init(this.$refs.chart_meqtl_eqtl, null, { renderer: 'svg' }));

      // 提取热图数据
      data.sort((a, b) => a.b_SMR - b.b_SMR);
      const values = data.map(item => item.b_SMR);  // 热图值
      const gene = data.map(item => item.symbol);  // 横轴数据
      const expoIds = data[0].Expo_ID;  // 纵轴只有一个symbol

      // 将数据转换为热图需要的二维数组格式
      const heatmapData = gene.map((symbol, index) => {
        return [symbol, 0, values[index]];  // 使用expoId作为横轴，0作为纵轴
      });
      const maxAbsValue = Math.max(...values.map(v => Math.abs(v)));  // 获取绝对值最大的数
      // 配置项
      const option = {
        title: {
          text: "Causal effect (beta) between methylation (exposure) and gene (outcome) based on SMR analysis",
          left: 'center',
          top: 0,
          textStyle: { fontSize: 14, fontWeight: 'bold' }
        },
        tooltip: {
          position: 'right',
          formatter: function (params) {
            const data_tooltip = data[params.dataIndex];
            return `<b>Methylation:</b> ${expoIds}<br/>
                    <b>Gene:</b> ${data_tooltip.symbol}<br/>
                    <b>Beta_SMR:</b> ${params.data[2]}<br/>`;
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
          data: [expoIds],  // 纵轴只有一个symbol
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

      this.chart_meqtl_eqtl.setOption(option);
    },
    plot_smr_meqtl(data) {
      this.chart_meqtl = markRaw(echarts.init(this.$refs.chart_meqtl, null, { renderer: 'svg' }));

      // 提取热图数据
      data.sort((a, b) => a.b_SMR - b.b_SMR);
      const values = data.map(item => item.b_SMR);  // 热图值
      const cancers = data.map(item => item.cancer);  // 横轴数据
      const probe = data[0].probeID;  // 纵轴只有一个symbol

      // 将数据转换为热图需要的二维数组格式
      const heatmapData = cancers.map((cancer, index) => {
        return [cancer, 0, values[index]];  
      });

      const maxAbsValue = Math.max(...values.map(v => Math.abs(v)));  // 获取绝对值最大的数

      // 配置项
      const option = {
        title: {
          text: "Causal effect (beta) between methylation (exposure) and cancer (outcome) based on SMR analysis",
          left: 'center',
          top: 0,
          textStyle: { fontSize: 14, fontWeight: 'bold' }
        },
        tooltip: {
          position: 'right',
          formatter: function (params) {
            const data_tooltip = data[params.dataIndex];
            return `<b>Methylation:</b> ${probe}<br/>
                    <b>Cancer:</b> ${data_tooltip.cancer}<br/>
                    <b>Beta_SMR:</b> ${params.data[2]}<br/>`;
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
          data: cancers,  // 横轴数据
        },
        yAxis: {
          type: 'category',
          data: [probe],  // 纵轴只有一个symbol
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
    plotNetwork() {
      // 将数据存储到 sessionStorage 或 localStorage
      sessionStorage.setItem('meQTL', JSON.stringify(this.meQTL));
      sessionStorage.setItem('smr_meQTL_eQTL', JSON.stringify(this.smr_meQTL_eQTL));
      sessionStorage.setItem('smr_meQTL', JSON.stringify(this.smr_meQTL));
      

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

.container-content {
  margin-left: 150px;
  flex: 1;
  box-sizing: border-box;
  overflow-y: auto;
}
.link-snpid {
  color: #409EFF;           /* 默认字体颜色为红色 */
  text-decoration: none; /* 默认没有下划线 */
}
.link-snpid:hover {
  text-decoration: underline; /* 鼠标悬停时显示下划线 */
}

.link-snpid:active {
  color: #409EFF; /* 点击时字体颜色不变 */
}
</style>
  