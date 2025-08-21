#!/bin/bash 

fastp -i  ${i}_1_raw.fq.gz -I ${i}_2_raw.fq.gz -o ${i}_1_out.fq.gz -O ${i}_2_out.fq.gz -h out_R.html -j out_R.json

bwa mem -t 20 -R '@RG\tID:'$i'\tSM:'$i'\tPL:illumina'  genome.fa  ${i}_1_out.fq.gz ${i}_2_out.fq.gz | samtools sort -@ 20 -m 4G  -o  ${i}.sort.bam -

picard -Xmx10g MarkDuplicates I=${i}.sort.bam O=${i}.sort.rmdup.bam CREATE_INDEX=true REMOVE_DUPLICATES=true   M=${i}.sort.markdup_metrics.txt

gatk --java-options "-Xmx10g -Djava.io.tmpdir=~tmp" HaplotypeCaller -R  genome.fa -I ${i}.sort.rmdup.bam  -ERC GVCF -O  ${i}.g.vcf 

ls  *.g.vcf > gvcf.list
gatk   CombineGVCFs -R  genome.fa  -V ./gvcf.list  -O ./all.merge.g.vcf

gatk     GenotypeGVCFs -R genome.fa --variant  all.merge.g.vcf -O ./all.merge_raw.vcf

gatk   SelectVariants  -R genome.fa -V all.merge_raw.vcf  --select-type SNP -O ./all.raw.snp.vcf

gatk   VariantFiltration -R genome.fa  -V  ./all.raw.snp.vcf  --filter-expression "QUAL <200 || QD < 2.0 ||  DP < 3 || DP > 300  || MQ < 40.0 || FS > 60.0 || SOR > 3.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0" --filter-name 'filter' -O ./all.filter.snp.vcf

gatk  SelectVariants -R genome.fa -V all.filter.snp.vcf --exclude-filtered -O all.filtered.snp.vcf

vcftools --vcf all.filtered.snp.vcf  --recode-INFO-all   --max-alleles 2   --min-alleles 2  --max-missing 0.8 --out all_snp --recode --remove-filtered-all  

java -Xmx200g -jar beagle.29Oct24.c8e.jar   gt=snp.vcf.gz     out=imputed     impute=true     nthreads=30
