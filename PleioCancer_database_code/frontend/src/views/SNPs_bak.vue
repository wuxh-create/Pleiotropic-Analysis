<template>
  
  <div class="bg">
    <div class="bg2">
      <div class="searchSNP">
        <p class="cancerTypeSelect">Cancer type</p>
        <div class="cTypeSelectBox">
          <el-select
            v-model="cancerType"
            multiple
            collapse-tags
            collapse-tags-tooltip
            :max-collapse-tags="3"
            placeholder="Select"
            style="width: 500px"
          >
            <el-option
              v-for="item in options"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </div>
        <div class="rsIDinputBox">
          <el-input v-model="searchSNPs" clearable />
          <span>SNP (rsID or genomic region)</span>
        </div>
        <el-button class="snpSearchButton" type="primary" :icon="Search" @click="queryData"
          >Search</el-button
        >
        <!--分页-->
        <el-pagination
          center
          background
          layout="prev, pager, next, sizes, total, jumper"
          :page-sizes="[10, 20, 50, 100]"
          :page-size="pagesize"
          :total="mySNPs.length"
          @current-change="handleCurrentChange"
          @size-change="handleSizeChange"
        >
        </el-pagination>
      </div>
    </div>
  </div>
  <div class="bg_table_1">
    <div class="bg_table_2">
      <div class="bg_table_3">
        <!-- 添加@sort-change和sortable="custom"，解决排序只排当前页的问题，
          参考：https://blog.csdn.net/zebghfv/article/details/120993629 -->
        <el-table
          class="tableSNP"
          :data="mySNPs.slice((currpage - 1) * pagesize, currpage * pagesize)"
          border
          style="width: 80%; margin: 10px 0; text-align: center"
          :header-cell-style="{ background: '#f0f2f5', color: '#337ecc' }"
          v-loading="loading"
          @sort-change="handleSort"
        >
          <!-- columns在JS中定义，v-for循环，防止每一列都要写一次el-table-column组件，未成功实现 -->
          <el-table-column
            property="trait_pairs"
            label="trait pairs"
            min-width="40%"
            align="center"
          />
          <el-table-column
            prop="snpid"
            align="center"
            min-width="20px"
          >
            <template v-slot:header>
              <span>rsID</span>
              <el-tooltip
                content="我是一个手机号"
                placement="top-start"
                effect="light"
              >
                <el-icon class="icon">
                  <QuestionFilled />
                </el-icon>
              </el-tooltip>
            </template>
          </el-table-column>
          <el-table-column
            property="hg19chr"
            label="chr"
            sortable="custom"
            min-width="20%"
            align="center"
          />
          <el-table-column
            prop="bp"
            align="center"
            label="bp"
            min-width="20%"
            sortable="custom"
          />
          <el-table-column
            property="a1"
            label="a1"
            min-width="20%"
            align="center"
          />
          <el-table-column
            property="a2"
            label="a2"
            min-width="20%"
            align="center"
          />
          <!-- 调用rounding方法，用formatter属性使得数值保留三位小数 -->
          <el-table-column
            property="T"
            label="T"
            sortable="custom"
            min-width="20%"
            align="center"
            
          />
          <el-table-column
            property="P"
            label="P"
            sortable="custom"
            min-width="20%"
            align="center"
          />
        </el-table>
      </div>
    </div>
  </div>
  <div class="bg_bottom_1">
    <div class="bg_bottom_2">
      <el-dialog :visible="true" title="search_tips" class="cc" :append-to-body="true" width="30%">
        <span >no</span>
        <span >error</span>
      </el-dialog>
    </div>
  </div>
</template>

