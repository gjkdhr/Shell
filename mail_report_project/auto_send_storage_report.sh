#!/bin/bash

Date=`date +%Y%m%d`


Color_Text()
{
  echo -e " \e[0;$2m$1\e[0m"
}

Echo_Red()
{
  echo $(Color_Text "$1" "31")
}

Storage_Mail_Report_Dir="/mnt/mail_report_project/mail_report_dir"
Storage_Report_Txt="${Storage_Mail_Report_Dir}/storage_report_mail_module_${Date}.txt"
if [ -d ${Storage_Mail_Report_Dir} ]
then
	touch ${Storage_Report_Txt}
else
	echo "The Storage_Mail_Report_Dir is not exist."
	mkdir -pv ${Storage_Mail_Report_Dir}
	touch ${Storage_Report_Txt}
fi

PB_Unit=$(expr 1024 \* 1024 \* 1024 \* 1024 \* 1024)
TB_Unit=$(expr 1024 \* 1024 \* 1024 \* 1024)
Cluster_Store_Total_KB=`/usr/local/zabbix/bin/zabbix_get -s 10.1.1.203 -p 10050 -k 'vfs.fs.size[/annoroad/data1,]'`
#echo ${Cluster_Store_Total_KB}
Cluster_Store_Total_TB=`echo "scale=4; ${Cluster_Store_Total_KB}/${TB_Unit}"|bc`
Cluster_Store_Total_PB=`echo "scale=4; ${Cluster_Store_Total_KB}/${PB_Unit}"|bc`
#echo ${Cluster_Store_Total_PB}



Cluster_Store_Free_KB=`/usr/local/zabbix/bin/zabbix_get -s 10.1.1.203 -p 10050 -k 'vfs.fs.size[/annoroad/data1,free]'`
Cluster_Store_Free_TB=`echo "scale=2; ${Cluster_Store_Free_KB}/${TB_Unit}"|bc`
#echo ${Cluster_Store_Free_TB}


Cluster_Store_Used_KB=`/usr/local/zabbix/bin/zabbix_get -s 10.1.1.203 -p 10050 -k 'vfs.fs.size[/annoroad/data1,used]'`
Cluster_Store_Used_TB=`echo "scale=2; ${Cluster_Store_Used_KB}/${TB_Unit}"|bc`
#echo ${Cluster_Store_Used_TB}

Cluster_Store_Used_Percentage=`echo "scale=2; ${Cluster_Store_Used_TB} * 100/${Cluster_Store_Total_TB}"|bc`
#echo "${Cluster_Store_Used_Percentage}"


Storage_Used_Data_File="/mnt/mail_report_project/zabbix_storage_used_value/storage_used_data${Date}.txt"

curl -s -X POST -H 'Content-Type:application/json' -d '
{
    "jsonrpc": "2.0",
    "method": "history.get",
    "params": {
        "output": "extend",
        "history": 3,
        "itemids": "35008",
        "sortfield": "clock",
        "limit": 2000
    },
    "id": 1,
    "auth": "a6fcc40404e94b016fc592a3ac93040f"
}' http://192.168.60.254/zabbix/api_jsonrpc.php > ${Storage_Used_Data_File}

sed -i 's/\}/\n/g' ${Storage_Used_Data_File}
Cluster_Store_Used_7D_Min_Str=`head -n 1 ${Storage_Used_Data_File} | cut -d ":" -f 6 | cut -d "," -f 1`
Cluster_Store_Used_7D_Min_Str1=`echo ${Cluster_Store_Used_7D_Min_Str#*\"}`
Cluster_Store_Used_7D_Min_Value=`echo ${Cluster_Store_Used_7D_Min_Str1%*\"}`
Cluster_Store_Used_7D_Min_TB=`echo "scale=2; ${Cluster_Store_Used_7D_Min_Value}/${TB_Unit}"|bc`
#echo ${Cluster_Store_Used_7D_Min_TB}


Cluster_Store_Used_7D_Max_Str=`tail -n 2 ${Storage_Used_Data_File} | cut -d ":" -f 4|cut -d "," -f 1|head -n 1`
Cluster_Store_Used_7D_Max_Str1=`echo ${Cluster_Store_Used_7D_Max_Str#*\"}`
Cluster_Store_Used_7D_Max_Value=`echo ${Cluster_Store_Used_7D_Max_Str1%*\"}`
Cluster_Store_Used_7D_Max_TB=`echo "scale=2; ${Cluster_Store_Used_7D_Max_Value}/${TB_Unit}"|bc`
#echo ${Cluster_Store_Used_7D_Max_TB}

