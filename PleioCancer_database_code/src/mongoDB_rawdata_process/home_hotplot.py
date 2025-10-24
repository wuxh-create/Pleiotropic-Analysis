# f = read.table("/home/yanyq/share_genetics/result/PLACO/sig_num", header = F)
# f = f[-704,]
# f$V2 = gsub("/home/yanyq/share_genetics/result/PLACO/sig_","",f$V2)
# f = f[!grepl("CORP", f$V2),]
# f = tidyr::separate(f, col = "V2", into = c("trait1", "trait2"), sep = "-")
# f$V1 = f$V1-1

# abbrev = as.data.frame(read_tsv("/home/yanyq/share_genetics/data/english_abbrev"))

# colnames(abbrev)[2] = "trait1"
# f = dplyr::left_join(f,abbrev,by = "trait1")
# colnames(abbrev)[2] = "trait2"
# f = dplyr::left_join(f,abbrev,by = "trait2")
# f = f[,c(1,4,5)]
# sum(f[,1])
# f = f[order(f$name.x,f$name.y),]
# write_tsv(f,"/home/yanyq/share_genetics/result/PLACO/sig_num.tsv")

# placo_gene = as.data.frame(read_tsv("/home/yanyq/database/flask_vue/data/placo_gene"))
# placo_gene_t = as.data.frame(table(paste0(placo_gene$cancer1,":",placo_gene$cancer2)))
# placo_gene_t$Var1 = as.character(placo_gene_t$Var1)
# placo_gene_t = tidyr::separate(placo_gene_t,"Var1", into = c("trait1","trait2"),sep = ":")
# write_tsv(placo_gene_t,"/home/yanyq/share_genetics/result/MAGMA/sig_num.tsv")


import pandas as pd

placo_snp = pd.read_csv("/home/yanyq/share_genetics/result/PLACO/sig_num.tsv", sep="\t")
placo_gene = pd.read_csv("/home/yanyq/share_genetics/result/MAGMA/sig_num.tsv", sep="\t")
cancer = [
  'Acute myeloid leukaemia',
  'Basal cell carcinoma',
  'Bladder cancer',
  'Brain glioblastoma and astrocytoma',
  'Brain meningioma',
  'Breast cancer',
  'Cervical cancer',
  'Chronic myeloid leukaemia',
  'Colorectal cancer',
  'Diffuse large B-cell lymphoma',
  'Endometrioid Cancer',
  'Esophageal cancer',
  'Gastrointestinal stromal tumor and sarcoma',
  'Head and neck cancer',
  'Hepatocellular carcinoma',
  'Hodgkins lymphoma',
  'Kidney cancer, except renal pelvis',
  'Lung cancer',
  'Lymphocytic leukemia',
  'Malignant neoplasm of bone and articular cartilage',
  'Malignant neoplasm of eye and adnexa',
  'Malignant neoplasm of intrahepatic ducts, biliary tract and gallbladder',
  'Mantle cell lymphoma',
  'Mesothelioma',
  'Multiple myeloma',
  'Myelodysplastic syndrome',
  'Marginal zone B-cell lymphoma',
  'Ovarian cancer',
  'Pancreatic cancer',
  'Prostate cancer',
  'Skin melanoma',
  'Small intestine cancer',
  'Squamous cell carcinoma',
  'Stomach cancer',
  'Testicular cancer',
  'Thyroid cancer',
  'Vulvar cancer']

list_all = []
for i in range(0, 37):
    x = i
    y = i
    for j in range(0, 37):
        x = j
        if x == y:
            list = [x, y, 0]
        elif x>y:
            rows = placo_snp[
                ((placo_snp["name.x"] == cancer[i]) & (placo_snp["name.y"] == cancer[j])) |
                ((placo_snp["name.y"] == cancer[i]) & (placo_snp["name.x"] == cancer[j]))
            ]
            if len(rows)==0:
                list = [x, y, 0]
            else:
                list = [x, y, rows["V1"].iloc[0]]
        else:
            rows = placo_gene[
                ((placo_gene["trait1"] == cancer[i]) & (placo_gene["trait2"] == cancer[j])) |
                ((placo_gene["trait2"] == cancer[i]) & (placo_gene["trait1"] == cancer[j]))
            ]
            if len(rows)==0:
                list = [x, y, 0]
            else:
                list = [x, y, rows["Freq"].iloc[0]]
            
        list_all.append(list)
