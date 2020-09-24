###
 # @Author: Jesse
 # @mail: Cherryamme@qq.com
 # @Date: 2020-09-08 07+8:33:07
 # @LastEditTime: 2020-09-16 03+8:48:56
 # @FilePath: /jc/My-script/extract_taxa_reads.sh
 # @Description: use to extract taxa reads to analysis
 # @Version: 
 # @fuck world!
### 

#从提取Hymenobacter的序列，用extract.py
report_dir="/dsk2/who/jc/microbio-pd1/All/NR"
fastq_dir="/dsk2/who/jc/microbio-pd1/All/all_fastq"
taxa_id="33959"

for i in $(ls $report_dir/*.kraken2-conf20.out)
do
j=$(basename ${i%%.kr*})
python /dsk2/who/jc/kraken2-tools/extract_kraken_reads.py \
-k $i \
-s $fastq_dir$j.fastq -o $j_extracrt_$taxa_id \
-t $taxa_id
done

###############################################   单端序列文件中提取   ####################################################
#提取 Lactobacillus johnsonii 的序列   NR中，用extract.py
report_dir="/dsk2/who/jc/microbio-pd1/NR_out"
fastq_dir="/dsk2/who/jc/microbio-pd1/All/all_fastq"
extract_dir="/dsk2/who/jc/microbio-pd1/NR_out/NR_extract_fastq"
taxa_id="33959"

cd extract_dir
for i in $(ls $report_dir/*.kraken2-conf20.out)
do
j=$(basename ${i%%.kr*})
# echo $j
# echo $i
python /dsk2/who/jc/kraken2-tools/extract_kraken_reads.py \
-k $i \
-s $fastq_dir/$j.fastq -o $j'_extracrt_'$taxa_id \
-t $taxa_id
done

#提取 Lactobacillus johnsonii 的序列   R中，用extract.py
report_dir="/dsk2/who/jc/microbio-pd1/R_out"
fastq_dir="/dsk2/who/jc/microbio-pd1/All/all_fastq"
extract_dir="/dsk2/who/jc/microbio-pd1/R_out/R_extract_fastq"
taxa_id="33959"

cd $extract_dir
for i in $(ls $report_dir/*.kraken2-conf20.out)
do
j=$(basename ${i%%.kr*})
# echo $j
# echo $i
python /dsk2/who/jc/kraken2-tools/extract_kraken_reads.py \
-k $i \
-s $fastq_dir/$j.fastq -o $j'_extracrt_'$taxa_id \
-t $taxa_id
done

##############################################   双端序列文件中提取   ##################################################
#双端测序文件中提取 Lactobacillus johnsonii的序列  R中
report_dir="/dsk2/who/jc/microbio-pd1/R_out"
fastq_dir="/dsk2/who/jc/microbio-pd1/All/all_fastq"
extract_dir="/dsk2/who/jc/microbio-pd1/R_out/R_extract_fastq"
taxa_id="33959"

cd $extract_dir
for i in $(ls $report_dir/SRR*.kraken2-conf20.out)
do
j=$(basename ${i%%.kr*})
# echo $j
# echo $i
python /dsk2/who/jc/kraken2-tools/extract_kraken_reads.py \09
-k $i \
-s1 $fastq_dir/$j'_paired_1.fastq' \
-s2 $fastq_dir/$j'_paired_2.fastq' \
-o $extract_dir/$j'_paired_1_extracrt_'$taxa_id \
-o2 $extract_dir/$j'_paired_2_extracrt_'$taxa_id \
-t $taxa_id
done

#双端测序文件中提取 Lactobacillus johnsonii的序列  NR中
report_dir="/dsk2/who/jc/microbio-pd1/NR_out"
fastq_dir="/dsk2/who/jc/microbio-pd1/All/all_fastq"
extract_dir="/dsk2/who/jc/microbio-pd1/NR_out/NR_extract_fastq"
taxa_id="33959"

cd $extract_dir
for i in $(ls $report_dir/SRR*.kraken2-conf20.out)
do
j=$(basename ${i%%.kr*})
# echo $j
# echo $i
python /dsk2/who/jc/kraken2-tools/extract_kraken_reads.py \
-k $i \
-s1 $fastq_dir/$j'_paired_1.fastq' \
-s2 $fastq_dir/$j'_paired_2.fastq' \
-o $extract_dir/$j'_paired_1_extracrt_'$taxa_id \
-o2 $extract_dir/$j'_paired_2_extracrt_'$taxa_id \
-t $taxa_id
done
#####################################################################################################################