Storage_Drop_Difference=`echo "scale=2; ${Cluster_Store_Used_7D_Max_TB}-${Cluster_Store_Used_7D_Min_TB}"|bc`
#echo ${Storage_Drop_Difference}
Storage_Average_Value=$(printf "%.2f" `echo "scale=4; ${Storage_Drop_Difference}/7"|bc`)
#echo ${Storage_Average_Value}

Storage_Available_Day=`echo "scale=2; ${Cluster_Store_Used_TB}/${Storage_Average_Value}"|bc`

echo "各位领导及同事，大家好：" >> ${Storage_Report_Txt}
echo "    当前本地存储可用空间为 ${Cluster_Store_Free_TB} TB，总空间为${Cluster_Store_Total_PB} PB（含归档存储），利用率已达 ${Cluster_Store_Used_Percentage} %，" >> ${Storage_Report_Txt}
echo "    本地存储使用情况明细:" >> ${Storage_Report_Txt}
#echo -e "\n" >> ${Storage_Report_Txt}
Date1=`date +%Y.%m.%d`
echo "    1.截止到 ${Date1} 下午 5 点，本地存储可用空间为 ${Cluster_Store_Free_TB} TB，总空间为 ${Cluster_Store_Total_PB} PB，利用率已达 ${Cluster_Store_Used_Percentage} %" >> ${Storage_Report_Txt}
echo -e "\n" >> ${Storage_Report_Txt}
echo "    2.存储 7 天趋势图如下:" >> ${Storage_Report_Txt}
echo "      访问链接:http://monitor.annoroad.com:3000/dashboard/db/sge-dashboard-cpu-load" >> ${Storage_Report_Txt}
echo "      注意:该链接只能在公司办公网络或无线网络情况下访问。" >> ${Storage_Report_Txt}
echo "      账号:storageuser" >> ${Storage_Report_Txt}
echo "      密码:storagepasswd" >> ${Storage_Report_Txt}
echo -e "\n" >> ${Storage_Report_Txt}
echo "    根据监控趋势图平均日增长量为：${Cluster_Store_Used_7D_Max_TB}-${Cluster_Store_Used_7D_Min_TB}（T）=${Storage_Drop_Difference}/7(T/天）= ${Storage_Average_Value} T/天" >> ${Storage_Report_Txt}
echo "    按照 ${Storage_Average_Value} T/天 增长速度，本地存储可用空间可维持 ${Cluster_Store_Free_TB} / ${Storage_Average_Value} = ${Storage_Available_Day} (天) 左右。" >> ${Storage_Report_Txt}
echo "    注释：监控图中 Cluster_store_used 趋势骤降，为IT中心-系统部在清理已经迁移到云端的相关数据造成，属于正常现象。" >> ${Storage_Report_Txt}
#echo -e "\n" >> ${Storage_Report_Txt}
echo "    存储告警规则：" >> ${Storage_Report_Txt}
echo "    存储空间可维持天数 <= 15 天  触发 I 级告警" >> ${Storage_Report_Txt}
echo "    存储空间可维持天数 <= 20 天  触发 II 级告警" >> ${Storage_Report_Txt}
echo "    存储空间可维持天数 <= 25 天  触发 III 级告警" >> ${Storage_Report_Txt}


Storage_Report_CSV_File=/mnt/mail_report_project/storage_report_dir/Storage_report_${Date}.csv
sed -i '1d' ${Storage_Report_CSV_File}
sed -i 's/\r//g' ${Storage_Report_CSV_File}
sed -i 's/,/ /g' ${Storage_Report_CSV_File}

Commer_Cooper="/ifs/data1/bioinfo/PROJECT/Commercial/Cooperation"
RD_Cooper="/ifs/data1/bioinfo/PROJECT/RD/Cooperation"

Commer_Medical="/ifs/data1/bioinfo/PROJECT/Commercial/Medical"
RD_Medical="/ifs/data1/bioinfo/PROJECT/RD/Medical"
#肿瘤项目目录数组
Tumor_Project=("${RD_Medical}/cancerResearch" "${RD_Medical}/Leukemia" "${Commer_Medical}/Leukemia" "${RD_Medical}/ProjectsStatistics" \
"${RD_Medical}/tmp" "/ifs/data1/fqdata/data2016/cancer" "/ifs/data1/fqdata/cancer" "/ifs/data1/cancer_download")

