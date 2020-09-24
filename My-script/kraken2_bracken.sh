###
 # @Author: Jesse
 # @mail: Cherryamme@qq.com
 # @Date: 2020-09-16 08+8:25:28
 # @LastEditTime: 2020-09-19 10+8:25:14
 # @FilePath: /jc/My-script/kraken2_bracken.sh
 # @Description: use to convert kraken2 report to bracken report
 # @Version: 
 # @fuck world!
### 

#00 基础设置
KRAKEN_DB="/dsk2/who/jc/microbio-data/Database/kraken_database"
R_bracken_dir="/dsk2/who/jc/microbio-pd1/R/R_bracken"
NR_bracken_dir="/dsk2/who/jc/microbio-pd1/NR/NR_bracken"
KMER_LEN="35"
READ_LEN="100"


################################################## R  在种水平上作bracken报告 #################################################
kreport_dir="/dsk2/who/jc/microbio-pd1/R"
mkdir -p $R_bracken_dir
cd $R_bracken_dir

for i in $(ls $kreport_dir/*.report*)
do
a=`basename $i |cut -c 1-10`
bracken -d ${KRAKEN_DB} -i $i -o ${a}.bracken -w ${a}.breport -r ${READ_LEN} -l S
done


################################################## NR 在种水平上作bracken报告 #################################################
kreport_dir="/dsk2/who/jc/microbio-pd1/NR"
mkdir -p $NR_bracken_dir
cd $NR_bracken_dir

for i in $(ls $kreport_dir/*.report*)
do
a=`basename $i |cut -c 1-10`
bracken -d ${KRAKEN_DB} -i $i -o ${a}.bracken -w ${a}.breport -r ${READ_LEN} -l S
done

################################################## NR 合并bracken报告 #################################################
cd $NR_bracken_dir

# combine_bracken="/dsk2/who/jc/Bracken-2.6.0/analysis_scripts/combine_bracken_outputs.py"
breport_dir="$NR_bracken_dir"
combine_bracken_outputs.py --files $breport_dir/*.bracken -o NR_combine_bracken

################################################## R 合并bracken报告 #################################################
cd $R_bracken_dir

breport_dir="$R_bracken_dir"
combine_bracken_outputs.py --files $breport_dir/*.bracken -o R_combine_bracken


################################################## All 合并bracken报告 #################################################

cd /dsk2/who/jc/microbio-pd1
combine_bracken_outputs.py --files $NR_bracken_dir/*.bracken $R_bracken_dir/*.bracken -o all_combine_bracken
