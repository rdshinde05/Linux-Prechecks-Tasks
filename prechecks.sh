#!/bin/bash

rhel_version=`uname -r | sed -r -n 's/^.*el([[:digit:]]).*$/\1/p'`
if (( rhel_version == 5 || rhel_version == 6 || rhel_version == 7 )); then
echo "Your Machine is ok to proceed with to acquire Pre Change Outputs"
else
    
    echo " Your Machine may not provide you the right and expected output. Please check if you are running this Script on the Right OS"
fi
echo "Current Server is running on a either of RHEL/OEL/CentOS $rhel_version.x Version"
Script_Error_File=/var/tmp/Error_Pre_Change_Checks.txt
Script_Output_File=/var/tmp/Pre_Change_Pre-Checks_Output.txt
Format_String=----------------------------------------------------------------------------------------------------------------------
Format_String2=************************************
if [ -f $Script_Output_File ] ; then
    echo " Script Output File Already Exist, and is removed now. " 
    rm $Script_Output_File
fi
if [ -f $Script_Error_File ] ; then
    echo " Pre-Checks Error output file already exists, and is removed now " 
    rm $Script_Error_File
fi
echo " Output and Error Output files are Created "
touch /var/tmp/Pre_Change_Pre-Checks_Output.txt
touch /var/tmp/Error_Pre_Change_Checks.txt


RootSpace()
	{
echo "###############################"
printf "Root Space on system\n\n"
# Shell script to monitor or watch the low-disk space
# of space is >= 85%
# Disk Space Monitoring Script
#### Script START here ###
## You can change your threshold value whatever you want ##
THRESHOLD=85
PATHS=/
AWK=/bin/awk
DU=`/usr/bin/du -ks`
GREP=/bin/grep
SED=/bin/sed
CAT=/bin/cat
for path in $PATHS
do
## Validate the Percentage of Disk space ##
DISK_AVAIL=`/bin/df -k / | grep -v Filesystem |awk '{print $5}' |sed 's/%//g'`
if [ $DISK_AVAIL -ge $THRESHOLD ]
then
echo "Root space is more than 85% utilized Please clean before patching"
else
echo "Root space sufficient for Patching"
fi
done
## END of the Script ##
echo "###############################"
}
RootSpace
RootSpace 2>> $Script_Error_File 1>> $Script_Output_File

printf "\n"


Bootspace(){

echo "###############################"
printf "Boot space on server\n\n"
# Shell script to monitor or watch the low-disk space
# of space is >= 85%
# Disk Space Monitoring Script
#### Script START here ###
## You can change your threshold value whatever you want ##
THRESHOLD=85
PATHS=/boot
AWK=/bin/awk
DU=`/usr/bin/du -ks`
GREP=/bin/grep
SED=/bin/sed
CAT=/bin/cat
for path in $PATHS
do
## Validate the Percentage of Disk space ##
DISK_AVAIL=`/bin/df -k /boot | grep -v Filesystem |awk '{print $5}' |sed 's/%//g'`
if [ $DISK_AVAIL -ge $THRESHOLD ]
then
echo "Boot space is more than 85% utilized Please clean before patching"
else
echo "Boot space sufficient for Patching"
fi
done
## END of the Script ##
echo "###############################"
}
Bootspace
Bootspace 2>> $Script_Error_File 1>> $Script_Output_File

printf "\n"


FSTABCheck()
	{
echo "###############################"
printf "Check FSTAB entries with mount point\n\n"
FSTAB_ENTRIES=$(cat /etc/fstab | awk '$1 !~/#|^$|swap/ {print $2}')

printf "%-40s%-15s%-15s%-s\n" FILESYSTEM ETC_FSTAB MOUNTED
printf "%-40s%-15s%-15s%-s\n" ---------- --------- -------

for FS in ${FSTAB_ENTRIES}
do
df -hPT | grep -wq ${FS}

if [ $? -eq 0 ]
 then
    PR_FSTAB="Yes"
    PR_MOUNT="Yes"
 else
    PR_FSTAB="Yes"
    PR_MOUNT="No"
fi

printf "%-40s%-15s%-15s%-s\n" $FS $PR_FSTAB $PR_MOUNT
done
echo "###############################\n\n"
}
FSTABCheck
FSTABCheck 2>> $Script_Error_File 1>> $Script_Output_File

printf "\n"


