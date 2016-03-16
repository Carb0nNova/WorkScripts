#!/bin/bash
#This script is designed to find the PID of the process with the highest memory usage, and kill it.

#Getting basic info about highest mem usage in the system
PID=`ps --no-headers -eo pid --sort=-%mem |head -1`
CMD=`ps --no-headers -eo cmd --sort=-%mem |head -1`
MEM=`ps --no-headers -eo pmem --sort=-%mem|head -1`

#Getting basic Yes/No answer as to whether the executor wants to kill the process, in the event it picks up the wrong PID. 

#!!!!The lack of space between up and $MEM is intentional!!!!
read -p "The command $CMD running under PID $PID is using up$MEM percent of memory. Do you wish to kill it? (y/n) " ANS

#Parsing arguments
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
