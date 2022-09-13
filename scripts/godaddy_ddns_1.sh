#!/bin/bash


# Key
# dLPDHFvqYw1i_YKnYKGZ53ib9xrNS3etjQj
# Secret
# 2fjNuDPKj7RnrYbDS9uNrP

api_url="https://api.godaddy.com/v1/domains";
mydomain="pandavon.com";
myhostname="app";
ARRAY_INT=("pppoe-WAN1" "pppoe-WAN2" "pppoe-WAN3");
ARRAY_HOST_NAME=(); #"app0" "app1" "app2" ...
ARRAY_HOST_IP=();

gdapikey="dLPDHFvqYw1i_YKnYKGZ53ib9xrNS3etjQj:2fjNuDPKj7RnrYbDS9uNrP"

log_done="get $myhostname.$mydomain done!"
log_none="get $myhostname.$mydomain none!"
log_err="get $myhostname.$mydomain error!"
log_file=/tmp/ddns_log

# 入参检查
echo param num = $#

if [ $# == 3 ]; then
        myhostname=$1
        mydomain=$2
        api_url=$3
elif [ $# == 2 ]; then
        myhostname=$1
        mydomain=$2
elif [ $# == 1 ]; then
        myhostname=$1
fi

# 取DNS
dns_get_cmd="curl --connect-timeout 10 -s -X GET -H \"Authorization: sso-key ${gdapikey}\" \"${api_url}/${mydomain}/records/A/${myhostname}\""
echo $dns_get_cmd
dnsdata=`curl --connect-timeout 10 -s -X GET -H "Authorization: sso-key ${gdapikey}" "${api_url}/${mydomain}/records/A/${myhostname}0"`
#app1_ip=`echo $dnsdata | cut -d ',' -f 1 | tr -d '"' | cut -d ":" -f 2-9`

echo dnsdata=$dnsdata ;


if [ "$dnsdata" =  "" ]; then
        echo $log_none;
        echo $log_none > $log_file;
else
#       len_app1_ip=${#app1_ip}
#       if [  $app1_ip == "[]" ]; then
#               echo $log_none
#               echo $log_none > $log_file;
#               exit 0
#       else
#               echo ${myhostname}.${mydomain}=$app1_ip len_app1_ip=${len_app1_ip}
#               echo $log_done > $log_file;
#       fi
        echo $log_done;
        echo $log_done > $log_file;
        echo $dnsdata >> $log_file;
fi
echo `date` >> $log_file;

# 获取本地端口IP

len_array_int=${#ARRAY_INT[*]}
i=0
while [ $i -lt $len_array_int ]
do
        # to do
        echo [${ARRAY_INT[i]}] "IP:";
        #echo `/sbin/ifconfig ${ARRAY_INT[i]}|sed -n '/inet addr/s/^[^:]*:\([0-9.]\{7,15\}\) .*/\1/p'`
        ARRAY_HOST_IP[i]=`/sbin/ifconfig ${ARRAY_INT[i]}|sed -n '/inet addr/s/^[^:]*:\([0-9.]\{7,15\}\) .*/\1/p'`
        ARRAY_HOST_NAME[i]="${myhostname}"${i};
        echo [${ARRAY_HOST_IP[i]}]  "==>" [${ARRAY_HOST_NAME[i]}.$mydomain];

        dns_set_cmd="curl --connect-timeout 10 -s -X PUT \"${api_url}/${mydomain}/records/A/${ARRAY_HOST_NAME[i]}\" -H \"Authorization: sso-key ${gdapikey}\" -H \"Content-Type: application/json\" -d \"[{\\\"data\\\": \\\"${ARRAY_HOST_IP[i]}\\\"}]\""
        echo $dns_set_cmd;
        echo $dns_set_cmd >> $log_file;
        echo `date` >> $log_file;
        curl --connect-timeout 10 -s -X PUT "${api_url}/${mydomain}/records/A/${ARRAY_HOST_NAME[i]}" -H "Authorization: sso-key ${gdapikey}" -H "Content-Type: application/json" -d "[{\"data\": \"${ARRAY_HOST_IP[i]}\"}]"
let i++
done


#local_ip=`/sbin/ifconfig|sed -n '/inet addr/s/^[^:]*:\([0-9.]\{7,15\}\) .*/\1/p'`

#echo ${local_ip}


# ARRAY
#ARRAY_IP=(${local_ip})
#len_array_ip=${#ARRAY_IP[*]}
#i=0
# while [ $i -lt $len_array_ip ]
# do
# echo ${ARRAY_IP[$i]}
# # to do

# let i++
# done


#echo "`date '+%Y-%m-%d %H:%M:%S'` - Current External IP is GoDaddy DNS IP is $app1_ip"

