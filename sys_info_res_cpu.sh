#!/bin/bash

# Time variables
export YYMMDD=`date +%y%m%d`
export pretty_date=`date`

# Directory Variables
export LOGDIR=/opt/psoft/logs
export LogFileRES=$LOGDIR/top_res_$YYMMDD.out
export LogFileCPU=$LOGDIR/top_cpu_$YYMMDD.out

# Output system information sorted by RES and CPU into log files

printf "\n`date`\n\n" >>$LogFileRES
 top -b -o +RES | head -n 22 >> $LogFileRES
printf "\n`date`\n\n" >>$LogFileCPU
 top -b -o +%CPU | head -n 22 >> $LogFileCPU