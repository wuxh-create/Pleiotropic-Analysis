<template>
  <div class="notfound">
    <span class="title">404<br /></span>
    <span class="sub_title">Page Not Found</span>
    <div class="button_f">
      <el-button class="button" @click="jump"> Go Home </el-button>
    </div>
  </div>
</template>

<script>
export default {
  name: "NotFound",
  components: {},
  methods: {
    jump() {
      this.$router.push("/cancerdb");
    },
  },
};
</script>

<style scoped>
.notfound {
  width: 100%;
  height: 100%;
  min-height: 800px;
  background-color: #409eff;
  background-size: 100% 100%;
  text-align: center;
  justify-content: center;
}
.title {
  font-family: Verdana, Geneva, Tahoma, sans-serif;
  font-weight: bold;
  position: relative;
  font-size: 200px;
  top: 35%;
  color: #fff;
}
.sub_title {
  font-family: cursive;
  font-weight: bold;
  font-size: 50px;
  position: relative;
  top: 35%;
  color: #244e79;
}
.button_f {
  position: relative;
  top: 40%;
}
.button {
  width: 150px;
  height: 50px;
  font-weight: bold;
  font-size: 25px;
  color: #409eff;
}
</style>