#生育生殖项目目录数组
Fertility_Project=("${Commer_Medical}/AT" "${Commer_Medical}/MD" "${Commer_Medical}/GT" "${Commer_Medical}/PD" "${Commer_Medical}/PG" \
"${Commer_Medical}/PGS" "${RD_Medical}/MD" "${RD_Medical}/PD" "/ifs/data1/fqdata/data2016/pd" "/ifs/data1/fqdata/pd")

#科技服务项目目录数组
Technology_Project=("/ifs/data1/bakPROJECT" "/ifs/data1/oss_download" "/ifs/data1/bioinfo/PMO" "${Commer_Cooper}/AP" "${Commer_Cooper}/DNA" \
"${Commer_Cooper}/EPI" "${Commer_Cooper}/Filter" "${Commer_Cooper}/Hic" "${Commer_Cooper}/Medical" "${Commer_Cooper}/Mic" "${Commer_Cooper}/Other" \
"${Commer_Cooper}/PAG" "${Commer_Cooper}/QC" "${Commer_Cooper}/RNA" "${Commer_Cooper}/SinCell" "${Commer_Cooper}/Stat" "${RD_Cooper}/AP" \
"${RD_Cooper}/Database" "${RD_Cooper}/DNA" "${RD_Cooper}/EPI" "${RD_Cooper}/Hic" "${RD_Cooper}/Medical" "${RD_Cooper}/Mic" "${RD_Cooper}/Other" \
"${RD_Cooper}/PAG" "${RD_Cooper}/QC" "${RD_Cooper}/RNA" "${RD_Cooper}/SinCell" "${RD_Cooper}/Proteomics"  "/ifs/data1/fqdata/data2016/sci" \
"/ifs/data1/bioinfo/PROJECT/RD/Pipeline_test" "/ifs/data1/fqdata/sci")

#declare -a Tumor_Project_Used_Size
#declare -a Fertility_Project_Used_Size
#declare -a Technology_Project_Used_Size

Data_File_PATH="/mnt/mail_report_project/storage_report_dir/"
Tumor_Project_Data_Total_File="${Data_File_PATH}/Tumor_Project_Data_Total_${Date}.txt"
Tumor_Project_Data_Used_File="${Data_File_PATH}/Tumor_Project_Data_Used_${Date}.txt"
Fertility_Project_Data_Total_File="${Data_File_PATH}/Fertility_Project_Data_Total_${Date}.txt"
Fertility_Project_Data_Used_File="${Data_File_PATH}/Fertility_Project_Data_Used_${Date}.txt"
Technology_Project_Data_Total_File="${Data_File_PATH}/Technology_Project_Data_Total_${Date}.txt"
Technology_Project_Data_Used_File="${Data_File_PATH}/Technology_Project_Data_Used_${Date}.txt"


