library(bigreadr)
library(Matching)
library(tableone)
library(readr)

breast = fread2("/home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/singleCancer.breast.pheno.filtered")
ovary = fread2("/home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/singleCancer.ovary.pheno.filtered")
breast_ovary = fread2("/home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/breastThenOvary.pheno.filtered")
ovary_breast = fread2("/home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/ovaryThenBreast.pheno.filtered")
nonCancer = fread2("/home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/nonCancer.filtered.white.pheno.filtered")
nonCancer = unique(nonCancer)

breast$`20116-0.0`[!is.na(breast$`20116-1.0`)] = breast$`20116-1.0`[!is.na(breast$`20116-1.0`)]
breast$`20116-0.0`[!is.na(breast$`20116-2.0`)] = breast$`20116-1.0`[!is.na(breast$`20116-2.0`)]
breast$`20116-0.0`[!is.na(breast$`20116-3.0`)] = breast$`20116-1.0`[!is.na(breast$`20116-3.0`)]
ovary$`20116-0.0`[!is.na(ovary$`20116-1.0`)] = ovary$`20116-1.0`[!is.na(ovary$`20116-1.0`)]
ovary$`20116-0.0`[!is.na(ovary$`20116-2.0`)] = ovary$`20116-1.0`[!is.na(ovary$`20116-2.0`)]
ovary$`20116-0.0`[!is.na(ovary$`20116-3.0`)] = ovary$`20116-1.0`[!is.na(ovary$`20116-3.0`)]
breast_ovary$`20116-0.0`[!is.na(breast_ovary$`20116-1.0`)] = breast_ovary$`20116-1.0`[!is.na(breast_ovary$`20116-1.0`)]
breast_ovary$`20116-0.0`[!is.na(breast_ovary$`20116-2.0`)] = breast_ovary$`20116-1.0`[!is.na(breast_ovary$`20116-2.0`)]
breast_ovary$`20116-0.0`[!is.na(breast_ovary$`20116-3.0`)] = breast_ovary$`20116-1.0`[!is.na(breast_ovary$`20116-3.0`)]
ovary_breast$`20116-0.0`[!is.na(ovary_breast$`20116-1.0`)] = ovary_breast$`20116-1.0`[!is.na(ovary_breast$`20116-1.0`)]
ovary_breast$`20116-0.0`[!is.na(ovary_breast$`20116-2.0`)] = ovary_breast$`20116-1.0`[!is.na(ovary_breast$`20116-2.0`)]
ovary_breast$`20116-0.0`[!is.na(ovary_breast$`20116-3.0`)] = ovary_breast$`20116-1.0`[!is.na(ovary_breast$`20116-3.0`)]
nonCancer$`20116-0.0`[!is.na(nonCancer$`20116-1.0`)] = nonCancer$`20116-1.0`[!is.na(nonCancer$`20116-1.0`)]
nonCancer$`20116-0.0`[!is.na(nonCancer$`20116-2.0`)] = nonCancer$`20116-1.0`[!is.na(nonCancer$`20116-2.0`)]
nonCancer$`20116-0.0`[!is.na(nonCancer$`20116-3.0`)] = nonCancer$`20116-1.0`[!is.na(nonCancer$`20116-3.0`)]

breast = breast[,c("eid","20116-0.0","20117-0.0","21001-0.0","21022-0.0", "22001-0.0")]
ovary = ovary[,c("eid","20116-0.0","20117-0.0","21001-0.0","21022-0.0", "22001-0.0")]
breast_ovary = breast_ovary[,c("eid","20116-0.0","20117-0.0","21001-0.0","21022-0.0", "22001-0.0")]
ovary_breast = ovary_breast[,c("eid","20116-0.0","20117-0.0","21001-0.0","21022-0.0", "22001-0.0")]
nonCancer = nonCancer[,c("eid","20116-0.0","20117-0.0","21001-0.0","21022-0.0", "22001-0.0")]

