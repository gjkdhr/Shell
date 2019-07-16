#!/bin/bash
#APPID值
APPID=4.00010
echo "APPID=${APPID}"
#数据库无登录连接
Mysql_Connect="mysql --defaults-extra-file=/tmp/.mysql_password.txt -se"
echo "Mysql_Connect=${Mysql_Connect}"
#查询Appid表的值
Select_Appid_Table="FROM TESConfig.Appid WHERE APPID='${APPID}'"
echo "Select_Appid_Table=${Select_Appid_Table}"

#查询Base表的值
Server_IP=`${Mysql_Connect} "SELECT Server_IP ${Select_Appid_Table}"|tail -n 1`
echo "Server_IP=${Server_IP}"
Select_Base_Table="FROM TESConfig.Base WHERE Server_IP='${Server_IP}';"
ID=`${Mysql_Connect} "SELECT Service_Config ${Select_Base_Table}"|tail -n 1`

#查询Service表的值
#Service_Config=`${Mysql_Connect} "${Select_Base_Table}"|tail -n 1|awk '{print $NF}'`
echo "ID=${ID}"
#echo "Service_Config=${Service_Config}"
Select_Service_Table="FROM TESConfig.Service WHERE ID='${ID}';"


#TES/mtsconfig.xml配置文件;
#获取ACC配置地址
ACC_URL=`${Mysql_Connect} "SELECT ACC_URL ${Select_Base_Table}"|tail -n 1`
echo "ACC_URL=${ACC_URL}"

#获取BatchFlag值,BatchFlag1为启动时自动创建CreateNum个机器人的标志;当值为1时,CreateNum值生效;当值为2时,CreateNum值失效;
BatchFlag=`${Mysql_Connect} "SELECT BatchFlag ${Select_Base_Table}"|tail -n 1`
echo "BatchFlag=${BatchFlag}"

#获取CreateNum的值,该值表示初始化创建的机器人个数;
CreateNum=`${Mysql_Connect} "SELECT CreateNum ${Select_Base_Table}"|tail -n 1`
echo "CreateNum=${CreateNum}"

#获取RobotIdDB_IP的值,RobotId连接的数据库IP地址
RobotIdDB_IP=`${Mysql_Connect} "SELECT RobotIdDB_IP ${Select_Base_Table}"|tail -n 1`
echo "RobotIdDB_IP=${RobotIdDB_IP}"

#获取RobotIdDB_DBname的值,RobotId连接的数据库名
RobotIdDB_DBname=`${Mysql_Connect} "SELECT RobotIdDB_DBname ${Select_Base_Table}"|tail -n 1`
echo "RobotIdDB_DBname=${RobotIdDB_DBname}"

#获取RobotIdDB_User的值,RobotId连接的数据库的用户
RobotIdDB_User=`${Mysql_Connect} "SELECT RobotIdDB_User ${Select_Base_Table}"|tail -n 1`
echo "RobotIdDB_User=${RobotIdDB_User}"

#获取RobotIdDB_Password的值,RobotId连接的数据库的密码
RobotIdDB_Password=`${Mysql_Connect} "SELECT RobotIdDB_Password ${Select_Base_Table}"|tail -n 1`
echo "RobotIdDB_Password=${RobotIdDB_Password}"

#获取ProjectDB_IP的值,项目数据库连接的IP;
ProjectDB_IP=`${Mysql_Connect} "SELECT ProjectDB_IP ${Select_Base_Table}"|tail -n 1`
echo "ProjectDB_IP=${ProjectDB_IP}"

#获取ProjectDB_DBname的值,项目数据库名;
ProjectDB_DBname=`${Mysql_Connect} "SELECT ProjectDB_DBname ${Select_Base_Table}"|tail -n 1`
echo "ProjectDB_DBname=${ProjectDB_DBname}"

#获取ProjectDB_User的值,项目数据库连接的用户名;
ProjectDB_User=`${Mysql_Connect} "SELECT ProjectDB_User ${Select_Base_Table}"|tail -n 1`
echo "ProjectDB_User=${ProjectDB_User}"

#获取ProjectDB_Password的值,项目数据库连接的密码;
ProjectDB_Password=`${Mysql_Connect} "SELECT ProjectDB_Password ${Select_Base_Table}"|tail -n 1`
echo "ProjectDB_Password=${ProjectDB_Password}"

