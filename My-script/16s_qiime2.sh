#!/usr/bin/env bash
###
 # @Author: Jesse
 # @mail: Cherryamme@qq.com
 # @Date: 2020-09-04 03:07:53 
 # @LastEditTime: 2020-09-04 06:48:57 
 # @FilePath: /jc/microbio-work/9.04_16S_104_tidy/16s_qiime2.sh
 # @Description: qiime2流程，
 # @Version: 20.1
 # @fuck world!
### 
#00定义变量
manifestfile="/dsk2/who/jc/microbio-work/9.04_16S_104_tidy/manifest-16s-homo-V1.csv"
metadata="/dsk2/who/jc/microbio-work/9.04_16S_104_tidy/metadata-16s-homo.txt"
data=$(awk -F "," '{print $2}' $manifestfile |grep -v absolut)
workdir="/dsk2/who/jc/microbio-work/9.04_16S_104_tidy"
classifier_16s="/dsk2/who/jc/microbio-data/Database/16S_classifier_database/classifier_silva_132_99_16S.qza"

NCORES=1


. /dsk2/who/jc/miniconda3/etc/profile.d/conda.sh
source ~/miniconda3/bin/activate qiime2

cd $workdir
mkdir 00_fastqc_out
fastqc -t $NCORES $data -o 00_fastqc_out/
multiqc 00_fastqc_out/ -o 00_multiqc_result



#01开始运行qiime2包、导入数据
mkdir 01_reads_qza

qiime tools import \
   --type SampleData[PairedEndSequencesWithQuality] \
   --input-path ${manifestfile} \
   --output-path 01_reads_qza/reads.qza \
   --input-format PairedEndFastqManifestPhred33

qiime demux summarize \
   --i-data 01_reads_qza/reads.qza \
   --o-visualization 01_reads_qza/reads_summary.qzv

#02dada2去噪
mkdir 02_dada2
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs 01_reads_qza/reads.qza \
  --p-trim-left-f 0 \
  --p-trim-left-r 0 \
  --p-trunc-len-f 0 \
  --p-trunc-len-r 0 \
  --o-table 02_dada2/table.qza \
  --o-representative-sequences 02_dada2/rep-seqs.qza \
  --o-denoising-stats 02_dada2/denoising-stats.qza

#02可视化denoising stats
qiime metadata tabulate \
  --m-input-file 02_dada2/denoising-stats.qza \
  --o-visualization 02_dada2/denoising-stats.qzv

#02生成Feature表
qiime feature-table summarize \
  --i-table 02_dada2/table.qza \
  --o-visualization 02_dada2/table.qzv \
  --m-sample-metadata-file $metadata

#02代表序列可视化
qiime feature-table tabulate-seqs \
  --i-data 02_dada2/rep-seqs.qza \
  --o-visualization 02_dada2/rep-seqs.qzv


#03.1建发育树

mkdir 03_tree
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences 02_dada2/rep-seqs.qza \
  --o-alignment 03_tree/aligned-rep-seqs.qza \
  --o-masked-alignment 03_tree/masked-aligned-rep-seqs.qza \
  --o-tree 03_tree/unrooted-tree.qza \
  --o-rooted-tree 03_tree/rooted-tree.qza

#03.2 Alpha多样性分析
mkdir 03_alpha_beta
# 计算多样性(包括所有常用的Alpha和Beta多样性方法)，输入有根树、Feature表、样本重采样深度和样本信息
# 取样深度通过table.qzv文件确定（一般为样本最小的sequence count，或覆盖绝大多数样品的sequence count）
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny 03_tree/rooted-tree.qza \
  --i-table 02_dada2/table.qza \
  --p-sampling-depth 1 \
  --m-metadata-file $metadata \
  --output-dir 03_alpha_beta/core-metrics-results

# 输出结果包括多种多样性结果，文件列表和解释如下：
# beta多样性bray_curtis距离矩阵 bray_curtis_distance_matrix.qza
# alpha多样性evenness(均匀度，考虑物种和丰度)指数 evenness_vector.qza
# alpha多样性faith_pd(考虑物种间进化关系)指数 faith_pd_vector.qza
# beta多样性jaccard距离矩阵 jaccard_distance_matrix.qza
# alpha多样性observed_otus(OTU数量)指数 observed_otus_vector.qza
# alpha多样性香农熵(考虑物种和丰度)指数 shannon_vector.qza
# beta多样性unweighted_unifrac距离矩阵，不考虑丰度 unweighted_unifrac_distance_matrix.qza
# beta多样性weighted_unifrac距离矩阵，考虑丰度 weighted_unifrac_distance_matrix.qza

# 测试分类元数据(sample-metadata)列和alpha多样性数据之间的关联，输入多样性值、sample-medata，输出统计结果