colnames(breast) = c("eid","smoking","alcohol","BMI","age","sex")
colnames(ovary) = c("eid","smoking","alcohol","BMI","age","sex")
colnames(breast_ovary) = c("eid","smoking","alcohol","BMI","age","sex")
colnames(ovary_breast) = c("eid","smoking","alcohol","BMI","age","sex")
colnames(nonCancer) = c("eid","smoking","alcohol","BMI","age","sex")

breast = na.omit(breast)
ovary = na.omit(ovary)
breast_ovary = na.omit(breast_ovary)
ovary_breast = na.omit(ovary_breast)
nonCancer = na.omit(nonCancer)

table(breast$smoking)
table(breast$alcohol)
table(breast$BMI)
table(breast$age)
table(breast$sex)
table(ovary$smoking)
table(ovary$alcohol)
table(ovary$BMI)
table(ovary$age)
table(ovary$sex)
table(nonCancer$smoking)
table(nonCancer$alcohol)
table(nonCancer$BMI)
table(nonCancer$age)
table(nonCancer$sex)
breast = breast[breast$smoking!=-3,]
ovary = ovary[ovary$smoking!=-3,]
breast_ovary = breast_ovary[breast_ovary$smoking!=-3,]
ovary_breast = ovary_breast[ovary_breast$smoking!=-3,]
nonCancer = nonCancer[nonCancer$smoking!=-3,]
breast = breast[breast$alcohol!=-3,]
ovary = ovary[ovary$alcohol!=-3,]
breast_ovary = breast_ovary[breast_ovary$alcohol!=-3,]
ovary_breast = ovary_breast[ovary_breast$alcohol!=-3,]
nonCancer = nonCancer[nonCancer$alcohol!=-3,]

write_tsv(breast,"/home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/singleCancer.breast.pheno.filtered.before_PSM")
write_tsv(ovary,"/home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/singleCancer.ovary.pheno.filtered.before_PSM")
write_tsv(breast_ovary,"/home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/breastThenOvary.pheno.filtered.before_PSM")
write_tsv(ovary_breast,"/home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/ovaryThenBreast.pheno.filtered.before_PSM")
write_tsv(nonCancer,"/home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/nonCancer.filtered.white.pheno.filtered.before_PSM")

breast$outcome = 1
nonCancer$outcome = 0
breast_nonCancer = rbind(breast,nonCancer)
anyNA(breast_nonCancer)

ovary$outcome = 1
nonCancer$outcome = 0
ovary_nonCancer = rbind(ovary,nonCancer)
anyNA(ovary_nonCancer)

