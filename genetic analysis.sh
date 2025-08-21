#!/bin/bash 

plink --vcf  imputed.vcf.gz  --indep-pairwise 50 5 0.5 --out tmp.ld   --allow-extra-chr --set-missing-var-ids @:#  

plink --vcf  imputed.vcf.gz  --make-bed --extract tmp.ld.prune.in  --out LD_filter --recode vcf-iid  --keep-allele-order  --allow-extra-chr --set-missing-var-ids @:#


##PCA
plink --vcf  LD_filter.vcf   --pca 10 --out  PCA_out   --allow-extra-chr --set-missing-var-ids @:#

##NJ tree
VCF2Dis   -InPut LD_filter.vcf    -OutPut p_dis.mat

##LD
~PopLDdecay/PopLDdecay -InVCF imputed.vcf.gz -SubPop pop1.txt -MaxDist 100 -OutStat pop1.stat 
~PopLDdecay/PopLDdecay -InVCF imputed.vcf.gz -SubPop pop2.txt -MaxDist 100 -OutStat pop2.stat 
~PopLDdecay/PopLDdecay -InVCF imputed.vcf.gz -SubPop pop3.txt -MaxDist 100 -OutStat pop3.stat 
~PopLDdecay/PopLDdecay -InVCF imputed.vcf.gz -SubPop pop4.txt -MaxDist 100 -OutStat pop4.stat 