#获取Redis_IP的值,redis的连接IP地址
Redis_IP=`${Mysql_Connect} "SELECT Redis_IP ${Select_Base_Table}"|tail -n 1`
echo "Redis_IP=${Redis_IP}"

#获取Redis_Port的值,redis集群可用的端口
Redis_Port=`${Mysql_Connect} "SELECT Redis_Port ${Select_Base_Table}"|tail -n 1`
echo "Redis_Port=${Redis_Port}"

#获取Redis_Password的值,redis集群连接的密码
Redis_Password=`${Mysql_Connect} "SELECT Redis_Password ${Select_Base_Table}"|tail -n 1`
echo "Redis_Password=${Redis_Password}"



#配置TES/tes/config/TESConfig.ini文件
#获取ISOPEN的值,第三方应答配置;0表示关闭,1表示开启;
ISOPEN=`${Mysql_Connect} "SELECT ISOPEN ${Select_Service_Table}"|tail -n 1`
echo "ISOPEN=${ISOPEN}"

#获取ThirdPartyChoice的值,配置第三方接口的信息;目前的值可能为三种:"Tencent","ZhuJian","Tencent|ZhuJian"
ThirdPartyChoice=`${Mysql_Connect} "SELECT ThirdPartyChoice ${Select_Service_Table}"|tail -n 1`
echo "ThirdPartyChoice=${ThirdPartyChoice}"

#获取ActiveLearning的值;主动学习开关,0表示关闭 1表示开启
ActiveLearning=`${Mysql_Connect} "SELECT ActiveLearning ${Select_Service_Table}"|tail -n 1`
echo "ActiveLearning=${ActiveLearning}"

#获取CLI_ON_CAMERA_TIME的值,用户在镜头前的配置时间;
CLI_ON_CAMERA_TIME=`${Mysql_Connect} "SELECT CLI_ON_CAMERA_TIME ${Select_Service_Table}"|tail -n 1`
echo "CLI_ON_CAMERA_TIME=${CLI_ON_CAMERA_TIME}"

#获取SVarTimeOut的值,该值表示s变元超时时长设置,单位为s;
SVarTimeOut=`${Mysql_Connect} "SELECT SVarTimeOut ${Select_Service_Table}"|tail -n 1`
echo "SVarTimeOut=${SVarTimeOut}"






#配置TES/topicManager.xml文件;
#获取listenTime的值,设置的听的超时时间
AE_listenTime=`${Mysql_Connect} "SELECT AE_listenTime ${Select_Service_Table}"|tail -n 1`
echo "AE_listenTime=${AE_listenTime}"

#获取expressTime的值,设置表达的超时时间
AE_expressTime=`${Mysql_Connect} "SELECT AE_expressTime ${Select_Service_Table}"|tail -n 1`
echo "AE_expressTime=${AE_expressTime}"



#获取ExpressControl中，需要添加的表达控制项目的行数;
EC_Rows=`${Mysql_Connect} "SELECT count(*) FROM TESConfig.Appid WHERE Server_IP='${Server_IP}';"|tail -n 1`
echo "EC_Rows=${EC_Rows}"

#获取所有匹配ExpressControl的Mark值,并放入数组Index中;
Mark=`${Mysql_Connect} "SELECT Mark from TESConfig.Appid WHERE Server_IP='${Server_IP}';"|grep -v Mark`
echo "Mark=${#Mark[*]}"

gjkdhr=();
for((i=0;i<${EC_Rows};i++));
do
	val=`echo "${i}+1"|bc`
	gjkdhr[${i}]=`echo $Mark|cut -d " " -f ${val}`
	echo "gjkdhr[${i}]=${gjkdhr[${i}]}"
done
echo "gjkdhr array length=${#gjkdhr[@]}"

#在配置文件topicManager.xml中添加{EC_Rows}行有关rule规则配置,并将gjkdhr[${i}]获取的Mark字段的值放进去;
#获取<rule appid="1.00001" offline="300" duration="60" />示例配置的行数;
Match_Line_Num=`grep -n appid=\"1\.00001\" topicManager.xml|awk -F ":" '{print $1}'`
echo "Match_Line_Num=${Match_Line_Num}"

#添加规则模板;
echo -e "\t<rule appid=\"1.00001\" offline=\"300\" duration=\"60\" />"