Loadaverage(){
echo "###############################"
printf "Load Average on system\n\n"
loadavg=`uptime | awk '{print $10+0}'`
# bash doesn't understand floating point
# so convert the number to an interger
thisloadavg=`echo $loadavg|awk -F \. '{print $1}'`
if [ "$thisloadavg" -ge "2" ]; then
 echo "Busy - Load Average $loadavg ($thisloadavg) "
 top -bn 1
else
 echo "Okay - Load Average $loadavg ($thisloadavg) "
fi
echo "###############################"
}
Loadaverage
Loadaverage 2>> $Script_Error_File 1>> $Script_Output_File

printf "\n"


MemoryTotal(){
echo "###############################"
printf "Total Memory available\n\n"
TotalMem=$(free -m)
echo "$TotalMem"
echo "###############################"
}
MemoryTotal
MemoryTotal 2>> $Script_Error_File 1>> $Script_Output_File

printf "\n"



CPUTotal(){
echo "###############################"
printf "Total CPU on box\n\n"
TotalCPU=(`cat /proc/cpuinfo | grep 'processor' | wc -l`)
echo $TotalCPU
echo "###############################"
}
CPUTotal
CPUTotal 2>> $Script_Error_File 1>> $Script_Output_File

printf "\n"

MemCPUDisk(){
echo "###############################"
printf "Memory/Disk/CPU utilization output\n\n"
printf "Memory\t\tDisk\t\tCPU\n"
MEMORY=$(free -m | awk 'NR==2{printf "%.2f%%\t\t", $3*100/$2 }')
DISK=$(df -h | awk '$NF=="/"{printf "%s\t\t", $5}')
CPU=$(top -bn1 | grep load | awk '{printf "%.2f%%\t\t\n", $(NF-2)}')
echo "$MEMORY$DISK$CPU"
echo "###############################"
}
MemCPUDisk
MemCPUDisk 2>> $Script_Error_File 1>> $Script_Output_File

