<template>
  <div style="margin: 10px 0"></div>

  <div style="display: flex;width: 1750px; height: 700px; margin: 0 auto;  border:1px solid #e9e9eb;">
    <div class="left-container" style="height: 100%;width: 25%; overflow-y: auto;">
      <el-tabs v-model="activeTabs" style="padding-left: 10px;padding-right: 10px;">
        <el-tab-pane label="Search" name="searchTab" >
          <el-collapse v-model="searchCollapse" accordion style="padding:5px">
            <el-collapse-item name="snpSearch" >
              <template #title>
                <el-icon style="margin-right:10px; margin-left:5px"><LocationInformation /></el-icon>
                <span>SNP</span>
              </template>
              <div style="position: relative; display: inline-block; width: 100%;">
                <el-input
                  v-model="textarea_SNP"
                  type="textarea"
                  placeholder="Please input"
                />
                <el-button
                  v-if="textarea_SNP"
                  size="small"
                  @click="clearSNPTextarea"
                  style="position: absolute; top: 5px; right: 5px; z-index: 1;border: 0px;padding: 0px;"
                >
                  <el-icon><CircleClose /></el-icon>
                </el-button>
              </div>
            </el-collapse-item>
            <el-collapse-item name="methySearch">
              <template #title>
                <el-icon style="margin-right:10px; margin-left:5px"><LocationInformation /></el-icon>
                <span>Methylation</span>
              </template>
              <div style="position: relative; display: inline-block; width: 100%;">
                <el-input
                  v-model="textarea_methy"
                  type="textarea"
                  placeholder="Please input"
                />
                <el-button
                  v-if="textarea_methy"
                  size="small"
                  @click="clearMethyTextarea"
                  style="position: absolute; top: 5px; right: 5px; z-index: 1;border: 0px;padding: 0px;"
                >
                  <el-icon><CircleClose /></el-icon>
                </el-button>
              </div>
            </el-collapse-item>
            <el-collapse-item name="geneSearch">
              <template #title>
                <el-icon style="margin-right:10px; margin-left:5px"><LocationInformation /></el-icon>
                <span>Gene</span>
              </template>
              <div style="position: relative; display: inline-block; width: 100%;">
                <el-input
                  v-model="textarea_gene"
                  type="textarea"
                  placeholder="Please input"
                />
                <el-button
                  v-if="textarea_gene"
                  size="small"
                  @click="clearGeneTextarea"
                  style="position: absolute; top: 5px; right: 5px; z-index: 1;border: 0px;padding: 0px;"
                >
                  <el-icon><CircleClose /></el-icon>
                </el-button>
              </div>
            </el-collapse-item>
            <el-collapse-item name="cancerSearch">
              <template #title>
                <el-icon style="margin-right:10px; margin-left:5px"><LocationInformation /></el-icon>
                <span>Cancer</span>
              </template>
              <el-select
                ref="select"
                v-model="cancerType"
                filterable
                multiple
                collapse-tags
                collapse-tags-tooltip
                :max-collapse-tags="12"
                placeholder="Select"
                @change="handleCancerChange"
              >
                <el-option
                  v-for="item in options"
                  :key="item.value"
                  :label="item.label"
                  :value="item.value"
                />
              </el-select>
            </el-collapse-item>
            
          </el-collapse>
          <el-row :gutter="0">
            <el-col :span="12" style="text-align: center;">
              <el-button type="primary" :icon="Search" @click="fetchDataFromBackend" style="width: 100px">Search</el-button>
            </el-col> 
            <el-col :span="12" style="text-align: center;">
              <el-button type="danger" :icon="RefreshRight" @click="clearData" style="width: 100px">Reset</el-button>
            </el-col> 
          </el-row>
        </el-tab-pane>
        <el-tab-pane label="Filter" name="filterTab">
          <el-collapse v-model="outerActiveNames" accordion>
            <el-collapse-item name="node">
              <template #title>
                <el-icon style="margin-right:10px; margin-left:10px"><LocationInformation /></el-icon>
                <span>Node</span>
              </template>
              <el-collapse v-model="innerActiveNames" accordion>
                <!-- 遍历所有分类 -->
                <el-collapse-item v-for="category in categories" :key="category" :name="category" style="margin-left:25px; ">
                  <template #title>
                    <el-checkbox v-model="selectedCategories" :label="category" @change="toggleCategoryNodes(category)">
                      <div style="display: flex; justify-content: center; align-items: center;">
                        <span  style=" margin-right: 8px;">
                          <i class="dotClass" :class="getCategoryDotClass(category)"></i>
                        </span>
                        {{ category }}
                      </div>
                    </el-checkbox>
                  </template>
                  <!-- 折叠面板内的内容（即该类别下的节点） -->
                  <div v-show="true" style="padding-left: 22px;">
                    <el-checkbox-group v-model="selectedNodes">
                      <el-checkbox 
                        v-for="node in getNodesByCategory(category)" 
                        :key="node.id" 
                        :label="node.id"
                      >
                        {{ node.name }}
                      </el-checkbox>
                    </el-checkbox-group>
                  </div>
                </el-collapse-item>
              </el-collapse>
            </el-collapse-item>
            <el-collapse-item name="link">
              <template #title>
                <el-icon style="margin-right:10px; margin-left:10px"><LocationInformation /></el-icon>
                <span>Link</span>
              </template>
              <el-checkbox v-model="selectedLinkAll" style="padding-bottom: 15px; padding-left: 22px;" @change="selectAllLink">All</el-checkbox>
              <el-checkbox-group v-model="selectedLinkClasses" @change="updateChart">
                <el-checkbox
                  v-for="linkClass in linkClasses"
                  :key="linkClass"
                  :label="linkClass"
                  style="display: block; padding-left: 22px;"
                >
                  <div style="display: flex; justify-content: center; align-items: center;">
                    <span style="margin-right: 8px;">
                      <i :class="['lineClass', getLinklineClass(linkClass)]"></i> <!-- 添加lineClass -->
                    </span>
                    {{ getLinkName(linkClass) }}
                  </div>
                </el-checkbox>
              </el-checkbox-group>
            </el-collapse-item>
            
          </el-collapse>
          <el-row :gutter="0">
            <el-col :span="12" style="text-align: center;">
                <el-button type="success" :icon="Check" @click="filterData" style="width: 100px">Filter</el-button>
            </el-col> 
            <el-col :span="12" style="text-align: center;">
                <el-button type="danger" :icon="RefreshRight" @click="resetData" style="width: 100px">Reset</el-button>
            </el-col> 
          </el-row>
        </el-tab-pane>
      </el-tabs>
      
    </div>
    <div ref="network" style="width: 75%; height: 100%; border-left:1px solid #e9e9eb;"></div>
  </div>
  <!-- </el-row> -->
