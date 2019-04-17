#!/bin/bash

Tumor_Project_Total_Size_GB=189132.90
Tumor_Project_Total_Size_TB=189132.90
Tumor_Project_Used_Size_GB=140.67
Tumor_Project_Used_Size_TB=140.67
Tumor_Project_Used_Percentage=76.16
Fertility_Project_Total_Size_GB=186873.00
Fertility_Project_Total_Size_TB=182.49
Fertility_Project_Used_Size_GB=131780.68
Fertility_Project_Used_Size_TB=128.69
Fertility_Project_Used_Percentage=70.51
Technology_Project_Total_Size_GB=1025590.00
Technology_Project_Total_Size_TB=1001.55
Technology_Project_Used_Size_GB=662235.34
Technology_Project_Used_Size_TB=646.71
Technology_Project_Used_Percentage=64.57

echo "    3.各部门存储使用情况如下：" >> storage_report`date +%Y%m%d`.txt
echo "    ===========集群目录配额使用信息============" >> storage_report`date +%Y%m%d`.txt
echo "    部门              已使用(TB)        总配额(TB)        使用率(%)" >> storage_report`date +%Y%m%d`.txt
echo "    科技服务        ${Technology_Project_Used_Size_TB}             ${Technology_Project_Total_Size_TB}            ${Technology_Project_Used_Percentage}" >> storage_report`date +%Y%m%d`.txt
echo "    生育生殖        ${Fertility_Project_Used_Size_TB}             ${Fertility_Project_Total_Size_TB}              ${Fertility_Project_Used_Percentage}" >> storage_report`date +%Y%m%d`.txt
echo "    肿瘤              ${Tumor_Project_Used_Size_TB}             ${Tumor_Project_Total_Size_TB}        ${Tumor_Project_Used_Percentage}" >> storage_report`date +%Y%m%d`.txt
echo -e "\n" >> storage_report`date +%Y%m%d`.txt
echo "    4.IT中心-系统部已对各部门配额目录做了扫描，请各部门查阅邮件附件，进行相关目录数据清理工作，" >> storage_report`date +%Y%m%d`.txt
echo "      有需要转移至OSS存储的数据，请提供转移目录。" >> storage_report`date +%Y%m%d`.txt

mailx -v -s "存储使用报告"  -c "guiyang@annoroad.com gjkdhr@163.com" jingkunguo@annoroad.com < /mnt/mail_report_project/mail_format/storage_report`date +%Y%m%d`.txt