for((i=0;i<${EC_Rows};i++));
do
        Rule[${i}]=`echo -e "\t<rule appid=\"{{ appid_index_${gjkdhr[${i}]} }}\" offline=\"{{ offline_index_${gjkdhr[${i}]} }}\" duration=\"{{ duration_index_${gjkdhr[${i}]} }}\" />"`
	echo "Rule[${i}]=${Rule[${i}]}"
	sed -i "N; ${Match_Line_Num} a\ ${Rule[${i}]}" topicManager.xml
done

#获取topicManager.xml模板中的值;
for((i=0;i<${EC_Rows};i++));
do
	APPID_Value=`${Mysql_Connect} "SELECT APPID FROM TESConfig.Appid WHERE Mark='${gjkdhr[${i}]}'"|tail -n 1`
	echo "appid_index_${gjkdhr[${i}]}=${APPID_Value}"
	Offline_Value=`${Mysql_Connect} "SELECT ExpressControl_Offline ${Select_Appid_Table}"|tail -n 1`
	echo "offline_index_${gjkdhr[${i}]}=${Offline_Value}"
	Duration_Value=`${Mysql_Connect} "SELECT ExpressControl_Duration ${Select_Appid_Table}"|tail -n 1`
	echo "duration_index_${gjkdhr[${i}]}=${Duration_Value}"
done



#获取TES/config/services/T_sender/T_sender.json文件的配置信息;
#获取T_Sender_Model的值,就是发送速度模式;0表示每个用户的主动思维时间间隔是固定的,1表示定时定量的发送主动思维;
T_Sender_Model=`${Mysql_Connect} "SELECT T_Sender_Model ${Select_Service_Table}"|tail -n 1`
echo "T_Sender_Model=${T_Sender_Model}"

#获取T_Sender_Interval的值,该值表示每个用户的主动思维的间隔时间;单位为秒;
T_Sender_Interval=`${Mysql_Connect} "SELECT T_Sender_Interval ${Select_Service_Table}"|tail -n 1`
echo "T_Sender_Interval=${T_Sender_Interval}"

#获取T_Sender_Batch的值,该值表示每个用户的主动思维的批次;
T_Sender_Batch=`${Mysql_Connect} "SELECT T_Sender_Batch ${Select_Service_Table}"|tail -n 1`
echo "T_Sender_Batch=${T_Sender_Batch}"

#获取T_Sender_Num的值,设置主动思维每秒发送用户数
T_Sender_Num=`${Mysql_Connect} "SELECT T_Sender_Num ${Select_Service_Table}"|tail -n 1`
echo "T_Sender_Num=${T_Sender_Num}"

#获取T_Sender_Status的值,主动思维是否设置有效时长，默认为0:1为开启设置，0为关闭设置
T_Sender_Status=`${Mysql_Connect} "SELECT T_Sender_Status ${Select_Service_Table}"|tail -n 1`
echo "T_Sender_Status=${T_Sender_Status}"


#获取每个APPID的T_Sender_Duration的值,并写入到T_sender.json文件中;
#获取匹配行{"appid":"1.00002","duration":300}的行数;
Match_Tsender_Num=`grep -En '\{\"appid\"' T_sender.json |awk -F ":" '{print $1}'`
echo "Match_Tsender_Num=${Match_Tsender_Num}"

#添加规则模板
echo -e "{\"appid\":\"1.00002\",\"duration\":300}"
for((i=0;i<${EC_Rows};i++));
do
        Tsender[${i}]=`echo -e "{\"appid\":\"{{ appid_index_${gjkdhr[${i}]} }}\",\"duration\":{{ tsender_duration_index_${gjkdhr[${i}]} }}}"`
        echo "Tsender[${i}]=${Tsender[${i}]}"
        sed -i "N; ${Match_Tsender_Num} a\ ${Tsender[${i}]}" T_sender.json
done


#获取T_sender.json模板中的值;
for((i=0;i<${EC_Rows};i++));
do
        APPID_Value=`${Mysql_Connect} "SELECT APPID FROM TESConfig.Appid WHERE Mark='${gjkdhr[${i}]}'"|tail -n 1`
        echo "appid_index_${gjkdhr[${i}]}=${APPID_Value}"
        Tsender_Duration_Value=`${Mysql_Connect} "SELECT T_Sender_Duration FROM TESConfig.Appid WHERE Mark='${gjkdhr[${i}]}'"|tail -n 1`
        echo "tsender_duration_index_${gjkdhr[${i}]}=${Tsender_Duration_Value}"
done


