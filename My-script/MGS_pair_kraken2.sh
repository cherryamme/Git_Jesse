#!/usr/bin/env bash
###
 # @Author: Jesse
 # @mail: Cherryamme@qq.com
 # @Date: 2020-09-04 08:07:47 
 # @LastEditTime: 2020-09-12 03+8:03:12
 # @FilePath: /jc/My-script/MGS_pair_kraken2.sh
 # @Description: 
 # @Version: 
 # @fuck world!
### 



# input: paired-end fastq (质控->去人->比对微生物）
# 内存需要至少100-200G
# 所有样品的前缀写在一个文件里，一个一行，例如sampleA_R1.fastq sampleA_R2.fastq sampleB_R1.fastq sampleB_R2.fastq ...
# cat sample_list.txt
# sampleA
# sampleB
# ...
# 以下目录均假定已经存在
# 原始数据文件存放位置
# ==============================================================================================================
#00 设置工作目录
style_1="_1.fastq"
style_2="_2.fastq"
raw_dir="/dsk2/who/jc/microbio-data/MGSdata/data2_104"
workdir="/dsk2/who/jc/microbio-work/MGS_104"
sample_list="$workdir/sample_list.txt"
#00 kneaddata和kraken2的数据库文件位置
db_kneaddata_dir="/dsk2/who/jc/microbio-data/Database/kneaddata_database"
db_kraken_dir="/dsk2/who/jc/microbio-data/Database/kraken_database"
#00 trimmomatic软件位置，接头文件位置
tm_dir="/dsk2/who/jc/miniconda3/bin/"
tm_adapter="/dsk2/who/jc/miniconda3/share/trimmomatic-0.39-1/adapters/TruSeq3-PE.fa"
# ==========




#01. quality control
cd $workdir
mkdir 01_cleandata
cd 01_cleandata

for SAMPLE in $(cat ${sample_list})
do

/dsk2/who/jc/miniconda3/bin/trimmomatic PE -threads 16 -phred33 ${raw_dir}/${SAMPLE}${style_1} ${raw_dir}/${SAMPLE}${style_2} ${SAMPLE}.trim_1.fastq ${SAMPLE}.trim_1_unpaired.fastq ${SAMPLE}.trim_2.fastq ${SAMPLE}.trim_2_unpaired.fastq ILLUMINACLIP:${tm_adapter}:2:30:10 LEADING:20 TRAILING:20 SLIDINGWINDOW:4:20 MINLEN:75 AVGQUAL:20
rm ${SAMPLE}.trim_1_unpaired.fastq ${SAMPLE}.trim_2_unpaired.fastq

done

cd $workdir


#02. remove human reads
# =============
# 待添加载入kneaddata软件的代码
# 以下为示例
# module load Trimmomatic/0.36 
# module load python/2.7.13
# =============

idx_1="${db_kneaddata_dir}/hg37dec_v0.1"
idx_2="${db_kneaddata_dir}/human_hg38_refMrna"
idx_3="${db_kneaddata_dir}/hs_ref_GRCh37.p5"
idx_4="${db_kneaddata_dir}/hs_alt_HuRef"
idx_5="${db_kneaddata_dir}/hs_alt_CRA_TCAGchr7v2"
idx_6="${db_kneaddata_dir}/SILVA_128_LSUParc_SSUParc_ribosomal_RNA"



for SAMPLE in $(cat ${sample_list})
do

kneaddata \
-i 01_cleandata/${SAMPLE}.trim_1.fastq \
-i 01_cleandata/${SAMPLE}.trim_2.fastq \
-db $idx_1 \
-db $idx_2 \
-db $idx_3 \
-db $idx_4 \
-db $idx_5 \
-db $idx_6 \
--output-prefix ${SAMPLE} \
-t 16 \
--bypass-trim \
-o 02_kneaddata \
--log ${SAMPLE}_PAIRED_kneaddata.log \
--serial --remove-intermediate-output

rm 02_kneaddata/${SAMPLE}*contam*
rm 02_kneaddata/${SAMPLE}*unmatched*

rm ${SAMPLE}_PAIRED_kneaddata.log 

done




#03. taxonomic classification

# =============
# 待添加载入kraken2软件的代码
# 以下为示例
# module add compiler/gnu/5.5.0
# =============

cd $workdir
mkdir -p 03_kraken2/detail

for SAMPLE in $(cat ${sample_list})
do

kraken2 --db ${db_kraken_dir} \
--paired 02_kneaddata/${SAMPLE}_paired_1.fastq 02_kneaddata/${SAMPLE}_paired_2.fastq \
--report 03_kraken2/${SAMPLE}.report-conf20.txt \
--threads 16 --confidence 0.20 > 03_kraken2/detail/${SAMPLE}.kraken2-conf20.out

done
# 需要的最终结果：03_kraken2 下面所有以.report-conf20.txt结尾的文件