printf "\n"


   echo " ************************** Pre-Checks Summary Presenting Output Prior to Activity Start ****************************** " 2>> $Script_Error_File 1>> $Script_Output_File
   echo "$Format_String" 2>> $Script_Error_File 1>> $Script_Output_File
   echo " uname -a command output " 2>> $Script_Error_File 1>> $Script_Output_File
   uname -a 2>> $Script_Error_File 1>> $Script_Output_File
   echo ""
   
   echo "$Format_String" 2>> $Script_Error_File 1>> $Script_Output_File
   echo " Host-name command output " 2>> $Script_Error_File 1>> $Script_Output_File
   hostnamectl 2>> $Script_Error_File 1>> $Script_Output_File
   echo ""
   
   echo "$Format_String" 2>> $Script_Error_File 1>> $Script_Output_File
    echo " Who is Logged in command output " 2>> $Script_Error_File 1>> $Script_Output_File
	who 2>> $Script_Error_File 1>> $Script_Output_File
	echo ""
	
   echo "$Format_String" 2>> $Script_Error_File 1>> $Script_Output_File
   echo "Date and Time Information  - `date`" 2>> $Script_Error_File 1>> $Script_Output_File
   
   echo "$Format_String" 2>> $Script_Error_File 1>> $Script_Output_File
   echo "Operating System Info  - `cat /etc/*-release`" 2>> $Script_Error_File 1>> $Script_Output_File
   echo ""
   
   echo "$Format_String" 2>> $Script_Error_File 1>> $Script_Output_File
   echo "Current Kernel Information is - `uname -r`" 2>> $Script_Error_File 1>> $Script_Output_File
   echo ""
   
   echo "$Format_String" 2>> $Script_Error_File 1>> $Script_Output_File
   echo "System's Uptime Information - `uptime`" 2>> $Script_Error_File 1>> $Script_Output_File
   echo ""
   
   echo "$Format_String" 2>> $Script_Error_File 1>> $Script_Output_File   
   echo " Existing df -hP output " 2>> $Script_Error_File 1>> $Script_Output_File   
   echo "$Format_String2" 2>> $Script_Error_File 1>> $Script_Output_File
   df -hP 2>> $Script_Error_File 1>> $Script_Output_File
   echo ""
   
   echo "$Format_String" 2>> $Script_Error_File 1>> $Script_Output_File   
   echo " FDISK -l output " 2>> $Script_Error_File 1>> $Script_Output_File
   echo "$Format_String2" 2>> $Script_Error_File 1>> $Script_Output_File
   fdisk -l 2>> $Script_Error_File 1>> $Script_Output_File
   echo ""
   
   echo "$Format_String" 2>> $Script_Error_File 1>> $Script_Output_File
   echo " Current state of NIC in ifconfig -a output " 2>> $Script_Error_File 1>> $Script_Output_File
	echo "$Format_String2" 2>> $Script_Error_File 1>> $Script_Output_File
	ifconfig -a 2>> $Script_Error_File 1>> $Script_Output_File
   echo ""
   
	echo "$Format_String" 2>> $Script_Error_File 1>> $Script_Output_File
	echo " List interface configuration file " 2>> $Script_Error_File 1>> $Script_Output_File
	echo "$Format_String2" 2>> $Script_Error_File 1>> $Script_Output_File
	ls -l /etc/sysconfig/network-scripts/ifcfg-*	2>> $Script_Error_File 1>> $Script_Output_File
	echo ""
	
	echo "$Format_String" 2>> $Script_Error_File 1>> $Script_Output_File
	echo " List interface configuration file " 2>> $Script_Error_File 1>> $Script_Output_File
	echo "$Format_String2" 2>> $Script_Error_File 1>> $Script_Output_File
	cat /etc/sysconfig/network-scripts/ifcfg-*	2>> $Script_Error_File 1>> $Script_Output_File
	echo ""
	
	echo "$Format_String" 2>> $Script_Error_File 1>> $Script_Output_File
	echo " List Routes configuration file " 2>> $Script_Error_File 1>> $Script_Output_File
	echo "$Format_String2" 2>> $Script_Error_File 1>> $Script_Output_File
	ls -l /etc/sysconfig/network-scripts/route-*	2>> $Script_Error_File 1>> $Script_Output_File
	echo ""
	
	echo "$Format_String" 2>> $Script_Error_File 1>> $Script_Output_File
	echo "Routes configuration file details " 2>> $Script_Error_File 1>> $Script_Output_File
	echo "$Format_String2" 2>> $Script_Error_File 1>> $Script_Output_File
	cat /etc/sysconfig/network-scripts/route-*	2>> $Script_Error_File 1>> $Script_Output_File
	echo ""
	

	
	echo "$Format_String" 2>> $Script_Error_File 1>> $Script_Output_File
	echo " List Hostname Config files details " 2>> $Script_Error_File 1>> $Script_Output_File
	echo "$Format_String2" 2>> $Script_Error_File 1>> $Script_Output_File
	cat /etc/sysconfig/network	2>> $Script_Error_File 1>> $Script_Output_File
	echo ""
	
	echo "$Format_String" 2>> $Script_Error_File 1>> $Script_Output_File
	echo " List Resolve.conf details " 2>> $Script_Error_File 1>> $Script_Output_File
	echo "$Format_String2" 2>> $Script_Error_File 1>> $Script_Output_File
	cat /etc/resolv.conf	2>> $Script_Error_File 1>> $Script_Output_File
	echo ""

   echo "$Format_String" 2>> $Script_Error_File 1>> $Script_Output_File
   echo " Existing Route Information on Server "  2>> $Script_Error_File 1>> $Script_Output_File
   echo "$Format_String2" 2>> $Script_Error_File 1>> $Script_Output_File
   netstat -rvn  2>> $Script_Error_File 1>> $Script_Output_File
   echo ""
   
   echo " Output for LVM related information " 2>> $Script_Error_File 1>> $Script_Output_File
   echo " Volume Group, Logical Volume and Physical Volume Information " 2>> $Script_Error_File 1>> $Script_Output_File
   echo "$Format_String2" 2>> $Script_Error_File 1>> $Script_Output_File
   echo " Volume Group Information " 2>> $Script_Error_File 1>> $Script_Output_File
   vgdisplay 2>> $Script_Error_File 1>> $Script_Output_File
   echo "$Format_String2" 2>> $Script_Error_File 1>> $Script_Output_File
   echo ""
   
   echo " Logical Volume Information " 2>> $Script_Error_File 1>> $Script_Output_File
   lvdisplay 2>> $Script_Error_File 1>> $Script_Output_File
   echo "$Format_String2" 2>> $Script_Error_File 1>> $Script_Output_File
   echo ""
   
   echo " Physical Volume Information " 2>> $Script_Error_File 1>> $Script_Output_File
   pvdisplay 2>> $Script_Error_File 1>> $Script_Output_File
   echo "$Format_String2" 2>> $Script_Error_File 1>> $Script_Output_File
   echo ""

   echo " Information on pv,vg and lv in shorter form " 2>> $Script_Error_File 1>> $Script_Output_File
   echo "$Format_String2" 2>> $Script_Error_File 1>> $Script_Output_File
   echo " VG Info " 2>> $Script_Error_File 1>> $Script_Output_File
   vgs 2>> $Script_Error_File 1>> $Script_Output_File
   echo " PV Info " 2>> $Script_Error_File 1>> $Script_Output_File
   pvs 2>> $Script_Error_File 1>> $Script_Output_File
   echo " LV Info " 2>> $Script_Error_File 1>> $Script_Output_File
   lvs 2>> $Script_Error_File 1>> $Script_Output_File
	echo ""
	
   echo "$Format_String" 2>> $Script_Error_File 1>> $Script_Output_File
   echo " fstab configuration file output " 2>> $Script_Error_File 1>> $Script_Output_File
   echo "$Format_String2" 2>> $Script_Error_File 1>> $Script_Output_File
   cat /etc/fstab 2>> $Script_Error_File 1>> $Script_Output_File
   echo ""	
	
   echo "$Format_String" 2>> $Script_Error_File 1>> $Script_Output_File
   echo " df -hP and netstat -rnv output line count " 2>> $Script_Error_File 1>> $Script_Output_File
   echo "$Format_String2" 2>> $Script_Error_File 1>> $Script_Output_File
   echo " Count for df -hP is `df -hP | wc -l` and Routes is `netstat -rnv | wc -l` " 2>> $Script_Error_File 1>> $Script_Output_File
   echo "$Format_String" 2>> $Script_Error_File 1>> $Script_Output_File
   echo ""
   
   echo " Listing Installed Kernel Summary " 2>> $Script_Error_File 1>> $Script_Output_File
   rpm -qa kernel  2>> $Script_Error_File 1>> $Script_Output_File
   echo "$Format_String" 2>> $Script_Error_File 1>> $Script_Output_File
	echo ""
	
   echo " Listing out all the packages version installed details " 2>> $Script_Error_File 1>> $Script_Output_File
   rpm -qa  2>> $Script_Error_File 1>> $Script_Output_File
   echo ""
   
    echo " Process running on server " 2>> $Script_Error_File 1>> $Script_Output_File
    ps -ef  2>> $Script_Error_File 1>> $Script_Output_File  
   echo ""
   
   echo "$Format_String" 2>> $Script_Error_File 1>> $Script_Output_File
   echo " Listing Memory/Swap/CPU/Process information of the machine "  2>> $Script_Error_File 1>> $Script_Output_File
   echo " Memory Stats using free command "   2>> $Script_Error_File 1>> $Script_Output_File
   echo "$Format_String" 2>> $Script_Error_File 1>> $Script_Output_File
   free -m 2>> $Script_Error_File 1>> $Script_Output_File
	echo ""
	
   echo "$Format_String" 2>> $Script_Error_File 1>> $Script_Output_File
   echo " CPU Information for the Server "  2>> $Script_Error_File 1>> $Script_Output_File
   echo "$Format_String" 2>> $Script_Error_File 1>> $Script_Output_File
   cat /proc/cpuinfo 2>> $Script_Error_File 1>> $Script_Output_File
   echo "$Format_String" 2>> $Script_Error_File 1>> $Script_Output_File
	echo ""
	
   echo "$Format_String" 2>> $Script_Error_File 1>> $Script_Output_File
   echo " Listing yum config and some related files information " 2>> $Script_Error_File 1>> $Script_Output_File
   echo " Yum Configuration Files " 2>> $Script_Error_File 1>> $Script_Output_File
   cat /etc/yum.conf  2>> $Script_Error_File 1>> $Script_Output_File
	echo ""
	
   echo " Listing Out if any version lock is done " 2>> $Script_Error_File 1>> $Script_Output_File
   cat /etc/yum/pluginconf.d/versionlock.list 2>> $Script_Error_File 1>> $Script_Output_File
   echo "$Format_String" 2>> $Script_Error_File 1>> $Script_Output_File
   echo ""
   
   	echo "$Format_String" 2>> $Script_Error_File 1>> $Script_Output_File
	echo " List Repos on server" 2>> $Script_Error_File 1>> $Script_Output_File
	yum repolist	2>> $Script_Error_File 1>> $Script_Output_File
	echo "$Format_String2" 2>> $Script_Error_File 1>> $Script_Output_File
	echo ""
	
	
