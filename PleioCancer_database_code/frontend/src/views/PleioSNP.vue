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
            <span class="rsIDinputBox">SNP (rsID or position)</span>
            <el-input v-model="searchSNPs" clearable style="position:relative; top:5px" />
          </el-col>
          <el-col :span="7">
            <span class="regioninputBox">Genomic region</span>
            <el-input v-model="searchRegion" clearable style="position:relative; top:5px" />
          </el-col>
          <el-col :span="3">
              <div class="searchButton"><el-button type="primary" :icon="Search" @click="queryData" style="width: 100px">Search</el-button></div>
              <div class="clearButton"><el-button type="danger" :icon="RefreshRight" @click="clearData" style="width: 100px">Reset</el-button></div>
          </el-col>    
        </el-row>
        <el-row class="searchExample" :gutter="20">
          <el-col :span="6">
            <span style="position: relative;font-size: 16px;font-weight: bold;color: #409EFF;">Search examples:</span>
          </el-col>
          <el-col :span="6">
            <el-button
              :type="info"
              link
              @click="searchsnp_eg"
              style="font-size: 16px;"
              >rs2714491</el-button
            >
          </el-col>
          <el-col :span="6">
            <el-button
              :type="info"
              link
              @click="searchsnp_eg"
              style="font-size: 16px;"
              >2:202373160</el-button
            >
          </el-col>
          <el-col :span="6">
            <el-button
              :type="info"
              link
              @click="searchregion_eg"
              style="font-size: 16px;"
              >2:202373160-202473160</el-button
            >
          </el-col>
        </el-row>
      </div>
      <div style="margin: 10px 0"></div>
      <!-- 选择展示的列和分页功能 -->
      <div class="table_display">
        <div class="plot_sankey">
          <div id="chart_sankey" ref="chart_sankey" style="width: 80%; height: 400px; margin: 0 auto;"></div>
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
          <el-table-column label="Selector" min-width="100px" align="center">
            <template #default="scope">
              <el-checkbox @change="selectRow(scope.row, $event)" v-model="scope.row.check" />
            </template>
          </el-table-column>

          <el-table-column v-if="checkedColumns.includes('Cancer 1')" prop="cancer1" label="Cancer 1" min-width="120px" align="center" />
          <el-table-column v-if="checkedColumns.includes('Cancer 2')" prop="cancer2" label="Cancer 2" min-width="120px" align="center" />
          
          <el-table-column v-if="checkedColumns.includes('SNP')" prop="snpid" label="SNP" min-width="120px" align="center" sortable="custom">
            <template v-slot="scope">
              <a :href="'http://localhost:8081/cancerdb/search_pleio_snp?snp=' + scope.row.snpid" target="_blank" class="link-snpid">
                {{ scope.row.snpid }}
              </a>
            </template>
          </el-table-column>
          <el-table-column v-if="checkedColumns.includes('SNP position')" label="SNP position" min-width="120px" align="center">
            <template v-slot="slotProps">
              {{ slotProps.row.hg19chr }}:{{ slotProps.row.bp }}
            </template>
          </el-table-column>
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
          <el-table-column v-if="checkedColumns.includes('PLACO_T')" prop="T.placo" label="PLACO_T" min-width="120px" align="center" sortable="custom"/>
          <el-table-column v-if="checkedColumns.includes('PLACO_P')" prop="p.placo" label="PLACO_P" min-width="120px" align="center" sortable="custom"/>
          
          <el-table-column v-if="checkedColumns.includes('OR_cancer1')" prop="or.trait1" label="OR_cancer1" min-width="120px" align="center" sortable="custom"/>
          <el-table-column v-if="checkedColumns.includes('SE_cancer1')" prop="se.trait1" label="SE_cancer1" min-width="120px" align="center" sortable="custom"/>
          <el-table-column v-if="checkedColumns.includes('P_cancer1')" prop="pval.trait1" label="P_cancer1" min-width="120px" align="center" sortable="custom"/>
          <el-table-column v-if="checkedColumns.includes('EAF_cancer1')" prop="EURaf.trait1" min-width="120px" align="center">
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

          <el-table-column v-if="checkedColumns.includes('OR_cancer2')" prop="or.trait2" label="OR_cancer2" min-width="120px" align="center" sortable="custom"/>
          <el-table-column v-if="checkedColumns.includes('SE_cancer2')" prop="se.trait2" label="SE_cancer2" min-width="120px" align="center" sortable="custom"/>
          <el-table-column v-if="checkedColumns.includes('P_cancer2')" prop="pval.trait2" label="P_cancer2" min-width="120px" align="center" sortable="custom"/>
          <el-table-column v-if="checkedColumns.includes('EAF_cancer2')" prop="EURaf.trait2" min-width="120px" align="center">
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
      </div>

  <!-- placo图展示 -->
      <div class="fig_description">
        <span style="font-size: 20px; font-weight: bold; color: white;">
          PLACO/GWAS figures in SNP and its ± 1Mb flanking region based on the selected SNP 
          <span :style="{color: selectedSNP ? '#ffd04b' : 'white'}">{{ selectedSNP }}</span>
          and cancers 
          <span :style="{color: selectedCancer1 ? '#ffd04b' : 'white'}">{{ selectedCancer1 }}</span>
          <span>/</span>
          <span :style="{color: selectedCancer2 ? '#ffd04b' : 'white'}">{{ selectedCancer2 }}</span>
        </span>
      </div>
      <div class="plot" v-loading="loading_echart">
        <div id="chart_GWAS" ref="chart_GWAS" style="width: 100%; height: 1200px;"></div>
        <div id="chart_zscore" ref="chart_zscore" style="width: 100%; height: 800px;"></div>
      </div>
      