#03.3 统计faith_pd算法Alpha多样性组间差异是否显著
qiime diversity alpha-group-significance \
  --i-alpha-diversity 03_alpha_beta/core-metrics-results/faith_pd_vector.qza \
  --m-metadata-file $metadata \
  --o-visualization 03_alpha_beta/core-metrics-results/faith-pd-group-significance.qzv

#03.4统计evenness组间差异是否显著
qiime diversity alpha-group-significance \
  --i-alpha-diversity 03_alpha_beta/core-metrics-results/evenness_vector.qza \
  --m-metadata-file $metadata \
  --o-visualization 03_alpha_beta/core-metrics-results/evenness-group-significance.qzv

qiime diversity beta-group-significance \
  --i-distance-matrix 03_alpha_beta/core-metrics-results/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file $metadata \
  --m-metadata-column subject \
  --o-visualization 03_alpha_beta/core-metrics-results/unweighted-unifrac-subject-significance.qzv \
  --p-pairwise

qiime emperor plot \
  --i-pcoa 03_alpha_beta/core-metrics-results/unweighted_unifrac_pcoa_results.qza \
  --m-metadata-file $metadata \
  --p-custom-axes effect \
  --o-visualization 03_alpha_beta/core-metrics-results/unweighted-unifrac-emperor-weight.qzv

qiime emperor plot \
  --i-pcoa 03_alpha_beta/core-metrics-results/unweighted_unifrac_pcoa_results.qza \
  --m-metadata-file $metadata \
  --p-custom-axes effect \
  --o-visualization 03_alpha_beta/core-metrics-results/unweighted-unifrac-emperor-effect.qzv

qiime diversity alpha-rarefaction \
  --i-table 02_dada2/table.qza \
  --i-phylogeny 03_tree/rooted-tree.qza \
  --p-max-depth 27311 \
  --m-metadata-file $metadata \
  --o-visualization 03_alpha_beta/alpha-rarefaction.qzv

mkdir 04_taxonomic


#04 物种分类
qiime feature-classifier classify-sklearn \
  --i-classifier ${classifier_16s} \
  --i-reads 02_dada2/rep-seqs.qza \
  --o-classification 04_taxonomic/taxonomy.qza #(另一种导出--output-dir taxa)

#04 结果可视化
qiime metadata tabulate \
  --m-input-file 04_taxonomic/taxonomy.qza \
  --o-visualization 04_taxonomic/taxonomy.qzv

#04 物种分类条形图
qiime taxa barplot \
  --i-table 02_dada2/table.qza \
  --i-taxonomy 04_taxonomic/taxonomy.qza \
  --m-metadata-file $metadata \
  --o-visualization 04_taxonomic/taxa-bar-plots.qzv

#04 按元数据对样本进行分组
qiime feature-table group \
   --i-table 02_dada2/table.qza \
   --p-axis sample \
   --p-mode sum \
   --m-metadata-file $metadata \
   --m-metadata-column effect \
   --o-grouped-table 04_taxonomic/taxa-bar-plots-category.qza

qiime taxa barplot \
   --i-table 04_taxonomic/taxa-bar-plots-category.qza \
   --i-taxonomy 04_taxonomic/taxonomy.qza \
   --m-metadata-file $metadata \
   --o-visualization 04_taxonomic/taxa_barplot_category.qzv


mkdir 04_ancom
#04 按subject分组进行差异分析
qiime feature-table filter-samples \
  --i-table 02_dada2/table.qza \
  --m-metadata-file $metadata \
  --p-where "subject='subject-1'" \
  --o-filtered-table 04_ancom/subject-1-table.qza

#04 OTU表添加假count，因为ANCOM不允许有零
qiime composition add-pseudocount \
  --i-table 04_ancom/subject-1-table.qza \
  --o-composition-table 04_ancom/comp-subject-1-table.qza

# subject-1 -->weight
qiime composition ancom \
  --i-table 04_ancom/comp-subject-1-table.qza \
  --m-metadata-file $metadata \
  --m-metadata-column effect \
  --o-visualization 04_ancom/ancom-subject-1-weight.qzv

#按属水平进行差异分析，genus level (i.e. level 6 of the Greengenes taxonomy)
# 按种水平进行合并，统计各种的总reads
qiime taxa collapse \
  --i-table 04_ancom/subject-1-table.qza \
  --i-taxonomy taxonomic/taxonomy.qza \
  --p-level 6 \
  --o-collapsed-table 04_ancom/subject-1-table-l6.qza
#用时0m2.496s

# add-pseudocount
qiime composition add-pseudocount \
  --i-table 04_ancom/subject-1-table-l6.qza \
  --o-composition-table 04_ancom/comp-subject-1-table-l6.qza

# subject-1 -->weight
qiime composition ancom \
  --i-table 04_ancom/comp-subject-1-table-l6.qza \
  --m-metadata-file $metadata \
  --m-metadata-column weight \
  --o-visualization 04_ancom/l6-ancom-subject-1-weight.qzv

source deactivate