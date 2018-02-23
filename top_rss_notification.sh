#!/bin/bash
#Created by Xiumei on 02/04/2018 and modified by Anna Dukhovich 02/14/2018
#
#
# Description:  Goal of the script - identify processes with over-the-limit 
#				RSS memory use  and send out notification to DBAs mailing list
#				 - dba_list. 
#
# Maintenance:  The dba_list is are maintained by /opt/psoft/.mailrc.
#


set -o errexit
set -o pipefail
set -o nounset


# Email will go to
export EMAILTO=dba_list

# Directory Variables
export LOGDIR=/opt/psoft/logs

# Declaring name of the logfile and file that will serve as a transit spot for manipulating with data
export LogFile=${LOGDIR}/check_rss_psoft_process.log
export RSSDetail=${LOGDIR}/RSS_DETAIL.out

# Host name
export HOST=`hostname`

# Get PID, RSS and COMMAND sorted by RSS in descending order
ps -u psoft -o pid,rss,args --sort -rss|awk '{print $1 " " $2 " " $3 " " $4 " " $5}'> ${RSSDetail}


# Composing a table of processes that use RSS memory over the limit, excluding certain processes and lines (e.g. Java and first line with headers)
# CHANGE RSS LIMIT HERE
export RSS=`cat ${RSSDetail}|awk '{if (NR!=1 && $2>1000000 && $3!="java") {printf "%-15s %-20s %-30s %-50s\n",$1, $2, $3, $5}}'` >$LogFile 2>&1

echo "${RSS}" >> $LogFile 2>&1

# Getting the size of the log file. If it's over 1 - send an email with the notification, because it means that it's log file is not empty
export LOGFILESIZE=$(stat -c%s "$LogFile")

if (( $LOGFILESIZE > 1)); then
		sed -i '1s/^/PID		RSS			PROCESS				DESCRIPTION \n----------	----------		-------------------			-----------------------------------\n/' $LogFile
        mailx -s "Top RSS Processes - ${HOST}" $EMAILTO < $LogFile
else
        exit 0
fi
