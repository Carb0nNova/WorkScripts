#!/bin/bash
#This script is designed to find the PID of the process with the highest memory usage, and kill it.

PID=`ps --no-headers -eo pid --sort=-%mem |head -1`
CMD=`ps --no-headers -eo cmd --sort=-%mem |head -1`
MEM=`ps --no-headers -eo pmem --sort=-%mem|head -1`

read -p "The command $CMD running under PID $PID is using up$MEM percent of memory. Do you wish to kill it? (y/n) " ANS

case $ANS in
	[Yy]* )
		kill -9 $PID
		echo "Process $PID, $CMD killed"
		;;
	[Nn]* )
		echo "Aborting. $PID is still running."
		exit 1
		;;
	* ) 
		echo "Your response must be either y or n"
		exit 2
	;;
esac
