#!/usr/bin/env bash
###
 # @Author: Jesse
 # @mail: Cherryamme@qq.com
 # @Date: 2020-09-07 02:43:46 
 # @LastEditTime: 2020-09-14 02:27:56 
 # @FilePath: /jc/My-script/combine_kraken2_report.sh
 # @Description: 
 # @Version: 
 # @fuck world!
### 

#00 设置工作目录
workdir="/dsk2/who/jc/microbio-pd1/All"
combine_kreports="/dsk2/who/jc/kraken2-tools/combine_kreports.py"
#04 合并kraken2报告
cd $workdir 
mkdir 04_combine_kreports

python $combine_kreports -r $workdir/NR/*.report* $workdir/R/*.report* -o $workdir/04_combine_kreports/combine_kreport
