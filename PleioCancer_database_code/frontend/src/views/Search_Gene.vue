<template>
  <div style="margin: 10px 0"></div>
  <div class="container">
    <div class="container-menu" >
      <el-menu :default-active="activeMenu">
        <el-menu-item index="1" @click="scrollTo('menu_pleioGene')">Pleiotropic gene</el-menu-item>
        <el-menu-item index="2" @click="scrollTo('menu_eQTL')">eQTL</el-menu-item>
        <el-menu-item index="3" @click="scrollTo('menu_pQTL')">pQTL</el-menu-item>
        <el-menu-item index="4" @click="scrollTo('menu_smr_eQTL')">Causal gene</el-menu-item>
        <el-menu-item index="5" @click="scrollTo('menu_smr_pQTL')">Causal protein</el-menu-item>
        <el-button type="primary" style="margin-left:20px;margin-top: 50px;" @click="plotNetwork">
          Plot network
        </el-button>
      </el-menu>
    </div>
    <div class="container-content">
      <el-collapse v-model="activeNames">
        <el-collapse-item id="menu_pleioGene" title="Pleiotropic Gene" name="1">
          <div style="width:98%;margin:0 auto;margin-top: 20px;">
            <el-tabs v-model="active_tabs_pleioGene">
              <el-tab-pane label="Table" name="first">
                <el-row :gutter="0">
                  <el-col :span="20">
                    <el-pagination
                      center
                      background
                      layout="prev, pager, next, total, jumper"
                      :page-size="pagesize_pleioGene"
                      :total="pleioGene.length"
                      :current-page="currpage_pleioGene"
                      @current-change="handleCurrentChange_pleioGene"
                      @size-change="handleSizeChange_pleioGene"
                    >
                  </el-pagination>
                </el-col>
              
                <el-col :span="4" style="display: flex; justify-content: flex-end; align-items: center;">
                  <el-button @click="download_pleioGene" type="primary" plain style="width: 100px;">Download</el-button>
                </el-col>  
                </el-row>
                <el-table
                  :data="pleioGene.slice((currpage_pleioGene - 1) * pagesize_pleioGene, currpage_pleioGene * pagesize_pleioGene)"
                  border
                  style="margin: 10px 0; text-align: center; width: 100%; max-width: 2000px"
                  :header-cell-style="{ background: '#ecf5ff', color: '#337ecc' }"
                  v-loading="loading"
                  @sort-change="handleSort_pleioGene"
                  :row-class-name="rowClassName"
                >
                  <el-table-column prop="cancer1" label="Cancer 1" min-width="120px" align="center" sortable="custom" />
                  <el-table-column prop="cancer2" label="Cancer 2" min-width="120px" align="center" sortable="custom" />
                  
                  <el-table-column prop="SYMBOL" label="Gene" min-width="120px" align="center" />
                  <el-table-column label="Gene position" min-width="180px" align="center" >
                    <template v-slot="slotProps">
                      {{ slotProps.row.CHR }}:{{ slotProps.row.START }}-{{ slotProps.row.STOP }}
                    </template>
                  </el-table-column>
                  <el-table-column prop="X5" label="Gene strand" min-width="120px" align="center" />
                  <el-table-column prop="NSNPS" label="Number of SNPs" min-width="120px" align="center" sortable="custom" />
                  <el-table-column prop="fdr.PLACO" label="PLACO_FDR" min-width="120px" align="center" sortable="custom" />
                  <el-table-column prop="fdr.trait1" label="Cancer1_FDR" min-width="120px" align="center" sortable="custom"/>
                  <el-table-column prop="fdr.trait2" label="Cancer2_FDR" min-width="120px" align="center" sortable="custom"/>
                  <el-table-column prop="PP.H4.abf" label="PP.H4.abf" min-width="120px" align="center" sortable="custom"/>
                  <el-table-column prop="PP.H0.abf" label="PP.H0.abf" min-width="120px" align="center" sortable="custom"/>
                  <el-table-column prop="PP.H1.abf" label="PP.H1.abf" min-width="120px" align="center" sortable="custom"/>
                  <el-table-column prop="PP.H2.abf" label="PP.H2.abf" min-width="120px" align="center" sortable="custom"/>
                  <el-table-column prop="PP.H3.abf" label="PP.H3.abf" min-width="120px" align="center" sortable="custom"/>
                  <el-table-column prop="snp" label="Candidate SNP" min-width="120px" align="center" sortable="custom">
                    <template v-slot="scope">
                      <a :href="'http://localhost:8081/cancerdb/search_pleio_snp?snp=' + scope.row.snp" target="_blank" class="link-snpid">
                        {{ scope.row.snp }}
                      </a>
                    </template>
                  </el-table-column>
                  <el-table-column prop="SNP.PP.H4" label="SNP.PP.H4" min-width="120px" align="center" sortable="custom"/>
                </el-table>
              </el-tab-pane>
              <el-tab-pane label="Heatmap" name="second">
                <div style="display: flex;width: 100%; height: 750px; margin: 0 auto;">
                  <div id="chart_pleioGene" ref="chart_pleioGene" style="width: 750px; height: 750px;"></div>
                  <div id="chart_pleioGene_PP" ref="chart_pleioGene_PP" style="width: 750px; height: 750px;"></div>
                </div>
              </el-tab-pane>
            </el-tabs>
          </div>
        </el-collapse-item>
        <el-collapse-item id="menu_eQTL" title="eQTL" name="2">
          <div style="width:98%;margin:0 auto;margin-top: 20px;">
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
              <el-table-column prop="SNP" label="SNP" min-width="120px" align="center" sortable="custom">
                <template v-slot="scope">
                  <a :href="'http://localhost:8081/cancerdb/search_pleio_snp?snp=' + scope.row.SNP" target="_blank" class="link-snpid">
                    {{ scope.row.SNP }}
                  </a>
                </template>
              </el-table-column>
              <el-table-column label="SNP position" min-width="120px" align="center" >
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
              <el-table-column prop="PLACO" label="Pleiotropic SNP" min-width="120px" align="center" sortable="custom" :formatter="formatBoolean" />
              <el-table-column prop="GeneSymbol" label="Gene" min-width="120px" align="center" />
              <el-table-column label="Gene position" min-width="120px" align="center">
                <template v-slot="slotProps">
                  {{ slotProps.row.GeneChr }}:{{ slotProps.row.GenePos }}
                </template>
              </el-table-column>
              <el-table-column prop="Zscore" label="Z-score" min-width="120px" align="center"  sortable="custom" />
              <el-table-column prop="Pvalue" label="P" min-width="120px" align="center"  sortable="custom" />
              <el-table-column prop="FDR" label="FDR" min-width="120px" align="center"  sortable="custom" />
            </el-table>
          </div>
        </el-collapse-item>
        <el-collapse-item id="menu_pQTL" title="pQTL" name="3">
          <div style="width:98%;margin:0 auto;margin-top: 20px;">
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
              <el-table-column prop="PLACO" label="Pleiotropic SNP" min-width="120px" align="center" sortable="custom" :formatter="formatBoolean" />
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
          </div>
        </el-collapse-item>
        <el-collapse-item id="menu_smr_eQTL" title="Causal gene" name="5">
          <div style="width:98%;margin:0 auto;margin-top: 20px;">
            <el-tabs v-model="active_tabs_smr_eQTL">
              <el-tab-pane label="Table" name="first">
                <el-row :gutter="0">
                  <el-col :span="20">
                    <el-pagination
                      center
                      background
                      layout="prev, pager, next, total, jumper"
                      :page-size="pagesize_smr_eQTL"
                      :total="smr_eQTL.length"
                      :current-page="currpage_smr_eQTL"
                      @current-change="handleCurrentChange_smr_eQTL"
                      @size-change="handleSizeChange_smr_eQTL"
                    >
                    </el-pagination>
                  </el-col>
                  <el-col :span="4" style="display: flex; justify-content: flex-end; align-items: center;">
                    <el-button @click="download_smr_eqtl" type="primary" plain style="width: 100px;">Download</el-button>
                  </el-col>
                </el-row>
                <el-table
                  :data="smr_eQTL.slice((currpage_smr_eQTL - 1) * pagesize_smr_eQTL, currpage_smr_eQTL * pagesize_smr_eQTL)"
                  border
                  style="margin: 10px 0; text-align: center; width: 100%; max-width: 2000px"
                  :header-cell-style="{ background: '#ecf5ff', color: '#337ecc' }"
                  v-loading="loading"
                  @sort-change="handleSort_smr_eQTL"
                  :row-class-name="rowClassName"
                >
                  <el-table-column prop="symbol" label="Gene" min-width="120px" align="center" />
                  <el-table-column label="Gene position" min-width="120px" align="center">
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
                  <div id="chart_eqtl" ref="chart_eqtl" style="width: 750px; height: 300px;"></div>
                </div>
              </el-tab-pane>
            </el-tabs>
          </div>
        </el-collapse-item>
        <el-collapse-item id="menu_smr_pQTL" title="Causal protien" name="6">
          <div style="width:98%;margin:0 auto;margin-top: 20px;">
            <el-tabs v-model="active_tabs_smr_pQTL">
              <el-tab-pane label="Table" name="first">
                <el-row :gutter="0">
                  <el-col :span="20">
                    <el-pagination
                      center
                      background
                      layout="prev, pager, next, total, jumper"
                      :page-size="pagesize_smr_pQTL"
                      :total="smr_pQTL.length"
                      :current-page="currpage_smr_pQTL"
                      @current-change="handleCurrentChange_smr_pQTL"
                      @size-change="handleSizeChange_smr_pQTL"
                    >
                    </el-pagination>
                  </el-col>
                  <el-col :span="4" style="display: flex; justify-content: flex-end; align-items: center;">
                    <el-button @click="download_smr_pqtl" type="primary" plain style="width: 100px;">Download</el-button>
                  </el-col>
                </el-row>
                <el-table
                  :data="smr_pQTL.slice((currpage_smr_pQTL - 1) * pagesize_smr_pQTL, currpage_smr_pQTL * pagesize_smr_pQTL)"
                  border
                  style="margin: 10px 0; text-align: center; width: 100%; max-width: 2000px"
                  :header-cell-style="{ background: '#ecf5ff', color: '#337ecc' }"
                  v-loading="loading"
                  @sort-change="handleSort_smr_pQTL"
                  :row-class-name="rowClassName"
                >
                  <el-table-column prop="Gene" label="Gene" min-width="120px" align="center" />
                  <el-table-column label="Gene position" min-width="120px" align="center">
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

                  <!-- b_pQTL  se_pQTL p_pQTL -->
                  <el-table-column prop="b_eQTL" label="pQTL_beta" min-width="120px" align="center" sortable="custom"/>
                  <el-table-column prop="se_eQTL" label="pQTL_SE" min-width="120px" align="center" sortable="custom"/>
                  <el-table-column prop="p_eQTL" label="pQTL_P" min-width="120px" align="center" sortable="custom"/>

                  <!-- b_GWAS  se_GWAS p_GWAS -->
                  <el-table-column prop="b_GWAS" label="GWAS_beta" min-width="120px" align="center" sortable="custom"/>
                  <el-table-column prop="se_GWAS" label="GWAS_SE" min-width="120px" align="center" sortable="custom"/>
                  <el-table-column prop="p_GWAS" label="GWAS_P" min-width="120px" align="center" sortable="custom"/>
                  
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
  name: "SearchPleiotropyGene",
  data() {
    return {
      pleioGene: [],
      eQTL: [],
      pQTL: [],
      smr_eQTL: [],
      smr_meQTL_eQTL:[],
      smr_pQTL: [],
      gene: this.$route.query.gene,   
      error: null,                   // 错误信息

      // 表格
      pagesize_pleioGene: 10,
      currpage_pleioGene: 1,
      pagesize_eQTL: 10,
      currpage_eQTL: 1,
      pagesize_pQTL: 10,
      currpage_pQTL: 1,
      pagesize_smr_eQTL: 10,
      currpage_smr_eQTL: 1,
      pagesize_smr_meQTL_eQTL: 10,
      currpage_smr_meQTL_eQTL: 1,
      pagesize_smr_pQTL: 10,
      currpage_smr_pQTL: 1,
      loading: false,
      
      // 当前选中的菜单项
      activeMenu: '1',
      
      // 当前显示的表格
      activeTab: 1,
      activeNames: ['1','2','3','4', '5', '6'],

      //显示表格还是heatmap
      active_tabs_pleioGene:'first',
      active_tabs_smr_eQTL:'first',
      active_tabs_smr_meQTL_eQTL: 'first',
      active_tabs_smr_pQTL: 'first',

      chart_pleioGene: null,
      chart_pleioGene_PP: null,
      chart_smr_meqtl_eqtl: null,
      chart_eqtl: null,
      chart_pqtl: null,

    };
  },

  created() {
    // 获取查询参数并请求数据
    this.fetchData(this.gene);
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
    handleCurrentChange_pleioGene(cpage) {
      this.currpage_pleioGene = cpage;
    },
    handleSizeChange_pleioGene(psize) {
      this.pagesize_pleioGene = psize;
    },
    handleCurrentChange_eQTL(cpage) {
      this.currpage_eQTL = cpage;
    },
    handleSizeChange_eQTL(psize) {
      this.pagesize_eQTL = psize;
    },
    handleCurrentChange_pQTL(cpage) {
      this.currpage_pQTL = cpage;
    },
    handleSizeChange_pQTL(psize) {
      this.pagesize_pQTL = psize;
    },
    handleCurrentChange_smr_meQTL_eQTL(cpage) {
      this.currpage_smr_meQTL_eQTL = cpage;
    },
    handleSizeChange_smr_meQTL_eQTL(psize) {
      this.pagesize_smr_meQTL_eQTL = psize;
    },
    handleCurrentChange_smr_eQTL(cpage) {
      this.currpage_smr_eQTL = cpage;
    },
    handleSizeChange_smr_eQTL(psize) {
      this.pagesize_smr_eQTL = psize;
    },
    handleCurrentChange_smr_pQTL(cpage) {
      this.currpage_smr_pQTL = cpage;
    },
    handleSizeChange_smr_pQTL(psize) {
      this.pagesize_smr_pQTL = psize;
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

    handleSort_pleioGene(column) {
      this.pleioGene = this.handleSort(this.pleioGene, column);
    },
    handleSort_eQTL(column) {
      this.eQTL = this.handleSort(this.eQTL, column);
    },
    handleSort_pQTL(column) {
      this.pQTL = this.handleSort(this.pQTL, column);
    },
    handleSort_smr_meQTL_eQTL(column) {
      this.smr_meQTL_eQTL = this.handleSort(this.smr_meQTL_eQTL, column);
    },
    handleSort_smr_eQTL(column) {
      this.smr_eQTL = this.handleSort(this.smr_eQTL, column);
    },
    handleSort_smr_pQTL(column) {
      this.smr_pQTL = this.handleSort(this.smr_pQTL, column);
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
    
    download_pleioGene() {
      const columnMap = {
        'Cancer 1': 'cancer1',
        'Cancer 2': 'cancer2',
        'Gene': 'SYMBOL',
        'Gene position': (row) => `${row.CHR}:${row.START}-${row.STOP}`,
        "Gene strand": 'X5',

        "Number of SNPs":'NSNPS',
        "PLACO_FDR":"fdr.PLACO",
        "Cancer1_FDR":"fdr.trait1",
        "Cancer2_FDR":"fdr.trait2",
        "PP.H4.abf":"PP.H4.abf",
        "PP.H0.abf":"PP.H0.abf",
        "PP.H1.abf":"PP.H1.abf",
        "PP.H2.abf":"PP.H2.abf",
        "PP.H3.abf":"PP.H3.abf",
        "Candidate SNP":"snp",
        "SNP.PP.H4":"SNP.PP.H4"
      };

      this.downloadTable(this.pleioGene, columnMap, 'Pleiotropic_Gene_FDR0.05.csv');
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
    download_smr_eqtl() {
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

      this.downloadTable(this.smr_eQTL, columnMap, 'SMR_eQTL_FDR0.05.csv');
    },
    download_smr_pqtl() {
      const columnMap = {
        Protein: 'Gene',
        'Protein position': (row) => `${row.ProbeChr}:${row.Probe_bp}`,
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
        pQTL_beta: 'b_eQTL',
        pQTL_SE: 'se_eQTL',
        pQTL_P: 'p_eQTL',
        GWAS_beta: 'b_GWAS',
        GWAS_SE: 'se_GWAS',
        GWAS_P: 'p_GWAS'
        
      };

      this.downloadTable(this.smr_pQTL, columnMap, 'SMR_pQTL_FDR0.05.csv');
    },

    fetchData() {
      if (!this.gene) return;  // 如果没有提供snp参数，直接返回

      this.loading = true;
      this.error = null;

      axios.get("/api/cancerdb/pleio_gene",{params: { searchGene: this.gene },})
        .then((res) => {
          this.pleioGene = res.data.pleioGene;
          this.eQTL = res.data.eQTL;
          this.pQTL = res.data.pQTL;
          this.smr_meQTL_eQTL = res.data.smr_meQTL_eQTL;
          this.smr_eQTL = res.data.smr_eQTL;
          this.smr_pQTL = res.data.smr_pQTL;
          this.loading = false; 
          const areAllListsEmpty = [this.pleioGene, this.eQTL, this.smr_meQTL_eQTL, this.smr_eQTL, this.smr_pQTL].every(list => Array.isArray(list) && list.length === 0);
          if (areAllListsEmpty) {
            // 如果后端返回的数据长度为0，则弹出窗口提示用户
            this.$alert("Sorry, this gene is not a pleiotropic or causal gene related to any cancers in our results.", "No results", {
              confirmButtonText: "OK",
            });
          } else {
            if(this.pleioGene.length > 0) {
              this.plot_pleioGene(this.pleioGene);
            };
            if(this.smr_meQTL_eQTL.length > 0) {
              this.plot_smr_meqlt_eqtl(this.smr_meQTL_eQTL);
            };
            if(this.smr_eQTL.length > 0) {
              this.plot_smr_eqtl(this.smr_eQTL);
            };
            if(this.smr_pQTL.length > 0) {
              this.plot_smr_pqtl(this.smr_pQTL);
            }
          };
        })
        .catch((err) => {console.log(err)})
    },

    plot_pleioGene(data) {
      // 获取所有cancer1和cancer2的唯一值
      const cancer1List = [...new Set(data.map(item => item.cancer1))];
      const cancer2List = [...new Set(data.map(item => item.cancer2))];

      // 创建数据矩阵
      const createMatrix = (key) => {
        return cancer1List.map(cancer1 => {
          return cancer2List.map(cancer2 => {
            const item = data.find(d => d.cancer1 === cancer1 && d.cancer2 === cancer2);
            return item ? item[key] : null;
          });
        });
      };

      const matrix = createMatrix('log10FDR');
      const matrix_PP = createMatrix('PP.H4.abf');

      // 初始化图表
      const initChart = (ref) => markRaw(echarts.init(ref, null, { renderer: 'svg' }));

      this.chart_pleioGene = initChart(this.$refs.chart_pleioGene);
      this.chart_pleioGene_PP = initChart(this.$refs.chart_pleioGene_PP);

      // 创建通用配置
      const createOption = (title, tooltipFormatter, visualMapMax, seriesData) => ({
        title: {
          text: title,
          left: 'center',
          top: 0,
          textStyle: { fontSize: 14, fontWeight: 'bold' }
        },
        textStyle: { fontSize: 12 },
        tooltip: {
          position: 'bottom',
          formatter: tooltipFormatter
        },
        grid: { left: 200, height: '50%' },
        xAxis: {
          type: 'category',
          data: cancer1List,
          name: 'Cancer1',
          nameGap: 5,
          axisLabel: { rotate: 45, interval: 0 }
        },
        yAxis: {
          type: 'category',
          data: cancer2List,
          name: 'Cancer2',
          nameGap: 5,
          axisLabel: { interval: 0 }
        },
        visualMap: {
          min: 0,
          max: visualMapMax,
          calculable: true,
          orient: 'vertical',
          left: '680',
          top: '0',
          inRange: {
            color: ['#FFFFFF', "rgb(191,68,76)"]
          }
        },
        series: [{
          name: title,
          type: 'heatmap',
          data: seriesData,
          label: { show: false },
          itemStyle: { normal: { borderColor: '#fff', borderWidth: 1 } }
        }]
      });

      // 创建tooltip格式化函数
      const tooltipFormatterFDR = (params) => 
        `<b>Cancer1:</b> ${cancer1List[params.data[0]]}<br/>
        <b>Cancer2:</b> ${cancer2List[params.data[1]]}<br/>
        <b>-log10FDR:</b> ${params.data[2]}<br/>`;

      const tooltipFormatterPP = (params) => 
        `<b>Cancer1:</b> ${cancer1List[params.data[0]]}<br/>
        <b>Cancer2:</b> ${cancer2List[params.data[1]]}<br/>
        <b>PP.H4.abf:</b> ${params.data[2]}<br/>`;

      // 填充数据
      const createSeriesData = (matrix) => 
        matrix.flatMap((row, i) => row.map((value, j) => [i, j, value]));

      const seriesData = createSeriesData(matrix);
      const seriesData_PP = createSeriesData(matrix_PP);

      // 设置图表选项
      const option = createOption(
        "P value based on pleiotropy analysis",
        tooltipFormatterFDR,
        Math.max(...data.map(d => d.log10FDR)),
        seriesData
      );

      const option_PP = createOption(
        "PP.H4.abf based on colocalization analysis",
        tooltipFormatterPP,
        Math.max(...data.map(d => d["PP.H4.abf"])),
        seriesData_PP
      );

      // 应用选项
      this.chart_pleioGene.setOption(option);
      this.chart_pleioGene_PP.setOption(option_PP);

      // 连接图表
      // echarts.connect([this.chart_pleioGene, this.chart_pleioGene_PP]); // visual map也被联动了
    },
    plot_smr_meqlt_eqtl(data) {
      this.chart_meqtl_eqtl = markRaw(echarts.init(this.$refs.chart_meqtl_eqtl, null, { renderer: 'svg' }));

      // 提取热图数据
      data.sort((a, b) => a.b_SMR - b.b_SMR);
      const values = data.map(item => item.b_SMR);  // 热图值
      const expoIds = data.map(item => item.Expo_ID);  // 横轴数据
      const symbol = data[0].symbol;  // 纵轴只有一个symbol

      // 将数据转换为热图需要的二维数组格式
      const heatmapData = expoIds.map((expoId, index) => {
        return [expoId, 0, values[index]];  // 使用expoId作为横轴，0作为纵轴
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
            return `<b>Methylation:</b> ${data_tooltip.Expo_ID}<br/>
                    <b>Gene:</b> ${symbol}<br/>
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
          data: expoIds,  // 横轴数据
        },
        yAxis: {
          type: 'category',
          data: [symbol],  // 纵轴只有一个symbol
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
    plot_smr_eqtl(data) {
      this.chart_eqtl = markRaw(echarts.init(this.$refs.chart_eqtl, null, { renderer: 'svg' }));

      // 提取热图数据
      data.sort((a, b) => a.b_SMR - b.b_SMR);
      const values = data.map(item => item.b_SMR);  // 热图值
      const cancers = data.map(item => item.cancer);  // 横轴数据
      const symbol = data[0].symbol;  // 纵轴只有一个symbol

      // 将数据转换为热图需要的二维数组格式
      const heatmapData = cancers.map((cancer, index) => {
        return [cancer, 0, values[index]];  
      });

      const maxAbsValue = Math.max(...values.map(v => Math.abs(v)));  // 获取绝对值最大的数

      // 配置项
      const option = {
        title: {
          text: "Causal effect (beta) between gene (exposure) and cancer (outcome) based on SMR analysis",
          left: 'center',
          top: 0,
          textStyle: { fontSize: 14, fontWeight: 'bold' }
        },
        tooltip: {
          position: 'right',
          formatter: function (params) {
            const data_tooltip = data[params.dataIndex];
            return `<b>Gene:</b> ${symbol}<br/>
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
          data: [symbol],  // 纵轴只有一个symbol
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
    plot_smr_pqtl(data) {
      this.chart_pqtl = markRaw(echarts.init(this.$refs.chart_pqtl, null, { renderer: 'svg' }));

      // 提取热图数据
      data.sort((a, b) => a.b_SMR - b.b_SMR);
      const values = data.map(item => item.b_SMR);  // 热图值
      const cancers = data.map(item => item.cancer);  // 横轴数据
      const symbol = data[0].Gene;  // 纵轴只有一个symbol
      console.log(data)

      // 将数据转换为热图需要的二维数组格式
      const heatmapData = cancers.map((cancer, index) => {
        return [cancer, 0, values[index]];  
      });

      const maxAbsValue = Math.max(...values.map(v => Math.abs(v)));  // 获取绝对值最大的数

      // 配置项
      const option = {
        title: {
          text: "Causal effect (beta) between protein (exposure) and cancer (outcome) based on SMR analysis",
          left: 'center',
          top: 0,
          textStyle: { fontSize: 14, fontWeight: 'bold' }
        },
        tooltip: {
          position: 'right',
          formatter: function (params) {
            const data_tooltip = data[params.dataIndex];
            return `<b>Protein:</b> ${symbol}<br/>
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
          data: [symbol],  // 纵轴只有一个symbol
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
      sessionStorage.setItem('pleioGene', JSON.stringify(this.pleioGene));
      sessionStorage.setItem('eQTL', JSON.stringify(this.eQTL));
      sessionStorage.setItem('pQTL', JSON.stringify(this.pQTL));
      sessionStorage.setItem('smr_meQTL_eQTL', JSON.stringify(this.smr_meQTL_eQTL));
      sessionStorage.setItem('smr_pQTL', JSON.stringify(this.smr_pQTL));
      sessionStorage.setItem('smr_eQTL', JSON.stringify(this.smr_eQTL));
      

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
  