for Data_Dir_Name in `awk -F " " '{print $1}' ${Storage_Report_CSV_File}`
do
        Data_Dir_Used=`grep "${Data_Dir_Name}" ${Storage_Report_CSV_File}|awk -F " " '{print $2}'`
        Data_Dir_Total=`grep "${Data_Dir_Name}" ${Storage_Report_CSV_File}|awk -F " " '{print $3}'`
        #echo ${Data_Dir_Name}
        #echo ${Data_Dir_Used}
        #echo ${#Data_Dir_Used}
        Data_Dir_Used_Unit=`echo ${Data_Dir_Used:0-1:1}`
        Data_Dir_Used_Value=`echo ${Data_Dir_Used%%[a-zA-Z]*}`
        #echo ${Data_Dir_Used_Unit}

        #echo ${Data_Dir_Total}
        #echo ${#Data_Dir_Total}
        #Data_Dir_Total_Unit=${Data_Dir_Total:$Index:1}
        Data_Dir_Total_Unit=`echo ${Data_Dir_Total:0-1:1}`
        Data_Dir_Total_Value=`echo ${Data_Dir_Total%%[a-zA-Z]*}`
        #echo ${Data_Dir_Total_Unit}
        #echo -e "\n"

        if [ "${Data_Dir_Used_Unit}" = "T" ]
        then
                Data_Dir_Used_Value=`echo "scale=4; ${Data_Dir_Used_Value}*1024"|bc`
        elif [ "${Data_Dir_Used_Unit}" = "M" ]
        then
                Data_Dir_Used_Value=`echo "scale=4; ${Data_Dir_Used_Value}/1024"|bc`
        elif [ "${Data_Dir_Used_Unit}" = "k" ]
        then
                Data_Dir_Used_Value=`echo "scale=4; ${Data_Dir_Used_Value}/1048576"|bc`
	else 
		Data_Dir_Used_Unit="k"
        fi

        if [ "${Data_Dir_Total_Unit}" = "T" ]
        then
                Data_Dir_Total_Value=`echo "scale=4; ${Data_Dir_Total_Value}*1024"|bc`
        elif [ "${Data_Dir_Total_Unit}" = "M" ]
        then
                Data_Dir_Total_Value=`echo "scale=4; ${Data_Dir_Total_Value}/1024"|bc`
        fi

        #echo ${Data_Dir_Used_Value}
        #echo ${Data_Dir_Total_Value}


        for x in ${Tumor_Project[@]}
        do
                #echo ${x}
                if [ "${x}" = "${Data_Dir_Name}" ]
                then
                        #echo "${x}" >> ${Tumor_Project_Data_Total_File}
                        echo "${Data_Dir_Total_Value}" >> ${Tumor_Project_Data_Total_File}
                        #echo "${x}" >> ${Tumor_Project_Data_Used_File}
                        echo "${Data_Dir_Used_Value}" >> ${Tumor_Project_Data_Used_File}
                fi
        done


        for y in ${Fertility_Project[@]}
        do
                if [ "${y}" = "${Data_Dir_Name}" ]
                then
                        #echo "${y}" >> ${Fertility_Project_Data_Total_File}
                        echo "${Data_Dir_Total_Value}" >> ${Fertility_Project_Data_Total_File}
                        #echo "${y}" >> ${Fertility_Project_Data_Used_File}
                        echo "${Data_Dir_Used_Value}" >> ${Fertility_Project_Data_Used_File}
                fi
        done


        for z in ${Technology_Project[@]}
        do
                if [ "${z}" = "${Data_Dir_Name}" ]
                then
                        #echo "${z}" >> ${Technology_Project_Data_Total_File}
                        echo "${Data_Dir_Total_Value}" >> ${Technology_Project_Data_Total_File}
                        #echo "${z}" >> ${Technology_Project_Data_Used_File}
                        echo "${Data_Dir_Used_Value}" >> ${Technology_Project_Data_Used_File}
                fi
        done
done


Tumor_Project_Total_Size_GB=`awk 'BEGIN{total=0}{total+=$1}END{printf ("%.2f\n",total)}' ${Tumor_Project_Data_Total_File}`
Tumor_Project_Total_Size_TB=`echo "scale=2; ${Tumor_Project_Total_Size_GB}/1024"|bc`
Tumor_Project_Used_Size_GB=`awk 'BEGIN{total=0}{total+=$1}END{printf ("%.2f\n",total)}' ${Tumor_Project_Data_Used_File}`
Tumor_Project_Used_Size_TB=`echo "scale=2; ${Tumor_Project_Used_Size_GB}/1024"|bc`
Tumor_Project_Used_Percentage=`echo "scale=2; ${Tumor_Project_Used_Size_GB} * 100/${Tumor_Project_Total_Size_GB}"|bc`

Fertility_Project_Total_Size_GB=`awk 'BEGIN{total=0}{total+=$1}END{printf ("%.2f\n",total)}' ${Fertility_Project_Data_Total_File}`
Fertility_Project_Total_Size_TB=`echo "scale=2; ${Fertility_Project_Total_Size_GB}/1024"|bc`
Fertility_Project_Used_Size_GB=`awk 'BEGIN{total=0}{total+=$1}END{printf ("%.2f\n",total)}' ${Fertility_Project_Data_Used_File}`
Fertility_Project_Used_Size_TB=`echo "scale=2; ${Fertility_Project_Used_Size_GB}/1024"|bc`
Fertility_Project_Used_Percentage=`echo "scale=2; ${Fertility_Project_Used_Size_GB} * 100/${Fertility_Project_Total_Size_GB}"|bc`


