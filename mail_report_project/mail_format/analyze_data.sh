#!/bin/bash

Date1=`date +%Y%m%d`
Storage_Report_CSV_File=/mnt/mail_report_dir/storage_report_dir/Storage_report_${Date1}.csv

#sed -i 's/ ,/ /g' ${Storage_Report_CSV_File}
#sed -i '1d' ${Storage_Report_CSV_File}

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

Data_File_PATH="/mnt/mail_report_dir/storage_report_dir/"
Tumor_Project_Data_Total_File="${Data_File_PATH}/Tumor_Project_Data_Total_${Date1}.txt"
Tumor_Project_Data_Used_File="${Data_File_PATH}/Tumor_Project_Data_Used_${Date1}.txt"
Fertility_Project_Data_Total_File="${Data_File_PATH}/Fertility_Project_Data_Total_${Date1}.txt"
Fertility_Project_Data_Used_File="${Data_File_PATH}/Fertility_Project_Data_Used_${Date1}.txt"
Technology_Project_Data_Total_File="${Data_File_PATH}/Technology_Project_Data_Total_${Date1}.txt"
Technology_Project_Data_Used_File="${Data_File_PATH}/Technology_Project_Data_Used_${Date1}.txt"

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
	else
		Data_Dir_Total_Unit="G"
	fi
	
	#echo ${Data_Dir_Used_Value}
	#echo ${Data_Dir_Total_Value}
	

	for x in ${Tumor_Project[@]}
	do
		#echo ${x}
		if [ "${x}" = "${Data_Dir_Name}" ]
		then
			echo "${x}" >> ${Tumor_Project_Data_Total_File}
			echo "${Data_Dir_Total_Value}" >> ${Tumor_Project_Data_Total_File}
			echo "${x}" >> ${Tumor_Project_Data_Used_File}
			echo "${Data_Dir_Used_Value}" >> ${Tumor_Project_Data_Used_File}
		fi
	done

	for y in ${Fertility_Project[@]}
	do
		if [ "${y}" = "${Data_Dir_Name}" ]
		then
			echo "${y}" >> ${Fertility_Project_Data_Total_File}
			echo "${Data_Dir_Total_Value}" >> ${Fertility_Project_Data_Total_File}
			echo "${y}" >> ${Fertility_Project_Data_Used_File}
			echo "${Data_Dir_Used_Value}" >> ${Fertility_Project_Data_Used_File}
		fi
	done

	for z in ${Technology_Project[@]}
	do
		if [ "${z}" = "${Data_Dir_Name}" ]
		then
			echo "${z}" >> ${Technology_Project_Data_Total_File}
			echo "${Data_Dir_Total_Value}" >> ${Technology_Project_Data_Total_File}
			echo "${z}" >> ${Technology_Project_Data_Used_File}
			echo "${Data_Dir_Used_Value}" >> ${Technology_Project_Data_Used_File}
		fi
	done

done	

Tumor_Project_Total_Size=`awk 'BEGIN{total=0}{total+=$1}END{printf ("%.2f\n",total)}' ${Tumor_Project_Data_Total_File}`
Tumor_Project_Used_Size=`awk 'BEGIN{total=0}{total+=$1}END{printf ("%.2f\n",total)}' ${Tumor_Project_Data_Used_File}`
Tumor_Project_Used_Percentage=`echo "scale=4; ${Tumor_Project_Used_Size}/${Tumor_Project_Total_Size}"|bc`

Fertility_Project_Total_Size=`awk 'BEGIN{total=0}{total+=$1}END{printf ("%.2f\n",total)}' ${Fertility_Project_Data_Total_File}`
Fertility_Project_Used_Size=`awk 'BEGIN{total=0}{total+=$1}END{printf ("%.2f\n",total)}' ${Fertility_Project_Data_Used_File}`
Fertility_Project_Used_Percentage=`echo "scale=4; ${Fertility_Project_Used_Size}/${Fertility_Project_Total_Size}"|bc`


Technology_Project_Total_Size=`awk 'BEGIN{total=0}{total+=$1}END{printf ("%.2f\n",total)}' ${Technology_Project_Data_Total_File}`
Technology_Project_Used_Size=`awk 'BEGIN{total=0}{total+=$1}END{printf ("%.2f\n",total)}' ${Technology_Project_Data_Used_File}`
Technology_Project_Used_Percentage=`echo "scale=4; ${Technology_Project_Used_Size}/${Technology_Project_Total_Size}"|bc`

echo "Tumor_Project_Data_Total_File=${Tumor_Project_Total_Size}GB"
echo "Tumor_Project_Data_Used_File=${Tumor_Project_Used_Size}GB"
echo "Tumor_Project_Used_Percentage=${Tumor_Project_Used_Percentage}"

echo "Fertility_Project_Data_Total_File=${Fertility_Project_Total_Size}GB"
echo "Fertility_Project_Data_Used_File=${Fertility_Project_Used_Size}GB"
echo "Fertility_Project_Used_Percentage=${Fertility_Project_Used_Percentage}"

echo "Technology_Project_Data_Total_File=${Technology_Project_Total_Size}GB"
echo "Technology_Project_Data_Used_Size=${Technology_Project_Used_Size}GB"
echo "Technology_Project_Used_Percentage=${Technology_Project_Used_Percentage}"



















