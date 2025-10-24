<template>
      <div class="search">
        <el-row class="searchContent" :gutter="20">
          <el-col :span="7">
            <span class="cancerTypeSelect">Cancer type</span>
            <el-select
              ref="select"
              v-model="cancerType"
              filterable
              multiple
              collapse-tags
              collapse-tags-tooltip
              :max-collapse-tags="1"
              placeholder="Select"
              style="position:relative; top:5px"
              @change="handleSelectChange"
            >
              <el-option
                v-for="item in options"
                :key="item.value"
                :label="item.label"
                :value="item.value"
              />
            </el-select>
          </el-col>
          <el-col :span="7">
            <span class="geneInputBox">Gene symbol</span>
            <el-input v-model="searchGene" clearable style="position:relative; top:5px" />
          </el-col>
          <el-col :span="7">
            <span class="rsIDinputBox">Genomic region</span>
            <el-input v-model="searchRegion" clearable style="position:relative; top:5px" />
          </el-col>
          <el-col :span="3">
              <div class="searchButton"><el-button type="primary" :icon="Search" @click="queryData" style="width: 100px">Search</el-button></div>
              <div class="clearButton"><el-button type="danger" :icon="RefreshRight" @click="clearData" style="width: 100px">Reset</el-button></div>
          </el-col>    
        </el-row>
        <el-row class="searchExample" :gutter="20">
          <el-col :span="8">
            <span style="position: relative;font-size: 16px;font-weight: bold;color: #409EFF;">Search examples:</span>
          </el-col>
          <el-col :span="8">
            <el-button
              :type="info"
              link
              @click="searchgene_eg"
              style="font-size: 16px;"
              >ZBTB48</el-button
            >
          </el-col>
          <el-col :span="8">
            <el-button
              :type="info"
              link
              @click="searchregion_eg"
              style="font-size: 16px;"
              >1:6644700-6654700</el-button
            >
          </el-col>
        </el-row>
      </div>
      <div style="margin: 10px 0"></div>
      <!-- 选择展示的列和分页功能 -->
      <div class="table_display">
        <div>
          <div id="chart_heatmap" ref="chart_heatmap" style="width: 80%; height: 400px; margin: 0 auto;"></div>
        </div>
        <el-row :gutter="20" style="padding-left: 80px; padding-right: 80px;">
          <el-col :span="3">
            <div class="columns_display" style="float:left">
              <!-- checkbox -->
              <el-popover
                placement="bottom"
                :width="100"
                trigger="hover"
              >
                <!-- 弹出框内容 -->
                <el-checkbox :indeterminate="isIndeterminate" v-model="checkAll" @change="handleCheckAllChange" >Select all</el-checkbox>
                <div style="margin: 10px 0;"></div>
                <el-checkbox-group v-model="checkedColumns" @change="handleCheckedColumnChange">
                  <el-checkbox v-for="column in columns" :value="column" :key="column">{{column}}</el-checkbox>
                </el-checkbox-group>
                <!-- 触发器 -->
                <template #reference>
                  <el-button type="primary" plain>Display columns</el-button>
                </template>
              </el-popover>
            </div>
          </el-col>
          <el-col :span="18" style="display:flex; justify-content:center; align-items:center;">
            <el-pagination
              center
              background
              layout="prev, pager, next, sizes, total, jumper"
              :page-sizes="[10, 20, 50, 100]"
              :page-size="pagesize"
              :total="myResults.length"
              :current-page="currpage"
              @current-change="handleCurrentChange"
              @size-change="handleSizeChange"
            >
            </el-pagination>
          </el-col>
          <el-col :span="3" style="margin: 0 auto;">
            <el-button @click="exportToExcel" type="primary" plain style="width: 100px;">Download</el-button>
          </el-col>
        </el-row>
      </div>

      <div class="bg_table_3">
        <!-- 添加@sort-change和sortable="custom"，解决排序只排当前页的问题，
          参考：https://blog.csdn.net/zebghfv/article/details/120993629 -->
        <el-table
          class="tableResults"
          :data="myResults.slice((currpage - 1) * pagesize, currpage * pagesize)"
          border
          style="margin: 10px 0; text-align: center; width: 100%; max-width: 2000px"
          :header-cell-style="{ background: '#ecf5ff', color: '#337ecc' }"
          v-loading="loading"
          @sort-change="handleSort"
          :row-class-name="rowClassName"
        >
          <!-- 选择单行：https://blog.csdn.net/weixin_45777909/article/details/108107729 -->
          <el-table-column label="Selector" min-width="100px" align="center">
            <template #default="scope">
              <el-checkbox @change="selectRow(scope.row, $event)" v-model="scope.row.check" />
            </template>
          </el-table-column>

          <el-table-column v-if="checkedColumns.includes('Gene')" prop="symbol" label="Gene" min-width="120px" align="center">
            <template v-slot="scope">
              <a :href="'http://localhost:8081/cancerdb/search_gene?gene=' + scope.row.symbol" target="_blank" class="link-snpid">
                {{ scope.row.symbol }}
              </a>
            </template>
          </el-table-column>
          <!-- <el-table-column v-if="checkedColumns.includes('Gene position')" prop="Gene_position" label="Gene position" min-width="120px" align="center"/> -->
          <el-table-column v-if="checkedColumns.includes('Gene position')" label="Gene position" min-width="120px" align="center">
            <template v-slot="slotProps">
              {{ slotProps.row.ProbeChr }}:{{ slotProps.row.Probe_bp }}
            </template>
          </el-table-column>
          <el-table-column v-if="checkedColumns.includes('Cancer')" prop="cancer" label="Cancer" min-width="120px" align="center" />
          
          <!-- b_SMR   se_SMR  p_SMR p_SMR_multi     p_HEIDI nsnp_HEIDI      p_thresh        fdr -->
          <el-table-column v-if="checkedColumns.includes('SMR_beta')" prop="b_SMR" label="SMR_beta" min-width="120px" align="center" sortable="custom"/>
          <el-table-column v-if="checkedColumns.includes('SMR_SE')" prop="se_SMR" label="SMR_SE" min-width="120px" align="center" sortable="custom"/>
          <el-table-column v-if="checkedColumns.includes('SMR_P')" prop="p_SMR" label="SMR_P" min-width="120px" align="center" sortable="custom"/>
          <el-table-column v-if="checkedColumns.includes('SMR_P_multi')" prop="p_SMR_multi" label="SMR_P_multi" min-width="120px" align="center" sortable="custom"/>
          <el-table-column v-if="checkedColumns.includes('SMR_FDR')" prop="fdr" label="SMR_FDR" min-width="120px" align="center" sortable="custom"/>
          <el-table-column v-if="checkedColumns.includes('HEIDI_P')" prop="p_HEIDI" label="HEIDI_P" min-width="120px" align="center" sortable="custom"/>
          <el-table-column v-if="checkedColumns.includes('HEIDI_nsnp')" prop="nsnp_HEIDI" label="HEIDI_nsnp" min-width="120px" align="center" sortable="custom"/>
        
          <!-- topSNP  topSNP_chr      topSNP_bp       A1      A2      Freq -->
          <el-table-column v-if="checkedColumns.includes('Top SNP')" prop="topSNP" label="Top SNP" min-width="120px" align="center">
            <template v-slot="scope">
              <a :href="'http://localhost:8081/cancerdb/search_pleio_snp?snp=' + scope.row.topSNP" target="_blank" class="link-snpid">
                {{ scope.row.topSNP }}
              </a>
            </template>
          </el-table-column>
          <el-table-column v-if="checkedColumns.includes('SNP position')" prop="SNP_position" label="SNP position" min-width="120px" align="center"/>
          <el-table-column v-if="checkedColumns.includes('EA/OA')" prop="alleles" align="center"  width="120 px">
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
          <el-table-column v-if="checkedColumns.includes('EAF')" prop="Freq" min-width="120px" align="center">
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
          <el-table-column v-if="checkedColumns.includes('eQTL_beta')" prop="b_eQTL" label="eQTL_beta" min-width="120px" align="center" sortable="custom"/>
          <el-table-column v-if="checkedColumns.includes('eQTL_SE')" prop="se_eQTL" label="eQTL_SE" min-width="120px" align="center" sortable="custom"/>
          <el-table-column v-if="checkedColumns.includes('eQTL_P')" prop="p_eQTL" label="eQTL_P" min-width="120px" align="center" sortable="custom"/>

          <!-- b_GWAS  se_GWAS p_GWAS -->
          <el-table-column v-if="checkedColumns.includes('GWAS_beta')" prop="b_GWAS" label="GWAS_beta" min-width="120px" align="center" sortable="custom"/>
          <el-table-column v-if="checkedColumns.includes('GWAS_SE')" prop="se_GWAS" label="GWAS_SE" min-width="120px" align="center" sortable="custom"/>
          <el-table-column v-if="checkedColumns.includes('GWAS_P')" prop="p_GWAS" label="GWAS_P" min-width="120px" align="center" sortable="custom"/>
          
        </el-table>
      </div>


  <!-- SMR图展示 -->

      <div class="fig_description">
        <span style="font-size: 20px; font-weight: bold; color: white;">
          SMR/eQTL/GWAS figures in gene and its ± 1Mb flanking region based on the selected gene 
          <span :style="{color: selectedGene ? '#ffd04b' : 'white'}">{{ selectedGene }}</span> 
          and cancer 
          <span :style="{color: selectedCancer ? '#ffd04b' : 'white'}">{{ selectedCancer }}</span>
        </span>
      </div>
      <div class="plot" v-loading="loading_echart">
        <div id="chart_eQTL" ref="chart_eQTL" style="width: 100%; height: 1200px;"></div>
        <div id="chart_zscore" ref="chart_zscore" style="width: 100%; height: 800px;"></div>
      </div>

