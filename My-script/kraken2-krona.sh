###
 # @Author: Jesse
 # @mail: Cherryamme@qq.com
 # @Date: 2020-09-13 04+8:55:53
 # @LastEditTime: 2020-09-14 02:23:15 
 # @FilePath: /jc/kraken2-krona.sh
 # @Description: use to get krona report
 # @Version: 
 # @fuck world!
### 

#00 基础设置
kraport_dir="/dsk2/who/jc/microbio-pd1/R"
krona_dir="/dsk2/who/jc/microbio-pd1/krona_R"
kreport_tool="/dsk2/who/jc/kraken2-tools/kreport2krona.py"

mkdir -p $krona_dir
cd $krona_dir
#使用kraport2krona.py转化为krona文件
for i in $(ls $kraport_dir/*.report*)
do
a=`basename $i |cut -c 1-10`
python $kreport_tool -r $i -o $krona_dir/$a.krona
done

#使用krona生成krona报告
ktImportText $krona_dir/*.krona