</template>

<script>
import { Search, RefreshRight, Check } from "@element-plus/icons-vue";
import axios from "axios";
import NProgress from 'nprogress';
import 'nprogress/nprogress.css';
import * as echarts from "echarts";

// 为axios添加拦截器
axios.interceptors.request.use(config => {
  NProgress.start();
  config.headers.Authorization = window.sessionStorage.getItem('token');
  return config;
});
axios.interceptors.response.use(config => {
  NProgress.done();
  return config;
});

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
const categories = ['SNP', 'Methylation', 'Gene', 'Protein', 'Cancer'];
const linkClasses = ['Pleiotropy', 'eQTL', 'meQTL', 'pQTL','GWAS', 'smr_meQTL_eQTL', 'smr_meQTL', 'smr_eQTL','smr_pQTL'];

export default {
  name: "NetworkGraph",
  data() {
    return {
      Search,
      RefreshRight,
      Check,
      options,
      loading: false,

      postData:false, //是否向后端传递数据

      cancerType: "",  // 选择的癌症类型
      textarea_SNP: '',
      textarea_methy: '',
      textarea_gene: '',

      activeTabs: "searchTab",
      outerActiveNames: [],
      innerActiveNames: [],
      categories,  // 节点分类
      selectedCategories: categories,
      selectedNodes: [],       // 记录选中的节点
      linkClasses, // link类
      selectedLinkClasses: linkClasses, // link类
      selectedLinkAll: true,
      chartData: {
        nodes: [],  // 保存节点数据
        links: []   // 保存边数据
      },
    };
  },
  mounted() {
    // 从 sessionStorage 获取数据
    const pleioSNP = sessionStorage.getItem('pleioSNP') ? JSON.parse(sessionStorage.getItem('pleioSNP')) : [];
    const pleioGene = sessionStorage.getItem('pleioGene') ? JSON.parse(sessionStorage.getItem('pleioGene')) : [];
    const eQTL = sessionStorage.getItem('eQTL') ? JSON.parse(sessionStorage.getItem('eQTL')) : [];
    const meQTL = sessionStorage.getItem('meQTL') ? JSON.parse(sessionStorage.getItem('meQTL')) : [];
    const pQTL = sessionStorage.getItem('pQTL') ? JSON.parse(sessionStorage.getItem('pQTL')) : [];
    const smr_meQTL_eQTL = sessionStorage.getItem('smr_meQTL_eQTL') ? JSON.parse(sessionStorage.getItem('smr_meQTL_eQTL')) : [];
    const smr_eQTL = sessionStorage.getItem('smr_eQTL') ? JSON.parse(sessionStorage.getItem('smr_eQTL')) : [];
    const smr_pQTL = sessionStorage.getItem('smr_pQTL') ? JSON.parse(sessionStorage.getItem('smr_pQTL')) : [];
    const GWAS = sessionStorage.getItem('GWAS') ? JSON.parse(sessionStorage.getItem('GWAS')) : [];
    const smr_meQTL = sessionStorage.getItem('smr_meQTL') ? JSON.parse(sessionStorage.getItem('smr_meQTL')) : [];

    if (
      [pleioSNP, pleioGene, eQTL, meQTL, pQTL, smr_meQTL_eQTL, smr_eQTL, smr_pQTL, GWAS, smr_meQTL]
        .some(arr => arr.length) && 
      !this.postData
    ) {
      this.chartData = this.processData(pleioSNP, pleioGene, eQTL, meQTL, pQTL, smr_meQTL_eQTL, smr_eQTL, smr_pQTL, GWAS, smr_meQTL);
      
      // 通过方法将所有节点加入到selectedNodes中，确保所有节点都被勾选
      this.chartData.nodes.forEach(node => {
        this.selectedNodes.push(node.id);
      });

      // 为各个分类的文本框赋值
      this.textarea_SNP = this.getNodesNamesByCategory('SNP');
      this.textarea_methy = this.getNodesNamesByCategory('Methylation');
      this.textarea_gene = this.getNodesNamesByCategory(['Gene', 'Protein']);
      this.cancerType = this.chartData.nodes
        .filter(node => (node.category === 'Cancer')) 
        .map(node => node.name) 

      this.initChart(this.chartData);
    } else {
      // 如果没有数据，可以向后端请求数据
      this.fetchDataFromBackend();
      this.postData = true;
    }
  },

  methods: {
    clearData() {
      this.cancerType = "";  // 选择的癌症类型
      this.textarea_SNP = '';
      this.textarea_methy = '';
      this.textarea_gene = '';
    },
    getNodesNamesByCategory(categories) {
      return this.chartData.nodes
        .filter(node => Array.isArray(categories) ? categories.includes(node.category) : node.category === categories)
        .map(node => node.name)
        .join('\n'); // 默认使用换行符连接
    },
    clearSNPTextarea() {
      this.textarea_SNP = '';
    },
    clearMethyTextarea() {
      this.textarea_methy = '';
    },
    clearGeneTextarea() {
      this.textarea_gene = '';
    },
    handleCancerChange() {
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
    getLinkName(linkClass) {
      const linkClassMapping = {
        eQTL: 'SNP - Gene',
        meQTL: 'SNP - Methylation',
        pQTL: 'SNP - Protein',
        smr_meQTL_eQTL: 'Methylation - Gene',
        smr_eQTL: 'Gene - Cancer',
        smr_pQTL: 'Protein - Cancer',
        smr_meQTL: 'Methylation - Cancer',
        GWAS: 'SNP - Cancer'
      };
      return linkClassMapping[linkClass] || linkClass; // 如果没有映射则显示原始值
    },
    // 获取edge类别并分配line颜色
    getLinklineClass(linkClass) {
      const classColors = {
        eQTL: 'line-eQTL',
        meQTL: 'line-meQTL',
        pQTL: 'line-pQTL',
        smr_meQTL_eQTL: 'line-smr_meQTL_eQTL',
        smr_eQTL: 'line-smr_eQTL',
        smr_pQTL: 'line-smr_pQTL',
        smr_meQTL: 'line-smr_meQTL',
        GWAS: 'line-GWAS',
        Pleiotropy: 'line-Pleiotropy',
      };
      // 返回对应的类，如果没有对应的类，返回默认样式
      return classColors[linkClass] || 'line-default';
    },
    // 获取节点类别并分配dot颜色
    getCategoryDotClass(category) {
      const categoryColors = {
        SNP: 'dot-snp',
        Methylation: 'dot-methylation',
        Gene: 'dot-gene',
        Protein: 'dot-protein',
        Cancer: 'dot-cancer',
      };
      return categoryColors[category] || 'dot-default';
    },
    filterData() {
      this.updateChart();
    },
    // 所有节点都被勾选
    resetData() {
      this.chartData.nodes.forEach(node => {
        this.selectedNodes.push(node.id);
      });
      this.selectedCategories = ['SNP', 'Methylation', 'Gene', 'Protein', 'Cancer'];
      this.selectedLinkClasses = ['Pleiotropy', 'eQTL', 'meQTL', 'pQTL', 'smr_meQTL_eQTL', 'smr_eQTL', 'smr_pQTL','GWAS','smr_meQTL'];
    },
    // 获取指定分类的节点
    getNodesByCategory(category) {
      return this.chartData.nodes.filter(node => node.category === category);
    },

    // 处理点击类别时，勾选或取消勾选该类别下的所有节点
    toggleCategoryNodes(category) {
      const nodesInCategory = this.getNodesByCategory(category);
      const categorySelected = this.selectedCategories.includes(category);

      if (categorySelected) {
        // 如果类别被选中，勾选该类别下所有节点（避免重复）
        nodesInCategory.forEach(node => {
          if (!this.selectedNodes.includes(node.id)) {
            this.selectedNodes.push(node.id);
          }
        });
      } else {
        // 如果类别取消选中，取消勾选该类别下所有节点
        nodesInCategory.forEach(node => {
          this.selectedNodes = this.selectedNodes.filter(id => id !== node.id);
        });
      }

      // 更新图表（如果需要更新图表）
      this.updateChart();
    },

    selectAllLink() {
      this.selectedLinkClasses = this.selectedLinkAll ? this.linkClasses : [];
      this.updateChart();
    },

    // 更新图表
    updateChart() {
      // 过滤出选中的节点和边
      const selectedNodeNames = new Set(this.selectedNodes);

      // 过滤出有连接的边
      const selectedLinks = this.chartData.links.filter(link => 
        this.selectedLinkClasses.includes(link.class)
      );

      // 通过连接的边来找出有连接的节点
      const connectedNodeIds = new Set();
      selectedLinks.forEach(link => {
        connectedNodeIds.add(link.source);
        connectedNodeIds.add(link.target);
      });

      // 只保留那些与边相连的节点
      const selectedNodes = this.chartData.nodes.filter(node => 
        selectedNodeNames.has(node.id) && connectedNodeIds.has(node.id)
      );

      // 初始化图表，更新节点和边
      this.initChart({
        nodes: selectedNodes,
        links: selectedLinks,
      });
    },

    // 从后端获取数据
    fetchDataFromBackend() {
      axios.post('/api/cancerdb/network', {cancer:this.cancerType, gene: this.textarea_gene, methy: this.textarea_methy,snp:this.textarea_SNP}) // 请求 Flask 后端接口
        .then(response => {
          const { pleioSNP, pleioGene, eQTL, meQTL, pQTL, smr_meQTL_eQTL, smr_eQTL, smr_pQTL, GWAS, smr_meQTL } = response.data;

          // 处理数据并绘制图表
          const chartData = this.processData(pleioSNP, pleioGene, eQTL, meQTL, pQTL, smr_meQTL_eQTL, smr_eQTL, smr_pQTL, GWAS, smr_meQTL);
          this.chartData = chartData;  // 更新图表数据
          // 将所有新的节点勾选上
          this.selectedNodes = chartData.nodes.map(node => node.id);
          
          this.initChart(chartData);
        })
        .catch(error => {
          console.error("There was an error fetching the data:", error);
        });
    },

    // 处理数据
    processData(pleioSNP, pleioGene, eQTL, meQTL, pQTL, smr_meQTL_eQTL, smr_eQTL, smr_pQTL, GWAS, smr_meQTL) {
      const nodes = [];
      const links = [];

      // 辅助函数：检查节点是否已经存在
      const addNodeIfNotExist = (id, name, className) => {
        if (!nodes.find(node => node.id === id)) {
          nodes.push({ id, name, category: className });
        }
      };

      // 处理 pleioSNP 数据
      pleioSNP.forEach(item => {
        addNodeIfNotExist(item.snpid, item.snpid, "SNP");
        addNodeIfNotExist(item.cancer1, item.cancer1, "Cancer");
        addNodeIfNotExist(item.cancer2, item.cancer2, "Cancer");

        if (item.cancer1 && item.cancer2) {
          const pleio1tooltip = `<b>Pleiotropy:</b> ${item.cancer1} - ${item.snpid} - ${item.cancer2}<br/><br/>
                                 <b>SNP:</b> ${item.snpid}<br/>
                                 <b>SNP position:</b> ${item.hg19chr}:${item.bp}<br/>
                                 <b>EA/OA:</b> ${item.alleles}<br/>
                                 <b>EAF:</b> ${item['EURaf.trait1']}<br/>
                                 <b>PLACO_P:</b> ${item["p.placo"]}<br/><br/>
                                 <b>GWAS:</b> ${item.snpid} - ${item.cancer1}<br/><br/>
                                 <b>OR:</b> ${item['or.trait1']}<br/>
                                 <b>SE:</b> ${item['se.trait1']}<br/>
                                 <b>P:</b> ${item['pval.trait1']}`;
                                 
          const pleio2tooltip = `<b>Pleiotropy:</b> ${item.cancer1} - ${item.snpid} - ${item.cancer2}<br/><br/>
                                 <b>SNP:</b> ${item.snpid}<br/>
                                 <b>SNP position:</b> ${item.hg19chr}:${item.bp}<br/>
                                 <b>EA/OA:</b> ${item.alleles}<br/>
                                 <b>EAF:</b> ${item['EURaf.trait2']}<br/>
                                 <b>PLACO_FDR:</b> ${item["p.placo"]}<br/><br/>
                                 <b>GWAS:</b> ${item.snpid} - ${item.cancer2}<br/><br/>
                                 <b>OR:</b> ${item['or.trait2']}<br/>
                                 <b>SE:</b> ${item['se.trait2']}<br/>
                                 <b>P:</b> ${item['pval.trait2']}`;
                                
          links.push({ source: item.snpid, target: item.cancer1, class: "Pleiotropy", tooltip:pleio1tooltip });
          links.push({ source: item.snpid, target: item.cancer2, class: "Pleiotropy", tooltip:pleio2tooltip });
        }
      });

      pleioGene.forEach(item => {
        addNodeIfNotExist(item.SYMBOL, item.SYMBOL, "Gene");
        addNodeIfNotExist(item.cancer1, item.cancer1, "Cancer");
        addNodeIfNotExist(item.cancer2, item.cancer2, "Cancer");
      
        if (item.cancer1 && item.cancer2) {
          const pleio1tooltip = `<b>Pleiotropy:</b> ${item.cancer1} - ${item.SYMBOL} - ${item.cancer2}<br/>
                                 <b>PLACO_FDR:</b> ${item["fdr.PLACO"]}`;
          const pleio2tooltip = `<b>Pleiotropy:</b> ${item.cancer1} - ${item.SYMBOL} - ${item.cancer2}<br/>
                                 <b>PLACO_FDR:</b> ${item["fdr.PLACO"]}`;
          links.push({ source: item.SYMBOL, target: item.cancer1, class: "Pleiotropy", tooltip:pleio1tooltip });
          links.push({ source: item.SYMBOL, target: item.cancer2, class: "Pleiotropy", tooltip:pleio2tooltip });
        }
      });

      // 处理 eQTL 数据
      eQTL.forEach(item => {
        if((eQTL.length>50 && item.PLACO) || eQTL.length<=50) {
          const eQTLtooltip = `<b>eQTL: </b>${item.SNP} - ${item.GeneSymbol}<br/><br/>
                              <b>SNP:</b> ${item.SNP}<br/>
                              <b>SNP position:</b> ${item.SNPChr}:${item.SNPPos}<br/>
                              <b>EA/OA:</b> ${item.AssessedAllele}/${item.OtherAllele}<br/>
                              <b>Gene:</b> ${item.GeneSymbol}<br/>
                              <b>Gene position:</b> ${item.GeneChr}:${item.GenePos}<br/>
                              <b>Z-score:</b> ${item.Zscore}<br/>
                              <b>P:</b> ${item.Pvalue}<br/>
                              <b>FDR:</b> ${item.FDR}`;
          addNodeIfNotExist(item.SNP, item.SNP, "SNP");
          addNodeIfNotExist(item.GeneSymbol, item.GeneSymbol, "Gene");

          links.push({ source: item.SNP, target: item.GeneSymbol, class: "eQTL", tooltip:eQTLtooltip });
        }
      });

      // 处理 meQTL 数据
      meQTL.forEach(item => {
        if((meQTL.length>50 && item.PLACO) || meQTL.length<=50) {
          addNodeIfNotExist(item.SNP, item.SNP, "SNP");
          addNodeIfNotExist(item.Probe, item.Probe, "Methylation");
        
          const meQTLtooltip = `<b>meQTL:</b> ${item.SNP} - ${item.Probe}<br/><br/>
                                <b>SNP:</b> ${item.SNP}<br/>
                                <b>SNP position:</b> ${item.Chr}:${item.BP}<br/>
                                <b>EA/OA:</b> ${item.A1}/${item.A2}<br/>
                                <b>EAF:</b> ${item.Freq}<br/>
                                <b>Methylation:</b> ${item.Probe}<br/>
                                <b>Methylation position:</b> ${item.Probe_Chr}:${item.Probe_bp}<br/>
                                <b>Beta:</b> ${item.b}<br/>
                                <b>SE:</b> ${item.SE}<br/>
                                <b>P:</b> ${item.p}`;

          links.push({ source: item.SNP, target: item.Probe, class: "meQTL", tooltip:meQTLtooltip });
        }
      });

      // 处理 pQTL 数据
      pQTL.forEach(item => {
        if((pQTL.length>50 && item.PLACO) || pQTL.length<=50) {
          addNodeIfNotExist(item.SNP, item.SNP, "SNP");
          addNodeIfNotExist(item.Probe, item.Gene, "Protein");

          const pQTLtooltip = `<b>pQTL:</b> ${item.SNP} - ${item.Gene}<br/><br/>
                              <b>SNP:</b> ${item.SNP}<br/>
                              <b>SNP position:</b> ${item.Chr}:${item.BP}<br/>
                              <b>EA/OA:</b> ${item.A1}/${item.A2}<br/>
                              <b>EAF:</b> ${item.Freq}<br/>
                              <b>Protein:</b> ${item.Gene}<br/>
                              <b>Protein position:</b> ${item.Probe_Chr}:${item.Probe_bp}<br/>
                              <b>Beta:</b> ${item.b}<br/>
                              <b>SE:</b> ${item.SE}<br/>
                              <b>P:</b> ${item.p}`;
          links.push({ source: item.SNP, target: item.Probe, class: "pQTL", tooltip:pQTLtooltip });
        }
      });

      // 处理 meqtl-eqtl 数据
      smr_meQTL_eQTL.forEach(item => {
        addNodeIfNotExist(item.Expo_ID, item.Expo_ID, "Methylation");
        addNodeIfNotExist(item.symbol, item.symbol, "Gene");

        const smr_meQTL_eQTLtooltip = `<b>SMR (meQTL-eQTL):</b> ${item.Expo_ID} - ${item.symbol}<br/><br/>
                                       <b>Methylation:</b> ${item.Expo_ID}<br/>
                                       <b>Methylation position:</b> ${item.Expo_Chr}:${item.Expo_bp}<br/>
                                       <b>Gene:</b> ${item.symbol}<br/>
                                       <b>Gene position:</b> ${item.Outco_Chr}:${item.Outco_bp}<br/>
                                       <b>Beta:</b> ${item.b_SMR}<br/>
                                       <b>SE:</b> ${item.se_SMR}<br/>
                                       <b>P:</b> ${item.p_SMR}<br/>
                                       <b>P_multi:</b> ${item.p_SMR_multi}<br/>                                
                                       <b>FDR:</b> ${item.fdr}<br/>
                                       <b>HEIDI_P:</b> ${item.p_HEIDI}<br/>
                                       <b>HEIDI_nsnp:</b> ${item.nsnp_HEIDI}<br/>`;
        links.push({ source: item.Expo_ID, target: item.symbol, class: "smr_meQTL_eQTL", tooltip:smr_meQTL_eQTLtooltip });
      });
      // 处理 smr-eqtl 数据
      smr_eQTL.forEach(item => {
        addNodeIfNotExist(item.symbol, item.symbol, "Gene");
        addNodeIfNotExist(item.cancer, item.cancer, "Cancer");

        const smr_eQTLtooltip = `<b>SMR (eQTL-GWAS):</b> ${item.symbol} - ${item.cancer}<br/><br/>
                             <b>Gene:</b> ${item.symbol}<br/>
                             <b>Gene position:</b> ${item.ProbeChr}:${item.Probe_bp}<br/>
                             <b>Cancer:</b> ${item.cancer}<br/>
                             <b>Beta:</b> ${item.b_SMR}<br/>
                             <b>SE:</b> ${item.se_SMR}<br/>
                             <b>P:</b> ${item.p_SMR}<br/>
                             <b>P_multi:</b> ${item.p_SMR_multi}<br/>                                
                             <b>FDR:</b> ${item.fdr}<br/>
                             <b>HEIDI_P:</b> ${item.p_HEIDI}<br/>
                             <b>HEIDI_nsnp:</b> ${item.nsnp_HEIDI}<br/>`;
        links.push({ source: item.symbol, target: item.cancer, class: "smr_eQTL", tooltip:smr_eQTLtooltip });
      });
      // 处理 smr-pqtl 数据
      smr_pQTL.forEach(item => {
        addNodeIfNotExist(item.probeID, item.Gene, "Protein");
        addNodeIfNotExist(item.cancer, item.cancer, "Cancer");

        const smr_pQTLtooltip = `<b>SMR (pQTL-GWAS):</b> ${item.Gene} - ${item.cancer}<br/><br/>
                                 <b>Protein:</b> ${item.Gene}<br/>
                                 <b>Protein position:</b> ${item.ProbeChr}:${item.Probe_bp}<br/>
                                 <b>Cancer:</b> ${item.cancer}<br/>
                                 <b>Beta:</b> ${item.b_SMR}<br/>
                                 <b>SE:</b> ${item.se_SMR}<br/>
                                 <b>P:</b> ${item.p_SMR}<br/>
                                 <b>P_multi:</b> ${item.p_SMR_multi}<br/>                                
                                 <b>FDR:</b> ${item.fdr}<br/>
                                 <b>HEIDI_P:</b> ${item.p_HEIDI}<br/>
                                 <b>HEIDI_nsnp:</b> ${item.nsnp_HEIDI}<br/>`;
        links.push({ source: item.probeID, target: item.cancer, class: "smr_pQTL", tooltip:smr_pQTLtooltip });
      });
      smr_meQTL.forEach(item => {
        addNodeIfNotExist(item.probeID, item.probeID, "Methylation");
        addNodeIfNotExist(item.cancer, item.cancer, "Cancer");

        const smr_meQTLtooltip = `<b>SMR (meQTL-GWAS):</b> ${item.probeID} - ${item.cancer}<br/><br/>
                                 <b>Methylation:</b> ${item.probeID}<br/>
                                 <b>Methylation position:</b> ${item.ProbeChr}:${item.Probe_bp}<br/>
                                 <b>Cancer:</b> ${item.cancer}<br/>
                                 <b>Beta:</b> ${item.b_SMR}<br/>
                                 <b>SE:</b> ${item.se_SMR}<br/>
                                 <b>P:</b> ${item.p_SMR}<br/>
                                 <b>P_multi:</b> ${item.p_SMR_multi}<br/>                                
                                 <b>FDR:</b> ${item.fdr}<br/>
                                 <b>HEIDI_P:</b> ${item.p_HEIDI}<br/>
                                 <b>HEIDI_nsnp:</b> ${item.nsnp_HEIDI}<br/>`;
        links.push({ source: item.probeID, target: item.cancer, class: "smr_meQTL", tooltip:smr_meQTLtooltip });
      });
      GWAS.forEach(item => {
        addNodeIfNotExist(item.snpid, item.snpid, "SNP");
        addNodeIfNotExist(item.cancer, item.cancer, "Cancer");

        const GWAStooltip = `<b>GWAS:</b> ${item.snpid} - ${item.cancer}<br/><br/>
                            <b>SNP:</b> ${item.snpid}<br/>
                            <b>SNP position:</b> ${item.hg19chr}:${item.bp}<br/>
                            <b>EA/OA:</b> ${item.a1}/${item.a2}<br/>
                            <b>EAF:</b> ${item.EURaf}<br/>
                            <b>OR:</b> ${item.or}<br/>
                            <b>SE:</b> ${item.se}<br/>
                            <b>P:</b> ${item.pval}`;
                                 
        links.push({ source: item.snpid, target: item.cancer, class: "GWAS", tooltip:GWAStooltip });
      });
      return { nodes, links };
    },


    // 初始化 ECharts
    initChart(chartData) {
      const myChart = echarts.init(this.$refs.network, null, { renderer: 'svg' });

      const option = {
        color:['#5470c6','#8fca74','#f6c557','#ea6464','#9a60b4'], // 蓝、绿
        animation: false, // 取消动画加载效果，头晕
        // animationDurationUpdate: 1500,
        // // 控制着图表在数据更新时的动画过渡效果，使得数据变化更加平滑自然
        // // 动画在开始和结束时速度较慢，在中间阶段速度最快，然后再次减缓
        // animationEasingUpdate: 'quinticInOut',

        tooltip: {
          trigger: 'item',  // 触发类型：'item'表示鼠标悬停在项上时触发
          formatter: function (params) {
            if(params.data.category){
              return params.data.name; // 节点默认显示
            } else {
              if(params.data.tooltip){
                return params.data.tooltip;
              } else {
                return params.data.class;
              };
            };
          },
        },
        legend: [
          {
            x: "right",
            show: false,
            data: ['SNP', 'Methylation', 'Gene', 'Protein', 'Cancer'],
            itemStyle: {
              // 设置图例项的颜色和形状
              borderWidth: 1,
              borderColor: '#ccc',
            },
            icon: 'circle',  // 使用圆形图标，默认是圆形，你也可以使用'rect'等其他图标
          },
        ],
        series: [
          {
            type: 'graph',
            layout: 'force',
            symbolSize: 40, // 节点大小
            // 当鼠标悬停在图例上时，对应的系列会突出显示，而其他系列则会变为半透明或者隐藏
            legendHoverLink: true,
            // 图可拖拽平移和缩放
            roam: true,
            // 节点可拖拽
            draggable: true,
            categories: [
              { name: "SNP" },
              { name: "Methylation" },
              { name: "Gene" },
              { name: "Protein" },
              { name: "Cancer"},
              // { name: "Protein", symbolSize: 20 },
            ],
            // cursor: 'pointer',
            data: chartData.nodes,
            links: chartData.links.map(link => {
              // 根据link的class设置不同的lineStyle
              if (link.class === 'Pleiotropy') {
                link.lineStyle = { color: '#9a60b4', type: 'solid', width: 2 };
              } else if (link.class === 'eQTL') {
                link.lineStyle = { color: '#f6c557', type: 'dashed', width: 2 };
              } else if (link.class === 'meQTL') {
                link.lineStyle = { color: '#8fca74', type: 'dashed', width: 2 };
              } else if (link.class === 'pQTL') {
                link.lineStyle = { color: '#ea6464', type: 'dashed', width: 2 };
              } else if (link.class === 'smr_meQTL_eQTL') {
                link.lineStyle = { color: '#8fca74', type: 'dotted', width: 2 };
              } else if (link.class === 'smr_eQTL') {
                link.lineStyle = { color: '#f6c557', type: 'dotted', width: 2 };
              } else if (link.class === 'smr_pQTL') {
                link.lineStyle = { color: '#ea6464', type: 'dotted', width: 2 };
              } else if (link.class === 'smr_meQTL') {
                link.lineStyle = { color: '#9a60b4', type: 'dotted', width: 2 };
              }else if (link.class === 'GWAS') {
                link.lineStyle = { color: '#5470c6', type: 'dashed', width: 2 };
              };
              return link;
            }),            // 节点在强调状态（emphasis）下的样式和行为的属性配置。
            emphasis: {
              scale: true, // 强调状态下是否进行缩放
              focus: 'adjacency', // 强调状态下的聚焦行为,当用户悬停在某个节点上时，与该节点相连的其他节点也会同时强调
            },
             // 节点标签
            label: {
              show: true,
              // fontStyle: "oblique", // 斜体
              // fontSize: 12,
              // color: '#000',
              // width: 100,
              // // 标签内容超出宽度时自动换行
              // overflow: "break",
              // position: 'right',
              // formatter: '{b}'
            },
            // 边线属性
            lineStyle: {
              
              // color: function(params) {
              //   if (params.data.class === 'SNP') {
              //     params.data.lineStyle = { color: '#ee6666', type: 'solid', width: 2 };
              //   } else if (params.data.class === 'Cancer') {
              //     params.data.lineStyle = { color: '#91cc75', type: 'dashed', width: 2 };
              //   } else if (params.data.class === 'Gene') {
              //     params.data.lineStyle = { color: '#5470c6', type: 'dotted', width: 2 };
              //   } else if (params.data.class === 'Methylation') {
              //     params.data.lineStyle = { color: '#fac858', type: 'solid', width: 2 };
              //   } else if (params.data.class === 'Protein') {
              //     params.data.lineStyle = { color: '#73c0de', type: 'dashed', width: 2 };
              //   } else {
              //     params.data.lineStyle = { color: '#666', type: 'solid', width: 2 };
              //   }
              // },
              // color: "#666",
              // width: 2,
              // curveness: 0.5, // 曲率
              // color: "#666",
              // width: 2,
              // curveness: 0.2, // 曲率
            },
            // 边标签
            edgeLabel: {
              show: false,
              fontWeight: 800,
              fontSize: 12,
              color: "#000",
              // formatter: function(x) {
              //     return x.data.class
              // },
              position: "middle",
            },
            force: {
              repulsion: [50, 2000],
              edgeLength: [1, 15],
              gravity: 0.2,
              friction: 0.1,
              // layoutAnimation: false,
            },
          },
        ],
      };

      // 处理 source 和 target 相同的边，增加 curveness
      const sameLinksMap = {};
      chartData.links.forEach((link, index) => {
        const key = `${link.source}-${link.target}`;
        if (!sameLinksMap[key]) {
          sameLinksMap[key] = [];
        }
        sameLinksMap[key].push(index);
      });

      Object.values(sameLinksMap).forEach(linkIndexes => {
        let curveness = 0;
        linkIndexes.forEach((index, i) => {
          // 确定 curveness 按 0.1、-0.1、0.2、-0.2 ... 排列
          curveness = i % 2 === 0 ? (i / 2) * 0.1 : -(Math.ceil(i / 2) * 0.1);
          option.series[0].links[index].lineStyle.curveness = curveness;
        });
      });

      // 如果节点只有两个，固定节点位置
      if (chartData.nodes.length === 2) {
        chartData.nodes[0].x = 500;
        chartData.nodes[0].y = 300;
        chartData.nodes[1].x = 600;
        chartData.nodes[1].y = 300;
      }
      myChart.setOption(option);
    }
  },
};
</script>

<style lang="less">

.row-selected {
  background-color: #a0cfff !important;
}
</style>

<style lang="scss" scoped>
:deep(.el-select__tags-text) {
  color: black;
}
:deep(.el-select__wrapper) {
  height: 350px;
}
:deep(.el-textarea__inner) {
  height: 350px;
}
.icon {
  padding: 5px;
}
.el-row{
  margin: 20px;
}
.display {
  display: flex;
  justify-content: center; /* 水平居中 */
}
.left-container {
  // margin-left: 150px;
  flex: 1;
  box-sizing: border-box;
  overflow-y: auto;
}
.dot-snp {
  background-color: #5470c6; /* 蓝色 */
}
.dot-methylation {
  background-color: #8fca74; /* 绿色 */
}
.dot-gene {
  background-color: #f6c557; /* 黄色 */
}
.dot-protein {
  background-color: #ea6464; /* 红色 */
}
.dot-cancer {
  background-color: #9a60b4; /* 紫色 */
}
.dot-default {
  background-color: #cccccc; /* 默认灰色 */
}
.dotClass {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  display: block;
}
.lineClass {
  display: inline-block;
  width: 40px; /* 可以根据需要调整线条的长度 */
  height: 1px;
  // margin-right: 8px; /* 设置文字与线条之间的间距 */
  border-bottom: 0px;
  border-left: 0px;
  border-right: 0px;
}

.line-default {
  border-top: 2px solid rgb(115.2, 117.6, 122.4);
}

.line-eQTL {
  border-top: 2px dashed #f6c557;
}
.line-Pleiotropy {
  border-top: 2px solid #9a60b4;
}
.line-GWAS {
  border-top: 2px dashed #5470c6;
}
.line-smr_meQTL {
  border-top: 2px dotted #9a60b4;
}
.line-smr_eQTL {
  border-top: 2px dotted #f6c557;
}
.line-smr_pQTL {
  border-top: 2px dotted #ea6464;
}
.line-smr_meQTL_eQTL {
  border-top: 2px dotted #8fca74;
}
.line-pQTL {
  border-top: 2px dashed #ea6464;
}
.line-meQTL {
  border-top: 2px dashed #8fca74;
}
</style>