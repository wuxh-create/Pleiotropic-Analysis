//https://blog.csdn.net/weixin_49668076/article/details/136014275
const { defineConfig } = require("@vue/cli-service");

module.exports = defineConfig({
  transpileDependencies: true,
  devServer: {
    proxy: {
      "/api": {
        target: "http://127.0.0.1:5000",  // 后端地址
        changeOrigin: true,               // 改变请求头中的 Origin 字段
        pathRewrite: {
          "^/api": "",                    // 去掉 /api 前缀
        },
      },
    },
  },
});




// module.exports = {
//   devServer: {
//     hot: true, //自动保存
//     open: true, //自动启动
//     port: 8080, //默认端口号
//     host: "0.0.0.0",
//   },
// };