</template>

<script>
import { Search,RefreshRight } from "@element-plus/icons-vue";
import axios from "axios";
//导入nprogress加载进度条包即样式
import NProgress from 'nprogress';
import 'nprogress/nprogress.css';
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

const columnOptions = ['Cancer 1', "Cancer 2", 'SNP',"SNP position","EA/OA","PLACO_T","PLACO_P","OR_cancer1","SE_cancer1","P_cancer1","EAF_cancer1", "OR_cancer2","SE_cancer2","P_cancer2","EAF_cancer2"];
const cancerTypes = [
  'Acute myeloid leukaemia',
  'Basal cell carcinoma',
  'Bladder cancer',
  'Brain glioblastoma and astrocytoma',
  'Brain meningioma',
  'Breast cancer',
  'Cervical cancer',
  'Chronic myeloid leukaemia',
  'Colorectal cancer',
  'Diffuse large B-cell lymphoma',
  'Endometrial cancer',
  'Esophageal cancer',
  'Gastrointestinal stromal tumor and sarcoma',
  'Head and neck cancer',
  'Hepatocellular carcinoma',
  'Hodgkins lymphoma',
  'Kidney cancer, except renal pelvis',
  'Lung cancer',
  'Lymphocytic leukemia',
  'Malignant neoplasm of bone and articular cartilage',
  'Malignant neoplasm of eye and adnexa',
  'Malignant neoplasm of intrahepatic ducts, biliary tract and gallbladder',
  'Mantle cell lymphoma',
  'Mesothelioma',
  'Multiple myeloma',
  'Myelodysplastic syndrome',
  'Marginal zone B-cell lymphoma',
  'Ovarian cancer',
  'Pancreatic cancer',
  'Prostate cancer',
  'Skin melanoma',
  'Small intestine cancer',
  'Squamous cell carcinoma',
  'Stomach cancer',
  'Testicular cancer',
  'Thyroid cancer',
  'Vulvar cancer'];