if (( rhel_version == 5 || rhel_version == 6 )); then
	
    echo "$Format_String" 2>> $Script_Error_File 1>> $Script_Output_File
   echo " List the services which are running on runlevel 3 before the change activity " 2>> $Script_Error_File 1>> $Script_Output_File
   chkconfig --list | egrep '3:on'	2>> $Script_Error_File 1>> $Script_Output_File
   echo ""
   
   echo "$Format_String2" 2>> $Script_Error_File 1>> $Script_Output_File
   echo " grub files listing " 2>> $Script_Error_File 1>> $Script_Output_File
   ls -l /etc/grub.conf /boot/grub/grub.conf /boot/grub/menu.lst 2>> $Script_Error_File 1>> $Script_Output_File
	echo ""
	
   echo "$Format_String2" 2>> $Script_Error_File 1>> $Script_Output_File
   echo " grub file's content " 2>> $Script_Error_File 1>> $Script_Output_File
   echo " cat /etc/grub.conf " 2>> $Script_Error_File 1>> $Script_Output_File
   cat /etc/grub.conf 2>> $Script_Error_File 1>> $Script_Output_File
   echo " cat /boot/grub.grub.conf " 2>> $Script_Error_File 1>> $Script_Output_File
   cat /boot/grub/grub.conf 2>> $Script_Error_File 1>> $Script_Output_File
   echo " cat /boot/grub/menu.lst " 2>> $Script_Error_File 1>> $Script_Output_File
   cat /boot/grub/menu.lst 2>> $Script_Error_File 1>> $Script_Output_File
	echo ""
	


