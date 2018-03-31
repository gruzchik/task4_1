#!/bin/bash

SCRIPT_PWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo '--- Hardware ---' | tee ${SCRIPT_PWD}/task4_1.out

CPU=$(cat /proc/cpuinfo  | grep "model \name" | uniq -c | awk -F":" {' print $2'})
TRIM_CPU=$(echo ${CPU} | sed 's/^[ \t]*//;s/[ \t]*$//') # removing initial spaces
echo -e "CPU: ${TRIM_CPU}" | tee -a ${SCRIPT_PWD}/task4_1.out

MEMORY=$(cat /proc/meminfo| grep MemTotal | awk -F':' {'print $2'})
TRIM_MEMORY=$(echo ${MEMORY}| sed 's/^[ \t]*//;s/[ \t]*$//' | awk '{print toupper($0)}') # removing initial spaces
echo -e "RAM: ${TRIM_MEMORY}" | tee -a ${SCRIPT_PWD}/task4_1.out

### start Motherboard functionality
n=0 #counter for Motherboard block
echo '' > /root/tmp.txt # temporary file for Motherboard block

dmidecode| while read line; do
        if [[ $line == "Base Board Information" ]] || [ ${n} -eq 1 ]; then
                echo $line >> /root/tmp.txt
                n=1
        fi
        if [[ -z $line ]] && [ ${n} -eq 1 ]; then
                n=0
        fi

done

MANUFACTURER=$(cat /root/tmp.txt | grep "Manufacturer" | awk -F':' {'print $2'} | sed 's/^[ \t]*//;s/[ \t]*$//') #remove space
PRODUCT_NAME=$(cat /root/tmp.txt | grep "Product Name" | awk -F':' {'print $2'})
VERSION=$(cat /root/tmp.txt | grep "Version" | awk -F':' {'print $2'})

if [[ -z ${MANUFACTURER} ]] || [[ ${MANUFACTURER} =~ ^[0-9]$ ]] && [[ ${MANUFACTURER} -eq 0 ]];then MANUFACTURER=$(echo " Unknown"); fi
if [[ -z ${PRODUCT_NAME} ]] || [[ ${PRODUCT_NAME} =~ ^[0-9]$ ]] && [[ ${PRODUCT_NAME} -eq 0 ]];then PRODUCT_NAME=$(echo "Unknown"); fi

echo -e "Motherboard: ${MANUFACTURER} /${PRODUCT_NAME}" | tee -a ${SCRIPT_PWD}/task4_1.out
### end Motherboard functionality

SNUMBER=$(dmidecode -s system-serial-number)
if [[ -z ${SNUMBER} ]] || [[ ${SNUMBER} =~ ^[0-9]$ ]] && [[ ${SNUMBER} -eq 0 ]];then SNUMBER=$(echo "Unknown"); fi
echo -e "System Serial Number: ${SNUMBER}" | tee -a ${SCRIPT_PWD}/task4_1.out
echo '--- System ---' | tee -a ${SCRIPT_PWD}/task4_1.out

DISTR=$(cat /etc/os-release | grep PRETTY_NAME | awk -F'=' {'print $2'})
TRIM_DISTR=$(echo ${DISTR} | sed -e 's/^"//' -e 's/"$//') # removing initial quotes
echo -e "OS Distribution: ${TRIM_DISTR}" | tee -a ${SCRIPT_PWD}/task4_1.out

KERNEL=$(uname -a | awk {'print $3'})
echo -e "Kernel version: ${KERNEL}" | tee -a ${SCRIPT_PWD}/task4_1.out

INSTALL_DATE=$(tune2fs -l $(mount | grep 'on \/ ' | awk '{print $1}') | grep 'Filesystem \created' | awk -F"created:" {'print$2'})
TRIM_INSTALL_DATE=$(echo ${INSTALL_DATE} | sed 's/^[ \t]*//;s/[ \t]*$//') # removing initial spaces
echo -e "Installation date: ${TRIM_INSTALL_DATE}" | tee -a ${SCRIPT_PWD}/task4_1.out

HOSTNAME=$(hostname -f)
echo -e "Hostname: ${HOSTNAME}" | tee -a ${SCRIPT_PWD}/task4_1.out

UPTINFO=$(uptime  | awk -F',' {'print $1'}| awk {'print $4'})
if [[ -z $UPTINFO ]]; then
	UPTIME="$(uptime  | awk -F',' {'print $1'}| awk {'print $3" "$4'}) hours"
else
	UPTIME=$(uptime  | awk -F',' {'print $1'}| awk {'print $3" "$4'})
fi
echo -e "Uptime: ${UPTIME}" | tee -a ${SCRIPT_PWD}/task4_1.out

COUNTPROC=$(ps axfu | wc -l)
echo -e "Processes running: ${COUNTPROC}" | tee -a ${SCRIPT_PWD}/task4_1.out

USERSNUM=$(ps aux | awk {' print $1 '} | sort -n | uniq -c | wc -l)
echo -e "User logged in: ${USERSNUM}" | tee -a ${SCRIPT_PWD}/task4_1.out

#### start Network functionality
echo '--- Network ---' | tee -a ${SCRIPT_PWD}/task4_1.out

n=1
marker="stop"
ip a | while read line; do
        ETHSTART=$(echo $line | grep "^$n:\ ")
        ETHFINISH=$(echo $line | grep "inet\ ")
        if [[ -n ${ETHSTART} ]]; then
                marker="start"
                ETHLINE=$( echo $line | awk -F":" {' print $2 '} | sed 's/^[ \t]*//;s/[ \t]*$//')
                #echo ${ETHLINE}
                n=$((n+1))
        fi
        if [[ -n ${ETHFINISH} ]];then
                ETHFIN=$(echo $line | awk {' print $2 '})
                if [[ -z ${ETHFIN} ]];then ETHFIN="-"; fi
                number=$((n-1))
                echo "${ETHLINE}: ${ETHFIN}" | tee -a ${SCRIPT_PWD}/task4_1.out
                marker="stop"
        fi
done

#n=1 # count of network interfaces
#ip a | grep 'inet ' | while read line;do
#	IFACE=$(echo $line | awk {'print $2'})
#	echo "<Iface #${n} name>: ${IFACE}" | tee -a ${SCRIPT_PWD}/task4_1.out
#	n=$((n+1))
#done
### end Network functionality