# Matching 包方法进行PSM
{
  breast_nonCancer$outcome2 = as.logical(breast_nonCancer$outcome=="1")
  tabUnmatched = CreateTableOne(vars = c("smoking", "alcohol", "BMI","age","sex"), strata = "outcome2", data = breast_nonCancer, test = TRUE)
  write_tsv(as.data.frame(print(tabUnmatched, smd = TRUE)),"/home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/breast_before_SMD")
 
  # 大于0.1的标准化平均差（SMD）通常用于check治疗组和对照组之间的平衡性。我们可以看到，大多数混杂因素的 SMD 大于 0.1，且 p 值显着，这意味着实验组和对照组之间的混杂因素存在差异
  # 通过 logit 回归计算每个样本的倾向性分数
  psModel = glm(formula = outcome2~smoking+alcohol+BMI+age+sex, family = binomial(link = "logit"), data = breast_nonCancer)
  # 预测被分配到癌症事件的概率
  breast_nonCancer$predictCancer = predict(psModel, type = "response")
  # 预测被分配到截尾事件的概率
  breast_nonCancer$predictNonCancer = 1 - breast_nonCancer$predictCancer
  # 将癌症事件的概率分配给癌症事件的样本，截尾事件的概率分配给截尾样本
  breast_nonCancer$pAssign = NA
  breast_nonCancer$pAssign[breast_nonCancer$outcome2==TRUE] = breast_nonCancer$predictCancer[breast_nonCancer$outcome2==TRUE]
  breast_nonCancer$pAssign[breast_nonCancer$outcome2==FALSE] =  breast_nonCancer$predictNonCancer[breast_nonCancer$outcome2==FALSE]
  # 返回成对的癌症事件概率和结尾事件概率的最小值
  breast_nonCancer$pMin = pmin(breast_nonCancer$predictCancer, breast_nonCancer$predictNonCancer)
  # 使用 Matching 包进行匹配一致性样本(1:1 匹配)。
  listMatch = Match(Tr = (breast_nonCancer$outcome2==TRUE), X = log(breast_nonCancer$predictCancer/breast_nonCancer$predictNonCancer), M = 1, # 1:1 匹配
                    caliper = 0.1, replace = FALSE, ties = TRUE, version = "fast")
  # 确定数据集是否均衡
  mb = MatchBalance(psModel$formula, data = breast_nonCancer, match.out = listMatch, nboots = 50)
  # 提取匹配好的样本
  breastMatched = breast_nonCancer[unlist(listMatch[c("index.treated", "index.control")]),]
  # 查看匹配后的样本概况
  tabMatched = CreateTableOne(vars = c("smoking", "alcohol", "BMI","age","sex"), strata = "outcome2", data = breastMatched, test = TRUE)
  write_tsv(as.data.frame(print(tabMatched, smd = TRUE)),"/home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/breast_after_SMD")
  write_tsv(breastMatched,"/home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/breastMatched")
  
  # 一般情况下，匹配后大多数变量在两组比较检验的p>0.05，即能说明两组匹配较好。判断匹配情况更严格的方法是计算SMD（标准化均数差），SMD<0.1时表明匹配较好，也有认为SMD<0.2即可。
}
{
  ovary_nonCancer$outcome2 = as.logical(ovary_nonCancer$outcome=="1")
  tabUnmatched = CreateTableOne(vars = c("smoking", "alcohol", "BMI","age","sex"), strata = "outcome2", data = ovary_nonCancer, test = TRUE)
  print(tabUnmatched, smd = TRUE)
  write_tsv(as.data.frame(print(tabUnmatched, smd = TRUE)),"/home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/ovary_before_SMD")
  psModel = glm(formula = outcome2~smoking+alcohol+BMI+age+sex, family = binomial(link = "logit"), data = ovary_nonCancer)
  ovary_nonCancer$predictCancer = predict(psModel, type = "response")
  ovary_nonCancer$predictNonCancer = 1 - ovary_nonCancer$predictCancer
  ovary_nonCancer$pAssign = NA
  ovary_nonCancer$pAssign[ovary_nonCancer$outcome2==TRUE] = ovary_nonCancer$predictCancer[ovary_nonCancer$outcome2==TRUE]
  ovary_nonCancer$pAssign[ovary_nonCancer$outcome2==FALSE] =  ovary_nonCancer$predictNonCancer[ovary_nonCancer$outcome2==FALSE]
  ovary_nonCancer$pMin = pmin(ovary_nonCancer$predictCancer, ovary_nonCancer$predictNonCancer)
  listMatch = Match(Tr = (ovary_nonCancer$outcome2==TRUE), X = log(ovary_nonCancer$predictCancer/ovary_nonCancer$predictNonCancer), M = 1, # 1:1 匹配
                    caliper = 0.1, replace = FALSE, ties = TRUE, version = "fast")
  mb = MatchBalance(psModel$formula, data = ovary_nonCancer, match.out = listMatch, nboots = 50)
  ovaryMatched = ovary_nonCancer[unlist(listMatch[c("index.treated", "index.control")]),]
  tabMatched = CreateTableOne(vars = c("smoking", "alcohol", "BMI","age","sex"), strata = "outcome2", data = ovaryMatched, test = TRUE)
  write_tsv(as.data.frame(print(tabMatched, smd = TRUE)),"/home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/ovary_after_SMD")
  write_tsv(ovaryMatched,"/home/yanyq/share_genetics/data/UKB_multi_cancer/pheno/ovaryMatched")
}