fi
if (( rhel_version == 7 )); then
	
   echo "$Format_String" 2>> $Script_Error_File 1>> $Script_Output_File
   echo " List the services which are in enabled state before the change activity" 2>> $Script_Error_File 1>> $Script_Output_File
   systemctl list-unit-files --type service| grep -i enabled 	2>> $Script_Error_File 1>> $Script_Output_File
   echo ""
   
   echo " List the kernel order " 2>> $Script_Error_File 1>> $Script_Output_File
   echo "$Format_String2" 2>> $Script_Error_File 1>> $Script_Output_File
   awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg  2>> $Script_Error_File 1>> $Script_Output_File
   echo "$Format_String2" 2>> $Script_Error_File 1>> $Script_Output_File
   echo " Listing out Content of Some Key Grub Files "  2>> $Script_Error_File 1>> $Script_Output_File
   echo "$Format_String2" 2>> $Script_Error_File 1>> $Script_Output_File
   echo " grub.cfg file content " 2>> $Script_Error_File 1>> $Script_Output_File
   cat /boot/grub2/grub.cfg 2>> $Script_Error_File 1>> $Script_Output_File
   echo "$Format_String2" 2>> $Script_Error_File 1>> $Script_Output_File
   echo " Grub Other Files " 2>> $Script_Error_File 1>> $Script_Output_File
   echo "$Format_String2" 2>> $Script_Error_File 1>> $Script_Output_File
   echo " /etc/default/grub file content " 2>> $Script_Error_File 1>> $Script_Output_File
   echo "$Format_String2" 2>> $Script_Error_File 1>> $Script_Output_File
   cat /etc/default/grub 2>> $Script_Error_File 1>> $Script_Output_File
   echo "$Format_String2" 2>> $Script_Error_File 1>> $Script_Output_File
   echo " /boot/grub2/grubenv file content " 2>> $Script_Error_File 1>> $Script_Output_File
   cat /boot/grub2/grubenv 2>> $Script_Error_File 1>> $Script_Output_File
   echo "$Format_String2" 2>> $Script_Error_File 1>> $Script_Output_File
   echo " /etc/sysconfig/kernel file content "  2>> $Script_Error_File 1>> $Script_Output_File  
   cat /etc/sysconfig/kernel 2>> $Script_Error_File 1>> $Script_Output_File
   echo "$Format_String2" 2>> $Script_Error_File 1>> $Script_Output_File
	echo ""
	
fi
echo " Output of Script can be found on the Server @ $Script_Output_File Location " 2>> $Script_Error_File 1>> $Script_Output_File
echo " Error if any of this Script run can be found on the server @ $Script_Error_File Location"  2>> $Script_Error_File 1>> $Script_Output_File

cat $Script_Output_File
echo " ************************** End of Pre-Checks  ***************" 2>> $Script_Error_File 1>> $Script_Output_File