Technology_Project_Total_Size_GB=`awk 'BEGIN{total=0}{total+=$1}END{printf ("%.2f\n",total)}' ${Technology_Project_Data_Total_File}`
Technology_Project_Total_Size_TB=`echo "scale=2; ${Technology_Project_Total_Size_GB}/1024"|bc`
Technology_Project_Used_Size_GB=`awk 'BEGIN{total=0}{total+=$1}END{printf ("%.2f\n",total)}' ${Technology_Project_Data_Used_File}`
Technology_Project_Used_Size_TB=`echo "scale=2; ${Technology_Project_Used_Size_GB}/1024"|bc`
Technology_Project_Used_Percentage=`echo "scale=2; ${Technology_Project_Used_Size_GB} * 100/${Technology_Project_Total_Size_GB}"|bc`

#echo "Tumor_Project_Data_Total_GB: ${Tumor_Project_Total_Size_GB}GB"
#echo "Tumor_Project_Data_Total_TB: ${Tumor_Project_Total_Size_TB}TB"
#echo "Tumor_Project_Data_Used_GB: ${Tumor_Project_Used_Size_GB}GB"
#echo "Tumor_Project_Data_Used_TB: ${Tumor_Project_Used_Size_TB}TB"
#echo "Tumor_Project_Used_Percentage: ${Tumor_Project_Used_Percentage}"

#echo "Fertility_Project_Data_Total_GB: ${Fertility_Project_Total_Size_GB}GB"
#echo "Fertility_Project_Data_Total_TB: ${Fertility_Project_Total_Size_TB}TB"
#echo "Fertility_Project_Data_Used_GB: ${Fertility_Project_Used_Size_GB}GB"
#echo "Fertility_Project_Data_Used_TB: ${Fertility_Project_Used_Size_TB}TB"
#echo "Fertility_Project_Used_Percentage: ${Fertility_Project_Used_Percentage}"

#echo "Technology_Project_Data_Total_GB: ${Technology_Project_Total_Size_GB}GB"
#echo "Technology_Project_Data_Total_TB: ${Technology_Project_Total_Size_TB}TB"
#echo "Technology_Project_Data_Used_GB: ${Technology_Project_Used_Size_GB}GB"
#echo "Technology_Project_Data_Used_TB: ${Technology_Project_Used_Size_TB}TB"
#echo "Technology_Project_Used_Percentage: ${Technology_Project_Used_Percentage}"
echo -e "\n" >> ${Storage_Report_Txt}
echo "    3.各部门存储使用情况如下：" >> ${Storage_Report_Txt}
echo "    ===========集群目录配额使用信息============" >> ${Storage_Report_Txt}
echo "    部门              已使用(TB)        总配额(TB)        使用率(%)" >> ${Storage_Report_Txt}
echo "    科技服务        ${Technology_Project_Used_Size_TB}             ${Technology_Project_Total_Size_TB}            ${Technology_Project_Used_Percentage}" >> ${Storage_Report_Txt}
echo "    生育生殖        ${Fertility_Project_Used_Size_TB}             ${Fertility_Project_Total_Size_TB}              ${Fertility_Project_Used_Percentage}" >> ${Storage_Report_Txt}
echo "    肿瘤               ${Tumor_Project_Used_Size_TB}             ${Tumor_Project_Total_Size_TB}              ${Tumor_Project_Used_Percentage}" >> ${Storage_Report_Txt}
echo -e "\n" >> ${Storage_Report_Txt}
echo "    4.IT中心-系统部已对各部门配额目录做了扫描，请各部门查阅邮件附件，进行相关目录数据清理工作，" >> ${Storage_Report_Txt}
echo "      有需要转移至OSS存储的数据，请提供转移目录。" >> ${Storage_Report_Txt}

#mailx -v -s "存储使用报告" -a ${Storage_Report_CSV_File} -c "guiyang@annoroad.com gjkdhr@163.com wenmingxu@annoroad.com zhiyuancheng@annoroad.com zexinli@annoroad.com hongangu@annoroad.com jingzhang@annoroad.com" jingkunguo@annoroad.com < ${Storage_Report_Txt}
#mailx -v -s "存储使用报告" -a ${Storage_Report_CSV_File} -c "guiyang@annoroad.com gjkdhr@163.com" jingkunguo@annoroad.com < ${Storage_Report_Txt}
