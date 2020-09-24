#!/usr/bin/env bash
###
 # @Author: Jesse
 # @mail: Cherryamme@qq.com
 # @Date: 2020-08-29 08:24:28 
 # @LastEditTime: 2020-08-29 15:20:59
 # @FilePath: /jc/ascp_down_script.sh
 # @Description: 01需要设置，之后02需单独运行生成起始下载文件,04设置该脚本名称重复运行
 # 可下载NCBI、ENA的数据(需了解下载地址的格式，a1\a2\a3\a4\a5)，适配双端下载，增加下载文件完成检测导入日志，增加全部文件下载检测并重复运行。
 # @Version: 8
 # @fuck world!
### 

#00ascp软件位置,脚本名称和输出信息名称
ascp_dir=`which ascp`
mkdir ascp_log

#01设置——————需要下载的内容起始和结尾
ERR=SRR600
ERR2=$ERR'0'
data=940
datz=949
datatail=.fastq.gz

#01双端文件_1\_2，需设置分两个文件运行,单端则为空白
pair=_2
#01日志文件
downloadlist=downloadlist
#01下载目录文件
download_need=download_need

#02初始下载文件加载(单独运行生成一个下载目录)
#seq $data $datz>$download_need

#03循环下载
for i in $(cat $download_need)
do
a1=$ascp_dir' -k 1 -L ascp_log -QT -l 300m -P33001 -i /dsk2/who/jc/.aspera/connect/etc/asperaweb_id_dsa.openssh era-fasp@fasp.sra.ebi.ac.uk:/vol1/fastq/'$ERR'/00'
a2=$(($i % 10))
a3='/'$ERR2$i
a4=$pair$datatail\ \.
a5=$ERR2$i
$a1$a2$a3$a3$a4

#03添加log至日志文件
echo `date` >>$downloadlist
echo $a5$pair'跑完了' >> $downloadlist

#03检查下载文件是否完成（使用grep+$？判断是否存在文件）
name=$ERR2$i$pair$datatail
ls |grep $name$
if [ $? == 0 ];then
    echo "$name下载成功啦hahahah" >>$downloadlist
else
    echo "$name下载失败了——好可惜" >>$downloadlist
fi
done

#04检查文件是否下载完成并重复执行(grep所有fastq格式文件并与所需下载文件比较，提取缺失的文件信息,test检查是否重复运行)
ls $ERR2*$datatail |cut -c8-10 >temp
grep -v -f temp $download_need >temp2
cat temp2 >$download_need
rm temp temp2
test -s $download_need &&nohup bash ascp_down_script.sh & 