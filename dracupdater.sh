#!/bin/bash
#This requires a TFTP folder set up on the $HOST machine that presents as a folder with all of the DRAC versions. Inside those folders, the firmimg.dX should be present.


#Declaring some variables
declare -a HOSTLIST
DRACUSER="root"
LOGDIR="/tmp/draclogs"
DRYRUN=$false

#Setting function for showing help file
show_help(){
      echo " "
      echo "-f : Specify the file containing all hostnames/IPs"
      echo "-h : This help menu"
      echo "-p : Password or file w/password to log in to the DRAC."
      echo "-t : Test switch. Will output the commands it will send instead of executing."
      echo "-u : Username to log in to the DRAC (Default: root)"
      echo "-v : DRAC version. Valid args are DRAC5, DRAC6, DRAC7, or DRAC8."
      echo "-a : Host IP running TFTP."
      echo "-l : Specifies directory for logs (Default: /tmp/draclogs)"
      echo " "
      echo "Example syntax: dracupdater.sh -f hosts.txt -p dracpass.txt -a 192.168.12.1 -u root -v DRAC7"
      echo " "
      echo "Host and password files must be in same directory as script!"
      echo " "
      exit 0
}

#Declaring our argments
while getopts ":f:p:v:a:u:htl:" opt; do
  case $opt in
    f) FILENAME=$OPTARG
      ;;
    u) DRACUSER=$OPTARG
      ;;
    p) DRACPASS=$OPTARG
      ;;
    v) DRACVER=$OPTARG >&2
      ;;
    a) HOSTIP=$OPTARG >&2
      ;;
    h)
      show_help
      ;;
    t) DRYRUN=$true
      ;;
    l) LOGDIR=$OPTARG
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

#Checking that we have the necessary info
if [ "$FILENAME" = "" ] || [ "$DRACPASS" = "" ] || [ "$DRACVER" = "" ] || [ "$HOSTIP" = "" ] ; then
  echo " "
  echo "Error: Missing info!"
  echo " "
  echo "Host file: $FILENAME"
  echo "DRAC user: $DRACUSER"
  echo "DRAC password/file: $DRACPASS"
  echo "DRAC version: $DRACVER"
  echo "TFTP Host IP: $HOSTIP"
  show_help
fi

#Loading hostnames/IPs into the script
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

#Determining if the password is obtained from a file or is an actual password
if [[ -f $DRACPASS ]]; then
  PASSSW="-f"
else
  PASSSW="-p"
fi

#Capitalizing DRACVER
DRACVER="${DRACVER^^}"

#Confirming DRACVER is valid
case $DRACVER in
  'DRAC5'|'DRAC6'|'DRAC7'|'DRAC8') VALIDDRAC=$true ;;
  *) 
    echo 'DRAC version invalid.'
    exit 1
    ;;
esac

#Making the log dir if non-existent
if [[ -d $LOGDIR ]]; then
  :
else
  `mkdir -p $LOGDIR`
fi

echo " "
echo "Placing logs in $LOGDIR"
echo " "

#Executing loop to do updates
for i in "${HOSTLIST[@]}"
do
  LOGFILE="$LOGDIR/${i}_update.log"
  if [[ $DRYRUN ]]; then
    echo "touch $LOGFILE"
    echo "sshpass $PASSSW $DRACPASS ssh -o StrictHostKeyChecking=no $DRACUSER@$i racadm fwupdate -g -u -a $HOSTIP -d $DRACVER"
  else
    `touch $LOGFILE`
    echo "Starting update on $i" && sshpass $PASSSW $DRACPASS ssh -o StrictHostKeyChecking=no $DRACUSER@$i racadm fwupdate -g -u -a $HOSTIP -d $DRACVER > $LOGFILE &
  fi
done