<script>
import { Search } from "@element-plus/icons-vue";
import axios from "axios";
//导入nprogress加载进度条包即样式
import NProgress from 'nprogress'
import 'nprogress/nprogress.css'

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
  name: "SNPs",
  data() {
    return {
      Search,
      // CancerType选项
      options: [
        {
          value: "Bladder",
          label: "Bladder",
        },
        {
          value: "Breast",
          label: "Breast",
        },
        {
          value: "Head and neck",
          label: "Head and neck",
        },
        {
          value: "Kidney",
          label: "Kidney",
        },
        {
          value: "Lung",
          label: "Lung",
        },
        {
          value: "Ovary",
          label: "Ovary",
        },
        {
          value: "Pancreas",
          label: "Pancreas",
        },
        {
          value: "Prostate",
          label: "Prostate",
        },
        {
          value: "Skin melanoma",
          label: "Skin melanoma",
        },
        {
          value: "Endometrium",
          label: "Endometrium",
        },
      ],
      cancerType: "", // 选择的组件
      searchSNPs: "", // 输入的SNP
      // 表格
      pagesize: 10,
      currpage: 1,
      // allSNPs: [],
      mySNPs: [], // 展示的数据
      loading: false,
    };
  },

  mounted() {
    // 数据加载完前，使用loading图标展示
    this.loading = true,
    axios.get("http://127.0.0.1:5000/cancerdb/pleio_snp").then((response) => {
      // this.allSNPs = response.data;
      this.mySNPs = response.data;
      this.loading = false;
    });
  },

  methods: {
    handleCurrentChange(cpage) {
      this.currpage = cpage;
    },
    handleSizeChange(psize) {
      this.pagesize = psize;
    },
    // 自定义排序方法
    handleSort(column) {
      if (column.order === "descending") {
        this.mySNPs.sort((a, b) => b[column.prop] - (a[column.prop]))
      } else if (column.order === "ascending") {
        this.mySNPs.sort((a, b) => a[column.prop] - (b[column.prop]))
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
    queryData() {
      // 如果检索条件为空，则直接返回所有SNP
      // 检索条件返回后端进行查询
      this.loading = true
      axios.post("http://127.0.0.1:5000/cancerdb/pleio_snp",{cancerType:this.cancerType,searchSNPs:this.searchSNPs})
        .then((res) => {
          // https://cloud.tencent.com/developer/section/1489894
          if (res.data.length === 0) {
            // 如果后端返回的数据长度为0，则弹出窗口提示用户
            this.$alert("Sorry, the input content is not existed or not significant in our results.", "No results", {
              confirmButtonText: "OK",
              // callback: action => {
              //   this.$message({
              //     type: 'info',
              //     message: `action: ${ action }`
              //   });
              // }
            });
          } else if (res.data === "errorID") {
            // 如果后端返回的数据为"errorID"，则弹出窗口提示用户
            this.$alert("Invalid SNP search!", "Error", {
              confirmButtonText: "OK",
            });
          } else {
            // 如果后端返回的数据正常，则更新展示的数据
            this.mySNPs = res.data;
          }
          this.loading = false;
          
        })
        .catch((err) => {console.log(err)})

      // this.test = res.data
      //       axios.post("http://127.0.0.1:5000/test",{cancerType: this.test.length})
    },
  }
}
</script>

<style lang="less">
.el-select__wrapper {
  height: 40px;
}
</style>

<style lang="scss" scoped>
:deep(.el-select__tags-text) {
  color: black;
}
.icon {
  padding: 5px;
}
.bg {
  background-color: #ecf5ff;
}
.bg2 {
  background-color: #fff;
  width: 1700px;
  height: 180px;
  margin: 0 auto;
  display: flex;
}
.bg_table_3 {
  position: relative;
  /* top: 20px; */
  margin: 0 auto;
  display: flex;
  // border: 1px solid #337ecc;
  border: 1px solid  #e9e9eb;
  width: 1600px;
  /* height: 160px; */
  border-radius: 5px;
  border-top-left-radius: 0px;
  border-top-right-radius: 0px;
  border-top: #fff;
  background-color: #fff;
  justify-content: center;
}
.searchSNP {
  position: relative;
  // top: 20px;
  margin: 0 auto;
  display: flex;
  // border: 1px solid #337ecc;
  border: 1px solid  #e9e9eb;
  width: 1600px;
  height: 160px;
  border-radius: 5px;
  border-bottom-left-radius: 0px;
  border-bottom-right-radius: 0px;
  border-bottom: #fff;
  background-color: #fff;
  justify-content: center;
}
.cancerTypeSelect {
  position: absolute;
  top: -10px;
  left: 200px;
  font-size: 20px;
  font-weight: bold;
  color: #337ecc;
}
.cTypeSelectBox {
  position: absolute;
  top: 50px;
  left: 200px;
}
.rsIDinputBox {
  position: absolute;
  top: 50px;
  left: 730px;
  width: 500px;
}
.el-input {
  width: 100%;
  height: 40px;
}
.el-input :deep(.el-input__inner) {
  font-size: 16px;
  color: black;
}
.rsIDinputBox span {
  position: absolute;
  top: -40px;
  left: 0;
  pointer-events: none;
  color: #337ecc;
  font-size: 20px;
  font-weight: bold;
}
/* 输入框添加动画效果 */
.rsIDinputBox input:focus {
  border: 1px solid #409eff;
}
/* // .rsIDinputBox input:valid ~ span,
// .rsIDinputBox input:focus ~ span {
//   color: #337ecc;
//   font-weight: bold;
//   transform: translateX(-10px) translateY(-40px);
//   font-size: 20px;
// } */
.snpSearchButton {
  height: 40px;
  position: absolute;
  top: 50px;
  left: 1280px;
  font-size: 20px;
  font-weight: bold;
  background-color: #337ecc;
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
.el-table {
  position: relative;
  top: 0px;
}
.el-pagination {
  justify-content: center;
  position: absolute;
  top: 100px;
}
.bg_bottom_1 {
  background-color: #ecf5ff;
}
.bg_bottom_2 {
  background-color: #fff;
  width: 1700px;
  margin: 0 auto;
  display: flex;
  height: 20px;
}
.example-showcase .el-loading-mask {
  z-index: 9;
}
.cc {
  position: absolute;
  top:50%;
  z-index:20
}
</style>
