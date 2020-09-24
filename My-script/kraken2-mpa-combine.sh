###
 # @Author: Jesse
 # @mail: Cherryamme@qq.com
 # @Date: 2020-09-08 05:28:54 
 # @LastEditTime: 2020-09-08 07+8:50:12
 # @FilePath: /jc/My-script/kraken2-mpa-combine.sh
 # @Description: use to convert kraken2-report to mpamode and combine them
 # @Version: 
 # @fuck world!
### 

# 00 抬头变量设置
kreport2mpa_tooldir="/dsk2/who/jc/kraken2-tools/kreport2mpa.py"
combinempa_tooldir="/dsk2/who/jc/kraken2-tools/combine_mpa.py"
workdir="/dsk2/who/jc/microbio-work/MGS_91_2213/"
kraken2_report_dir="/dsk2/who/jc/microbio-work/MGS_91_2213/03_kraken2"


#00 工作文件夹
cd $workdir
mkdir 04_LefSe
#04 导出mpa格式的kraken2
#--percentages 以百分数形式显示(默认为reads数)
#--display-header 显示headers，默认为sample代号
for i in $(ls $kraken2_report_dir/*.report-conf20.txt)
do
python $kreport2mpa_tooldir --display-header --percentages -r $i -o 04_LefSe/$(basename ${i%%.*}).mpa
done
#04 合并所有的mpa报告
python $combinempa_tooldir -i 04_LefSe/*.mpa -o 04_LefSe/combine.mpa
sed -i 's/.report-conf20.txt//g' $workdir/04_LefSe/combine.mpa
