<template>
  <div>
    <!-- 按钮 -->
    <button @click="toggleFullscreen" class="btn-fullscreen">
      全屏展示
    </button>

    <!-- 图表容器 -->
    <div
      id="chart_heatmap"
      ref="chart_heatmap"
      :style="chartStyle"
      style="transition: all 0.3s ease-in-out;"
    ></div>
  </div>
</template>

<script>
import * as echarts from 'echarts';

export default {
  data() {
    return {
      isFullscreen: false, // 控制是否全屏
      chartInstance: null, // 保存图表实例
    };
  },
  computed: {
    // 根据是否全屏来动态设置样式
    chartStyle() {
      return this.isFullscreen
        ? {
            position: 'fixed',
            top: '0',
            left: '0',
            width: '100vw',  // 全屏时宽度为100vw
            height: '100vh',  // 全屏时高度为100vh
            zIndex: '9999',
            backgroundColor: '#fff',
          }
        : {
            width: '80%',    // 非全屏时宽度为80%
            height: '400px',
            margin: '0 auto',
          };
    },
  },
  mounted() {
    // 初始化图表
    this.chartInstance = echarts.init(this.$refs.chart_heatmap);
    this.updateChart();
    
    // 监听窗口大小变化，确保全屏时调整图表大小
    window.addEventListener('resize', this.onResize);
  },
  beforeUnmount() {
    // 移除事件监听，避免内存泄漏
    window.removeEventListener('resize', this.onResize);
  },
  methods: {
    toggleFullscreen() {
      this.isFullscreen = !this.isFullscreen;
      // 切换到全屏后重新调整图表大小
      this.$nextTick(() => {
        this.chartInstance.resize();
      });
    },
    onResize() {
      // 当窗口大小发生变化时，调整图表大小
      this.$nextTick(() => {
        this.chartInstance.resize();
      });
    },
    updateChart() {
      const option = {
        title: {
          text: 'Heatmap Example',
        },
        xAxis: {},
        yAxis: {},
        series: [
          {
            symbolSize: 20,
            data: [
              [10.0, 8.04],
              [8.07, 6.95],
              [13.0, 7.58],
              [9.05, 8.81],
              [11.0, 8.33],
              [14.0, 7.66],
              [13.4, 6.81],
              [10.0, 6.33],
              [14.0, 8.96],
              [12.5, 6.82],
              [9.15, 7.2],
              [11.5, 7.2],
              [3.03, 4.23],
              [12.2, 7.83],
              [2.02, 4.47],
              [1.05, 3.33],
              [4.05, 4.96],
              [6.03, 7.24],
              [12.0, 6.26],
              [12.0, 8.84],
              [7.08, 5.82],
              [5.02, 5.68]
            ],
            type: 'scatter'
          }
        ]
      };
      this.chartInstance.setOption(option);
    },
  },
};
</script>

<style scoped>
.btn-fullscreen {
  padding: 10px 20px;
  font-size: 16px;
  background-color: #4caf50;
  color: white;
  border: none;
  cursor: pointer;
  border-radius: 5px;
  margin-bottom: 10px;
  transition: background-color 0.3s ease;
}

.btn-fullscreen:hover {
  background-color: #45a049;
}
</style>
