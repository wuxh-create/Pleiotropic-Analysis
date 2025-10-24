// 路由配置

import { createRouter, createWebHistory } from "vue-router";
import Home from "../views/Home.vue";
import NotFound from "../views/404.vue";
import PleioSNP from "../views/PleioSNP.vue";
// import FumaLoci from "../views/FumaLoci.vue";
import PleioGene from "../views/PleioGene.vue";
import TmpVue from "../views/TmpVue.vue";
import GoodT from "../views/GoodT.vue";
import MyDownload from "../views/MyDownload.vue";
import NetworkGraph from "../views/NetworkGraph.vue";
import SMR_eQTL from "../views/SMR_eQTL.vue"
import SMR_meQTL from "@/views/SMR_meQTL.vue";
import SMR_pQTL from "@/views/SMR_pQTL.vue";
import SearchPleiotropySNP from "@/views/Search_SNP.vue"
import SearchPleiotropyGene from "@/views/Search_Gene.vue"
import SearchCausalMethy from "@/views/Search_Methy.vue"
import SearchRegion from "@/views/Search_Region.vue"
import SearchCancer from "@/views/Search_Cancer.vue"
import DocuMentation from "@/views/DocuMentation.vue"

const routes = [
  {
    path: "/cancerdb",
    name: "cancerdb",
    // route level code-splitting
    // this generates a separate chunk (about.[hash].js) for this route
    // which is lazy-loaded when the route is visited.
    component: Home,
    meta: {
      showfather: true,
    },

    // path: '/cancerdb/c2c/snps',
    // name: 'SNPs',
    // // route level code-splitting
    // // this generates a separate chunk (about.[hash].js) for this route
    // // which is lazy-loaded when the route is visited.
    // component: SNPs,

    children: [
      {
        path: "/cancerdb/home",
        redirect: "/cancerdb",
        name: "Home",
        component: Home,
        meta: {
          title: "Home",
          showfather: true,
        },
      },
      {
        path: "/cancerdb/pleio/snp",
        name: "PleioSNP",
        component: PleioSNP,
        meta: {
          title: "PleioSNP",
          showfather: false,
        },
      },
      // {
      //   path: "/cancerdb/pleio/loci",
      //   name: "FumaLoci",
      //   component: FumaLoci,
      //   meta: {
      //     title: "FumaLoci",
      //     showfather: false,
      //   },
      // },
      {
        path: "/cancerdb/pleio/gene",
        name: "PleioGene",
        component: PleioGene,
        meta: {
          title: "PleioGene",
          showfather: false,
        },
      },
      {
        path: "/cancerdb/causal/methy",
        name: "SMR_meQTL",
        component: SMR_meQTL,
        meta: {
          title: "SMR_meQTL",
          showfather: false,
        },
      },
      {
        path: "/cancerdb/causal/gene",
        name: "SMR_eQTL",
        component: SMR_eQTL,
        meta: {
          title: "SMR_eQTL",
          showfather: false,
        },
      },
      {
        path: "/cancerdb/causal/protein",
        name: "SMR_pQTL",
        component: SMR_pQTL,
        meta: {
          title: "SMR_pQTL",
          showfather: false,
        },
      },
      {
        path: "/cancerdb/network",
        name: "NetworkGraph",
        component: NetworkGraph,
        meta: {
          title: "NetworkGraph",
          showfather: false,
        }
      },
      
      {
        path: "/cancerdb/download",
        name: "MyDownload",
        component: MyDownload,
        meta: {
          title: "MyDownload",
          showfather: false,
        },
      },
      {
        path: "/cancerdb/help",
        name: "DocuMentation",
        component: DocuMentation,
        meta: {
          title: "DocuMentation",
          showfather: false,
        },
      },
      {
        path: '/cancerdb/search_pleio_snp',
        name: 'SearchPleiotropySNP',
        component: SearchPleiotropySNP,  // 该路由对应的组件
        props: route => ({ snp: route.query.snp }),  // 将查询参数传递给组件
        meta: {
          title: "SearchPleiotropySNP",
          showfather: false,
        },
      },
      {
        path: '/cancerdb/search_gene',
        name: 'SearchPleiotropyGene',
        component: SearchPleiotropyGene,  // 该路由对应的组件
        props: route => ({ gene: route.query.gene }),  // 将查询参数传递给组件
        meta: {
          title: "SearchPleiotropyGene",
          showfather: false,
        },
      },
      {
        path: '/cancerdb/search_methy',
        name: 'SearchCausalMethy',
        component: SearchCausalMethy,  // 该路由对应的组件
        props: route => ({ methy: route.query.methy }),  // 将查询参数传递给组件
        meta: {
          title: "SearchCausalMethy",
          showfather: false,
        },
      },
      {
        path: '/cancerdb/search_region',
        name: 'SearchRegion',
        component: SearchRegion,  // 该路由对应的组件
        props: route => ({ region: route.query.region }),  // 将查询参数传递给组件
        meta: {
          title: "SearchRegion",
          showfather: false,
        },
      },
      {
        path: '/cancerdb/search_cancer',
        name: 'SearchCancer',
        component: SearchCancer,  // 该路由对应的组件
        props: route => ({ cancer: route.query.cancer }),  // 将查询参数传递给组件
        meta: {
          title: "SearchCancer",
          showfather: false,
        },
      },
      // {
      //   path: '/cancerdb/c2c/genes',
      //   name:"Genes",
      //   component:Genes,
      //   meta:{
      //     title:'Genes',
      //   }
      // },
      // {
      //   path: '/cancerdb/m2c/meQTL',
      //   name:"MeQTL",
      //   component:MeQTL,
      //   meta:{
      //     title:'meQTL',
      //   }
      // },
      // {
      //   path: '/cancerdb/m2c/eQTL',
      //   name:"EQTL",
      //   component:EQTL,
      //   meta:{
      //     title:'eQTL',
      //   }
      // },
      // {
      //   path: '/cancerdb/m2c/pQTL',
      //   name:"PQTL",
      //   component:PQTL,
      //   meta:{
      //     title:'pQTL',
      //   }
      // },
    ],
  },

  {
    path: "/:catchAll(.*)",
    name: "/404",
    // route level code-splitting
    // this generates a separate chunk (about.[hash].js) for this route
    // which is lazy-loaded when the route is visited.
    component: NotFound,
  },
  {
    path: "/tmp",
    name: "TmpVue",
    component: TmpVue,
  },
  {
    path: "/goodt",
    name: "GoodT",
    component: GoodT,
  },

];

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes,
});

export default router;
