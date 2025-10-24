<template>
  <div style="width: 1630px;margin: 0 auto; margin-top: +10px;background-color: #337ecc;padding: 10px;border-top-left-radius: 4px;border-top-right-radius: 4px;">
    <span style="font-size: 18px; font-weight: bold; color: white;">1. Pleiotropic sites</span>
  </div>
  <div style="width: 1650px; margin: 0 auto; border-bottom-left-radius: 4px; border-bottom-right-radius: 4px; border: 1px solid #e9e9eb; display: flex; justify-content: flex-start; flex-wrap: wrap; align-items: flex-start;">
    <el-tabs v-model="activeTabsPleio" style="padding-left: 40px;padding-right: 40px;">
      <el-tab-pane label="SNP" name="pleiotropicsnp" >
        <a
          v-for="(cancer, index) in cancerList.slice(0, 37)"
          :key="index"
          :href="'http://127.0.0.1:5000/cancerdb/download/sig_BRCA-UCEC'"
          target="_blank"
        >
          <el-button
            plain
            type="primary"
            style="width: 200px; margin: 10px; height: 50px; word-wrap: break-word; white-space: normal;"
          >
            {{ cancer }}
          </el-button>
        </a>
      </el-tab-pane>
      <el-tab-pane label="Gene" name="causalgene" >
        <a
          v-for="(cancer, index) in cancerList.slice(0, 37)"
          :key="index"
          :href="'http://127.0.0.1:5000/cancerdb/download/sig_BRCA-UCEC'"
          target="_blank"
        >
          <el-button
            plain
            type="primary"
            style="width: 200px; margin: 10px; height: 50px; word-wrap: break-word; white-space: normal;"
          >
            {{ cancer }}
          </el-button>
        </a>
      </el-tab-pane>
      <el-tab-pane label="Protein" name="causalprotein" >
        <a
          v-for="(cancer, index) in cancerList.slice(0, 37)"
          :key="index"
          :href="'http://127.0.0.1:5000/cancerdb/download/sig_BRCA-UCEC'"
          target="_blank"
        >
          <el-button
            plain
            type="primary"
            style="width: 200px; margin: 10px; height: 50px; word-wrap: break-word; white-space: normal;"
          >
            {{ cancer }}
          </el-button>
        </a>
      </el-tab-pane>
    </el-tabs>
  </div>
  <div style="width: 1630px;margin: 0 auto; margin-top: +10px;background-color: #337ecc;padding: 10px;border-top-left-radius: 4px;border-top-right-radius: 4px;">
    <span style="font-size: 18px; font-weight: bold; color: white;">2. Causal sites</span>
  </div>
  <div style="width: 1650px; margin: 0 auto; border-bottom-left-radius: 4px; border-bottom-right-radius: 4px; border: 1px solid #e9e9eb; display: flex; justify-content: flex-start; flex-wrap: wrap; align-items: flex-start;">
    <el-tabs v-model="activeTabsCausal" style="padding-left: 40px;padding-right: 40px;">
      <el-tab-pane label="Methylation" name="causalmethy" >
        <a
          v-for="(cancer, index) in cancerList.slice(0, 37)"
          :key="index"
          :href="'http://127.0.0.1:5000/cancerdb/download/sig_BRCA-UCEC'"
          target="_blank"
        >
          <el-button
            plain
            type="primary"
            style="width: 200px; margin: 10px; height: 50px; word-wrap: break-word; white-space: normal;"
          >
            {{ cancer }}
          </el-button>
        </a>
      </el-tab-pane>
      <el-tab-pane label="Gene" name="causalgene" >
        <a
          v-for="(cancer, index) in cancerList.slice(0, 37)"
          :key="index"
          :href="'http://127.0.0.1:5000/cancerdb/download/sig_BRCA-UCEC'"
          target="_blank"
        >
          <el-button
            plain
            type="primary"
            style="width: 200px; margin: 10px; height: 50px; word-wrap: break-word; white-space: normal;"
          >
            {{ cancer }}
          </el-button>
        </a>
      </el-tab-pane>
      <el-tab-pane label="Protein" name="causalprotein" >
        <a
          v-for="(cancer, index) in cancerList.slice(0, 37)"
          :key="index"
          :href="'http://127.0.0.1:5000/cancerdb/download/sig_BRCA-UCEC'"
          target="_blank"
        >
          <el-button
            plain
            type="primary"
            style="width: 200px; margin: 10px; height: 50px; word-wrap: break-word; white-space: normal;"
          >
            {{ cancer }}
          </el-button>
        </a>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script scoped>
export default {
  name: "MyDownload",
  methods: {},
  data() {
    return {
      activeTabsCausal: "causalmethy",
      activeTabsPleio: "pleiotropicsnp",
      cancerList: ["Acute myeloid leukaemia", "Basal cell carcinoma", "Bladder cancer", "Brain glioblastoma and astrocytoma",
                  "Brain meningioma", "Breast cancer", "Cervical cancer", "Chronic myeloid leukaemia", "Colorectal cancer", "Diffuse large B-cell lymphoma",
                  "Endometrial cancer", "Esophageal cancer", "Gastrointestinal stromal tumor and sarcoma", "Head and neck cancer", "Hepatocellular carcinoma",                                               
                  "Hodgkins lymphoma", "Kidney cancer, except renal pelvis", "Lung cancer", "Lymphocytic leukemia", 
                  "Malignant neoplasm of bone and articular cartilage", "Malignant neoplasm of eye and adnexa",
                  "Malignant neoplasm of intrahepatic ducts, biliary tract and gallbladder", "Mantle cell lymphoma", "Marginal zone B-cell lymphoma",
                  "Mesothelioma", "Multiple myeloma", "Myelodysplastic syndrome", "Ovarian cancer", "Pancreatic cancer", "Prostate cancer", "Skin melanoma",
                  "Small intestine cancer", "Squamous cell carcinoma", "Stomach cancer", "Testicular cancer", "Thyroid cancer", "Vulvar cancer"]
    }
  },
};
</script>
<style>

</style>
