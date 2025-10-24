<!-- 数据库顶部图片，数据库名，菜单栏 -->
<template>
  <div class="home" style="display: flex; justify-content: space-between; box-sizing: border-box;">
    <div class="dbName">
      <img :src="home_background" class="home_background" />
      <span class="title" style="padding-left: 20px;color: white">PleioCancer</span>
    </div>
    <el-menu
      :default-active="$route.path"
      router="true"
      class="el-menu-demo"
      mode="horizontal"
      background-color="#337ECC"
      text-color="#fff"
      active-text-color="#ffd04b"
      collapse-transition
      @select="handleSelect"
    >
      
      <el-menu-item index="/cancerdb">Home</el-menu-item>
      <el-sub-menu index="/cancerdb/pleio">
        <template #title>Pleiotropic sites</template>
        <el-menu-item index="/cancerdb/pleio/snp">
          SNP
        </el-menu-item>
        <!-- <el-menu-item index="/cancerdb/pleio/loci">
          Loci
        </el-menu-item> -->
        <el-menu-item index="/cancerdb/pleio/gene">
          Gene
        </el-menu-item>
      </el-sub-menu>
      <el-sub-menu index="/cancerdb/causal">
        <template #title>Causal sites</template>
        <el-menu-item index="/cancerdb/causal/methy">Methylation</el-menu-item>
        <el-menu-item index="/cancerdb/causal/gene">Gene</el-menu-item>
        <el-menu-item index="/cancerdb/causal/protein">Protein</el-menu-item>
      </el-sub-menu>

      <el-menu-item index="/cancerdb/network">Network graph</el-menu-item>

      <!-- <el-menu-item index="/cancerdb/download">Download</el-menu-item> -->
      <el-menu-item index="/cancerdb/help">Help</el-menu-item>
      <!-- <el-menu-item index="/cancerdb/concact">Contact</el-menu-item> -->

    </el-menu>
  </div>
</template>

<script>
import { Edit } from "@element-plus/icons-vue";
export default {
  name: "Db_base",
  components: {},
  data() {
    return {
      Edit,
      home_background: require('@/assets/logo.png'),
    };
  },
};
</script>

<style type="text/css" scoped>
/* .home {
  background-color: #ecf5ff;
} */
.dbName {
  display: flex; 
  align-items: center; 
  justify-content: space-between;
  margin: 0 auto;
  height: 69px;
  background-color: #337ecc;
  width:300px;
  padding-left:75px;
  /* border-bottom: 1px solid white; */
  /* box-sizing: border-box */
}
.home_background {
  height: 50px;
  width: 50px;
}
.title {
  font-family: "Times New Roman", Times, serif;
  font-weight: bold;
  font-size: 40px;
}
.el-menu {
  /* width: 1700px; */
  height: 70px;
  margin: 0 auto;
  display: flex;
  align-items: center;
  justify-content: center;
  /* position: fixed; */
  width: 100%;
  background-color: #337ecc;

}
.el-menu-demo {
  display: flex;
  align-items: center;
  justify-content: center;
}
.el-menu-demo :deep(.el-menu-item) {
  font-size: 18px;
  font-weight: bold;
  /* margin-left: +5px; */
  /* margin-right: +20px; */
  /* background-color:  rgb(197.7, 225.9, 255)!important; */
  /* #337ecc */
}
/* 设置悬浮颜色 */
.el-menu-item:hover {
  background-color: #2965a3 !important;
}
.el-menu-demo :deep(.el-sub-menu__title) {
  font-size: 20px;
  font-weight: bold;
  /* margin-left: +5px; */
  /* margin-right: +20px; */
}
</style>
