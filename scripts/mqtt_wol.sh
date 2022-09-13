#!/bin/bash

ARRAY_USERS=("yfgg001" \
                "yfgg002" \
                "yfgg003" \
                "yfgg004" \
                "yfgg005" \
                "yfgg006");
ARRAY_MACS=("F4:39:09:26:80:8F" \
                "40:B0:34:3E:23:09" \
                "40:B0:34:38:6E:21" \
                "40:B0:34:40:C5:0E" \
                "2C:F0:5D:A1:13:42" \
                "D8:BB:C1:DC:5D:BB");

mqtt_file="/tmp/mqtt.log";
wol_file="/tmp/wol.log";

len_users=${#ARRAY_USERS[*]}
i=0

echo Start `date` > $mqtt_file
echo Start `date` > $wol_file

nohup mosquitto_sub -h 192.168.10.1 -p 61883 -u admin -P password -t wol >> $mqtt_file &

tail -fn0 $mqtt_file | \
while read line ; do
        echo `date` >> $wol_file
        echo "$line" >> $wol_file
        i=0
        while [ $i -lt $len_users ]
        do
                if [ "$line" = ${ARRAY_USERS[i]} ]
                then
                        etherwake -i br-lan ${ARRAY_MACS[i]};echo woke up ${ARRAY_MACS[i]} >> $wol_file &
                fi
        let i++
        done
done