const options = cancerTypes.map(type => ({
  value: type,
  label: type
}));
export default {
  name: "PleioSNP",
  data() {
    return {
      Search,
      RefreshRight,

      // cancertype 筛选
      options,
      cancerType: "", // 选择的组件
      searchSNPs: "", 
      searchRegion:"",

      // 表格
      pagesize: 10,
      currpage: 1,
      myResults: [], // 展示的数据
      loading: false,

      // checkbox
      checkAll: true,
      columns: columnOptions,
      checkedColumns: columnOptions,
      isIndeterminate: false,

      currentSelectedRow: null, // 当前选中的行
      selectedSNP:'',
      selected_chr:null,
      selected_pos:null,
      selectedCancer1: '', // 动态基因
      selectedCancer2: '', // 动态癌症

      plot_data:[],
      chart_GWAS:null,
      chart_zscore:null,
      loading_echart:false,
      chart_sankey:null,

      query: false,
    };
  },

  mounted() {
    const cancer1 = this.$route.query.cancer1;
    const cancer2 = this.$route.query.cancer2;
    this.query = this.$route.query.query;
    this.cancerType = [cancer1, cancer2];
    if(this.query){
      this.queryData();
    } else {
      this.cancerType = "",
      // 数据加载完前，使用loading图标展示
      this.loading = true,
      axios.get("/api/cancerdb/pleio_snp").then((response) => {
        // this.allSNPs = response.data;
        this.myResults = response.data;
        this.loading = false;
        // 确保数据加载完成后初始化图表
        this.$nextTick(() => {
          this.plotSankey(this.myResults);
        });

        // 默认选中第一行
        if (this.myResults.length > 0) {
          this.selectRow(this.myResults[0], true);
        }
      });
    }
  },

  methods: {
    searchsnp_eg() {
      // 获取按钮文本内容并赋值给searchSNPs
      const buttonText = event.target.textContent.trim();
      this.searchSNPs = buttonText; // 更新输入框内容
      this.searchRegion = "";
    },
    searchregion_eg() {
      const buttonText = event.target.textContent.trim();
      this.searchRegion = buttonText; // 更新输入框内容
      this.searchSNPs = "";
    },
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
        this.selectedSNP = row.snpid;
        this.selected_chr = row.hg19chr;
        this.selected_pos = row.bp;
        this.selectedCancer1 = row.cancer1;  // 更新选中的基因
        this.selectedCancer2 = row.cancer2; // 更新选中的癌症
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
      link.setAttribute('download', 'Pleiotropic_SNP_P5e-8.csv');
      link.style.visibility = 'hidden';
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    },

    plotSankey(rawData) {
      // 提取唯一节点，并加前缀
      const nodes = [];
      const nodeSet = new Set();

      rawData.forEach(item => {
        nodeSet.add(`cancer1_${item.cancer1}`);
        nodeSet.add(`cancer2_${item.cancer2}`);
      });

      // 添加节点并设置位置
      let index = 0;
      nodeSet.forEach(name => {
        nodes.push({
          name,
          x: name.startsWith('cancer1_') ? index * 200 : index * 200,
          y: name.startsWith('cancer1_') ? 0 : 300
        });
        index++;
      });

      // 统计链接权重
      const linksMap = {};
      rawData.forEach(item => {
        const key = `${item.cancer1}->${item.cancer2}`;
        if (linksMap[key]) {
          linksMap[key].value += 1;
        } else {
          linksMap[key] = { 
            source: `cancer1_${item.cancer1}`, 
            target: `cancer2_${item.cancer2}`, 
            value: 1 
          };
        }
      });
      const links = Object.values(linksMap);

      // 配置 ECharts
      const option = {
        // title: {
        //   text: 'Cancer Type Sankey Diagram',
        //   left: 'center'
        // },
        tooltip: {
          trigger: 'item',
          triggerOn: 'mousemove'
        },
        series: [
          {
            type: 'sankey',
            layout: 'none',
            emphasis: {
              focus: 'adjacency'
            },
            data: nodes,
            links: links,
            lineStyle: {
              // color: 'source',
              color: 'gradient',
              curveness: 0.5
            },
            label: {
              formatter: function (param) {
                return param.name.replace(/^cancer1_|^cancer2_/, ''); // 移除前缀
              }
            },
            draggable: false // 固定位置
          }
        ]
      };

      // 使用 echarts 实例绘制图表
      this.chart_sankey = echarts.init(this.$refs.chart_sankey);
      this.chart_sankey.setOption(option);

      // 监听点击事件
      this.chart_sankey.on('click', (params) => {
        if (params.dataType === 'node') {
          const clickedNode = params.data.name;
          this.cancerType = [clickedNode.replace(/^cancer1_|^cancer2_/, '')];
          this.searchSNPs = "";
          this.searchRegion = "";
          this.queryData();
        };
        if (params.dataType === 'edge') {
          // 获取连接线的 source 和 target
          const sourceNode = params.data.source;
          const targetNode = params.data.target;

          // 提取 cancer1 和 cancer2 类型
          this.cancerType = [sourceNode.replace(/^cancer1_/, ''),targetNode.replace(/^cancer2_/, '')];
          this.searchSNPs = "";
          this.searchRegion = "";
          this.queryData();
          console.log(this.cancerType)
        }
      });
    },

    // placo 结果可视化
    sendFigData() {
      this.loading_echart=true;

      axios.post("/api/cancerdb/pleio_snp_fig", {cancer1: this.selectedCancer1, cancer2: this.selectedCancer2, chr: this.selected_chr, pos: this.selected_pos})
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
      this.chart_GWAS = markRaw(echarts.init(this.$refs.chart_GWAS,null, { renderer : 'svg' })); // 渲染为svg，防止放大模糊

      // 提取坐标和 -log10(P)
      const GWAS1Data_sig = input_data.GWAS1_result_sig.map(item => {
        return [item.bp, item.log10P];
      });
      const GWAS1Data_notsig = input_data.GWAS1_result_notsig.map(item => {
        return [item.bp, item.log10P];
      });
      const GWAS2Data_sig = input_data.GWAS2_result_sig.map(item => {
        return [item.bp, item.log10P];
      });
      const GWAS2Data_notsig = input_data.GWAS2_result_notsig.map(item => {
        return [item.bp, item.log10P];
      });
      const placoData_sig = input_data.placo_result_sig.map(item => {
        return [item.BP, item.placo_log10P];
      });
      const placoData_notsig = input_data.placo_result_notsig.map(item => {
        return [item.BP, item.placo_log10P];
      });

      const xAxisConfig = {
        type: "value",
        min: this.selected_pos - 1000000,
        max: this.selected_pos + 1000000,
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
        splitNumber: 10,
        splitLine: { show: false }, // 去除网格线
        minInterval: 1,
      };

      const thresh = {
        name: 'thresh',
        type: 'line',
        markLine: {
          symbol: 'none',
          data: [{ yAxis: 7.30103 }],
          label: { show: true, position: 'end', formatter: '-log10(5e-8)' },
          lineStyle: { type: 'dashed', color: 'red' }
        },
      };

      const axisConfig = [0, 1, 2].map(index => ({
        ...thresh,
        xAxisIndex: index,
        yAxisIndex: index,
      }));

      const option = {
        tooltip: {
          trigger: 'item',
          formatter: (params) => {
            const seriesIndex = params.seriesIndex;
            let tooltipContent = '';
            if (seriesIndex === 0) {
              const data_tooltip = input_data.placo_result_sig[params.dataIndex];
              tooltipContent = `
                    <b>SNP:</b> ${data_tooltip.SNP}<br>
                    <b>SNP position:</b> ${data_tooltip.Chr}:${data_tooltip.BP}<br>
                    <b>EA/OA:</b> ${data_tooltip.A1}/${data_tooltip.A2}<br/>
                    <b>PLACO_P:</b> ${data_tooltip.placo_p}<br/>
                    <table style="width: 100%; text-align: left; font-size: 12px;">
                      <tr>
                        <td></td>
                        <td><b>${this.selectedCancer1}</b></td>
                        <td><b>${this.selectedCancer1}</b></td>
                      </tr>
                      <tr>
                        <td><b>EAF:</b></td>
                        <td>${data_tooltip.gwas1_EAF}</td>
                        <td>${data_tooltip.gwas2_EAF}</td>
                      </tr>
                      <tr>
                        <td><b>Beta:</b></td>
                        <td>${data_tooltip.gwas1_beta}</td>
                        <td>${data_tooltip.gwas2_beta}</td>
                      </tr>
                      <tr>
                        <td><b>SE:</b></td>
                        <td>${data_tooltip.gwas1_se}</td>
                        <td>${data_tooltip.gwas2_se}</td>
                      </tr>
                      <tr>
                        <td><b>P:</b></td>
                        <td>${data_tooltip.gwas1_p}</td>
                        <td>${data_tooltip.gwas2_p}</td>
                      </tr>
                    </table>
                `;
            } else if ( seriesIndex === 1) {
              const data_tooltip = input_data.placo_result_notsig[params.dataIndex];
              tooltipContent = `
                    <b>SNP:</b> ${data_tooltip.SNP}<br>
                    <b>SNP position:</b> ${data_tooltip.Chr}:${data_tooltip.BP}<br>
                    <b>EA/OA:</b> ${data_tooltip.A1}/${data_tooltip.A2}<br/>
                    <b>PLACO_P:</b> ${data_tooltip.placo_p}<br/>
                    <table style="width: 100%; text-align: left; font-size: 12px;">
                      <tr>
                        <td></td>
                        <td><b>${this.selectedCancer1}</b></td>
                        <td><b>${this.selectedCancer1}</b></td>
                      </tr>
                      <tr>
                        <td><b>EAF:</b></td>
                        <td>${data_tooltip.gwas1_EAF}</td>
                        <td>${data_tooltip.gwas2_EAF}</td>
                      </tr>
                      <tr>
                        <td><b>Beta:</b></td>
                        <td>${data_tooltip.gwas1_beta}</td>
                        <td>${data_tooltip.gwas2_beta}</td>
                      </tr>
                      <tr>
                        <td><b>SE:</b></td>
                        <td>${data_tooltip.gwas1_se}</td>
                        <td>${data_tooltip.gwas2_se}</td>
                      </tr>
                      <tr>
                        <td><b>P:</b></td>
                        <td>${data_tooltip.gwas1_p}</td>
                        <td>${data_tooltip.gwas2_p}</td>
                      </tr>
                    </table>
                `;
            } else if (seriesIndex === 2) {
              const data_tooltip = input_data.GWAS1_result_sig[params.dataIndex];
              tooltipContent = `<b>SNP:</b> ${data_tooltip.snpid}<br/>
                                <b>SNP position:</b> ${data_tooltip.hg19chr}:${data_tooltip.bp}<br/>
                                <b>EA/OA:</b> ${data_tooltip.a1}/${data_tooltip.a2}<br/>
                                <b>EAF:</b> ${data_tooltip.EURaf}<br/>
                                <b>Beta:</b> ${data_tooltip.beta}<br/>
                                <b>SE:</b> ${data_tooltip.se}<br/>
                                <b>P:</b> ${data_tooltip.pval}`;
            } else if (seriesIndex === 3) {
              const data_tooltip = input_data.GWAS1_result_notsig[params.dataIndex];
              tooltipContent = `<b>SNP:</b> ${data_tooltip.snpid}<br/>
                                <b>SNP position:</b> ${data_tooltip.hg19chr}:${data_tooltip.bp}<br/>
                                <b>EA/OA:</b> ${data_tooltip.a1}/${data_tooltip.a2}<br/>
                                <b>EAF:</b> ${data_tooltip.EURaf}<br/>
                                <b>Beta:</b> ${data_tooltip.beta}<br/>
                                <b>SE:</b> ${data_tooltip.se}<br/>
                                <b>P:</b> ${data_tooltip.pval}`;
            } else if (seriesIndex === 4) {
              const data_tooltip = input_data.GWAS2_result_sig[params.dataIndex];
              tooltipContent = `<b>SNP:</b> ${data_tooltip.snpid}<br/>
                                <b>SNP position:</b> ${data_tooltip.hg19chr}:${data_tooltip.bp}<br/>
                                <b>EA/OA:</b> ${data_tooltip.a1}/${data_tooltip.a2}<br/>
                                <b>EAF:</b> ${data_tooltip.EURaf}<br/>
                                <b>Beta:</b> ${data_tooltip.beta}<br/>
                                <b>SE:</b> ${data_tooltip.se}<br/>
                                <b>P:</b> ${data_tooltip.pval}`;
            } else if (seriesIndex === 5) {
              const data_tooltip = input_data.GWAS2_result_notsig[params.dataIndex];
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
        
        // toolbox: {
        //   feature: {
        //     dataZoom: {
        //       yAxisIndex: 'none' // y轴不放缩
        //     },
        //     restore: {},
        //     saveAsImage: {}
        //   }
        // },
        dataZoom: [
          {
            show: true,
            realtime: true,
            start: 0, // 缩放的起始和终止位置
            end: 100,
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
          { ...yAxisConfig, name: "-log10(PLACO_P)", },
          { ...yAxisConfig, name: `-log10(GWAS_P) ${this.selectedCancer1}`, gridIndex: 1 },
          { ...yAxisConfig, name: `-log10(GWAS_P) ${this.selectedCancer2}`, gridIndex: 2 },
        ],
        series: [
          {
            name: "Significant",
            type: "scatter",
            data: placoData_sig,
            symbolSize: 5,
            itemStyle: {
                color: 'red'
            },
          },
          {
            name: "Insignificant",
            type: "scatter",
            data: placoData_notsig,
            symbolSize: 5,
            itemStyle: {
                color: '#79bbff'
            },
          },
          {
            name: "Significant",
            type: "scatter",
            data: GWAS1Data_sig,
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
            data: GWAS1Data_notsig,
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
            data: GWAS2Data_sig,
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
            data: GWAS2Data_notsig,
            xAxisIndex: 2,
            yAxisIndex: 2,
            symbolSize: 5,
            itemStyle: {
                color: '#79bbff'
            },
          },
          ...axisConfig,
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
      this.chart_GWAS.setOption(option);
    },
    plotZscore(input_data){
      this.chart_zscore = echarts.init(this.$refs.chart_zscore);

      // 数据转换，提取 qtl_zscore 和 gwas2_zscore
      const scatterData = input_data.merged_result.map(item => [item.gwas1_zscore, item.gwas2_zscore]);

      // ECharts 配置项
      const option = {
        title: {
          text: `GWAS Z-scores (${this.selectedCancer1} vs ${this.selectedCancer2})`,
          left: 'center'
        },
        tooltip: [
          {
            trigger: 'item',
            formatter: (params) => {
              const data_tooltip = input_data.merged_result[params.dataIndex]; // 获取当前点的数据
              return `
                    <b>SNP:</b> ${data_tooltip.SNP}<br>
                    <b>SNP position:</b> ${data_tooltip.Chr}:${data_tooltip.BP}<br>
                    <b>EA/OA:</b> ${data_tooltip.A1}/${data_tooltip.A2}<br/>
                    <table style="width: 100%; text-align: left; font-size: 12px;">
                      <tr>
                        <td></td>
                        <td><b>${this.selectedCancer1}</b></td>
                        <td><b>${this.selectedCancer2}</b></td>
                      </tr>
                      <tr>
                        <td><b>EAF:</b></td>
                        <td>${data_tooltip.gwas1_EAF}</td>
                        <td>${data_tooltip.gwas2_EAF}</td>
                      </tr>
                      <tr>
                        <td><b>Z-score:</b></td>
                        <td>${data_tooltip.gwas1_zscore}</td>
                        <td>${data_tooltip.gwas2_zscore}</td>
                      </tr>
                      <tr>
                        <td><b>P:</b></td>
                        <td>${data_tooltip.gwas1_p}</td>
                        <td>${data_tooltip.gwas2_p}</td>
                      </tr>
                    </table>
                `;
            },
          },
        ],
        xAxis: {
          name: `GWAS Z-score\n(${this.selectedCancer1})`,
          type: 'value'
        },
        yAxis: {
          name: `GWAS Z-score\n(${this.selectedCancer2})`,
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
      this.loading = true;
      axios.post("/api/cancerdb/pleio_snp",{cancerType:this.cancerType,searchSNPs:this.searchSNPs,searchRegion:this.searchRegion})
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
            this.plotSankey(this.myResults)
            this.selectRow(this.myResults[0], true);
          }
          this.loading = false;
          
        })
        .catch((err) => {console.log(err)})
    },
    clearData() {
      this.cancerType = "";
      this.searchSNPs = "";
      this.searchGene = "";
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
.regioninputBox{
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
// SNP link颜色
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

</style>
  