</template>

<script>
import { Search,RefreshRight } from "@element-plus/icons-vue";
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

const columnOptions = ['Gene', "Gene position", 'Cancer',"SMR_beta","SMR_SE","SMR_P","SMR_P_multi","SMR_FDR","HEIDI_P","HEIDI_nsnp", 'Top SNP', 'SNP position', "EA/OA", "EAF", "eQTL_beta","eQTL_SE","eQTL_P","GWAS_beta","GWAS_SE","GWAS_P"];

export default {
  name: "eQTL_SMR",
  data() {
    const cancerTypes = ['Basal cell carcinoma', 'Brain meningioma', 'Breast cancer', 'Cervical cancer', 'Colorectal cancer',
    'Endometrial cancer', 'Hepatocellular carcinoma', 'Kidney cancer, except renal pelvis', 
    'Lung cancer', 'Lymphocytic leukemia', 'Malignant neoplasm of intrahepatic ducts, biliary tract and gallbladder',
    'Ovarian cancer', 'Prostate cancer', 'Skin melanoma', 'Squamous cell carcinoma', 'Stomach cancer', 'Thyroid cancer'];

    const options = cancerTypes.map(type => ({
      value: type,
      label: type
    }));

    return {
      Search,
      RefreshRight,

      // cancertype 筛选
      options,
      cancerType: "", // 选择的组件
      searchRegion: "", 
      searchGene:"",

      // 表格
      pagesize: 10,
      currpage: 1,
      // allresults: [],
      myResults: [], // 展示的数据
      loading: false,

      // checkbox
      checkAll: true,
      columns: columnOptions,
      checkedColumns: columnOptions,
      isIndeterminate: false,

      currentSelectedRow: null, // 当前选中的行
      selectedGene: '', // 动态基因
      selectedCancer: '', // 动态癌症

      plot_data:[],
      chart_eQTL:null,
      chart_GWAS:null,
      loading_echart:false,
      chart_heatmap:null,

      query:false,
    };
  },

  mounted() {
    this.query = this.$route.query.query;
    this.cancerType = [this.$route.query.cancer];
    if(this.query){
      this.queryData();
    } else {
      this.cancerType = "",
      // 数据加载完前，使用loading图标展示
      this.loading = true,
      axios.get("/api/cancerdb/SMR_eQTL").then((response) => {
        // this.allSNPs = response.data;
        this.myResults = response.data;
        this.loading = false;
        this.$nextTick(() => {
          this.plot_heatmap(this.myResults);
        });

        // 默认选中第一行
        if (this.myResults.length > 0) {
          this.selectRow(this.myResults[0], true);
        }
      });
    }
  },

  methods: {
    handleSelectChange() {
      this.$nextTick(() => {
        // 确保访问的是正确的输入框
        const input = this.$refs.select && this.$refs.select.$el.querySelector('input');
        
        if (input) {
          input.value = ''; // 清空输入框的内容
        } else {
          console.error('Input element not found');
        }
      });
    },
    searchregion_eg() {
      // 获取按钮文本内容并赋值给searchSNPs
      const buttonText = event.target.textContent.trim();
      this.searchRegion = buttonText; // 更新输入框内容
      this.searchGene = "";
    },
    searchgene_eg() {
      // 获取按钮文本内容并赋值给searchSNPs
      const buttonText = event.target.textContent.trim();
      this.searchGene = buttonText; // 更新输入框内容
      this.searchRegion = "";
    },
    handleCurrentChange(cpage) {
      this.currpage = cpage;
    },
    handleSizeChange(psize) {
      this.pagesize = psize;
    },
    // 自定义排序方法
    handleSort(column) {
      if (column.order === "descending") {
        this.myResults.sort((a, b) => b[column.prop] - (a[column.prop]))
      } else if (column.order === "ascending") {
        this.myResults.sort((a, b) => a[column.prop] - (b[column.prop]))
      }
    },
    // 使前端的数据保留两位小数
    rounding(row, column, cellValue) {
      return cellValue.toFixed(3);
    },
    toggleDialog() {
      this.showDialog = !this.showDialog;
    },
    // https://blog.csdn.net/weixin_44636778/article/details/106397902
    // https://blog.csdn.net/m0_72196169/article/details/134340635

    // checkbox
    handleCheckAllChange(val) {
      this.checkedColumns = val ? columnOptions : [];
      this.isIndeterminate = false;
    },
    handleCheckedColumnChange(value) {
      let checkedCount = value.length;
      this.checkAll = checkedCount === this.columns.length;
      this.isIndeterminate = checkedCount > 0 && checkedCount < this.columns.length;
    },
    selectRow(row, value) {
      // 如果当前行已经被选中，则取消选中
      if (this.currentSelectedRow === row) {
        this.currentSelectedRow = null;
        row.checked = false;
      } else {
        this.myResults.forEach(item => {
          // 设置所有行未选中
          item.check = false;
        });
        // 选中当前行
        this.currentSelectedRow = row;
        row.check = value;
        this.selectedGene = row.symbol;  // 更新选中的基因
        this.selectedCancer = row.cancer; // 更新选中的癌症
        this.sendFigData(); // 选中新的行后发送数据至后端，用于绘图
      }
    },
    rowClassName({ row }) {
      // 如果行是选中的，返回高亮类名
      return row.check ? 'row-selected' : '';
    },

    // 导出Excel或CSV
    exportToExcel() {
      // 1. 定义prop与label的映射关系
      const columnMap = {
        Gene: 'symbol',
        'Gene position': (row) => `${row.ProbeChr}:${row.Probe_bp}`,
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
        eQTL_beta: 'b_eQTL',
        eQTL_SE: 'se_eQTL',
        eQTL_P: 'p_eQTL',
        GWAS_beta: 'b_GWAS',
        GWAS_SE: 'se_GWAS',
        GWAS_P: 'p_GWAS'
        
      };

      // const out_table = this.myResults.slice((this.currpage - 1) * this.pagesize, this.currpage * this.pagesize);
      const out_table = this.myResults;

      // 2. 获取展示的列并根据映射转换为label
      const headers = this.checkedColumns.map(prop => columnMap[prop]);
      // 3. 构造导出的数据，根据checkedColumns中选择的列构造每一行
      const data = out_table.map(row => {
        return headers.map(prop => {
          // 如果prop是函数（'Gene position'列），则执行函数
          if (typeof prop === 'function') {
            return prop(row);
          }
          return row[prop];
        });
      });

      // 4. 将数据转换为CSV格式或使用其他库导出为Excel
      let csvContent = '';
      csvContent += this.checkedColumns.join(',') + '\n'; // 添加头
      data.forEach(row => {
        csvContent += row.join(',') + '\n'; // 添加数据行
      });

      // 5. 创建blob对象并触发下载
      const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
      const url = URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.setAttribute('href', url);
      link.setAttribute('download', 'SMR_eQTL_FDR0.05.csv');
      link.style.visibility = 'hidden';
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    },

    // SMR 结果可视化
    sendFigData() {
      this.loading_echart=true;
      axios.post("/api/cancerdb/SMR_eQTL_fig", {gene: this.selectedGene, cancer: this.selectedCancer})
        .then(response => {
          this.plot_data = response.data;
          // 使用 Chart.js 绘制曼哈顿图
          this.plotManhattanWithChartJS(this.plot_data);
          // 绘制Z分数相关性图
          this.plotZscore(this.plot_data);
          this.loading_echart=false;
        })
        .catch(error => {
          console.error('Error sending data to the backend:', error);
        });
    },
    
    plotManhattanWithChartJS(input_data) {

      this.chart_eQTL = markRaw(echarts.init(this.$refs.chart_eQTL,null, { renderer : 'svg' })); // 渲染为svg，防止放大模糊

      // 提取坐标和 -log10(P)
      const eQTLData_sig = input_data.eQTL_result_sig.map(item => {
        return [item.SNPPos, item.log10P];
      });
      const eQTLData_notsig = input_data.eQTL_result_notsig.map(item => {
        return [item.SNPPos, item.log10P];
      });
      const GWASData_sig = input_data.GWAS_result_sig.map(item => {
        return [item.bp, item.log10P];
      });
      const GWASData_notsig = input_data.GWAS_result_notsig.map(item => {
        return [item.bp, item.log10P];
      });
      const SMRData_sig = input_data.SMR_result_sig.map(item => {
        return [item.Probe_bp, item.log10FDR];
      });
      const SMRData_notsig = input_data.SMR_result_notsig.map(item => {
        return [item.Probe_bp, item.log10FDR];
      });

      const xAxisConfig = {
        type: "value",
        min: input_data.gene_start,
        max: input_data.gene_end,
        splitNumber: 10,
        splitLine: { show: false }, // 去除网格线
        axisLabel: {
          show: true,
          formatter: (value) => {
            // 格式化数字为带逗号的字符串
            return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
          },
        },
      };
      const yAxisConfig = {
        type: "value", // 使用线性坐标系
        min: 0, // 可以根据实际情况调整最小值
        // 设置适合的 max，可能需要根据数据动态计算
        // max: Math.max(...input_data.eQTL_result.map(item => item.log10P)) + 1, // 留出一些空间
        splitNumber: 10,
        splitLine: { show: false }, // 去除网格线
        minInterval: 1,
        // axisLabel: {
        //   formatter: (value) => Math.floor(value), // 仅显示整数
        // },
      };

      const threshSMR = {
        name: 'threshSMR',
        type: 'line',
        markLine: {
          symbol: 'none',
          data: [{ yAxis: 1.30103 }],
          label: { show: true, position: 'end', formatter: '-log10(0.05)' },
          lineStyle: { type: 'dashed', color: 'red'
          }
        },
      };

      const threshQTLGWAS = {
        name: 'threshQTLGWAS',
        type: 'line',
        markLine: {
          symbol: 'none',
          data: [{ yAxis: 7.30103 }],
          label: { show: true, position: 'end', formatter: '-log10(5e-8)' },
          lineStyle: { type: 'dashed', color: 'red' }
        },
      };

      const option = {
        tooltip: {
          trigger: 'item',
          formatter: function(params) {
            const seriesIndex = params.seriesIndex;
            let tooltipContent = '';

            if (seriesIndex === 0) {
              const data_tooltip = input_data.SMR_result_sig[params.dataIndex];
              tooltipContent = `<b>Gene:</b> ${data_tooltip.symbol}<br/>
                                <b>Gene position:</b> ${data_tooltip.ProbeChr}:${data_tooltip.Probe_bp}<br/>
                                <b>Beta:</b> ${data_tooltip.b_SMR}<br/>
                                <b>SE:</b> ${data_tooltip.se_SMR}<br/>
                                <b>P:</b> ${data_tooltip.p_SMR}<br/>
                                <b>P_multi:</b> ${data_tooltip.p_SMR_multi}<br/>                                
                                <b>FDR:</b> ${data_tooltip.fdr}<br/>
                                <b>HEIDI_P:</b> ${data_tooltip.p_HEIDI}<br/>
                                <b>HEIDI_nsnp:</b> ${data_tooltip.nsnp_HEIDI}<br/>`;
            } else if ( seriesIndex === 1) {
              const data_tooltip = input_data.SMR_result_notsig[params.dataIndex];
              tooltipContent = `<b>Gene:</b> ${data_tooltip.symbol}<br/>
                                <b>Gene position:</b> ${data_tooltip.ProbeChr}:${data_tooltip.Probe_bp}<br/>
                                <b>Beta:</b> ${data_tooltip.b_SMR}<br/>
                                <b>SE:</b> ${data_tooltip.se_SMR}<br/>
                                <b>P:</b> ${data_tooltip.p_SMR}<br/>
                                <b>P_multi:</b> ${data_tooltip.p_SMR_multi}<br/>                                
                                <b>FDR:</b> ${data_tooltip.fdr}<br/>
                                <b>HEIDI_P:</b> ${data_tooltip.p_HEIDI}<br/>
                                <b>HEIDI_nsnp:</b> ${data_tooltip.nsnp_HEIDI}<br/>`;
            } else if (seriesIndex === 2) {
              const data_tooltip = input_data.eQTL_result_sig[params.dataIndex];
              tooltipContent = `<b>SNP:</b> ${data_tooltip.SNP}<br/>
                                <b>SNP position:</b> ${data_tooltip.SNPChr}:${data_tooltip.SNPPos}<br/>
                                <b>EA/OA:</b> ${data_tooltip.AssessedAllele}/${data_tooltip.OtherAllele}<br/>
                                <b>Z-score:</b> ${data_tooltip.Zscore}<br/>
                                <b>P:</b> ${data_tooltip.Pvalue}<br/>
                                <b>FDR:</b> ${data_tooltip.FDR}`;
            } else if (seriesIndex === 3) {
              const data_tooltip = input_data.eQTL_result_notsig[params.dataIndex];
              tooltipContent = `<b>SNP:</b> ${data_tooltip.SNP}<br/>
                                <b>SNP position:</b> ${data_tooltip.SNPChr}:${data_tooltip.SNPPos}<br/>
                                <b>EA/OA:</b> ${data_tooltip.AssessedAllele}/${data_tooltip.OtherAllele}<br/>
                                <b>Z-score:</b> ${data_tooltip.Zscore}<br/>
                                <b>P:</b> ${data_tooltip.Pvalue}<br/>
                                <b>FDR:</b> ${data_tooltip.FDR}`;
            } else if (seriesIndex === 4) {
              const data_tooltip = input_data.GWAS_result_sig[params.dataIndex];
              tooltipContent = `<b>SNP:</b> ${data_tooltip.snpid}<br/>
                                <b>SNP position:</b> ${data_tooltip.hg19chr}:${data_tooltip.bp}<br/>
                                <b>EA/OA:</b> ${data_tooltip.a1}/${data_tooltip.a2}<br/>
                                <b>EAF:</b> ${data_tooltip.EURaf}<br/>
                                <b>Beta:</b> ${data_tooltip.beta}<br/>
                                <b>SE:</b> ${data_tooltip.se}<br/>
                                <b>P:</b> ${data_tooltip.pval}`;
            } else if (seriesIndex === 5) {
              const data_tooltip = input_data.GWAS_result_notsig[params.dataIndex];
              tooltipContent = `<b>SNP:</b> ${data_tooltip.snpid}<br/>
                                <b>SNP position:</b> ${data_tooltip.hg19chr}:${data_tooltip.bp}<br/>
                                <b>EA/OA:</b> ${data_tooltip.a1}/${data_tooltip.a2}<br/>
                                <b>EAF:</b> ${data_tooltip.EURaf}<br/>
                                <b>Beta:</b> ${data_tooltip.beta}<br/>
                                <b>SE:</b> ${data_tooltip.se}<br/>
                                <b>P:</b> ${data_tooltip.pval}`;
            }

            return tooltipContent;
          },
        },
        
        
        dataZoom: [
          {
            show: true,
            realtime: true,
            // start: 30, // 缩放的起始和终止位置
            // end: 70,
            xAxisIndex: [0, 1, 2],
            top:'90%',
          },
          {
            type: 'inside',
            realtime: true,
            // start: 30,
            // end: 70,
            xAxisIndex: [0, 1, 2],
            top:'90%',
          }
        ],
        grid: [
          { height: '20%' },
          { top: '35%', height: '20%' },
          { top: '65%', height: '20%' }
        ],
        xAxis: [
          { ...xAxisConfig, },
          { ...xAxisConfig, gridIndex: 1, },
          { ...xAxisConfig, gridIndex: 2, }
        ],
        
        yAxis: [
          { ...yAxisConfig, name: "-log10(SMR_FDR)", },
          { ...yAxisConfig, name: "-log10(eQTL_P)", gridIndex: 1 },
          { ...yAxisConfig, name: "-log10(GWAS_P)", gridIndex: 2 },
        ],
        series: [
          {
            name: "Significant",
            type: "scatter",
            data: SMRData_sig,
            symbolSize: 5,
            itemStyle: {
                color: 'red'
            },
          },
          {
            name: "Insignificant",
            type: "scatter",
            data: SMRData_notsig,
            symbolSize: 5,
            itemStyle: {
                color: '#79bbff'
            },
          },
          {
            name: "Significant",
            type: "scatter",
            data: eQTLData_sig,
            xAxisIndex: 1,
            yAxisIndex: 1,
            symbolSize: 5,
            itemStyle: {
                color: 'red'
            },
          },
          {
            name: "Insignificant",
            type: "scatter",
            data: eQTLData_notsig,
            xAxisIndex: 1,
            yAxisIndex: 1,
            symbolSize: 5,
            itemStyle: {
                color: '#79bbff'
            },
          },
          {
            name: "Significant",
            type: "scatter",
            data: GWASData_sig,
            xAxisIndex: 2,
            yAxisIndex: 2,
            symbolSize: 5,
            itemStyle: {
                color: 'red'
            },
          },
          {
            name: "Insignificant",
            type: "scatter",
            data: GWASData_notsig,
            xAxisIndex: 2,
            yAxisIndex: 2,
            symbolSize: 5,
            itemStyle: {
                color: '#79bbff'
            },
          },
          // Threshold line for SMR (y = 1)
          {
            ...threshSMR,
            xAxisIndex: 0, // First grid (SMR)
            yAxisIndex: 0,
          },
          // Threshold line for eQTL and GWAS (y = 7.30103)
          {
            ...threshQTLGWAS,
            xAxisIndex: 1, // Second grid (eQTL)
            yAxisIndex: 1,
          },
          {
            ...threshQTLGWAS,
            xAxisIndex: 2, // Third grid (GWAS)
            yAxisIndex: 2,
          }
        ],
        legend: {
          data: [
            {
              name: "Significant",
              icon: 'circle', // 设置图例的图标形状
              itemStyle: { color: 'red' } // 设置图例的图标颜色
            },
            {
              name: "Insignificant",
              icon: 'circle', // 设置图例的图标形状
              itemStyle: { color: '#79bbff' } // 设置图例的图标颜色
            },
          ], // 更新图例名称
        }
      };

      // 设置图表配置
      this.chart_eQTL.setOption(option);
    },
    plotZscore(input_data){
      this.chart_zscore = echarts.init(this.$refs.chart_zscore);

      // 数据转换，提取 qtl_zscore 和 gwas_zscore
      const scatterData = input_data.merged_result.map(item => [item.qtl_zscore, item.gwas_zscore]);

      // ECharts 配置项
      const option = {
        title: {
          text: 'eQTL vs GWAS Z-scores',
          left: 'center'
        },
        tooltip: [
          {
            trigger: 'item',
            formatter: function(params) {
              const data_tooltip = input_data.merged_result[params.dataIndex]; // 获取当前点的数据
              return `
                    <b>SNP:</b> ${data_tooltip.SNP}<br>
                    <b>SNP position:</b> ${data_tooltip.Chr}:${data_tooltip.BP}<br>
                    <b>EA/OA:</b> ${data_tooltip.A1}/${data_tooltip.A2}<br/>
                    <table style="width: 100%; text-align: left; font-size: 12px;">
                      <tr>
                        <td></td>
                        <td><b>QTL</b></td>
                        <td><b>GWAS</b></td>
                      </tr>
                      <tr>
                        <td><b>EAF:</b></td>
                        <td></td>
                        <td>${data_tooltip.gwas_EAF}</td>
                      </tr>
                      <tr>
                        <td><b>Z-score:</b></td>
                        <td>${data_tooltip.qtl_zscore}</td>
                        <td>${data_tooltip.gwas_zscore}</td>
                      </tr>
                      <tr>
                        <td><b>P:</b></td>
                        <td>${data_tooltip.qtl_p}</td>
                        <td>${data_tooltip.gwas_p}</td>
                      </tr>
                    </table>
                `;
            },
          },
        ],
        xAxis: {
          name: 'eQTL Z-score',
          type: 'value'
        },
        yAxis: {
          name: 'GWAS Z-score',
          type: 'value'
        },
        series: [
          {
            type: 'scatter',
            data: scatterData,
            symbolSize: 10,
            itemStyle: {
              color: '#5470C6'
            }
          }
        ]
      };

      // 渲染图表
      this.chart_zscore.setOption(option);

    },

    queryData() {
      this.currpage = 1;
      // 如果检索条件为空，则直接返回所有
      // 检索条件返回后端进行查询
      this.loading = true
      axios.post("/api/cancerdb/SMR_eQTL",{cancerType:this.cancerType,searchRegion:this.searchRegion,searchGene:this.searchGene})
        .then((res) => {
          if (res.data.length === 0) {
            // 如果后端返回的数据长度为0，则弹出窗口提示用户
            this.$alert("Sorry, the input content is not existed or not significant in our results.", "No results", {
              confirmButtonText: "OK",
            });
          } else if (res.data === "errorID") {
            // 如果后端返回的数据为"errorID"，则弹出窗口提示用户
            this.$alert("Invalid genomic region search!", "Error", {
              confirmButtonText: "OK",
            });
          } else {
            // 如果后端返回的数据正常，则更新展示的数据
            this.myResults = res.data;
            this.plot_heatmap(this.myResults)
            this.selectRow(this.myResults[0], true);
          }
          this.loading = false;
          
        })
        .catch((err) => {console.log(err)})
    },
    clearData() {
      this.cancerType = "";
      this.searchRegion = "";
      this.searchGene = "";
    },
    plot_heatmap(data) {
      const genes = [...new Set(data.map(item => item.symbol))];
      const cancers = [...new Set(data.map(item => item.cancer))];
      const matrix = [];
      
      const dataMap = data.reduce((acc, item) => {
        const key = `${item.symbol}-${item.cancer}`;
        acc[key] = item.b_SMR;
        return acc;
      }, {});
      
      genes.forEach(symbol => {
        const row = [];
        cancers.forEach(cancer => {
          const value = dataMap[`${symbol}-${cancer}`] || null;
          row.push(value);
        });
        matrix.push(row);
      });

      // 使用非响应式实例化，否则拖动范围时报错https://blog.csdn.net/weixin_50508597/article/details/123552563
      this.chart_heatmap = markRaw(echarts.init(this.$refs.chart_heatmap,null, { renderer : 'svg' })); // 渲染为svg，防止放大模糊
      const maxValue = Math.max(...matrix.flat());
      const option = {
        title: {
          text: "Causal effect (beta) between gene (exposure) and cancer (outcome) based on SMR analysis",
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
            return `<b>Gene:</b> ${genes[params.data[0]]}<br/>
                    <b>Cancer:</b> ${cancers[params.data[1]]}<br/>
                    <b>SMR_beta:</b> ${params.data[2]}<br/>`;  // params.data[2] 是heatmap的值
          }
        },
        dataZoom: [
          {
            show: true,
            realtime: true,
            start: 0, // 缩放的起始和终止位置
            end: 20,
            top:'90%',
          },
          {
            type: 'inside',
            realtime: true,
            start: 0,
            end: 20,
            top:'90%',
          }
        ],
        grid: {
          left: '30%',
          right: '10%',
          bottom: '10%',
          top: '10%',
          height: '70%'
        },
        xAxis: {
          type: 'category',
          data: genes,
          name: 'Gene',
          // nameGap: 5,
          splitArea: {
            show: false, // 不显示网格背景，背景有颜色，会视觉干扰
          }
        },
        yAxis: {
          type: 'category',
          data: cancers,
          name: 'Cancer',
          nameGap: 5,
          splitArea: {
            show: false,
          }
        },
        visualMap: {
          min: -maxValue,
          max: maxValue,
          calculable: true,
          orient: 'vertical',
          left: '1250',
          top: '10%',
          inRange: {
            color: ['#313695','#FFFFFF','#a50026']
          }
        },
        series: [{
          name: 'SMR_beta',
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
      this.chart_heatmap.setOption(option)
    },
  },
}
</script>
  
<style lang="less">
.el-select__wrapper {
  height: 40px;
}
.row-selected {
  background-color: #a0cfff !important;
}
</style>

<style lang="scss" scoped>
:deep(.el-select__tags-text) {
  color: black;
}
.icon {
  padding: 5px;
}
.bg1 {
  background-color: #ecf5ff;
}
.bg2 {
  background-color: #fff;
  width: 1700px;
  margin: 0 auto;
  padding-top: 20px;
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
  padding-left: 600px;
  padding-right: 600px;
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
.bg_table_1 {
  background-color: #ecf5ff;
}
.bg_table_2 {
  background-color: #fff;
  width: 1700px;
  margin: 0 auto;
  display: flex;
}
.bg_table_3 {
  position: relative;
  margin: 0 auto;
  display: flex;
  width: 1750px;
  border-top-left-radius: 0px;
  border-top-right-radius: 0px;
  border-top: #fff;
  background-color: #fff;
  justify-content: center;
  flex-direction: column;
}
.bg_fig_1 {
  background-color: #ecf5ff;
}
.bg_fig_2 {
  background-color: #fff;
  width: 1700px;
  margin: 0 auto;
}
.fig_description{
  width: 1750px;
  margin: 0 auto;
  background-color: #337ecc;
  padding: 10px
}

.plot{
  width: 1750px;
  margin: 0 auto;
  padding: 10px
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
  