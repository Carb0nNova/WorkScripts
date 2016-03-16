#!/bin/bash

declare -a HOSTLIST
DRACUSER="root"

show_help(){
      echo " "
      echo "-f : Specify the file containing all hostnames/IPs"
      echo "-h : This help menu"
      echo "-p : Password or file w/password to log in to the DRAC."
      echo "-u : Username to log in to the DRAC (Default: root)"
      echo " "
      echo "Example syntax: dracver.sh -f hosts.txt -p dracpass.txt"
      echo " "
      echo "Host and password files must be in same directory as script!"
      echo " "
      exit 0
}


while getopts ":f:p:u:h" opt; do
  case $opt in
    f) FILENAME=$OPTARG
      ;;
    u) DRACUSER=$OPTARG
      ;;
    p) DRACPASS=$OPTARG
      ;;
    h)
      show_help
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done


if [[ -f $FILENAME ]]; then
  let i=0
  while read -r FILENAME; do
    HOSTLIST[i]="$FILENAME"
    ((i++))
  done<$FILENAME
else
  echo "Host file not found!"
  exit 1
fi

if [[ -f $DRACPASS ]]; then
  PASSSW="-f"
else
  PASSSW="-p"
fi


for i in "${HOSTLIST[@]}"
do
	echo "$i " && sshpass $PASSSW $DRACPASS ssh -o StrictHostKeyChecking=no $DRACUSER@$i racadm getversion
done
