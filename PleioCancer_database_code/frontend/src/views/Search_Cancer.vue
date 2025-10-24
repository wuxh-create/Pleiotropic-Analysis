<template>
  <div style="margin: 10px 0"></div>
  <div class="container">
    <div class="container-menu" >
      <el-menu :default-active="activeMenu">
        <el-menu-item index="1" @click="scrollTo('menu_pleioSNP')">Pleiotropic SNP</el-menu-item>
        <el-menu-item index="2" @click="scrollTo('menu_pleioGene')">Pleiotropic gene</el-menu-item>
        <el-menu-item index="3" @click="scrollTo('menu_smr_meQTL')">Causal methylation</el-menu-item>
        <el-menu-item index="4" @click="scrollTo('menu_smr_eQTL')">Causal gene</el-menu-item>
        <el-menu-item index="5" @click="scrollTo('menu_smr_pQTL')">Causal protein</el-menu-item>
        <!-- <el-button type="primary" style="margin-left:20px;margin-top: 50px;" @click="plotNetwork">
          Plot network
        </el-button> -->
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
                  
                  <el-table-column prop="snpid" label="SNP" min-width="120px" align="center">
                    <template v-slot="scope">
                      <a :href="'http://localhost:8081/cancerdb/search_pleio_snp?snp=' + scope.row.snpid" target="_blank" class="link-snpid">
                        {{ scope.row.snpid }}
                      </a>
                    </template>
                  </el-table-column>
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
        <el-collapse-item id="menu_pleioGene" title="Pleiotropic Gene" name="2">
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
                  
                  <el-table-column prop="SYMBOL" label="Gene" min-width="120px" align="center">
                    <template v-slot="scope">
                      <a :href="'http://localhost:8081/cancerdb/search_gene?gene=' + scope.row.SYMBOL" target="_blank" class="link-snpid">
                        {{ scope.row.SYMBOL }}
                      </a>
                    </template>
                  </el-table-column>
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
                <div style="width: 100%; height: 750px; margin: 0 auto; display: flex; justify-content: center; align-items: center; ">
                  <div id="chart_pleioGene" ref="chart_pleioGene" style="width: 750px; height: 750px;"></div>
                </div>
              </el-tab-pane>
            </el-tabs>
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
        <el-collapse-item id="menu_smr_eQTL" title="Causal gene" name="4">
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
        <el-collapse-item id="menu_smr_pQTL" title="Causal protein" name="5">
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
  name: "SearchCancer",
  data() {
    return {
      pleioSNP: [],
      pleioGene: [],
      smr_meQTL: [],
      smr_eQTL: [],
      smr_pQTL: [],
      searchCancer: this.$route.query.cancer,   
      error: null,                   // 错误信息

      // 表格
      pagesize_pleioSNP: 10,
      currpage_pleioSNP: 1,
      pagesize_pleioGene: 10,
      currpage_pleioGene: 1,
      pagesize_smr_meQTL: 10,
      currpage_smr_meQTL: 1,
      pagesize_smr_eQTL: 10,
      currpage_smr_eQTL: 1,
      pagesize_smr_pQTL: 10,
      currpage_smr_pQTL: 1,
      loading: false,
      
      // 当前选中的菜单项
      activeMenu: '1',
      
      // 当前显示的表格
      activeTab: 1,
      activeNames: ['1','2','3','4', '5', '6', '7', '8', '9'],

      //显示表格还是heatmap
      active_tabs_pleioSNP:'first',
      active_tabs_pleioGene:'first',
      active_tabs_smr_eQTL:'first',
      active_tabs_smr_meQTL: 'first',
      active_tabs_smr_pQTL: 'first',

      chart_pleioSNP: null,
      chart_pleioGene: null,
      chart_eqtl: null,
      chart_meqtl: null,
      chart_pqtl: null,

    };
  },

  created() {
    // 获取查询参数并请求数据
    this.fetchData(this.searchCancer);
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
    handleCurrentChange_pleioSNP(cpage) {
      this.currpage_pleioSNP= cpage;
    },
    handleSizeChange_pleioSNP(psize) {
      this.pagesize_pleioSNP = psize;
    },
    handleCurrentChange_pleioGene(cpage) {
      this.currpage_pleioGene = cpage;
    },
    handleSizeChange_pleioGene(psize) {
      this.pagesize_pleioGene = psize;
    },
    handleCurrentChange_smr_eQTL(cpage) {
      this.currpage_smr_eQTL = cpage;
    },
    handleSizeChange_smr_eQTL(psize) {
      this.pagesize_smr_eQTL = psize;
    },
    handleCurrentChange_smr_meQTL(cpage) {
      this.currpage_smr_meQTL = cpage;
    },
    handleSizeChange_smr_meQTL(psize) {
      this.pagesize_smr_meQTL = psize;
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
    handleSort_pleioSNP(column) {
      this.pleioSNP = this.handleSort(this.pleioSNP, column);
    },
    handleSort_pleioGene(column) {
      this.pleioGene = this.handleSort(this.pleioGene, column);
    },
    handleSort_smr_meQTL(column) {
      this.smr_meQTL = this.handleSort(this.smr_meQTL, column);
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
      if (!this.searchCancer) return;  // 如果没有提供snp参数，直接返回

      this.loading = true;
      this.error = null;

      axios.get("/api/cancerdb/search_cancer",{params: { searchCancer: this.searchCancer },})
        .then((res) => {
          this.pleioSNP = res.data.pleioSNP;
          this.pleioGene = res.data.pleioGene;
          this.smr_eQTL = res.data.smr_eQTL;
          this.smr_meQTL = res.data.smr_meQTL;
          this.smr_pQTL = res.data.smr_pQTL;
          this.loading = false; 
          const areAllListsEmpty = [this.pleioSNP,this.pleioGene, this.smr_eQTL,this.smr_meQTL, this.smr_pQTL].every(list => Array.isArray(list) && list.length === 0);
          if (areAllListsEmpty) {
            // 如果后端返回的数据长度为0，则弹出窗口提示用户
            this.$alert("Sorry, this gene is not a pleiotropic or causal gene related to any cancers in our results.", "No results", {
              confirmButtonText: "OK",
            });
          } else {
            if(this.pleioSNP.length > 0) {
              this.plot_pleioSNP(this.pleioSNP);
            };
            if(this.pleioGene.length > 0) {
              this.plot_pleioGene(this.pleioGene);
            };
            if(this.smr_eQTL.length > 0) {
              this.plot_smr_eqtl(this.smr_eQTL);
            };
            if(this.smr_meQTL.length > 0) {
              this.plot_smr_meqtl(this.smr_meQTL);
            };
            if(this.smr_pQTL.length > 0) {
              this.plot_smr_pqtl(this.smr_pQTL);
            }
          };
        })
        .catch((err) => {console.log(err)})
    },
    plot_pleioSNP(data) {
      const countMap = {};
      data.forEach(item => {
        const key = `${item.cancer1}-${item.cancer2}`;
        countMap[key] = (countMap[key] || 0) + 1;
      });

      // 转换成 ECharts 需要的格式
      const heatmapData = [];
      Object.keys(countMap).forEach(key => {
        const [cancer1, cancer2] = key.split('-');
        heatmapData.push([cancer1, cancer2, countMap[key]]);
      });
      
      const cancer1Categories = [...new Set(data.map(item => item.cancer1))];
      const cancer2Categories = [...new Set(data.map(item => item.cancer2))];

      // 使用非响应式实例化，否则拖动范围时报错https://blog.csdn.net/weixin_50508597/article/details/123552563
      this.chart_pleioSNP = markRaw(echarts.init(this.$refs.chart_pleioSNP,null, { renderer : 'svg' })); // 渲染为svg，防止放大模糊
      const option = {
        title: {
          text: "Number of pleiotropic SNPs across cancer pairs.",
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
            console.log(params)
            console.log(cancer1Categories)
            return `<b>Cancer1:</b> ${params.data[0]}<br/>
                    <b>Cancer2:</b> ${params.data[1]}<br/>
                    <b>Number of pleiotropic SNPs:</b> ${params.data[2]}<br/>`;
          }
        },
        grid: {
          left:200,
          // top: '20%',
          height: '50%'
        },
        xAxis: {
          type: 'category',
          data: cancer1Categories,
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
          data: cancer2Categories,
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
          max: Math.max(...heatmapData.map(item => item[2])),
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
          data: heatmapData,
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
      this.chart_pleioSNP.setOption(option)
    },
    plot_pleioGene(data) {
      const countMap = {};
      data.forEach(item => {
        const key = `${item.cancer1}-${item.cancer2}`;
        countMap[key] = (countMap[key] || 0) + 1;
      });

      // 转换成 ECharts 需要的格式
      const heatmapData = [];
      Object.keys(countMap).forEach(key => {
        const [cancer1, cancer2] = key.split('-');
        heatmapData.push([cancer1, cancer2, countMap[key]]);
      });
      
      const cancer1Categories = [...new Set(data.map(item => item.cancer1))];
      const cancer2Categories = [...new Set(data.map(item => item.cancer2))];

      // 使用非响应式实例化，否则拖动范围时报错https://blog.csdn.net/weixin_50508597/article/details/123552563
      this.chart_pleioGene = markRaw(echarts.init(this.$refs.chart_pleioGene,null, { renderer : 'svg' })); // 渲染为svg，防止放大模糊
      const option = {
        title: {
          text: "Number of pleiotropic genes across cancer pairs.",
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
            console.log(params)
            console.log(cancer1Categories)
            return `<b>Cancer1:</b> ${params.data[0]}<br/>
                    <b>Cancer2:</b> ${params.data[1]}<br/>
                    <b>Number of pleiotropic genes:</b> ${params.data[2]}<br/>`;
          }
        },
        grid: {
          left:200,
          // top: '20%',
          height: '50%'
        },
        xAxis: {
          type: 'category',
          data: cancer1Categories,
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
          data: cancer2Categories,
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
          max: Math.max(...heatmapData.map(item => item[2])),
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
          data: heatmapData,
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
    
      // 应用选项
      this.chart_pleioGene.setOption(option);
    },
    plot_smr_eqtl(data) {
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
      this.chart_eqtl = markRaw(echarts.init(this.$refs.chart_eqtl,null, { renderer : 'svg' })); // 渲染为svg，防止放大模糊

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
          position: 'right',
          formatter: function (params) {
            return `<b>Gene:</b> ${genes[params.data[0]]}<br/>
                    <b>Cancer:</b> ${cancers[params.data[1]]}<br/>
                    <b>SMR_beta:</b> ${params.data[2]}<br/>`;  // params.data[2] 是heatmap的值
          }
        },
        grid: {
          left: '20%',
          right: '10%',
          bottom: '10%',
          top: '20%',
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
          // nameGap: 5,
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

      this.chart_eqtl.setOption(option);
    },
    plot_smr_meqtl(data) {
      this.chart_meqtl = markRaw(echarts.init(this.$refs.chart_meqtl, null, { renderer: 'svg' }));

      // 获取所有cancer1和cancer2的唯一值
      const methy = [...new Set(data.map(item => item.probeID))];
      const cancers = [...new Set(data.map(item => item.cancer))];

      // 创建数据矩阵
      const matrix = [];
      const dataMap = data.reduce((acc, item) => {
        const key = `${item.probeID}-${item.cancer}`;
        acc[key] = item.b_SMR;
        return acc;
      }, {});
      
      methy.forEach(probeID => {
        const row = [];
        cancers.forEach(cancer => {
          const value = dataMap[`${probeID}-${cancer}`] || null;
          row.push(value);
        });
        matrix.push(row);
      });


      // 使用非响应式实例化，否则拖动范围时报错https://blog.csdn.net/weixin_50508597/article/details/123552563
      const maxValue = Math.max(...matrix.flat());
      const option = {
        title: {
          text: "Causal effect (beta) between methylation (exposure) and cancer (outcome) based on SMR analysis",
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
          position: 'right',
          formatter: function (params) {
            return `<b>Methylation:</b> ${methy[params.data[0]]}<br/>
                    <b>Cancer:</b> ${cancers[params.data[1]]}<br/>
                    <b>SMR_beta:</b> ${params.data[2]}<br/>`;  // params.data[2] 是heatmap的值
          }
        },
        grid: {
          left: '20%',
          right: '10%',
          bottom: '10%',
          top: '20%',
          height: '70%'
        },
        xAxis: {
          type: 'category',
          data: methy,
          name: 'Methylation',
          // nameGap: 5,
          splitArea: {
            show: false, // 不显示网格背景，背景有颜色，会视觉干扰
          }
        },
        yAxis: {
          type: 'category',
          data: cancers,
          name: 'Cancer',
          // nameGap: 5,
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

      this.chart_meqtl.setOption(option);
    },
    plot_smr_pqtl(data) {
      this.chart_pqtl = markRaw(echarts.init(this.$refs.chart_pqtl, null, { renderer: 'svg' }));

      // 获取所有cancer1和cancer2的唯一值
      const proteins = [...new Set(data.map(item => item.probeID))];
      const cancers = [...new Set(data.map(item => item.cancer))];

      // 创建数据矩阵
      const matrix = [];
      const dataMap = data.reduce((acc, item) => {
        const key = `${item.probeID}-${item.cancer}`;
        acc[key] = item.b_SMR;
        return acc;
      }, {});
      
      proteins.forEach(probeID => {
        const row = [];
        cancers.forEach(cancer => {
          const value = dataMap[`${probeID}-${cancer}`] || null;
          row.push(value);
        });
        matrix.push(row);
      });


      // 使用非响应式实例化，否则拖动范围时报错https://blog.csdn.net/weixin_50508597/article/details/123552563
      const maxValue = Math.max(...matrix.flat());
      const option = {
        title: {
          text: "Causal effect (beta) between protein (exposure) and cancer (outcome) based on SMR analysis",
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
            const i = params.data[0];  // 获取热图行
            const j = params.data[1];  // 获取热图列
            const probeID = proteins[i]; // 从行索引找到probeID
            const cancer = cancers[j];   // 从列索引找到cancer

            // 根据i和j获取对应的数据项
            const item = data.find(d => d.probeID === probeID && d.cancer === cancer);

            return `<b>Protein:</b> ${item.Gene}<br/>
                    <b>Cancer:</b> ${cancer}<br/>
                    <b>SMR_beta:</b> ${params.data[2]}<br/>`;  // params.data[2] 是heatmap的值
          }
        },
        grid: {
          left: '20%',
          right: '10%',
          bottom: '10%',
          top: '20%',
          height: '70%'
        },
        xAxis: {
          type: 'category',
          data: proteins,
          name: 'Protein',
          // nameGap: 5,
          axisLabel: {
            formatter: function (index) {
              const cur_gene = data.find(d => d.probeID === index);
              return cur_gene.Gene;
            },
          },
          splitArea: {
            show: false, // 不显示网格背景，背景有颜色，会视觉干扰
          }
        },
        yAxis: {
          type: 'category',
          data: cancers,
          name: 'Cancer',
          // nameGap: 5,
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

      this.chart_pqtl.setOption(option);
    },
    plotNetwork() {
      // 将数据存储到 sessionStorage 或 localStorage
      sessionStorage.setItem('pleioSNP', JSON.stringify(this.pleioSNP));
      sessionStorage.setItem('pleioGene', JSON.stringify(this.pleioGene));
      sessionStorage.setItem('smr_pQTL', JSON.stringify(this.smr_pQTL));
      sessionStorage.setItem('smr_eQTL', JSON.stringify(this.smr_eQTL));
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

:deep(.el-collapse-item__content) {
  background-color: #f5f7fa;
  border: 1px solid #ebeef5;
  padding: 10px;
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
  